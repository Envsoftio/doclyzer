/** Private CPU shadow run. No database writes or clinical release. */
import { readFileSync, writeFileSync } from 'node:fs';
import { extname } from 'node:path';
import { createHash } from 'node:crypto';
import { PDFDocument } from 'pdf-lib';
import { ImageToPdfService } from '../src/modules/reports/image-to-pdf.service';
import {
  adaptNativeWords,
  adaptPaddle,
  bounds,
  type PageEvidence,
} from '../src/modules/reports/geometry/evidence';
import {
  applyVerification,
  parseGeometry,
} from '../src/modules/reports/geometry/lab-parser';

interface PageResponse {
  page_width: number;
  page_height: number;
  dpi: number;
  native_words: Array<{
    text: string;
    bbox: [number, number, number, number];
    coord_origin: 'TOPLEFT';
  }>;
  paddle: { rec_texts: string[]; rec_scores: number[]; rec_polys: unknown[] };
  model_version: string;
  paddleocr_version: string;
  docling_parse_version: string;
}
const [inputPath, outputPath] = process.argv.slice(2);
if (!inputPath || !outputPath)
  throw new Error(
    'Usage: ts-node scripts/report-geometry-extract.ts report.pdf review.json',
  );
if (process.env.REPORT_GEOMETRY_SHADOW_ENABLED !== 'true')
  throw new Error('Set REPORT_GEOMETRY_SHADOW_ENABLED=true');
const base = (process.env.LAB_OCR_BASE_URL ?? 'http://paddleocr:5005').replace(
  /\/+$/,
  '',
);
const key = process.env.LAB_OCR_API_KEY ?? '';
const maxCrops = 5;
async function request(path: string, bytes: Uint8Array, timeoutMs: number) {
  const signal = AbortSignal.timeout(timeoutMs);
  const response = await fetch(`${base}${path}`, {
    method: 'POST',
    body: new Uint8Array(bytes),
    headers: {
      'Content-Type': 'application/pdf',
      ...(key ? { 'X-Api-Key': key } : {}),
    },
    signal,
  });
  if (!response.ok) throw new Error(`OCR service HTTP ${response.status}`);
  return response.json() as Promise<Record<string, unknown>>;
}
async function run() {
  const source = readFileSync(inputPath);
  const documentId = createHash('sha256').update(source).digest('hex');
  const extension = extname(inputPath).toLowerCase();
  if (!['.pdf', '.jpg', '.jpeg', '.png'].includes(extension))
    throw new Error('Expected PDF, JPG or PNG');
  const pdfBytes =
    extension === '.pdf'
      ? source
      : await new ImageToPdfService().convertSingleImageToPdf({
          buffer: source,
          mimetype: extension === '.png' ? 'image/png' : 'image/jpeg',
        });
  const pdf = await PDFDocument.load(pdfBytes);
  const expectedPageIds = Array.from(
    { length: pdf.getPageCount() },
    (_, i) => `${documentId}:page:${i + 1}`,
  );
  const pages: PageEvidence[] = [];
  const failures: Array<{ pageId: string; reason: string }> = [];
  const verification: Array<{
    candidateId: string;
    tsv: string;
    cropToOriginal: unknown;
  }> = [];
  for (let i = 0; i < pdf.getPageCount(); i++) {
    const pageId = expectedPageIds[i];
    const one = await PDFDocument.create();
    const [copied] = await one.copyPages(pdf, [i]);
    one.addPage(copied);
    const pageBytes = await one.save();
    try {
      const raw = (await request(
        '/v1/extract/page',
        pageBytes,
        30_000,
      )) as unknown as PageResponse;
      const paddle = adaptPaddle(raw.paddle, {
        documentId,
        pageId,
        engineVersion: raw.paddleocr_version,
        modelVersion: raw.model_version,
        preprocessingId: `render:${raw.dpi}dpi`,
        workingToOriginal: [72 / raw.dpi, 0, 0, 72 / raw.dpi, 0, 0],
      });
      const native = adaptNativeWords(raw.native_words, {
        documentId,
        pageId,
        pageHeight: raw.page_height,
        engineVersion: raw.docling_parse_version,
      });
      // OCR is the parser baseline. Native words remain independent evidence;
      // a selectable header never suppresses OCR of a scanned table.
      pages.push({
        document_id: documentId,
        page_id: pageId,
        page_number: i + 1,
        width: raw.page_width,
        height: raw.page_height,
        source_ref: 'original_upload',
        render_ref: 'original_upload',
        route: native.length ? 'hybrid' : 'ocr',
        tokens: paddle,
        failed_regions: [],
        raw_output_ref: `${pageId}:raw`,
      });
      const pageResult = parseGeometry([pages.at(-1)!], [pageId]);
      const started = Date.now();
      for (const candidate of pageResult.candidates.slice(0, maxCrops)) {
        if (Date.now() - started >= 5_000) break;
        const resultTokens = paddle.filter((t) =>
          candidate.evidence.result.includes(t.token_id),
        );
        if (!resultTokens.length) continue;
        const boxes = resultTokens.map((t) => bounds(t.polygon_original));
        const rect = [
          Math.max(0, Math.min(...boxes.map((b) => b.left)) - 2),
          Math.max(0, Math.min(...boxes.map((b) => b.top)) - 2),
          Math.min(raw.page_width, Math.max(...boxes.map((b) => b.right)) + 2),
          Math.min(
            raw.page_height,
            Math.max(...boxes.map((b) => b.bottom)) + 2,
          ),
        ];
        try {
          const v = await request(
            `/v1/verify/field?rect=${rect.join(',')}`,
            pageBytes,
            Math.max(1, 5_000 - (Date.now() - started)),
          );
          verification.push({
            candidateId: candidate.id,
            tsv: typeof v.tsv === 'string' ? v.tsv : '',
            cropToOriginal: v.crop_to_original,
          });
        } catch {
          verification.push({
            candidateId: candidate.id,
            tsv: '',
            cropToOriginal: null,
          });
        }
      }
      // Keep both raw streams for review; they must not be treated as votes.
      (
        pages.at(-1)! as PageEvidence & {
          native_tokens?: unknown;
          raw_paddle?: unknown;
        }
      ).native_tokens = native;
      (pages.at(-1)! as PageEvidence & { raw_paddle?: unknown }).raw_paddle =
        raw.paddle;
    } catch (error) {
      const reason =
        error instanceof Error && error.name === 'TimeoutError'
          ? 'primary_timeout'
          : 'failed_region';
      failures.push({ pageId, reason });
      pages.push({
        document_id: documentId,
        page_id: pageId,
        page_number: i + 1,
        width: copied.getWidth(),
        height: copied.getHeight(),
        source_ref: 'original_upload',
        render_ref: 'original_upload',
        route: 'unprocessed',
        tokens: [],
        failed_regions: [reason],
        raw_output_ref: null,
      });
    }
  }
  const result = parseGeometry(pages, expectedPageIds);
  result.candidates = result.candidates.map((candidate) => {
    const read = verification.find((v) => v.candidateId === candidate.id);
    if (!read?.tsv) return applyVerification(candidate, null, true);
    const cells = read.tsv
      .trim()
      .split(/\r?\n/)
      .slice(1)
      .map((line) => line.split('\t'));
    const words = cells
      .filter((row) => row[0] === '5')
      .map((row) => row.at(-1)?.trim())
      .filter(Boolean);
    return applyVerification(candidate, {
      engine: 'tesseract',
      raw: words.join(' '),
      cropId: candidate.id,
    });
  });
  writeFileSync(
    outputPath,
    JSON.stringify(
      {
        schemaVersion: 1,
        automaticRelease: false,
        documentId,
        expectedPageIds,
        pages,
        result,
        failures,
        verification,
      },
      null,
      2,
    ),
    { mode: 0o600 },
  );
}
void run().catch((error: unknown) => {
  process.stderr.write(
    `${error instanceof Error ? error.message : 'Extraction failed'}\n`,
  );
  process.exitCode = 1;
});
