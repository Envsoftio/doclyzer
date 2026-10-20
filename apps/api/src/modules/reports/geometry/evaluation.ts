import type { LabCandidate } from './lab-parser';

/** Annotators must identify the occurrence and location, not just the analyte. */
export interface GroundTruthObservation {
  documentId: string;
  pageId: string;
  panelId: string;
  rowId: string;
  resultColumn: string;
  date: string | null;
  specimen: string | null;
  test: string;
  result: string | null;
  unit: string | null;
  range: string | null;
  flag: string | null;
}
export interface EvaluationCase {
  documentId: string;
  truth: GroundTruthObservation[];
  predictions: LabCandidate[];
  pages: Array<{
    pageId: string;
    queueDelayMs: number | null;
    processingMs: number | null;
    timedOut: boolean;
    failed: boolean;
    peakContainerBytes: number | null;
  }>;
  documentProcessingMs: number | null;
  coldStart: boolean;
}
function key(row: GroundTruthObservation | LabCandidate) {
  const doc = 'documentId' in row ? row.documentId : '';
  const page = 'pageId' in row ? row.pageId : '';
  return [
    doc,
    page,
    row.panelId,
    row.rowId,
    row.resultColumn,
    row.date ?? '',
    row.specimen ?? '',
  ].join('\u0000');
}
function quantile(values: number[], p: number): number | null {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.ceil(p * sorted.length) - 1];
}
export function evaluate(cases: EvaluationCase[]) {
  let truthCount = 0,
    predicted = 0,
    missed = 0,
    wrongValue = 0,
    wrongUnit = 0,
    wrongPairing = 0;
  let eligible = 0,
    eligibleErrors = 0,
    needsReview = 0,
    timeouts = 0,
    failures = 0;
  const pageMs: number[] = [],
    documentMs: number[] = [],
    queueMs: number[] = [],
    coldStartMs: number[] = [];
  const peakBytes: number[] = [];
  for (const sample of cases) {
    const truth = new Map(sample.truth.map((r) => [key(r), r]));
    const matched = new Set<string>();
    truthCount += sample.truth.length;
    predicted += sample.predictions.length;
    for (const p of sample.predictions) {
      const k = key(p);
      const t = truth.get(k);
      const pairingError = !t || matched.has(k);
      if (pairingError) wrongPairing++;
      else {
        matched.add(k);
        if (p.testRaw !== t.test || p.resultRaw !== t.result) wrongValue++;
        if (p.unitRaw !== t.unit) wrongUnit++;
      }
      if (p.machineEligible) {
        eligible++;
        if (
          pairingError ||
          p.testRaw !== t?.test ||
          p.resultRaw !== t?.result ||
          p.unitRaw !== t?.unit
        )
          eligibleErrors++;
      } else needsReview++;
    }
    missed += sample.truth.length - matched.size;
    for (const p of sample.pages) {
      if (p.queueDelayMs !== null) queueMs.push(p.queueDelayMs);
      if (p.processingMs !== null) pageMs.push(p.processingMs);
      if (p.peakContainerBytes !== null) peakBytes.push(p.peakContainerBytes);
      if (p.timedOut) timeouts++;
      if (p.failed) failures++;
    }
    if (sample.documentProcessingMs !== null) {
      documentMs.push(sample.documentProcessingMs);
      if (sample.coldStart) coldStartMs.push(sample.documentProcessingMs);
    }
  }
  return {
    documents: cases.length,
    truthCount,
    predicted,
    missed,
    wrongValue,
    wrongUnit,
    wrongPairing,
    eligible,
    eligibleErrors,
    eligibleCoverage: truthCount ? eligible / truthCount : null,
    reviewRate: predicted ? needsReview / predicted : null,
    timeouts,
    failures,
    pageLatencyMs: { p50: quantile(pageMs, 0.5), p95: quantile(pageMs, 0.95) },
    documentLatencyMs: {
      p50: quantile(documentMs, 0.5),
      p95: quantile(documentMs, 0.95),
    },
    queueDelayMs: { p50: quantile(queueMs, 0.5), p95: quantile(queueMs, 0.95) },
    coldStartMs,
    peakContainerBytes: peakBytes.length ? Math.max(...peakBytes) : null,
  };
}
