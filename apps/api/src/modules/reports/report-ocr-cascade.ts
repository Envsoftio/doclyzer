import { Logger } from '@nestjs/common';
import { PDFDocument } from 'pdf-lib';
import { adaptDoclingDocument } from './docling-document-adapter';
import { OpenDataLoaderJsonParser } from './opendataloader-json-parser';
import { DoclingOcrClient } from './docling-ocr.client';
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
  Partial<Record<'docling-tesseract', OcrOutput>>
>;
export interface CascadeCheckpoint {
  progress?: CascadeProgress;
  save?: (
    page: number,
    engine: 'docling-tesseract',
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
  constructor(private readonly docling: DoclingOcrClient) {}

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
      parsedJson: {
        type: 'document',
        kids,
        extractionIncomplete: Boolean(
          (output?.parsedJson as Node | undefined)?.extractionIncomplete,
        ),
      },
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

  private isPeakAnalysisTable(node: Node): boolean {
    if (node.type !== 'table' || !Array.isArray(node.rows)) return false;
    const firstRow = node.rows[0] as { cells?: Array<{ content?: string }> };
    const header = (firstRow?.cells ?? [])
      .map((cell) => cell.content ?? '')
      .join(' ')
      .toLowerCase();
    return (
      /\bpeak name\b/.test(header) &&
      /\bretention time\b/.test(header) &&
      /\barea\b/.test(header)
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
    const native: OcrOutput | null = initial?.parsedJson
      ? initial
      : await this.docling.parsePdf(bytes, {
          doOcr: true,
          forceOcr: false,
          signal,
        });
    const accepted: Node[] = [];
    const transcripts: string[] = [];
    const failedPages: number[] = [];
    let successfulOcrPages = 0;
    let unavailablePages = 0;
    let consecutiveUnavailable = 0;
    const reviewPages: Record<
      string,
      {
        native: OcrOutput;
        visual: OcrOutput | null;
        tesseract?: OcrOutput | null;
        reason: string;
      }
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
        nativeCandidate.nodes.every(
          (node) => node.type !== 'table' || this.isPeakAnalysisTable(node),
        ) &&
        nativePage.text.trim().length > 80 &&
        !/[\uE000-\uF8FF]/u.test(nativePage.text) &&
        (!/\b(result|observed value|investigation|analyte|test name)\b/i.test(
          nativePage.text,
        ) ||
          nativeCandidate.nodes.some((node) =>
            this.isPeakAnalysisTable(node),
          ));
      if (!chosen && supplementary) chosen = nativeCandidate;
      // A complete full-document Docling result already has the playground's
      // OCR and table structure. Keep page OCR for incomplete output, or for
      // older native-only checkpoints that have not seen an OCR pass.
      if (!supplementary && (!chosen || native?.nativeOnly)) {
        const part = await PDFDocument.create();
        const [copied] = await part.copyPages(pdf, [index]);
        part.addPage(copied);
        const pageBytes = Buffer.from(await part.save());
        const tesseractEngine = 'docling-tesseract' as const;
        const cachedTesseract =
          checkpoint.progress?.[String(page)]?.[tesseractEngine];
        const tesseract =
          cachedTesseract ??
          (await this.docling.parsePdf(pageBytes, {
            doOcr: true,
            forceOcr: true,
            engine: 'tesseract',
            signal,
          }));
        signal.throwIfAborted();
        if (!cachedTesseract && tesseract?.parsedJson)
          await checkpoint.save?.(page, tesseractEngine, tesseract);
        const tesseractPage = tesseract
          ? this.pageOutput(tesseract, 1, 1)
          : null;
        const tesseractCandidate = this.reconcile(
          nativeCandidate,
          this.candidate(tesseractEngine, tesseractPage),
        );
        if (
          tesseractCandidate &&
          (!chosen || tesseractCandidate.rows > chosen.rows)
        )
          chosen = tesseractCandidate;
        this.log.log(
          JSON.stringify({
            action: 'REPORT_OCR_PAGE_ATTEMPT',
            page,
            engine: tesseractEngine,
            accepted: chosen?.engine === tesseractEngine,
          }),
        );
        if (chosen) {
          const selected = chosen;
          if (selected.engine === tesseractEngine) {
            successfulOcrPages++;
            consecutiveUnavailable = 0;
          }
          accepted.push(
            ...selected.nodes.map((node) => ({
              ...node,
              'page number': page,
              extractionEngine: selected.engine,
            })),
          );
          transcripts.push(selected.output.text);
          this.log.log(
            JSON.stringify({
              action: 'REPORT_OCR_PAGE_ACCEPTED',
              page,
              engine: selected.engine,
            }),
          );
          continue;
        }
        if (!tesseract) {
          unavailablePages++;
          consecutiveUnavailable++;
          // Do not spend a 100-page budget waiting on an unavailable service.
          if (consecutiveUnavailable >= 3)
            throw new OcrServiceUnavailableError();
        } else {
          successfulOcrPages++;
          consecutiveUnavailable = 0;
        }
        const rawTesseractCandidate = this.candidate(
          tesseractEngine,
          tesseractPage,
        );
        const reason = !tesseract
          ? 'visual_unavailable'
          : this.patientIdentityConflict(nativeCandidate, rawTesseractCandidate)
            ? 'patient_identity_conflict'
            : !rawTesseractCandidate?.complete
              ? 'visual_incomplete'
              : 'native_visual_conflict';
        reviewPages[String(page)] = {
          native: nativePage,
          visual: tesseractPage,
          tesseract: tesseractPage,
          reason,
        };
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
    // A missing OCR service is an infrastructure failure when no OCR page
    // was recovered. Isolated failures remain explicit review pages.
    if (unavailablePages > 0 && successfulOcrPages === 0)
      throw new OcrServiceUnavailableError();
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
