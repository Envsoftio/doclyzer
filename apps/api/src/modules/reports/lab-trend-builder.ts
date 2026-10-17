export interface TrendObservationInput {
  id?: string;
  reportId: string;
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange?: string | null;
}

export interface TrendObservation {
  id?: string;
  reportId: string;
  originalValue: string;
  date: string | null;
  dateProvenance: 'collection' | 'unknown';
  value: number | null;
  referenceRange: string | null;
  notPlottedReason: 'collection_date_unknown' | 'non_numeric_value' | 'collection_date_and_numeric_value_unknown' | null;
}

export interface TrendDataPoint {
  date: string;
  value: number;
  reportId: string;
  originalValue: string;
  dateProvenance: 'collection';
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

const APPROVED_ALIASES: Record<string, { id: string; name: string }> = {
  hb: { id: 'hemoglobin', name: 'Hemoglobin' },
  hgb: { id: 'hemoglobin', name: 'Hemoglobin' },
  haemoglobin: { id: 'hemoglobin', name: 'Hemoglobin' },
  hemoglobin: { id: 'hemoglobin', name: 'Hemoglobin' },
  hba1c: { id: 'hba1c', name: 'HbA1c' },
};

function testIdentity(label: string): { id: string; name: string } {
  const normalized = label.trim().replace(/\s+/g, ' ');
  const key = normalized.toLowerCase();
  return APPROVED_ALIASES[key] ?? { id: key, name: normalized };
}

function parseExactNumber(raw: string): number | null {
  const text = raw.trim();
  // Commas are accepted only as three-digit grouping, never as a decimal guess.
  const grouped = /^[+-]?\d{1,3}(?:,\d{3})+(?:\.\d+)?$/.test(text);
  const plain = /^[+-]?(?:\d+(?:\.\d+)?|\.\d+)$/.test(text);
  if (!grouped && !plain) return null;
  const value = Number(text.replaceAll(',', ''));
  return Number.isFinite(value) ? value : null;
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
): { parameters: TrendParameter[] } {
  const requestedId = parameterName ? testIdentity(parameterName).id : null;
  const grouped = new Map<string, TrendParameter>();

  for (const observation of observations) {
    const identity = testIdentity(observation.parameterName);
    if (!identity.id || (requestedId && identity.id !== requestedId)) continue;

    // No conversion is assumed. Even an unknown unit is a distinct series.
    const unit = observation.unit?.trim().replace(/\s+/g, ' ') || null;
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

    const value = parseExactNumber(observation.value);
    const date = validCollectionDate(observation.sampleDate);
    const referenceRange = observation.referenceRange?.trim() || null;
    const notPlottedReason = date === null && value === null
      ? 'collection_date_and_numeric_value_unknown'
      : date === null ? 'collection_date_unknown'
      : value === null ? 'non_numeric_value' : null;
    series.observations.push({
      ...(observation.id ? { id: observation.id } : {}),
      reportId: observation.reportId,
      originalValue: observation.value,
      date,
      dateProvenance: date === null ? 'unknown' : 'collection',
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
      dateProvenance: 'collection',
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
