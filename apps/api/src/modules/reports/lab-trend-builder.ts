import { canonicalTest, EMPTY_OBSERVATION_RULES, normalizeObservation,
  type ObservationRules } from './observation-normalizer';

export interface TrendObservationInput {
  id?: string;
  reportId: string;
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange?: string | null;
  canonicalTestId?: string | null;
  parsedNumericValue?: string | null;
  normalizedNumericValue?: string | null;
  comparisonQualifier?: string | null;
  resultKind?: string;
  normalizedUnit?: string | null;
  collectionDateSource?: string;
  reviewState?: string;
}

export interface TrendObservation {
  id?: string;
  reportId: string;
  originalValue: string;
  originalUnit: string | null;
  date: string | null;
  dateProvenance: string;
  reviewState: string;
  value: number | null;
  referenceRange: string | null;
  notPlottedReason: 'collection_date_unknown' | 'non_numeric_value' | 'collection_date_and_numeric_value_unknown' | null;
}

export interface TrendDataPoint {
  date: string;
  value: number;
  reportId: string;
  originalValue: string;
  originalUnit: string | null;
  dateProvenance: string;
  referenceRange: string | null;
}

export interface TrendParameter {
  parameterName: string;
  testId: string;
  unit?: string;
  dataPoints: TrendDataPoint[];
  observations: TrendObservation[];
  unplottedCount: number;
}

function testIdentity(label: string, rules: ObservationRules): { id: string; name: string } {
  const normalized = label.trim().replace(/\s+/g, ' ');
  return canonicalTest(normalized, rules) ?? { id: `unmapped:${normalized.toLowerCase()}`, name: normalized };
}

function validCollectionDate(raw: string | null): string | null {
  if (!raw || !/^\d{4}-\d{2}-\d{2}$/.test(raw)) return null;
  const date = new Date(`${raw}T00:00:00Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === raw
    ? raw
    : null;
}

export function buildLabTrends(
  observations: TrendObservationInput[],
  parameterName?: string,
  rules: ObservationRules = EMPTY_OBSERVATION_RULES,
): { parameters: TrendParameter[] } {
  const requestedId = parameterName ? testIdentity(parameterName, rules).id : null;
  const grouped = new Map<string, TrendParameter>();

  for (const observation of observations) {
    const identity = testIdentity(observation.parameterName, rules);
    if (!identity.id || (requestedId && identity.id !== requestedId)) continue;

    const normalized = normalizeObservation({
      parameterName: observation.parameterName,
      value: observation.value,
      unit: observation.unit,
      corrected: observation.reviewState === 'corrected',
    }, rules);
    // Unknown labels and units stay as distinct exact-label and exact-unit series.
    const unit = normalized.normalizedUnit ?? observation.unit?.trim().replace(/\s+/g, ' ') ?? null;
    const key = `${identity.id}\u0000${unit?.toLowerCase() ?? ''}`;
    let series = grouped.get(key);
    if (!series) {
      series = {
        parameterName: identity.name,
        testId: identity.id,
        ...(unit ? { unit } : {}),
        dataPoints: [],
        observations: [],
        unplottedCount: 0,
      };
      grouped.set(key, series);
    }

    const qualifier = normalized.comparisonQualifier;
    const decimal = normalized.normalizedNumericValue ?? normalized.parsedNumericValue;
    const numeric = decimal === null ? null : Number(decimal);
    const value = qualifier === 'exact' && numeric !== null && Number.isFinite(numeric)
      && Math.abs(numeric) <= Number.MAX_SAFE_INTEGER ? numeric : null;
    const date = validCollectionDate(observation.sampleDate);
    const dateProvenance = date === null ? 'unknown' : observation.collectionDateSource ?? 'extracted';
    const referenceRange = observation.referenceRange?.trim() || null;
    const notPlottedReason = date === null && value === null
      ? 'collection_date_and_numeric_value_unknown'
      : date === null ? 'collection_date_unknown'
      : value === null ? 'non_numeric_value' : null;
    series.observations.push({
      ...(observation.id ? { id: observation.id } : {}),
      reportId: observation.reportId,
      originalValue: observation.value,
      originalUnit: observation.unit,
      date,
      dateProvenance,
      reviewState: normalized.reviewState,
      value,
      referenceRange,
      notPlottedReason,
    });
    if (value === null || date === null) {
      series.unplottedCount++;
      continue;
    }
    series.dataPoints.push({
      date,
      value,
      reportId: observation.reportId,
      originalValue: observation.value,
      originalUnit: observation.unit,
      dateProvenance,
      referenceRange,
    });
  }

  const parameters = [...grouped.values()];
  for (const series of parameters) {
    series.dataPoints.sort(
      (a, b) => a.date.localeCompare(b.date) || a.reportId.localeCompare(b.reportId),
    );
    series.observations.sort((a, b) =>
      (b.date ?? '').localeCompare(a.date ?? '') ||
      a.reportId.localeCompare(b.reportId) ||
      (a.id ?? '').localeCompare(b.id ?? ''),
    );
  }
  parameters.sort(
    (a, b) =>
      a.parameterName.localeCompare(b.parameterName) ||
      (a.unit ?? '').localeCompare(b.unit ?? ''),
  );
  return { parameters };
}
