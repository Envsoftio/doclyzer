import {
  bounds,
  type EvidenceToken,
  type PageEvidence,
  type Polygon,
} from './evidence';

export type ReviewReason =
  | 'ambiguous_decimal'
  | 'ambiguous_row_pairing'
  | 'multiple_result_columns'
  | 'unit_conflict'
  | 'unknown_date_scope'
  | 'truncated_row'
  | 'unreadable_source'
  | 'verification_timeout'
  | 'reading_disagreement'
  | 'missing_result'
  | 'unassigned_value'
  | 'unprocessed_page'
  | 'context_unresolved'
  | 'quality_profile_unvalidated';
export interface LabTemplate {
  id: string;
  version: string;
  /** Both independent anchors must be present on the page. */
  anchors: [string, string, ...string[]];
  panels: Array<{
    id: string;
    rect: [number, number, number, number];
    columns: Array<{
      role: 'test' | 'result' | 'unit' | 'range' | 'flag';
      x: [number, number];
      date?: string;
      resultColumn?: string;
    }>;
    sharedUnit?: { text: string; scope: 'panel' };
  }>;
}
export interface LabCandidate {
  id: string;
  documentId: string;
  pageId: string;
  panelId: string;
  rowId: string;
  resultColumn: string;
  date: string | null;
  specimen: string | null;
  testRaw: string;
  resultRaw: string | null;
  resultKind: string;
  numericDecimal: string | null;
  qualifier: string | null;
  unitRaw: string | null;
  rangeRaw: string | null;
  flagRaw: string | null;
  evidence: Record<string, string[]>;
  sourcePolygon: Polygon;
  status: 'candidate' | 'needs_review' | 'verified' | 'unreadable';
  machineEligible: boolean;
  interpretationReady: boolean;
  reviewReasons: ReviewReason[];
  validatorVersion: string;
  templateVersion: string | null;
  readings: Array<{ engine: string; raw: string; cropId: string | null }>;
}
export interface RowLedger {
  pageId: string;
  panelId: string;
  rowId: string;
  state:
    | 'extracted_needs_review'
    | 'printed_missing'
    | 'non_result'
    | 'unresolved';
  tokenIds: string[];
  reasons: ReviewReason[];
}
export interface GeometryResult {
  candidates: LabCandidate[];
  ledger: RowLedger[];
  documentStatus: 'needs_review' | 'partial';
  unresolvedTokenIds: string[];
  pageStatus: Array<{
    pageId: string;
    accounted: boolean;
    failedRegions: string[];
  }>;
}
type Role = 'test' | 'result' | 'unit' | 'range' | 'flag';
type Column = {
  role: Role;
  left: number;
  right: number;
  resultColumn?: string;
  date?: string;
};
const LABEL = /^(?:test(?: name)?|investigations?|parameters?|analyte)$/i;
const RESULT =
  /^(?:result|observed value|current|previous|prior)(?:\s*\([^)]*\))?$/i;
const UNIT = /^(?:units?|uom)$/i;
const RANGE =
  /^(?:reference(?: range| interval)?|ref\.? range|biological ref\.? interval)$/i;
const FLAG = /^(?:flag|status)$/i;
const MISSING = /^(?:pending|not performed|see comment|[-–—])$/i;
const QUAL =
  /^(negative|positive|trace|reactive|nonreactive|detected|not detected)$/i;
const NUMERIC =
  /^([<>]=?|[≤≥])?\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)$/;
const INTERVAL =
  /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)\s*[-–]\s*[+-]?(?:\d+(?:\.\d*)?|\.\d+)$/;
const RATIO = /^\d+(?:\.\d+)?\s*:\s*\d+(?:\.\d+)?$/;
const VERSION = 'geometry-1';
function classify(raw: string | null) {
  if (raw == null || !raw.trim())
    return { kind: 'missing', decimal: null, qualifier: null };
  const value = raw.trim();
  if (MISSING.test(value))
    return { kind: 'printed_missing', decimal: null, qualifier: null };
  if (QUAL.test(value))
    return { kind: 'qualitative', decimal: null, qualifier: null };
  const numeric = value.match(NUMERIC);
  if (numeric)
    return {
      kind: 'numeric',
      decimal: numeric[2],
      qualifier: numeric[1] ?? null,
    };
  if (INTERVAL.test(value))
    return { kind: 'interval', decimal: null, qualifier: null };
  if (RATIO.test(value))
    return { kind: 'ratio', decimal: null, qualifier: null };
  return { kind: 'unparsed', decimal: null, qualifier: null };
}
function normalized(s: string) {
  return s.trim().replace(/\s+/g, ' ').toLowerCase();
}
function rowGroups(tokens: EvidenceToken[]) {
  const sorted = [...tokens].sort(
    (a, b) => bounds(a.polygon_original).cy - bounds(b.polygon_original).cy,
  );
  const rows: EvidenceToken[][] = [];
  for (const t of sorted) {
    const box = bounds(t.polygon_original);
    const last = rows.at(-1);
    const lastBox = last && bounds(last[0].polygon_original);
    const tolerance = lastBox
      ? Math.max(
          3,
          Math.min(lastBox.bottom - lastBox.top, box.bottom - box.top) * 0.5,
        )
      : 0;
    if (last && lastBox && Math.abs(box.cy - lastBox.cy) <= tolerance)
      last.push(t);
    else rows.push([t]);
  }
  return rows.map((r) =>
    r.sort(
      (a, b) =>
        bounds(a.polygon_original).left - bounds(b.polygon_original).left,
    ),
  );
}
function text(tokens: EvidenceToken[]) {
  return tokens
    .map((t) => t.text_raw)
    .join(' ')
    .trim();
}
function boxOf(tokens: EvidenceToken[]): Polygon {
  const b = tokens.map((t) => bounds(t.polygon_original));
  const l = Math.min(...b.map((x) => x.left));
  const r = Math.max(...b.map((x) => x.right));
  const t = Math.min(...b.map((x) => x.top));
  const d = Math.max(...b.map((x) => x.bottom));
  return [
    [l, t],
    [r, t],
    [r, d],
    [l, d],
  ];
}
function headerRole(s: string): Role | null {
  if (LABEL.test(s)) return 'test';
  if (RESULT.test(s)) return 'result';
  if (UNIT.test(s)) return 'unit';
  if (RANGE.test(s)) return 'range';
  if (FLAG.test(s)) return 'flag';
  return null;
}
function columnsFromHeader(
  row: EvidenceToken[],
  width: number,
): Column[] | null {
  const heads: Array<{ role: Role; x: number; raw: string }> = [];
  for (let i = 0; i < row.length; ) {
    let match: { role: Role; x: number; raw: string; count: number } | null =
      null;
    for (let count = Math.min(3, row.length - i); count >= 1; count--) {
      const segment = row.slice(i, i + count);
      const raw = text(segment);
      const role = headerRole(raw);
      if (role) {
        const left = bounds(segment[0].polygon_original).left;
        const right = bounds(segment.at(-1)!.polygon_original).right;
        match = { role, x: (left + right) / 2, raw, count };
        break;
      }
    }
    if (match) {
      heads.push(match);
      i += match.count;
    } else i++;
  }
  if (
    !heads.some((h) => h.role === 'test') ||
    !heads.some((h) => h.role === 'result')
  )
    return null;
  const recognized = heads;
  if (recognized.filter((h) => h.role === 'test').length !== 1) return null;
  return recognized.map((h, i) => ({
    role: h.role,
    left: i ? (recognized[i - 1].x + h.x) / 2 : 0,
    right: i < recognized.length - 1 ? (h.x + recognized[i + 1].x) / 2 : width,
    ...(h.role === 'result' ? { resultColumn: normalized(h.raw) } : {}),
  }));
}
function assign(row: EvidenceToken[], columns: Column[]) {
  const cells = columns.map(() => [] as EvidenceToken[]);
  const ambiguous: EvidenceToken[] = [];
  for (const t of row) {
    const b = bounds(t.polygon_original);
    const hits = columns
      .map((c, i) => ({
        i,
        overlap: Math.max(
          0,
          Math.min(b.right, c.right) - Math.max(b.left, c.left),
        ),
      }))
      .filter((x) => x.overlap > 0)
      .sort((a, b) => b.overlap - a.overlap);
    if (!hits.length || (hits[1] && hits[1].overlap >= hits[0].overlap * 0.5))
      ambiguous.push(t);
    else cells[hits[0].i].push(t);
  }
  return { cells, ambiguous };
}
function templateFor(
  page: PageEvidence,
  templates: LabTemplate[],
): LabTemplate | null {
  const all = page.tokens.map((t) => normalized(t.text_raw));
  const matches = templates.filter(
    (tpl) =>
      tpl.anchors.length >= 2 &&
      tpl.anchors.every((anchor) =>
        all.some((raw) => raw.includes(normalized(anchor))),
      ),
  );
  return matches.length === 1 ? matches[0] : null;
}
/** Parsing is deliberately conservative: headers or a multi-anchor template
 * establish columns; unmatched material stays in the completeness ledger. */
export function parseGeometry(
  pages: PageEvidence[],
  expectedPageIds: string[],
  templates: LabTemplate[] = [],
): GeometryResult {
  const candidates: LabCandidate[] = [];
  const ledger: RowLedger[] = [];
  const unresolved = new Set<string>();
  const status: GeometryResult['pageStatus'] = [];
  for (const pageId of expectedPageIds) {
    const page = pages.find((p) => p.page_id === pageId);
    if (!page || page.route === 'unprocessed') {
      status.push({
        pageId,
        accounted: false,
        failedRegions: ['unprocessed_page'],
      });
      continue;
    }
    const tpl = templateFor(page, templates);
    const panels = tpl
      ? tpl.panels.map((p) => ({
          id: p.id,
          tokens: page.tokens.filter((t) => {
            const b = bounds(t.polygon_original);
            return (
              b.cx >= p.rect[0] &&
              b.cx <= p.rect[2] &&
              b.cy >= p.rect[1] &&
              b.cy <= p.rect[3]
            );
          }),
          columns: p.columns.map((c) => ({
            role: c.role,
            left: c.x[0],
            right: c.x[1],
            resultColumn: c.resultColumn,
            date: c.date,
          })),
          sharedUnit:
            p.sharedUnit?.scope === 'panel' ? p.sharedUnit.text : null,
        }))
      : [
          {
            id: `${pageId}:panel:0`,
            tokens: page.tokens,
            columns: null as Column[] | null,
            sharedUnit: null as string | null,
          },
        ];
    let pageAccounted =
      page.failed_regions.length === 0 && page.tokens.length > 0;
    for (const panel of panels) {
      const rows = rowGroups(panel.tokens);
      let columns = panel.columns;
      let panelIndex = 0;
      for (const row of rows) {
        const heading = tpl ? null : columnsFromHeader(row, page.width);
        if (heading) {
          columns = heading;
          panelIndex++;
          ledger.push({
            pageId,
            panelId: `${pageId}:panel:${panelIndex}`,
            rowId: `${pageId}:row:${ledger.length}`,
            state: 'non_result',
            tokenIds: row.map((t) => t.token_id),
            reasons: [],
          });
          continue;
        }
        const rowId = `${pageId}:row:${ledger.length}`;
        const panelId = tpl ? panel.id : `${pageId}:panel:${panelIndex}`;
        if (!columns) {
          row.forEach((t) => unresolved.add(t.token_id));
          pageAccounted = false;
          ledger.push({
            pageId,
            panelId,
            rowId,
            state: 'unresolved',
            tokenIds: row.map((t) => t.token_id),
            reasons: ['ambiguous_row_pairing'],
          });
          continue;
        }
        const activeColumns = columns;
        const { cells, ambiguous } = assign(row, activeColumns);
        const get = (role: Role) =>
          activeColumns.flatMap((c, i) => (c.role === role ? cells[i] : []));
        const labels = get('test');
        const results = activeColumns
          .map((c, i) => ({ c, tokens: cells[i] }))
          .filter((x) => x.c.role === 'result');
        if (!labels.length) {
          const resultTokens = results.flatMap((x) => x.tokens);
          const reason: ReviewReason = resultTokens.length
            ? 'unassigned_value'
            : 'ambiguous_row_pairing';
          row.forEach((t) => unresolved.add(t.token_id));
          pageAccounted = false;
          ledger.push({
            pageId,
            panelId,
            rowId,
            state: 'unresolved',
            tokenIds: row.map((t) => t.token_id),
            reasons: [reason],
          });
          continue;
        }
        const populated = results.filter((x) => x.tokens.length);
        if (!populated.length) {
          row.forEach((t) => unresolved.add(t.token_id));
          pageAccounted = false;
          ledger.push({
            pageId,
            panelId,
            rowId,
            state: 'unresolved',
            tokenIds: row.map((t) => t.token_id),
            reasons: ['missing_result'],
          });
          continue;
        }
        for (const { c, tokens: result } of populated) {
          const raw = text(result);
          const parsed = classify(raw);
          const units = get('unit');
          const ranges = get('range');
          const flags = get('flag');
          const reasons: ReviewReason[] = [];
          if (ambiguous.length) reasons.push('ambiguous_row_pairing');
          if (parsed.kind === 'unparsed') reasons.push('unreadable_source');
          if (results.length > 1 && !c.resultColumn)
            reasons.push('multiple_result_columns');
          if (!c.date && results.length > 1) reasons.push('unknown_date_scope');
          if (page.route !== 'native' && !page.render_ref)
            reasons.push('unreadable_source');
          reasons.push('quality_profile_unvalidated');
          const unit = text(units) || panel.sharedUnit;
          const evidence = {
            test: labels.map((t) => t.token_id),
            result: result.map((t) => t.token_id),
            unit: units.map((t) => t.token_id),
            range: ranges.map((t) => t.token_id),
            flag: flags.map((t) => t.token_id),
          };
          const id = `${page.document_id}:${pageId}:${panelId}:${rowId}:${c.resultColumn ?? 'result'}:${c.date ?? ''}`;
          candidates.push({
            id,
            documentId: page.document_id,
            pageId,
            panelId,
            rowId,
            resultColumn: c.resultColumn ?? 'result',
            date: c.date ?? null,
            specimen: null,
            testRaw: text(labels),
            resultRaw: raw,
            resultKind: parsed.kind,
            numericDecimal: parsed.decimal,
            qualifier: parsed.qualifier,
            unitRaw: unit || null,
            rangeRaw: text(ranges) || null,
            flagRaw: text(flags) || null,
            evidence,
            sourcePolygon: boxOf([
              ...labels,
              ...result,
              ...units,
              ...ranges,
              ...flags,
            ]),
            status: 'needs_review',
            machineEligible: false,
            interpretationReady: false,
            reviewReasons: reasons,
            validatorVersion: VERSION,
            templateVersion: tpl?.version ?? null,
            readings: [{ engine: result[0].engine, raw, cropId: null }],
          });
        }
        if (ambiguous.length) {
          ambiguous.forEach((t) => unresolved.add(t.token_id));
          pageAccounted = false;
        }
        ledger.push({
          pageId,
          panelId,
          rowId,
          state: populated.every((x) => MISSING.test(text(x.tokens)))
            ? 'printed_missing'
            : 'extracted_needs_review',
          tokenIds: row.map((t) => t.token_id),
          reasons: ambiguous.length ? ['ambiguous_row_pairing'] : [],
        });
      }
    }
    status.push({
      pageId,
      accounted: pageAccounted,
      failedRegions: page.failed_regions,
    });
  }
  return {
    candidates,
    ledger,
    documentStatus:
      status.every((s) => s.accounted) && !unresolved.size
        ? 'needs_review'
        : 'partial',
    unresolvedTokenIds: [...unresolved],
    pageStatus: status,
  };
}
/** Keep every reading. A disagreement always requires human source review. */
export function applyVerification(
  candidate: LabCandidate,
  reading: { engine: string; raw: string; cropId: string | null } | null,
  timedOut = false,
): LabCandidate {
  const reasons = new Set(candidate.reviewReasons);
  if (timedOut || !reading) reasons.add('verification_timeout');
  else if (reading.raw.trim() !== candidate.resultRaw?.trim()) {
    reasons.add('reading_disagreement');
    if (
      reading.raw.replace(/[.,]/g, '') ===
      candidate.resultRaw?.replace(/[.,]/g, '')
    )
      reasons.add('ambiguous_decimal');
  }
  return {
    ...candidate,
    readings: reading ? [...candidate.readings, reading] : candidate.readings,
    reviewReasons: [...reasons],
    status: 'needs_review',
    machineEligible: false,
  };
}
