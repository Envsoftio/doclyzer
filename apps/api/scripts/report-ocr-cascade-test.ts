import assert from 'node:assert/strict';
import { PDFDocument } from 'pdf-lib';
import { ReportOcrCascade, type CascadeProgress, OcrServiceUnavailableError } from '../src/modules/reports/report-ocr-cascade';
import type { DoclingOcrClient } from '../src/modules/reports/docling-ocr.client';
import type { PaddleOcrClient } from '../src/modules/reports/paddle-ocr.client';

async function main() {
  const pdf = await PDFDocument.create();
  pdf.addPage();
  const bytes = Buffer.from(await pdf.save());
  const native = { text: '', nativeOnly: true, parsedJson: { type: 'document', kids: [] } };
  const visual = { text: 'Glucose\n90', parsedJson: { type: 'document', kids: [], extractionIncomplete: true,
    paddlePage: { page_width: 100, page_height: 100, dpi: 300, native_words: [],
      paddle: { rec_texts: ['Glucose', '90'], rec_scores: [0.9, 0.9], rec_polys: [] } } } };
  const noDocling = { parsePdf: async () => { throw new Error('unexpected Docling call'); } } as unknown as DoclingOcrClient;
  let calls = 0;
  const paddle = { parsePdf: async (part: Buffer) => {
    calls++;
    assert.equal((await PDFDocument.load(part)).getPageCount(), 1);
    return visual;
  } } as unknown as PaddleOcrClient;
  const saved: CascadeProgress = {};
  const cascade = new ReportOcrCascade(noDocling, paddle);
  const result = await cascade.run(bytes, new AbortController().signal, native, {
    save: async (page, engine, output) => { saved[String(page)] = { [engine]: output }; },
  });
  assert.deepEqual((result.parsedJson as { unresolvedPages: number[] }).unresolvedPages, [1]);
  assert.equal((result.parsedJson as { reviewPages: Record<string, { visual: unknown }> }).reviewPages['1'].visual, visual);
  assert.deepEqual((result.parsedJson as { kids: unknown[] }).kids, []);
  await cascade.run(bytes, new AbortController().signal, native, { progress: saved });
  assert.equal(calls, 1, 'Paddle page checkpoint reused');
  const unavailable = new ReportOcrCascade(noDocling, { parsePdf: async () => null } as unknown as PaddleOcrClient);
  await assert.rejects(unavailable.run(bytes, new AbortController().signal, native), OcrServiceUnavailableError);
  const aborted = new AbortController();
  aborted.abort();
  await assert.rejects(cascade.run(bytes, aborted.signal, native));
  console.log('PASS Paddle page targeting, evidence quarantine, checkpoint, unavailable service, cancellation');
}
void main().catch((error) => { console.error(error); process.exitCode = 1; });
