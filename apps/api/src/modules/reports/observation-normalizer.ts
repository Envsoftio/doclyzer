export interface ObservationRules {
  aliases: Map<string, { id: string; name: string }>;
  units: Map<string, { targetUnit: string; decimalExponent: number }>;
}

export const EMPTY_OBSERVATION_RULES: ObservationRules = {
  aliases: new Map(),
  units: new Map(),
};

export function labelKey(label: string): string {
  return label.trim().replace(/\s+/g, ' ').toLowerCase();
}

export function unitKey(unit: string): string {
  return unit.trim().replace(/\s+/g, '').toLowerCase();
}

/** Rules are approved data, not a list of test names compiled into the parser. */
export async function loadObservationRules(query: (sql: string) => Promise<unknown>): Promise<ObservationRules> {
  const aliases = await query(`SELECT a.alias_key, a.canonical_test_id, t.display_name AS canonical_name
    FROM lab_test_aliases a JOIN lab_tests t ON t.id = a.canonical_test_id`) as
    Array<{ alias_key: string; canonical_test_id: string; canonical_name: string }>;
  const units = await query(`SELECT canonical_test_id, source_unit_key, target_unit, decimal_exponent FROM lab_unit_rules`) as
    Array<{ canonical_test_id: string; source_unit_key: string; target_unit: string; decimal_exponent: number }>;
  const approvedAliases = new Map<string, { id: string; name: string }>();
  const conflictingKeys = new Set<string>();
  for (const row of aliases) {
    const key = labelKey(row.alias_key);
    if (!key) continue;
    const existing = approvedAliases.get(key);
    if (existing && existing.id !== row.canonical_test_id) {
      conflictingKeys.add(key);
      approvedAliases.delete(key);
    } else if (!conflictingKeys.has(key)) {
      approvedAliases.set(key, { id: row.canonical_test_id, name: row.canonical_name });
    }
  }

  return {
    aliases: approvedAliases,
    units: new Map(units.map((row) => [`${row.canonical_test_id}\u0000${row.source_unit_key}`,
      { targetUnit: row.target_unit, decimalExponent: row.decimal_exponent }])),
  };
}

export interface NormalizedObservation {
  canonicalTestId: string | null;
  parsedNumericValue: string | null;
  normalizedNumericValue: string | null;
  comparisonQualifier: 'exact' | 'lt' | 'lte' | 'gt' | 'gte' | null;
  resultKind: 'numeric' | 'qualified' | 'qualitative' | 'ambiguous';
  normalizedUnit: string | null;
  reviewState: 'unreviewed' | 'needs_review' | 'corrected';
}

export function canonicalTest(label: string, rules: ObservationRules = EMPTY_OBSERVATION_RULES): { id: string; name: string } | null {
  return rules.aliases.get(labelKey(label)) ?? null;
}

function exactDecimal(text: string): string | null {
  const trimmed = text.trim();
  const grouped = /^[+-]?\d{1,3}(?:,\d{3})+(?:\.\d+)?$/.test(trimmed);
  const plain = /^[+-]?(?:\d+(?:\.\d+)?|\.\d+)$/.test(trimmed);
  if (!grouped && !plain) return null;
  const decimal = trimmed.replaceAll(',', '').replace(/^\+/, '');
  // Reject values that cannot be represented as a finite chart number; raw text remains intact.
  return Number.isFinite(Number(decimal)) ? decimal : null;
}

function scaleDecimal(value: string, exponent: number): string {
  const negative = value.startsWith('-');
  const digits = negative ? value.slice(1) : value;
  const [integer, fraction = ''] = digits.split('.');
  const joined = integer + fraction;
  const point = integer.length + exponent;
  const shifted = point <= 0 ? `0.${'0'.repeat(-point)}${joined}`
    : point >= joined.length ? `${joined}${'0'.repeat(point - joined.length)}`
    : `${joined.slice(0, point)}.${joined.slice(point)}`;
  return `${negative ? '-' : ''}${shifted}`;
}

export function normalizeObservation(input: {
  parameterName: string;
  value: string;
  unit: string | null;
  corrected?: boolean;
}, rules: ObservationRules = EMPTY_OBSERVATION_RULES): NormalizedObservation {
  const identity = canonicalTest(input.parameterName, rules);
  const raw = input.value.trim();
  const qualified = raw.match(/^([<>]=?|≤|≥)\s*(.+)$/);
  const numeric = exactDecimal(qualified ? qualified[2] : raw);
  const qualifier = qualified?.[1] === '<' ? 'lt'
    : qualified?.[1] === '<=' || qualified?.[1] === '≤' ? 'lte'
    : qualified?.[1] === '>' ? 'gt'
    : qualified?.[1] === '>=' || qualified?.[1] === '≥' ? 'gte' : null;
  const ambiguous = numeric === null && (/^[+-]?[\d.,\s]+$/.test(raw) || qualified !== null);
  const resultKind = numeric !== null
    ? qualifier ? 'qualified' : 'numeric'
    : ambiguous ? 'ambiguous' : 'qualitative';
  const unit = unitKey(input.unit ?? '');
  const unitRule = identity ? rules.units.get(`${identity.id}\u0000${unit}`) : null;
  const normalizedUnit = unitRule?.targetUnit ?? null;
  const normalizedNumericValue = numeric === null || normalizedUnit === null
    ? null : scaleDecimal(numeric, unitRule!.decimalExponent);
  return {
    canonicalTestId: identity?.id ?? null,
    parsedNumericValue: numeric,
    normalizedNumericValue,
    comparisonQualifier: numeric === null ? null : qualifier ?? 'exact',
    resultKind,
    normalizedUnit,
    reviewState: !identity || ambiguous || !normalizedUnit
      ? 'needs_review' : input.corrected ? 'corrected' : 'unreviewed',
  };
}
