/** PaddleOCR-VL table HTML is a prediction. Its box covers the table, not cells. */
export interface VlTableCandidate {
  id: string;
  page: number;
  table: number;
  row: number;
  testRaw: string;
  resultRaw: string | null;
  unitRaw: string | null;
  rangeRaw: string | null;
  tableBox: [number, number, number, number];
  pageWidth: number;
  pageHeight: number;
  status: 'needs_review';
  reviewReasons: string[];
  machineEligible: false;
  sourcePolygon?: [number, number][];
  evidence?: Record<string, string[]>;
  readings?: Array<{ engine: string; raw: string; cropId: string | null }>;
}

function decode(value: string): string {
  return value.replace(/&(?:amp|lt|gt|quot|#39|nbsp|#(\d+)|#x([\da-f]+));/gi, (full, decimal, hex) => {
    const named: Record<string, string> = { '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&#39;': "'", '&nbsp;': ' ' };
    if (named[full.toLowerCase()]) return named[full.toLowerCase()];
    const code = Number.parseInt(decimal ?? hex, hex ? 16 : 10);
    return Number.isFinite(code) && code > 0 && code <= 0x10ffff ? String.fromCodePoint(code) : full;
  }).replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
}

function cells(row: string): string[] | null {
  const found = [...row.matchAll(/<(td|th)\b([^>]*)>([\s\S]*?)<\/\1>/gi)];
  if (!found.length || found.length > 12) return null;
  if (found.some((cell) => /\b(?:rowspan|colspan)\s*=\s*["']?(?!1\b)/i.test(cell[2]))) return null;
  return found.map((cell) => decode(cell[3]));
}

function role(value: string): 'test' | 'result' | 'unit' | 'range' | null {
  const normalized = value.toLowerCase().replace(/[^a-z ]/g, ' ').replace(/\s+/g, ' ').trim();
  if (/^(test name|test|investigation|parameter|analyte)$/.test(normalized)) return 'test';
  if (/^(obtained value|observed value|result|value)$/.test(normalized)) return 'result';
  if (/^(unit|units|uom)$/.test(normalized)) return 'unit';
  if (/^(reference range|reference interval|bio ref intervals age gender specific|bio ref interval|normal range)$/.test(normalized)) return 'range';
  return null;
}

export function parseVlTablePage(raw: unknown, page: number): VlTableCandidate[] {
  if (!raw || typeof raw !== 'object') throw new Error('VL result is not an object');
  const blocks = (raw as { parsing_res_list?: unknown }).parsing_res_list;
  const width = (raw as { width?: unknown }).width;
  const height = (raw as { height?: unknown }).height;
  if (typeof width !== 'number' || typeof height !== 'number' || width <= 0 || height <= 0) throw new Error('Invalid VL page dimensions');
  if (!Array.isArray(blocks) || blocks.length > 500) throw new Error('Invalid VL block list');
  const candidates: VlTableCandidate[] = [];
  blocks.forEach((block, table) => {
    if (!block || block.block_label !== 'table' || typeof block.block_content !== 'string') return;
    const box = block.block_bbox;
    if (!Array.isArray(box) || box.length !== 4 || !box.every((x: unknown) => typeof x === 'number' && Number.isFinite(x)) ||
      box[0] < 0 || box[1] < 0 || box[2] > width || box[3] > height || box[2] <= box[0] || box[3] <= box[1]) return;
    const html = block.block_content;
    if (html.length > 250_000) return;
    const rows = [...html.matchAll(/<tr\b[^>]*>([\s\S]*?)<\/tr>/gi)];
    if (rows.length > 500) return;
    let columns: { test: number; result: number; unit: number; range: number } | null = null;
    rows.forEach((match, row) => {
      const values = cells(match[1]);
      if (!values) return;
      const labels = values.map(role);
      const test = labels.indexOf('test');
      const result = labels.indexOf('result');
      if (test >= 0 && result >= 0) {
        // Repeated or multiple result headings have no safe single-column mapping.
        columns = labels.filter((x) => x === 'result').length === 1 && labels.filter((x) => x === 'test').length === 1
          ? { test, result, unit: labels.indexOf('unit'), range: labels.indexOf('range') }
          : null;
        return;
      }
      if (!columns || values.length <= Math.max(columns.test, columns.result)) return;
      const testRaw = values[columns.test];
      const resultRaw = values[columns.result] || null;
      if (!testRaw || role(testRaw)) return;
      // A label-only row is a section heading, not a printed missing result.
      const testIndex = columns.test;
      if (!resultRaw && values.every((value, index) => index === testIndex || !value)) return;
      const unitRaw = columns.unit >= 0 ? values[columns.unit] || null : null;
      const rangeRaw = columns.range >= 0 ? values[columns.range] || null : null;
      candidates.push({
        id: `p${page}-t${table}-r${row}`, page, table, row, testRaw, resultRaw,
        unitRaw, rangeRaw, tableBox: box as [number, number, number, number], pageWidth: width, pageHeight: height,
        status: 'needs_review', reviewReasons: [
          'table_block_only_source', 'source_confirmation_required',
          ...(resultRaw ? [] : ['missing_result']),
        ],
        machineEligible: false,
      });
    });
  });
  return candidates;
}
