import {
  adaptPaddle,
  bounds,
  type EvidenceToken,
  type PageEvidence,
} from './evidence';
import {
  parseGeometry,
  recoverStaggeredReviewCandidates,
  type LabCandidate,
} from './lab-parser';
import type { PaddlePageOutput } from '../paddle-ocr.client';
import {
  preferredPrintedRange,
  validPrintedNumericRange,
} from '../report-reference-range';

export interface AutoImageLabRow {
  parameterName: string;
  value: string;
  unit: string | null;
  referenceRange: string | null;
}

/** Accept a photographed table only when its OCR boxes form one
 * consistent, high confidence name/result alignment. This is layout based,
 * with no laboratory or report specific test names. */
export function extractAutoImageLabRows(
  page: PaddlePageOutput['parsedJson']['paddlePage'],
): AutoImageLabRow[] {
  const tokens = adaptPaddle(page.paddle, {
    documentId: 'image',
    pageId: 'image:page:1',
    engineVersion: page.paddleocr_version,
    modelVersion: page.model_version,
    preprocessingId: `render:${page.dpi}dpi`,
    workingToOriginal: [72 / page.dpi, 0, 0, 72 / page.dpi, 0, 0],
  });
  const evidence: PageEvidence = {
    document_id: 'image',
    page_id: 'image:page:1',
    page_number: 1,
    width: page.page_width,
    height: page.page_height,
    source_ref: 'original_upload',
    render_ref: 'original_upload',
    route: 'ocr',
    tokens,
    failed_regions: [],
    raw_output_ref: 'image:page:1:raw',
  };
  const parsed = parseGeometry([evidence], [evidence.page_id]);
  const candidates = parsed.candidates.length
    ? parsed.candidates
    : recoverStaggeredReviewCandidates(evidence);
  // A few isolated numbers cannot establish a whole table's alignment.
  if (candidates.length < 5) return [];
  const byId = new Map(tokens.map((token) => [token.token_id, token]));
  const used = new Set<string>();
  const offsets: number[] = [];
  const labels: number[] = [];
  const resultXs: number[] = [];
  const rows: AutoImageLabRow[] = [];
  for (const candidate of candidates) {
    if (!isEligibleRow(candidate)) return [];
    const labelIds = candidate.evidence.test;
    const resultIds = candidate.evidence.result;
    if (!labelIds.length || resultIds.length !== 1) return [];
    const rowTokens = [...labelIds, ...resultIds].map((id) => byId.get(id));
    if (rowTokens.some((token) => !token || (token.confidence_raw ?? 0) < 0.92))
      return [];
    if ([...labelIds, ...resultIds].some((id) => used.has(id))) return [];
    for (const id of [...labelIds, ...resultIds]) used.add(id);
    const labelY =
      labelIds.reduce(
        (sum, id) => sum + bounds(byId.get(id)!.polygon_original).cy,
        0,
      ) / labelIds.length;
    const resultY = bounds(byId.get(resultIds[0])!.polygon_original).cy;
    const resultX = bounds(byId.get(resultIds[0])!.polygon_original).cx;
    const labelX =
      labelIds.reduce(
        (sum, id) => sum + bounds(byId.get(id)!.polygon_original).cx,
        0,
      ) / labelIds.length;
    if (resultX <= labelX) return [];
    labels.push(labelY);
    offsets.push(resultY - labelY);
    resultXs.push(resultX);
    rows.push({
      parameterName: candidate.testRaw.trim(),
      value: candidate.resultRaw!.trim(),
      unit: null,
      referenceRange: null,
    });
  }
  const pitches = labels.slice(1).map((value, index) => value - labels[index]);
  if (pitches.some((pitch) => pitch <= 0)) return [];
  const pitch = median(pitches);
  const offset = median(offsets);
  if (
    offsets.some(
      (value) => Math.abs(value - offset) > Math.max(5, pitch * 0.25),
    )
  )
    return [];
  const resultColumn = median(resultXs);
  const columnTolerance = Math.max(12, page.page_width * 0.025);
  if (resultXs.some((x) => Math.abs(x - resultColumn) > columnTolerance))
    return [];
  const top = Math.min(...labels, ...labels.map((y, i) => y + offsets[i]));
  const bottom = Math.max(...labels, ...labels.map((y, i) => y + offsets[i]));
  const unpairedResult = tokens.some((token) => {
    const box = bounds(token.polygon_original);
    return (
      !used.has(token.token_id) &&
      box.cy >= top &&
      box.cy <= bottom &&
      Math.abs(box.cx - resultColumn) <= columnTolerance &&
      /^[<>≤≥]?\s*[+-]?(?:\d+(?:\.\d*)?|\.\d+)$/.test(token.text_raw.trim())
    );
  });
  if (unpairedResult) return [];
  attachAlignedMetadata(
    tokens,
    rows,
    labels,
    offsets,
    resultColumn,
    pitch,
    page.page_width,
  );
  return rows;
}

function attachAlignedMetadata(
  tokens: EvidenceToken[],
  rows: AutoImageLabRow[],
  labels: number[],
  offsets: number[],
  resultColumn: number,
  pitch: number,
  pageWidth: number,
): void {
  const header = tokens.find((token) =>
    /\bunits?\b.*\b(?:ref|reference|interval|range)\b/i.test(token.text_raw),
  );
  if (!header) return;
  const headerX = bounds(header.polygon_original).cx;
  if (headerX <= resultColumn) return;
  const resultYs = labels.map((y, index) => y + offsets[index]);
  const minY = Math.min(...resultYs) - pitch * 1.5;
  const maxY = Math.max(...resultYs) + pitch * 0.5;
  const halfBand = Math.max(90, pageWidth * 0.18);
  const items = tokens
    .filter((token) => {
      const box = bounds(token.polygon_original);
      return (
        token !== header &&
        box.cy >= minY &&
        box.cy <= maxY &&
        box.cx > resultColumn + 60 &&
        Math.abs(box.cx - headerX) <= halfBand
      );
    })
    .sort(
      (a, b) => bounds(a.polygon_original).cy - bounds(b.polygon_original).cy,
    );
  const groups: EvidenceToken[][] = [];
  for (const token of items) {
    const last = groups.at(-1);
    if (
      last &&
      bounds(token.polygon_original).cy - bounds(last[0].polygon_original).cy <=
        Math.max(7, pitch * 0.3)
    )
      last.push(token);
    else groups.push([token]);
  }
  // Incomplete right-hand columns must never shift units to another result.
  if (groups.length !== rows.length) return;
  const delta = median(
    groups.map(
      (group, index) => bounds(group[0].polygon_original).cy - resultYs[index],
    ),
  );
  if (
    groups.some(
      (group, index) =>
        Math.abs(
          bounds(group[0].polygon_original).cy - resultYs[index] - delta,
        ) > Math.max(9, pitch * 0.4),
    )
  )
    return;
  const rangeAtEnd = /(-?\d+(?:\.\d+)?\s*[-–]\s*-?\d+(?:\.\d+)?)$/;
  const unitPattern =
    /^(?:%|[a-zA-Zµμ][a-zA-Zµμ\d^./%-]*|\d+\^\d+\/[a-zA-Z]+)$/;
  const metadata = groups.map((group) => {
    group.sort(
      (a, b) => bounds(a.polygon_original).cx - bounds(b.polygon_original).cx,
    );
    const combined = group.map((token) => token.text_raw.trim()).join(' ');
    const categorical = /^(\S+)\s+(.+)$/.exec(combined);
    const categoryRange =
      categorical &&
      unitPattern.test(categorical[1]) &&
      preferredPrintedRange(categorical[2]) != null
        ? categorical[2]
        : null;
    const interval = categoryRange ? null : combined.match(rangeAtEnd)?.[1];
    const prefix = interval
      ? combined.slice(0, combined.length - interval.length).trim()
      : combined;
    // A numeric fragment at the end of a category list is not a range cell.
    const range =
      categoryRange ??
      (interval &&
      unitPattern.test(prefix) &&
      validPrintedNumericRange(interval)
        ? interval
        : null);
    const unit = categoryRange
      ? categorical![1]
      : unitPattern.test(prefix)
        ? prefix
        : group[0]?.text_raw.trim();
    const unitToken = group.find((token) =>
      token.text_raw.trim().startsWith(unit),
    );
    return {
      group,
      range,
      unit,
      unitToken,
      categorical: categoryRange != null,
    };
  });
  const corroboratedUnits = new Set(
    metadata
      .filter(
        ({ unit, unitToken }) =>
          unitPattern.test(unit) && (unitToken?.confidence_raw ?? 0) >= 0.9,
      )
      .map(({ unit }) => unit),
  );
  const referenceXs = metadata.flatMap(({ group }) =>
    group
      .filter(
        (token) =>
          rangeAtEnd.test(token.text_raw.trim()) &&
          (token.confidence_raw ?? 0) >= 0.9,
      )
      .map((token) => bounds(token.polygon_original).cx),
  );
  const referenceX = referenceXs.length ? median(referenceXs) : null;
  metadata.forEach(({ group, range, unit, unitToken, categorical }, index) => {
    const rangeToken = group.find((token) =>
      rangeAtEnd.test(token.text_raw.trim()),
    );
    const rangeConfidence = categorical
      ? Math.min(...group.map((token) => token.confidence_raw ?? 0))
      : (rangeToken?.confidence_raw ?? 0);
    const unitCorroborated = corroboratedUnits.has(unit);
    const correctedUnit = /^\d+~\d+\/[a-zA-Z]+$/.test(unit)
      ? unit.replace('~', '^')
      : null;
    const correctedUnitCorroborated =
      correctedUnit != null && corroboratedUnits.has(correctedUnit);
    if (
      range &&
      (rangeConfidence >= 0.9 ||
        (unitCorroborated && !categorical && rangeConfidence >= 0.88))
    )
      rows[index].referenceRange = categorical
        ? range
        : range.replace(/\s+/g, '');
    if (!range && referenceX != null && group.length > 1) {
      const last = group.at(-1)!;
      const text = last.text_raw.trim();
      if (
        /^\d+(?:\.\d+)?$/.test(text) &&
        (last.confidence_raw ?? 0) >= 0.85 &&
        Math.abs(bounds(last.polygon_original).cx - referenceX) <=
          Math.max(24, pitch) &&
        bounds(last.polygon_original).cx >
          bounds(group[0].polygon_original).cx + 20
      )
        rows[index].referenceRange = text;
    }
    if (
      unitPattern.test(unit) &&
      ((unitToken?.confidence_raw ?? 0) >= 0.9 ||
        (unitCorroborated && (unitToken?.confidence_raw ?? 0) >= 0.87) ||
        (['fl', 'pg', '%'].includes(unit.toLowerCase()) &&
          (unitToken?.confidence_raw ?? 0) >= 0.6 &&
          rows[index].referenceRange != null))
    )
      rows[index].unit = unit;
    else if (
      correctedUnitCorroborated &&
      (unitToken?.confidence_raw ?? 0) >= 0.8
    )
      rows[index].unit = correctedUnit;
  });
}

function isEligibleRow(candidate: LabCandidate): boolean {
  return (
    candidate.resultKind === 'numeric' &&
    Boolean(candidate.numericDecimal) &&
    Boolean(candidate.testRaw.trim()) &&
    !/^(?:remarks?|notes?|comments?|interpretation|method)$/i.test(
      candidate.testRaw.trim(),
    )
  );
}

function median(values: number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2
    ? sorted[middle]
    : (sorted[middle - 1] + sorted[middle]) / 2;
}
