import type { ExtractedLabValue } from './lab-value-extractor';
import type {
  StructuredPatientDetailsDto,
  StructuredReportDto,
  StructuredSectionDto,
  StructuredSectionItemDto,
} from './reports.service';

interface FlatNode {
  type: string;
  content: string;
  pageNumber: number | null;
  bbox: [number, number, number, number] | null;
}

interface ParsedCandidateRow {
  row: StructuredSectionItemDto;
  kind: 'complete' | 'name_only' | 'value_only';
}

export interface OpenDataLoaderParsedOutput {
  extractedLabValues: ExtractedLabValue[];
  structuredReport: StructuredReportDto;
}

export class OpenDataLoaderJsonParser {
  parse(input: unknown): OpenDataLoaderParsedOutput {
    const nodes = this.flattenNodes(input);
    const patientDetails = this.extractPatientDetails(nodes);
    const sections = this.extractSections(nodes);

    const extractedLabValues: ExtractedLabValue[] = [];
    for (const section of sections) {
      for (const test of section.tests) {
        extractedLabValues.push({
          parameterName: test.parameterName,
          value: test.value,
          unit: test.unit ?? null,
          sampleDate: test.sampleDate ?? null,
        });
      }
    }

    return {
      extractedLabValues: this.deduplicate(extractedLabValues),
      structuredReport: {
        patientDetails,
        sections: sections.filter((s) => s.tests.length > 0),
      },
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
      if (type && content) out.push({ type, content, pageNumber, bbox });
      const kids = obj.kids;
      if (Array.isArray(kids)) {
        for (const k of kids) walk(k);
      }
      const listItems = obj['list items'];
      if (Array.isArray(listItems)) {
        for (const li of listItems) walk(li);
      }
    };
    walk(input);
    return out;
  }

  private extractPatientDetails(nodes: FlatNode[]): StructuredPatientDetailsDto {
    const full = nodes.map((n) => n.content).join(' ');
    const read = (re: RegExp): string | undefined => {
      const m = full.match(re);
      return m?.[1]?.trim();
    };
    const name =
      read(/Patient Name\s*:\s*([^|]+?)(?:\s{2,}|Age\/Gender|Barcode|Order Id|$)/i) ??
      read(/\bDear\s+([A-Za-z][A-Za-z ]{1,80})[,!]/i) ??
      read(/^\s*([A-Za-z][A-Za-z ]{2,80})\s*$/m);
    const ageGender = read(/Age\/Gender\s*:\s*([^|]+?)(?:\s{2,}|Order Id|$)/i);
    const age =
      ageGender?.match(/(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?|\d+\s*Yrs?)/i)?.[1];
    const gender = ageGender?.match(/\b(Male|Female|Other)\b/i)?.[1];
    return {
      ...(name ? { name } : {}),
      ...(age ? { age } : {}),
      ...(gender ? { gender } : {}),
      ...(read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i)
        ? { bookingId: read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i) }
        : {}),
      ...(read(
        /Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i,
      )
        ? {
            sampleCollectionDate: read(
              /Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i,
            ),
          }
        : {}),
    };
  }

  private extractSections(nodes: FlatNode[]): StructuredSectionDto[] {
    const sections = new Map<string, StructuredSectionItemDto[]>();
    let currentSection = 'Other Tests';
    let pendingParameterName: string | null = null;
    const stitchedRows = this.stitchRowsByPageAndY(nodes);

    for (const node of [...nodes, ...stitchedRows]) {
      if (node.type.toLowerCase().includes('heading')) {
        const normalized = this.normalizeSectionHeading(node.content);
        if (normalized) currentSection = normalized;
      }
      const parsed = this.parseTestRow(node.content);
      if (!parsed) continue;

      if (parsed.kind === 'name_only') {
        pendingParameterName = parsed.row.parameterName;
        continue;
      }

      const heading =
        'sectionHint' in node && typeof node.sectionHint === 'string'
          ? node.sectionHint
          : currentSection;

      if (parsed.kind === 'value_only') {
        if (!pendingParameterName) continue;
        parsed.row.parameterName = pendingParameterName;
        pendingParameterName = null;
      } else {
        pendingParameterName = null;
      }

      if (!sections.has(heading)) sections.set(heading, []);
      sections.get(heading)!.push(parsed.row);
    }

    return Array.from(sections.entries()).map(([heading, tests]) => ({
      heading,
      tests: this.deduplicateRows(tests),
    }));
  }

  private stitchRowsByPageAndY(nodes: FlatNode[]): FlatNode[] {
    const candidates = nodes.filter(
      (n) =>
        n.pageNumber != null &&
        n.bbox != null &&
        n.type.toLowerCase() !== 'heading' &&
        !/^\s*method\s*:/i.test(n.content) &&
        !this.isLikelyNarrative(n.content),
    );
    const byPage = new Map<number, FlatNode[]>();
    for (const node of candidates) {
      const p = node.pageNumber!;
      if (!byPage.has(p)) byPage.set(p, []);
      byPage.get(p)!.push(node);
    }

    const stitched: FlatNode[] = [];
    const yTolerance = 2.2;

    for (const [, pageNodes] of byPage.entries()) {
      pageNodes.sort((a, b) => (b.bbox![1] - a.bbox![1]) || (a.bbox![0] - b.bbox![0]));
      const rows: FlatNode[][] = [];

      for (const n of pageNodes) {
        const y = n.bbox![1];
        let bucket: FlatNode[] | undefined;
        for (const r of rows) {
          const ry = r[0].bbox![1];
          if (Math.abs(ry - y) <= yTolerance) {
            bucket = r;
            break;
          }
        }
        if (!bucket) {
          rows.push([n]);
        } else {
          bucket.push(n);
        }
      }

      for (const rowNodes of rows) {
        rowNodes.sort((a, b) => a.bbox![0] - b.bbox![0]);
        const content = rowNodes.map((r) => r.content).join(' ').replace(/\s+/g, ' ').trim();
        if (content.length < 6) continue;
        if (/test name value unit bio\.? ref/i.test(content)) continue;
        stitched.push({
          type: 'stitched_row',
          content,
          pageNumber: rowNodes[0].pageNumber ?? null,
          bbox: rowNodes[0].bbox ?? null,
        });
      }
    }

    return stitched;
  }

  private normalizeSectionHeading(raw: string): string | null {
    const h = raw.replace(/\s+/g, ' ').trim();
    if (!h) return null;
    const l = h.toLowerCase();
    if (
      /test name value unit|smart report|summary|suggestions|end of report/.test(
        l,
      )
    ) {
      return null;
    }
    if (/thyroid/.test(l)) return 'Thyroid Function';
    if (/liver|lft/.test(l)) return 'Liver Function';
    if (/kidney|kft/.test(l)) return 'Kidney Function';
    if (/lipid|cholesterol/.test(l)) return 'Lipid Profile';
    if (/hba1c|glucose|diabet/.test(l)) return 'Diabetes';
    if (/blood count|hemogram|haematology|hematology/.test(l)) {
      return 'Complete Blood Count';
    }
    if (/iron/.test(l)) return 'Iron Studies';
    if (/vitamin/.test(l)) return 'Vitamin Profile';
    if (/urine|clinical pathology/.test(l)) return 'Urine Analysis';
    if (/crp|rheumatoid|inflammation/.test(l)) return 'Inflammation / Autoimmune';
    if (/cortisol|immunology/.test(l)) return 'Hormones';
    return h;
  }

  private parseTestRow(content: string): ParsedCandidateRow | null {
    const c = content.replace(/\s+/g, ' ').trim();
    if (!c || this.isLikelyNarrative(c)) return null;

    const colon = c.match(
      /^([A-Za-z][A-Za-z0-9\s/(),._%-]{2,100})\s*:\s*([<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?)\s*([A-Za-zµ/%^0-9._-]{0,20})/i,
    );
    if (colon) {
      const parameterName = this.cleanName(colon[1]);
      if (!this.isLikelyTestName(parameterName)) return null;
      return {
        kind: 'complete',
        row: {
          parameterName,
          value: this.normalizeValue(colon[2]),
          ...(colon[3] ? { unit: colon[3].trim() } : {}),
        },
      };
    }

    const nameFirst = c.match(
      /^([A-Za-z][A-Za-z0-9\s/(),._%-]{2,100})\s+([<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?)\s*([A-Za-zµ/%^0-9._-]{0,20})(?:\s|$)/,
    );
    if (nameFirst) {
      const parameterName = this.cleanName(nameFirst[1]);
      if (!this.isLikelyTestName(parameterName)) return null;
      return {
        kind: 'complete',
        row: {
          parameterName,
          value: this.normalizeValue(nameFirst[2]),
          ...(nameFirst[3] ? { unit: nameFirst[3].trim() } : {}),
        },
      };
    }

    const valueFirst = c.match(
      /^([<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?)\s*([A-Za-zµ/%^0-9._-]{0,20})(?:\s+\d[\d.\s-]*)?\s+([A-Za-z][A-Za-z0-9\s/(),._%-]{2,100})$/i,
    );
    if (valueFirst) {
      const parameterName = this.cleanName(valueFirst[3]);
      if (!this.isLikelyTestName(parameterName)) return null;
      return {
        kind: 'complete',
        row: {
          parameterName,
          value: this.normalizeValue(valueFirst[1]),
          ...(valueFirst[2] ? { unit: valueFirst[2].trim() } : {}),
        },
      };
    }

    const nameOnly = c.match(/^([A-Za-z][A-Za-z0-9\s/(),._%-]{2,100})$/);
    if (nameOnly) {
      const parameterName = this.cleanName(nameOnly[1]);
      if (!this.isLikelyTestName(parameterName)) return null;
      return {
        kind: 'name_only',
        row: { parameterName, value: '' },
      };
    }

    const valueOnly = c.match(
      /^([<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?)\s*([A-Za-zµ/%^0-9._-]{0,20})(?:\s+\d[\d.\s-]*)?$/,
    );
    if (valueOnly) {
      return {
        kind: 'value_only',
        row: {
          parameterName: '',
          value: this.normalizeValue(valueOnly[1]),
          ...(valueOnly[2] ? { unit: valueOnly[2].trim() } : {}),
        },
      };
    }

    return null;
  }

  private isLikelyNarrative(content: string): boolean {
    const l = content.toLowerCase();
    return (
      /test name value unit bio\.? ref|method\s*:|interpretation|reference range|suggested supplement|health score|personalized summary|congratulations|calculated from test reports|standards of medical care|american diabetes association|recommends|clinical interpretation|conditions that can result/.test(
        l,
      ) || l.length > 220
    );
  }

  private isLikelyTestName(name: string): boolean {
    const l = name.toLowerCase();
    if (name.length < 3 || name.length > 100) return false;
    if ((name.match(/\d/g) ?? []).length > 10) return false;
    if ((name.match(/[a-z]/gi) ?? []).length < 3) return false;
    if (
      /\b(report|summary|method|interpretation|reference|booking|sample|department|status|customer|doctor|recommend|analysis)\b/.test(
        l,
      )
    ) {
      return false;
    }
    return true;
  }

  private cleanName(name: string): string {
    return name
      .replace(/\s+/g, ' ')
      .trim()
      .replace(/\b\w/g, (m) => m.toUpperCase());
  }

  private normalizeValue(value: string): string {
    return value.replace(/[,\s]+/g, '').trim();
  }

  private deduplicate(values: ExtractedLabValue[]): ExtractedLabValue[] {
    const seen = new Set<string>();
    const out: ExtractedLabValue[] = [];
    for (const v of values) {
      const key = `${v.parameterName}::${v.value}::${v.unit ?? ''}`;
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(v);
    }
    return out;
  }

  private deduplicateRows(rows: StructuredSectionItemDto[]): StructuredSectionItemDto[] {
    const seen = new Set<string>();
    const out: StructuredSectionItemDto[] = [];
    for (const row of rows) {
      const key = `${row.parameterName}::${row.value}::${row.unit ?? ''}`;
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(row);
    }
    return out;
  }
}
