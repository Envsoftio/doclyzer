type SavedResult = {
  parameterName: string;
  value: string;
  unit?: string | null;
};

type ResultSelection = {
  parameterName?: unknown;
  value?: unknown;
  unit?: unknown;
};

/** Only select a value that is already stored in the user's report. */
export function selectStoredResult<T extends SavedResult>(
  rows: T[],
  selection: ResultSelection | undefined,
): T | undefined {
  if (
    typeof selection?.parameterName !== 'string' ||
    typeof selection.value !== 'string' ||
    selection.parameterName.trim().length === 0 ||
    selection.value.trim().length === 0
  ) {
    return undefined;
  }
  const name = selection.parameterName.trim().toLowerCase();
  const value = selection.value.trim();
  const candidates = rows.filter(
    (row) =>
      row.parameterName.trim().toLowerCase() === name &&
      row.value.trim() === value,
  );
  if (candidates.length === 0) return undefined;
  const selectedUnit =
    typeof selection.unit === 'string' ? selection.unit.trim() : '';
  const exact = candidates.find(
    (row) => (row.unit ?? '').trim() === selectedUnit,
  );
  if (exact) return exact;
  return candidates.length === 1 ? candidates[0] : undefined;
}
