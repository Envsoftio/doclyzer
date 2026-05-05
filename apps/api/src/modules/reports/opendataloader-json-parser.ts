import type { ExtractedLabValue } from './lab-value-extractor';
import type {
  StructuredLabDetailsDto,
  StructuredPatientDetailsDto,
  StructuredReportDto,
  StructuredSectionDto,
  StructuredSectionItemDto,
} from './reports.service';
import { LabDetailsExtractor } from './lab-details-extractor';

interface FlatNode {
  type: string;
  content: string;
  pageNumber: number | null;
  bbox: [number, number, number, number] | null;
}

interface ParsedValueRow {
  value: string;
  unit?: string;
  referenceRange?: string;
  isAbnormal?: boolean;
  nextTestName?: string;
}

interface ExtractionStats {
  candidateRows: number;
  parsedRows: number;
  aiCandidateRows: string[];
}

export interface OpenDataLoaderParsedOutput {
  extractedLabValues: ExtractedLabValue[];
  structuredReport: StructuredReportDto;
}

export interface OpenDataLoaderParseDiagnostics {
  confidence: number;
  coverage: number;
  candidateRows: number;
  parsedRows: number;
  extractedRows: number;
  sectionCount: number;
  lowConfidenceReasons: string[];
  aiCandidateRows: string[];
}

export interface OpenDataLoaderParsedWithDiagnosticsOutput extends OpenDataLoaderParsedOutput {
  diagnostics: OpenDataLoaderParseDiagnostics;
}

export class OpenDataLoaderJsonParser {
  private readonly labDetailsExtractor = new LabDetailsExtractor();

  parse(input: unknown): OpenDataLoaderParsedOutput {
    const parsed = this.parseWithDiagnostics(input);
    return {
      extractedLabValues: parsed.extractedLabValues,
      structuredReport: parsed.structuredReport,
    };
  }

  parseWithDiagnostics(
    input: unknown,
  ): OpenDataLoaderParsedWithDiagnosticsOutput {
    const nodes = this.flattenNodes(input);
    const patientDetails = this.extractPatientDetails(nodes);
    const labDetailLines = nodes.map((n) => this.normalizeSpace(n.content));
    const labDetails =
      this.labDetailsExtractor.extractFromLines(labDetailLines);
    const tableExtraction = this.extractSectionsFromExplicitTables(input);
    const heuristicExtraction = this.extractSections(nodes);
    const useTableAsPrimary = tableExtraction.stats.parsedRows >= 6;
    const sections = useTableAsPrimary
      ? tableExtraction.sections
      : this.mergeSections(tableExtraction.sections, heuristicExtraction.sections);
    const stats: ExtractionStats = useTableAsPrimary
      ? tableExtraction.stats
      : {
          candidateRows:
            tableExtraction.stats.candidateRows +
            heuristicExtraction.stats.candidateRows,
          parsedRows:
            tableExtraction.stats.parsedRows + heuristicExtraction.stats.parsedRows,
          aiCandidateRows: this.uniqueTrimmed([
            ...tableExtraction.stats.aiCandidateRows,
            ...heuristicExtraction.stats.aiCandidateRows,
          ]).slice(0, 400),
        };

    const extractedLabValues: ExtractedLabValue[] = [];
    for (const section of sections) {
      for (const test of section.tests) {
        extractedLabValues.push({
          parameterName: test.parameterName,
          value: test.value,
          unit: test.unit ?? null,
          sampleDate: test.sampleDate ?? null,
          ...(test.referenceRange
            ? { referenceRange: test.referenceRange }
            : {}),
          ...(typeof test.isAbnormal === 'boolean'
            ? { isAbnormal: test.isAbnormal }
            : {}),
        });
      }
    }

    const deduped = this.compactLabValues(this.deduplicate(extractedLabValues));
    const diagnostics = this.buildDiagnostics({
      stats,
      extractedRows: deduped.length,
      sectionCount: sections.length,
    });

    return {
      extractedLabValues: deduped,
      structuredReport: {
        patientDetails,
        ...(this.hasLabDetails(labDetails) ? { labDetails } : {}),
        sections: sections.filter((s) => s.tests.length > 0),
      },
      diagnostics,
    };
  }

  private flattenNodes(input: unknown): FlatNode[] {
    const out: FlatNode[] = [];

    const walk = (node: unknown): void => {
      if (!node || typeof node !== 'object') return;

      const obj = node as Record<string, unknown>;
      const type = typeof obj.type === 'string' ? obj.type : '';
      const content = typeof obj.content === 'string' ? obj.content.trim() : '';
      const pageNumber =
        typeof obj['page number'] === 'number' ? obj['page number'] : null;
      const bboxRaw = obj['bounding box'];
      const bbox =
        Array.isArray(bboxRaw) &&
        bboxRaw.length === 4 &&
        bboxRaw.every((v) => typeof v === 'number')
          ? (bboxRaw as [number, number, number, number])
          : null;

      if (type && content) {
        out.push({ type, content, pageNumber, bbox });
      }

      if (Array.isArray(obj.kids)) {
        for (const kid of obj.kids) walk(kid);
      }
      if (Array.isArray(obj['list items'])) {
        for (const item of obj['list items']) walk(item);
      }
    };

    walk(input);
    return out;
  }

  private extractPatientDetails(
    nodes: FlatNode[],
  ): StructuredPatientDetailsDto {
    const lines = nodes
      .map((n) => this.normalizeSpace(n.content))
      .filter((line) => line.length > 0);
    const full = lines.join(' ');
    const read = (re: RegExp): string | undefined => {
      const m = full.match(re);
      return m?.[1]?.trim();
    };
    const readNextLineValue = (labelRe: RegExp): string | undefined => {
      for (let i = 0; i < lines.length - 1; i++) {
        if (!labelRe.test(lines[i])) continue;
        for (let j = i + 1; j < Math.min(i + 5, lines.length); j++) {
          const candidate = lines[j];
          if (
            /^(patient name|age\/gender|care location|patient location|lab accession id|specimen|collected date|authorized date|investigation|results|uom|reference range)$/i.test(
              candidate,
            )
          ) {
            continue;
          }
          return candidate;
        }
      }
      return undefined;
    };

    const fieldMap = this.extractPatientFieldMap(nodes);
    const spatialName = fieldMap.patientName;
    const spatialAgeGender = fieldMap.ageGender;
    const spatialAccession = fieldMap.labAccessionId;
    const spatialCollected = fieldMap.collectedDateTime;

    const name =
      read(
        /Patient Name\s*:\s*([^|]+?)(?:\s{2,}|Age\/Gender|Barcode|Order Id|$)/i,
      ) ??
      spatialName ??
      readNextLineValue(/^patient name$/i) ??
      read(/\bDear\s+([A-Za-z][A-Za-z ]{1,80})[,!]/i);

    const ageGender =
      read(/Age\/Gender\s*:\s*([^|]+?)(?:\s{2,}|Order Id|$)/i) ??
      spatialAgeGender ??
      readNextLineValue(/^age\/gender$/i) ??
      read(/\b(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?\s+(?:Male|Female|Other))\b/i);
    const age = ageGender?.match(
      /(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?|\d+\s*Yrs?)/i,
    )?.[1];
    const gender = ageGender?.match(/\b(Male|Female|Other)\b/i)?.[1];
    const bookingId =
      read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i) ??
      spatialAccession ??
      readNextLineValue(/^booking id$/i) ??
      readNextLineValue(/^lab accession id$/i);
    const sampleCollectionDate =
      read(/Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i) ??
      (spatialCollected?.match(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}/)?.[0] ??
        undefined) ??
      read(/Collected Date&Time\s*[:\-]?\s*([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})/i);

    return {
      ...(name ? { name } : {}),
      ...(age ? { age } : {}),
      ...(gender ? { gender } : {}),
      ...(bookingId ? { bookingId } : {}),
      ...(sampleCollectionDate ? { sampleCollectionDate } : {}),
    };
  }

  private findSpatialFieldValue(
    nodes: FlatNode[],
    labelRe: RegExp,
  ): string | undefined {
    const labels = nodes.filter(
      (n) =>
        n.pageNumber != null &&
        n.bbox != null &&
        labelRe.test(this.normalizeSpace(n.content)),
    );
    if (labels.length === 0) return undefined;

    for (const label of labels) {
      const [lx1, ly1, lx2, ly2] = label.bbox!;
      const lcy = (ly1 + ly2) / 2;
      let best: { score: number; text: string } | null = null;
      for (const n of nodes) {
        if (n === label || n.pageNumber !== label.pageNumber || n.bbox == null) {
          continue;
        }
        const text = this.normalizeSpace(n.content);
        if (!text) continue;
        if (
          /^(patient name|age\/gender|care location|patient location|lab accession id|specimen|collected date|authorized date|investigation|results|uom|reference range)$/i.test(
            text,
          )
        ) {
          continue;
        }
        const [x1, y1, x2, y2] = n.bbox;
        const cy = (y1 + y2) / 2;
        const dy = Math.abs(cy - lcy);
        const dx = x1 - lx2;
        if (dx < -20 || dx > 900) continue;
        if (dy > 110) continue;
        const score = dy * 3 + Math.max(0, dx);
        if (!best || score < best.score) {
          best = { score, text };
        }
      }
      if (best?.text) return best.text;
    }
    return undefined;
  }

  private extractPatientFieldMap(nodes: FlatNode[]): {
    patientName?: string;
    ageGender?: string;
    labAccessionId?: string;
    collectedDateTime?: string;
  } {
    const read = (label: RegExp): string | undefined =>
      this.findSpatialFieldValue(nodes, label);
    return {
      patientName: read(/^patient name$/i),
      ageGender: read(/^age\/gender$/i),
      labAccessionId: read(/^lab accession id$/i),
      collectedDateTime: read(/^collected date&time$/i),
    };
  }

  private extractSections(nodes: FlatNode[]): {
    sections: StructuredSectionDto[];
    stats: ExtractionStats;
  } {
    const sections = new Map<string, StructuredSectionItemDto[]>();
    const pages = new Map<number, FlatNode[]>();
    const stats: ExtractionStats = {
      candidateRows: 0,
      parsedRows: 0,
      aiCandidateRows: [],
    };

    for (const node of nodes) {
      if (node.pageNumber == null || node.bbox == null) continue;
      if (!pages.has(node.pageNumber)) pages.set(node.pageNumber, []);
      pages.get(node.pageNumber)!.push(node);
    }

    const pageNumbers = Array.from(pages.keys()).sort((a, b) => a - b);
    for (const page of pageNumbers) {
      const pageNodes = pages.get(page)!;
      const sorted = pageNodes
        .slice()
        .sort((a, b) => b.bbox![1] - a.bbox![1] || a.bbox![0] - b.bbox![0]);

      const tableHeaderIndexes: number[] = [];
      for (let i = 0; i < sorted.length; i++) {
        if (this.isTableHeader(sorted[i].content)) {
          tableHeaderIndexes.push(i);
        }
      }
      if (tableHeaderIndexes.length === 0) continue;

      for (let i = 0; i < tableHeaderIndexes.length; i++) {
        const start = tableHeaderIndexes[i] + 1;
        const end =
          i + 1 < tableHeaderIndexes.length
            ? tableHeaderIndexes[i + 1]
            : sorted.length;
        const headerY = sorted[tableHeaderIndexes[i]].bbox![1];
        const rows = sorted
          .slice(start, end)
          .filter((n) => n.bbox![1] < headerY - 0.5 && n.bbox![1] > 120);
        this.extractRowsFromTableBlock(rows, sections, stats);
      }
    }

    return {
      sections: Array.from(sections.entries())
        .map(([heading, tests]) => ({
          heading,
          tests: this.deduplicateRows(tests),
        }))
        .filter((s) => s.tests.length > 0),
      stats: {
        ...stats,
        aiCandidateRows: this.uniqueTrimmed(stats.aiCandidateRows).slice(
          0,
          400,
        ),
      },
    };
  }

  private extractSectionsFromExplicitTables(input: unknown): {
    sections: StructuredSectionDto[];
    stats: ExtractionStats;
  } {
    const tables: Record<string, unknown>[] = [];
    this.collectTables(input, tables);
    const sections = new Map<string, StructuredSectionItemDto[]>();
    const stats: ExtractionStats = {
      candidateRows: 0,
      parsedRows: 0,
      aiCandidateRows: [],
    };

    for (const table of tables) {
      const rows = Array.isArray(table.rows)
        ? (table.rows as Record<string, unknown>[])
        : [];
      if (rows.length === 0) continue;
      let currentSection = 'Other Tests';
      for (const row of rows) {
        const cells = Array.isArray(row.cells)
          ? (row.cells as Record<string, unknown>[])
          : [];
        if (cells.length < 2) continue;
        const c1 = this.readCellText(cells[0]);
        const c2 = this.readCellText(cells[1]);
        const c3 = cells.length > 2 ? this.readCellText(cells[2]) : '';
        const c4 = cells.length > 3 ? this.readCellText(cells[3]) : '';

        if (this.isTableHeader(`${c1} ${c2} ${c3} ${c4}`)) continue;
        if (!c1) continue;

        const normalizedName = this.normalizeParameterName(this.cleanName(c1));
        if (!this.isLikelyTestName(normalizedName)) continue;

        const hasValue = Boolean(c2 && this.parseValueLedRow(c2));
        const hasUnit = Boolean(c3);
        const hasRef = Boolean(c4);

        if (!hasValue && !hasUnit && !hasRef) {
          currentSection = this.cleanHeading(normalizedName);
          continue;
        }

        const parsedValue = this.parseValueLedRow(c2);
        if (!parsedValue) continue;

        stats.candidateRows += 1;
        const candidateText =
          `${normalizedName} ${c2} ${c3} ${c4}`.trim();
        if (this.isSafeAiCandidate(candidateText)) {
          stats.aiCandidateRows.push(candidateText);
        }
        if (!sections.has(currentSection)) sections.set(currentSection, []);
        sections.get(currentSection)!.push({
          parameterName: normalizedName,
          value: parsedValue.value,
          ...(c3 ? { unit: this.cleanValuePhrase(c3) } : {}),
          ...(c4 ? { referenceRange: this.cleanValuePhrase(c4) } : {}),
          ...(typeof parsedValue.isAbnormal === 'boolean'
            ? { isAbnormal: parsedValue.isAbnormal }
            : {}),
        });
        stats.parsedRows += 1;
      }
    }

    return {
      sections: Array.from(sections.entries())
        .map(([heading, tests]) => ({
          heading,
          tests: this.deduplicateRows(tests),
        }))
        .filter((s) => s.tests.length > 0),
      stats,
    };
  }

  private collectTables(node: unknown, out: Record<string, unknown>[]): void {
    if (!node || typeof node !== 'object') return;
    const obj = node as Record<string, unknown>;
    if (obj.type === 'table' && Array.isArray(obj.rows)) {
      out.push(obj);
    }
    if (Array.isArray(obj.kids)) {
      for (const kid of obj.kids) this.collectTables(kid, out);
    }
    if (Array.isArray(obj['list items'])) {
      for (const item of obj['list items']) this.collectTables(item, out);
    }
  }

  private readCellText(cell: Record<string, unknown>): string {
    const direct = typeof cell.content === 'string' ? cell.content : '';
    if (direct.trim()) return this.normalizeSpace(direct);
    const kids = Array.isArray(cell.kids)
      ? (cell.kids as Record<string, unknown>[])
      : [];
    const chunks: string[] = [];
    for (const kid of kids) {
      if (typeof kid.content === 'string' && kid.content.trim()) {
        chunks.push(kid.content);
      }
    }
    return this.normalizeSpace(chunks.join(' '));
  }

  private mergeSections(
    primary: StructuredSectionDto[],
    secondary: StructuredSectionDto[],
  ): StructuredSectionDto[] {
    const sections = new Map<string, StructuredSectionItemDto[]>();
    for (const section of [...primary, ...secondary]) {
      const heading = this.cleanHeading(section.heading || 'Other Tests');
      if (!sections.has(heading)) sections.set(heading, []);
      sections.get(heading)!.push(...section.tests);
    }
    return Array.from(sections.entries())
      .map(([heading, tests]) => ({
        heading,
        tests: this.deduplicateRows(tests),
      }))
      .filter((s) => s.tests.length > 0);
  }

  private hasLabDetails(details: StructuredLabDetailsDto): boolean {
    return Boolean(details.name && details.name.trim().length > 0);
  }

  private extractRowsFromTableBlock(
    rows: FlatNode[],
    sections: Map<string, StructuredSectionItemDto[]>,
    stats: ExtractionStats,
  ): void {
    let currentSection = 'Other Tests';
    let pendingTestName: string | null = null;

    for (const row of rows) {
      const content = this.normalizeSpace(row.content);
      if (!content) continue;
      if (this.isIgnorableRow(content, row.type)) continue;

      if (
        row.type.toLowerCase().includes('heading') &&
        this.isLikelySectionHeading(content, row)
      ) {
        currentSection = this.cleanHeading(content);
        pendingTestName = this.isLikelyTestName(content)
          ? this.cleanName(content)
          : null;
        if (this.isSafeAiCandidate(content)) {
          stats.aiCandidateRows.push(content);
        }
        continue;
      }

      const parsedValue = this.parseValueLedRow(content);
      if (parsedValue) {
        stats.candidateRows += 1;
        if (this.isSafeAiCandidate(content)) {
          stats.aiCandidateRows.push(content);
        }
        if (pendingTestName && this.isLikelyTestName(pendingTestName)) {
          if (!sections.has(currentSection)) sections.set(currentSection, []);
          sections.get(currentSection)!.push({
            parameterName: this.normalizeParameterName(pendingTestName),
            value: parsedValue.value,
            ...(parsedValue.unit ? { unit: parsedValue.unit } : {}),
            ...(parsedValue.referenceRange
              ? { referenceRange: parsedValue.referenceRange }
              : {}),
            ...(typeof parsedValue.isAbnormal === 'boolean'
              ? { isAbnormal: parsedValue.isAbnormal }
              : {}),
          });
          stats.parsedRows += 1;
        }
        pendingTestName =
          parsedValue.nextTestName &&
          this.isLikelyTestName(parsedValue.nextTestName)
            ? this.cleanName(parsedValue.nextTestName)
            : null;
        continue;
      }

      const nameLed = this.parseNameLedValueRow(content);
      if (nameLed) {
        stats.candidateRows += 1;
        if (this.isSafeAiCandidate(content)) {
          stats.aiCandidateRows.push(content);
        }
        if (!sections.has(currentSection)) sections.set(currentSection, []);
        sections.get(currentSection)!.push({
          parameterName: this.normalizeParameterName(nameLed.parameterName),
          value: nameLed.value,
          ...(nameLed.unit ? { unit: nameLed.unit } : {}),
          ...(nameLed.referenceRange
            ? { referenceRange: nameLed.referenceRange }
            : {}),
          ...(typeof nameLed.isAbnormal === 'boolean'
            ? { isAbnormal: nameLed.isAbnormal }
            : {}),
        });
        stats.parsedRows += 1;
        pendingTestName =
          nameLed.nextTestName && this.isLikelyTestName(nameLed.nextTestName)
            ? this.cleanName(nameLed.nextTestName)
            : null;
        continue;
      }

      const parsedName = this.parseNameOnlyRow(content);
      if (parsedName) {
        stats.candidateRows += 1;
        if (this.isSafeAiCandidate(content)) {
          stats.aiCandidateRows.push(content);
        }
        pendingTestName = parsedName;
      }
    }
  }

  private buildDiagnostics(input: {
    stats: ExtractionStats;
    extractedRows: number;
    sectionCount: number;
  }): OpenDataLoaderParseDiagnostics {
    const { stats, extractedRows, sectionCount } = input;
    const coverage =
      stats.candidateRows > 0 ? stats.parsedRows / stats.candidateRows : 0;
    const lowConfidenceReasons: string[] = [];

    if (stats.candidateRows === 0) {
      lowConfidenceReasons.push('No table candidate rows were detected.');
    }
    if (coverage < 0.45) {
      lowConfidenceReasons.push(
        `Low row coverage (${Math.round(coverage * 100)}%).`,
      );
    }
    if (extractedRows < 8) {
      lowConfidenceReasons.push(
        `Very few tests extracted (${extractedRows} rows).`,
      );
    }
    if (sectionCount < 2) {
      lowConfidenceReasons.push(
        `Very few sections extracted (${sectionCount}).`,
      );
    }

    let confidence =
      coverage * 0.6 +
      Math.min(1, extractedRows / 40) * 0.25 +
      Math.min(1, sectionCount / 8) * 0.15;
    confidence = Math.max(0, Math.min(1, confidence));
    if (stats.candidateRows === 0) confidence = 0;

    return {
      confidence: Number(confidence.toFixed(3)),
      coverage: Number(coverage.toFixed(3)),
      candidateRows: stats.candidateRows,
      parsedRows: stats.parsedRows,
      extractedRows,
      sectionCount,
      lowConfidenceReasons,
      aiCandidateRows: stats.aiCandidateRows,
    };
  }

  private isTableHeader(content: string): boolean {
    return /test name value unit bio\.? ref interval/i.test(content);
  }

  private isLikelySectionHeading(content: string, row: FlatNode): boolean {
    const x = row.bbox?.[0] ?? 999;
    const l = content.toLowerCase();
    if (x > 140) return false;
    if (content.length < 3 || content.length > 100) return false;
    if (/^[<>]?\s*[-+]?\d/.test(content)) return false;
    if (
      /\b(department|test name|smart report|summary|suggestions|end of report|pregnancy interval|machine)\b/.test(
        l,
      )
    ) {
      return false;
    }
    return true;
  }

  private isIgnorableRow(content: string, type: string): boolean {
    const l = content.toLowerCase();
    const t = type.toLowerCase();
    if (
      t.includes('footer') ||
      t.includes('caption') ||
      t.includes('list item') ||
      t === 'list'
    ) {
      return true;
    }
    if (this.isTableHeader(content)) return true;
    if (/^\s*method\s*:/i.test(content)) return true;
    if (
      /\b(page\s+\d+\s+of\s+\d+|sin no|barcode|sample collected on|sample received on|report generated on|customer since|report status|sample temperature|referred by|order id|booking id)\b/i.test(
        l,
      )
    ) {
      return true;
    }
    if (
      /\b(interpretation|reference range|as per american|healthians recommends|clinical interpretation|conditions that can result|calculated from test reports)\b/i.test(
        l,
      )
    ) {
      return true;
    }
    if (content.length > 180) return true;
    return false;
  }

  private isSafeAiCandidate(content: string): boolean {
    const l = content.toLowerCase();
    if (content.length > 140) return false;
    if (
      /\b(patient|name|age\/gender|mobile|phone|address|email|booking id|order id|barcode|referred by|sample collected on|sample received on|report generated on)\b/.test(
        l,
      )
    ) {
      return false;
    }
    return true;
  }

  private parseNameOnlyRow(content: string): string | null {
    if (/[:|]/.test(content)) return null;
    if (/^[<>]?\s*[-+]?\d/.test(content)) return null;
    let name = this.cleanName(content);
    const lower = name.toLowerCase();
    const secondAbsolute = lower.indexOf(' absolute ', 1);
    if (secondAbsolute > 0) {
      name = this.cleanName(name.slice(secondAbsolute + 1));
    }
    name = this.normalizeParameterName(name);
    if (!this.isLikelyTestName(name)) return null;
    return name;
  }

  private parseNameLedValueRow(
    content: string,
  ): (ParsedValueRow & { parameterName: string }) | null {
    const c = this.normalizeSpace(content);
    const m = c.match(
      /^([A-Za-z][A-Za-z0-9\s(),/%._-]{1,80})\s+(Negative|Positive|Nil|Normal|Absent|Present|Clear|Cloudy|Turbid|Trace)\s+([A-Za-z][A-Za-z0-9\s(),/%._-]{1,80})$/i,
    );
    if (!m) return null;

    const parameterName = this.cleanName(m[1]);
    if (!this.isLikelyTestName(parameterName)) return null;
    const referenceRange = this.cleanValuePhrase(m[2]);
    return {
      parameterName,
      value: this.cleanValuePhrase(m[2]),
      referenceRange,
      isAbnormal: false,
      nextTestName: this.cleanName(m[3]),
    };
  }

  private parseValueLedRow(content: string): ParsedValueRow | null {
    const c = this.normalizeSpace(content);
    if (!c) return null;

    const numeric = c.match(/^([<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?)(?:\s+(.+))?$/);
    if (numeric) {
      const value = this.normalizeNumericValue(numeric[1]);
      let rest = numeric[2] ?? '';
      let unit: string | undefined;
      const tokens = rest.split(/\s+/).filter(Boolean);
      if (tokens.length > 0 && this.isLikelyUnitToken(tokens[0])) {
        unit = tokens[0];
        rest = tokens.slice(1).join(' ');
      }
      const extractedRef = this.extractReferenceRange(rest);
      const nextTestName = this.extractTrailingTestName(extractedRef.remainder);
      const isAbnormal = this.evaluateAbnormal(
        value,
        extractedRef.referenceRange,
      );
      return {
        value,
        ...(unit ? { unit } : {}),
        ...(extractedRef.referenceRange
          ? { referenceRange: extractedRef.referenceRange }
          : {}),
        ...(typeof isAbnormal === 'boolean' ? { isAbnormal } : {}),
        ...(nextTestName ? { nextTestName } : {}),
      };
    }

    const qual = this.parseQualitativeValue(c);
    if (qual) {
      const extractedRef = this.extractReferenceRange(qual.rest);
      const nextTestName = this.extractTrailingTestName(extractedRef.remainder);
      const isAbnormal = this.evaluateAbnormal(
        qual.value,
        extractedRef.referenceRange,
      );
      return {
        value: qual.value,
        ...(qual.unit ? { unit: qual.unit } : {}),
        ...(extractedRef.referenceRange
          ? { referenceRange: extractedRef.referenceRange }
          : {}),
        ...(typeof isAbnormal === 'boolean' ? { isAbnormal } : {}),
        ...(nextTestName ? { nextTestName } : {}),
      };
    }

    return null;
  }

  private parseQualitativeValue(
    content: string,
  ): { value: string; unit?: string; rest: string } | null {
    const c = this.normalizeSpace(content);
    const lower = c.toLowerCase();
    const qualifiers = [
      'negative',
      'positive',
      'nil',
      'normal',
      'absent',
      'present',
      'clear',
      'cloudy',
      'turbid',
      'trace',
      'amber',
      'yellow',
      'straw',
      'pale yellow',
    ];

    let matched: string | null = null;
    for (const q of qualifiers) {
      if (lower.startsWith(`${q} `) || lower === q) {
        matched = q;
        break;
      }
    }
    if (!matched) return null;

    const consumed = matched.split(' ').length;
    const tokens = c.split(/\s+/).filter(Boolean);
    let idx = consumed;
    let unit: string | undefined;
    if (tokens[idx] && this.isLikelyUnitToken(tokens[idx])) {
      unit = tokens[idx];
      idx += 1;
    }
    const rest = tokens.slice(idx).join(' ');
    return {
      value: this.cleanValuePhrase(tokens.slice(0, consumed).join(' ')),
      ...(unit ? { unit } : {}),
      rest,
    };
  }

  private extractReferenceRange(rest: string): {
    referenceRange?: string;
    remainder: string;
  } {
    const cleaned = this.normalizeSpace(rest);
    if (!cleaned) return { remainder: '' };

    const between = cleaned.match(
      /^\s*(-?\d+(?:\.\d+)?)\s*[-–]\s*(-?\d+(?:\.\d+)?)(?:\s+(.*))?$/,
    );
    if (between) {
      return {
        referenceRange: `${between[1]} - ${between[2]}`,
        remainder: this.normalizeSpace(between[3] ?? ''),
      };
    }

    const cmp = cleaned.match(/^\s*([<>]=?)\s*(-?\d+(?:\.\d+)?)(?:\s+(.*))?$/);
    if (cmp) {
      return {
        referenceRange: `${cmp[1]}${cmp[2]}`,
        remainder: this.normalizeSpace(cmp[3] ?? ''),
      };
    }

    const qual = cleaned.match(
      /^\s*(Negative|Positive|Nil|Normal|Absent|Present|Clear|Cloudy|Turbid|Trace|Pale Yellow|Yellow|Amber|Straw)(?:\s+(.*))?$/i,
    );
    if (qual) {
      return {
        referenceRange: this.cleanValuePhrase(qual[1]),
        remainder: this.normalizeSpace(qual[2] ?? ''),
      };
    }

    return { remainder: cleaned };
  }

  private evaluateAbnormal(
    rawValue: string,
    referenceRange?: string,
  ): boolean | undefined {
    if (!referenceRange) return undefined;

    const ref = referenceRange.trim();
    const refLower = ref.toLowerCase();
    const qual =
      /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale yellow|yellow|amber|straw)$/i;

    if (qual.test(refLower)) {
      const valueLower = rawValue.trim().toLowerCase();
      if (!qual.test(valueLower)) return undefined;
      return valueLower !== refLower;
    }

    const numericValue = this.tryParseNumeric(rawValue);
    if (numericValue === null) return undefined;

    const between = ref.match(
      /^\s*(-?\d+(?:\.\d+)?)\s*[-–]\s*(-?\d+(?:\.\d+)?)\s*$/,
    );
    if (between) {
      const low = Number(between[1]);
      const high = Number(between[2]);
      if (!Number.isFinite(low) || !Number.isFinite(high)) return undefined;
      return (
        numericValue < Math.min(low, high) || numericValue > Math.max(low, high)
      );
    }

    const lt = ref.match(/^\s*<\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (lt) return numericValue >= Number(lt[1]);
    const lte = ref.match(/^\s*<=\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (lte) return numericValue > Number(lte[1]);
    const gt = ref.match(/^\s*>\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (gt) return numericValue <= Number(gt[1]);
    const gte = ref.match(/^\s*>=\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (gte) return numericValue < Number(gte[1]);

    return undefined;
  }

  private tryParseNumeric(raw: string): number | null {
    const cleaned = raw
      .replace(/^[<>]=?\s*/, '')
      .replace(/,/g, '')
      .trim();
    if (!/^-?\d+(?:\.\d+)?$/.test(cleaned)) return null;
    const n = Number(cleaned);
    return Number.isFinite(n) ? n : null;
  }

  private extractTrailingTestName(rest: string): string | null {
    const tokens = rest.split(/\s+/).filter(Boolean);
    if (tokens.length === 0) return null;

    for (let start = 0; start < tokens.length; start++) {
      const raw = tokens.slice(start).join(' ');
      const candidate = raw.replace(/^[^A-Za-z]+/, '').trim();
      if (!candidate) continue;
      if (!/[A-Za-z]/.test(candidate)) continue;
      if (!this.isLikelyTestName(candidate)) continue;
      return this.cleanName(candidate);
    }
    return null;
  }

  private isLikelyUnitToken(token: string): boolean {
    const t = token.trim().replace(/[.,;:]+$/, '');
    const l = t.toLowerCase();
    if (!t) return false;
    if (t.length > 20) return false;
    if (/^[-–]$/.test(t)) return false;
    if (/^[<>]?\d[\d,]*(?:\.\d+)?$/.test(t)) return false;
    if (/^\d+\s*-\s*\d+$/.test(t)) return false;
    if (/[:]/.test(t)) return false;
    if (
      /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale|yellow|desirable|borderline|optimal|high|low|risk|first|second|third)$/i.test(
        l,
      )
    ) {
      return false;
    }
    if (/^[A-Za-z]+$/.test(t)) {
      return t.length <= 4 || l === 'ratio';
    }
    if (/^[A-Za-zµ/%][A-Za-zµ/%^0-9._/-]*$/.test(t)) return true;
    if (/^\d+\^\d+\/[A-Za-zµ/%][A-Za-zµ/%^0-9._/-]*$/.test(t)) return true;
    if (/^\/[A-Za-z]+$/i.test(t)) return true;
    return false;
  }

  private isLikelyTestName(name: string): boolean {
    const n = this.normalizeSpace(name);
    const l = n.toLowerCase();
    if (n.length < 2 || n.length > 100) return false;
    if (!/[A-Za-z]/.test(n)) return false;
    if ((n.match(/[A-Za-z]/g) ?? []).length < 2) return false;
    if ((n.match(/\s+/g) ?? []).length > 10) return false;
    if (/[:|]/.test(n)) return false;
    if (/^[<>]?\s*[-+]?\d/.test(n)) return false;
    if (
      /\b(department|test name|smart report|summary|suggestions|report generated|sample|customer|barcode|booking|order id|page \d|sin no|method|interpretation|reference|desirable|borderline|optimal|risk|first trimester|second trimester|third trimester|healthians|american diabetes association|end of report)\b/.test(
        l,
      )
    ) {
      return false;
    }
    if (
      /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale|yellow|amber|straw)\b/.test(
        l,
      )
    ) {
      return false;
    }
    return true;
  }

  private cleanHeading(heading: string): string {
    return this.normalizeSpace(heading)
      .replace(/^\*+\s*|\s*\*+$/g, '')
      .trim();
  }

  private cleanName(name: string): string {
    return this.normalizeSpace(name)
      .replace(/^[\s:;,-]+/, '')
      .replace(/[\s:;,-]+$/, '')
      .trim();
  }

  private normalizeParameterName(name: string): string {
    return name
      .replace(/^(physical|chemical)\s+examination\s+/i, '')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private cleanValuePhrase(value: string): string {
    return this.normalizeSpace(value).trim();
  }

  private normalizeNumericValue(value: string): string {
    return value.replace(/[,\s]+/g, '').trim();
  }

  private normalizeSpace(value: string): string {
    return value.replace(/\s+/g, ' ').trim();
  }

  private uniqueTrimmed(items: string[]): string[] {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const item of items) {
      const cleaned = this.normalizeSpace(item);
      if (!cleaned) continue;
      const key = cleaned.toLowerCase();
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(cleaned);
    }
    return out;
  }

  private deduplicate(values: ExtractedLabValue[]): ExtractedLabValue[] {
    const seen = new Set<string>();
    const out: ExtractedLabValue[] = [];
    for (const v of values) {
      const key = `${v.parameterName.toLowerCase()}::${v.value.toLowerCase()}::${(v.unit ?? '').toLowerCase()}`;
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(v);
    }
    return out;
  }

  private compactLabValues(values: ExtractedLabValue[]): ExtractedLabValue[] {
    const bestByParamValue = new Map<string, ExtractedLabValue>();
    for (const row of values) {
      const key = `${row.parameterName.toLowerCase()}::${row.value.toLowerCase()}`;
      const current = bestByParamValue.get(key);
      if (!current) {
        bestByParamValue.set(key, row);
        continue;
      }
      const currentScore =
        (current.unit ? 1 : 0) + (current.referenceRange ? 1 : 0);
      const nextScore = (row.unit ? 1 : 0) + (row.referenceRange ? 1 : 0);
      if (nextScore > currentScore) {
        bestByParamValue.set(key, row);
      }
    }
    return Array.from(bestByParamValue.values());
  }

  private deduplicateRows(
    rows: StructuredSectionItemDto[],
  ): StructuredSectionItemDto[] {
    const seen = new Set<string>();
    const out: StructuredSectionItemDto[] = [];
    for (const row of rows) {
      const key = `${row.parameterName.toLowerCase()}::${row.value.toLowerCase()}::${(row.unit ?? '').toLowerCase()}::${(row.referenceRange ?? '').toLowerCase()}`;
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(row);
    }
    return out;
  }
}
