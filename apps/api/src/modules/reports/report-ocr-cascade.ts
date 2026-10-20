import { Logger } from '@nestjs/common';
import { PDFDocument } from 'pdf-lib';
import { adaptDoclingDocument } from './docling-document-adapter';
import { OpenDataLoaderJsonParser } from './opendataloader-json-parser';
import { DoclingOcrClient } from './docling-ocr.client';
import { PaddleOcrClient } from './paddle-ocr.client';
import { comparisonNotation } from './lab-method-notation';

type Node = Record<string, unknown>;
export interface OcrOutput {
  text: string;
  parsedJson?: unknown;
  nativeOnly?: boolean;
}
export class OcrServiceUnavailableError extends Error {
  constructor() {
    super('Visual OCR service unavailable');
  }
}
export type CascadeProgress = Record<
  string,
  Partial<Record<'paddleocr-v5', OcrOutput>>
>;
export interface CascadeCheckpoint {
  progress?: CascadeProgress;
  save?: (
    page: number,
    engine: 'paddleocr-v5',
    output: OcrOutput,
  ) => Promise<void>;
}
type Candidate = {
  engine: string;
  output: OcrOutput;
  nodes: Node[];
  complete: boolean;
  signatures: string[];
  rows: number;
  candidates: number;
  patientNames: string[];
};

/** Retry whole pages, not detached cells: retain units, headers and specimen context. */
export class ReportOcrCascade {
  private readonly parser = new OpenDataLoaderJsonParser();
  private readonly log = new Logger(ReportOcrCascade.name);
  constructor(
    private readonly docling: DoclingOcrClient,
    private readonly paddle: PaddleOcrClient,
  ) {}

  private nodes(output: OcrOutput | null): Node[] {
    const doc = adaptDoclingDocument(output?.parsedJson) as
      | { kids?: Node[] }
      | undefined;
    return Array.isArray(doc?.kids) ? doc.kids : [];
  }
  private patientNames(nodes: Node[]): string[] {
    const names = new Set<string>();
    const add = (text: string) => {
      const name = text
        .replace(/^\s*:\s*/, '')
        .split(/\s+(?:Lab\s*Id|Sex\/Age|Registration)\b/i)[0]
        .trim()
        .replace(/\s+/g, ' ')
        .toLowerCase();
      if (name && /[a-z]/i.test(name)) names.add(name);
    };
    for (const node of nodes) {
      const metadataTable =
        Array.isArray(node.rows) &&
        /\b(patient information|patient name|patient id|lab id|date of birth|sex\/age)\b/i.test(
          JSON.stringify(node.rows),
        );
      for (const row of metadataTable ? (node.rows as Node[]) : []) {
        const cells = Array.isArray(row.cells) ? (row.cells as Node[]) : [];
        const index = cells.findIndex((c) =>
          /^(?:patient\s+)?name\s*:?\s*$/i.test(String(c.content ?? '')),
        );
        if (index >= 0 && typeof cells[index + 1]?.content === 'string')
          add(cells[index + 1].content as string);
      }
      if (
        typeof node.content === 'string' &&
        /\bpatient information\b/i.test(node.content)
      ) {
        const match = node.content.match(
          /\bName\s*:\s*(.+?)(?=\s+(?:Lab\s*Id|Sex\/Age|Registration)\b|$)/i,
        );
        if (match) add(match[1]);
      }
    }
    return [...names].sort();
  }
  private candidate(
    engine: string,
    output: OcrOutput | null,
  ): Candidate | null {
    if (!output?.parsedJson) return null;
    const nodes = this.nodes(output);
    const parsed = this.parser.parseWithDiagnostics({
      type: 'document',
      kids: nodes,
    });
    const d = parsed.diagnostics;
    // Compare only equivalent notation; never change numeric punctuation, comparators or unit scale.
    const label = (value: string | undefined) =>
      (value ?? '').trim().replace(/\s+/g, ' ').toLowerCase();
    const unitNotation = (unit: string | null) =>
      (unit ?? '')
        .trim()
        .replace(/[µμ]/g, 'u')
        .replace(
          /([A-Za-z0-9])([⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻]+)/g,
          (_match, base: string, exponent: string) =>
            base +
            '^' +
            [...exponent]
              .map((char) => '0123456789+-'['⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻'.indexOf(char)])
              .join(''),
        );
    const signatures = parsed.extractedLabValues
      .map((row) => [
        label(row.parameterName),
        row.value.trim(),
        unitNotation(row.unit),
        comparisonNotation(row.referenceRange ?? ''),
        row.sampleDate ?? '',
        label(row.identityEvidence?.specimen),
        comparisonNotation(row.identityEvidence?.method ?? ''),
        label(row.identityEvidence?.testCode),
      ])
      .map((row) => JSON.stringify(row))
      .sort();
    return {
      engine,
      output,
      nodes,
      signatures,
      complete:
        !(output.parsedJson as Node).extractionIncomplete &&
        d.hasMappedLabTables &&
        !d.hasUnmappedTables &&
        !d.hasAmbiguousHeaders &&
        d.candidateRows > 0 &&
        d.parsedRows === d.candidateRows &&
        parsed.extractedLabValues.length > 0,
      rows: parsed.extractedLabValues.length,
      candidates: d.candidateRows,
      patientNames: this.patientNames(nodes),
    };
  }
  private pageOutput(
    output: OcrOutput | null,
    page: number,
    pages: number,
  ): OcrOutput {
    const kids = this.nodes(output).filter(
      (node) =>
        node['page number'] === page ||
        (pages === 1 && node['page number'] == null),
    );
    return {
      text: kids
        .map((n) =>
          typeof n.content === 'string'
            ? n.content
            : Array.isArray(n.rows)
              ? (n.rows as Array<{ cells: Array<{ content?: string }> }>)
                  .map((row) =>
                    row.cells.map((cell) => cell.content ?? '').join(' | '),
                  )
                  .join('\n')
              : '',
        )
        .join('\n'),
      parsedJson: { type: 'document', kids },
    };
  }
  private reconcile(
    native: Candidate | null,
    visual: Candidate | null,
  ): Candidate | null {
    if (!visual?.complete) return null;
    if (this.patientIdentityConflict(native, visual)) return null;
    // Native readings may be incomplete, but every extracted native observation
    // must survive unchanged. Never let a larger OCR row count hide a conflict.
    const counts = new Map<string, number>();
    for (const signature of visual.signatures)
      counts.set(signature, (counts.get(signature) ?? 0) + 1);
    for (const signature of native?.signatures ?? []) {
      const available = counts.get(signature) ?? 0;
      if (!available) return null;
      counts.set(signature, available - 1);
    }
    return visual;
  }

  private patientIdentityConflict(
    native: Candidate | null,
    visual: Candidate | null,
  ): boolean {
    const n = native?.patientNames ?? [];
    const v = visual?.patientNames ?? [];
    return (
      n.length > 1 ||
      v.length > 1 ||
      (n.length === 1 && (v.length !== 1 || n[0] !== v[0]))
    );
  }

  async run(
    bytes: Buffer,
    signal: AbortSignal,
    initial?: OcrOutput,
    checkpoint: CascadeCheckpoint = {},
  ): Promise<OcrOutput & { parsedJson: unknown }> {
    signal.throwIfAborted();
    const pdf = await PDFDocument.load(bytes);
    const count = pdf.getPageCount();
    const native = initial?.nativeOnly
      ? initial
      : await this.docling.parsePdf(bytes, {
          doOcr: false,
          forceOcr: false,
          signal,
        });
    const accepted: Node[] = [];
    const transcripts: string[] = [];
    const failedPages: number[] = [];
    const reviewPages: Record<
      string,
      { native: OcrOutput; visual: OcrOutput | null; reason: string }
    > = {};
    for (let index = 0; index < count; index++) {
      signal.throwIfAborted();
      const page = index + 1;
      const nativePage = this.pageOutput(native, page, count);
      const nativeCandidate = this.candidate('native', nativePage);
      let chosen = nativeCandidate?.complete ? nativeCandidate : null;
      // A readable narrative-only page can be retained, but a missing result table cannot.
      const supplementary =
        nativeCandidate &&
        nativeCandidate.nodes.length > 0 &&
        nativeCandidate.rows === 0 &&
        nativeCandidate.candidates === 0 &&
        !nativeCandidate.nodes.some((n) => n.type === 'table') &&
        nativePage.text.trim().length > 80 &&
        !/\b(result|observed value|investigation|analyte|test name)\b/i.test(
          nativePage.text,
        );
      if (!chosen && supplementary) chosen = nativeCandidate;
      if (!chosen) {
        const part = await PDFDocument.create();
        const [copied] = await part.copyPages(pdf, [index]);
        part.addPage(copied);
        const pageBytes = Buffer.from(await part.save());
        const engine = 'paddleocr-v5' as const;
        const cached = checkpoint.progress?.[String(page)]?.[engine];
        this.log.log(
          JSON.stringify({
            action: 'REPORT_OCR_PAGE_STARTED',
            page,
            engine,
            cached: Boolean(cached),
          }),
        );
        const output =
          cached ?? (await this.paddle.parsePdf(pageBytes, signal));
        signal.throwIfAborted();
        // A missing OCR service is an infrastructure failure, not evidence that
        // the uploaded document has unreadable or incomplete results.
        if (!output) throw new OcrServiceUnavailableError();
        if (!cached && output?.parsedJson)
          await checkpoint.save?.(page, engine, output);
        const visualCandidate = this.candidate(engine, output);
        chosen = this.reconcile(nativeCandidate, visualCandidate);
        const reason = !output
          ? 'visual_unavailable'
          : this.patientIdentityConflict(nativeCandidate, visualCandidate)
            ? 'patient_identity_conflict'
            : !visualCandidate?.complete
              ? 'visual_incomplete'
              : 'native_visual_conflict';
        this.log.log(
          JSON.stringify({
            action: 'REPORT_OCR_PAGE_ATTEMPT',
            page,
            engine,
            rows: visualCandidate?.rows ?? 0,
            complete: visualCandidate?.complete ?? false,
            ...(chosen ? {} : { reason }),
          }),
        );
        if (!chosen)
          reviewPages[String(page)] = {
            native: nativePage,
            visual: output,
            reason,
          };
        signal.throwIfAborted();
      }
      if (!chosen) {
        failedPages.push(page);
        // Preserve source evidence for review without publishing partial rows.
        transcripts.push(nativePage.text);
        continue;
      }
      this.log.log(
        JSON.stringify({
          action: 'REPORT_OCR_PAGE_ACCEPTED',
          page,
          engine: chosen.engine,
        }),
      );
      accepted.push(
        ...chosen.nodes.map((node) => ({
          ...node,
          'page number': page,
          extractionEngine: chosen.engine,
        })),
      );
      transcripts.push(chosen.output.text);
    }
    this.log.log(
      JSON.stringify({
        action: 'REPORT_OCR_CASCADE_COMPLETE',
        pages: count,
        unresolvedPages: failedPages,
      }),
    );
    return {
      text: transcripts.join('\n\n'),
      parsedJson: {
        type: 'document',
        kids: accepted,
        ocrVerificationFailed: failedPages.length > 0,
        unresolvedPages: failedPages,
        reviewPages,
      },
    };
  }
}
