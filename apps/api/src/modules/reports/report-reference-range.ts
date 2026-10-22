/** Formatting normalization only: never supplies missing digits or bounds. */
export function normalizePrintedRangeText(raw: string): string {
  const entities: Record<string, string> = {
    lt: '<',
    gt: '>',
    le: '≤',
    ge: '≥',
    nbsp: ' ',
    amp: '&',
    ndash: '–',
    mdash: '—',
    minus: '-',
  };
  return raw
    .replace(
      /&(#x[\da-f]+|#\d+|lt|gt|le|ge|nbsp|amp|ndash|mdash|minus);/gi,
      (entity, key: string) => {
        if (!key.startsWith('#')) return entities[key.toLowerCase()] ?? entity;
        const code =
          key[1].toLowerCase() === 'x'
            ? Number.parseInt(key.slice(2), 16)
            : Number.parseInt(key.slice(1), 10);
        return code > 0 &&
          code <= 0x10ffff &&
          !(code >= 0xd800 && code <= 0xdfff)
          ? String.fromCodePoint(code)
          : entity;
      },
    )
    .replace(/<br\s*\/?\s*>/gi, ' ')
    .replace(/\\(?:r\\n|[nr])?/g, ' ')
    .replace(/\u2212/g, '-')
    .replace(/\s+/g, ' ')
    .trim();
}

const NUMBER = '-?\\d{1,5}(?:\\.\\d{1,6})?';
const INTERVAL = new RegExp(
  `^(${NUMBER})\\s*(?:[-–—]|to)\\s*(${NUMBER})$`,
  'i',
);
const LIMIT = new RegExp(`^(?:<=|>=|<|>|≤|≥)\\s*${NUMBER}$`);

type Bounds = {
  low: number;
  high: number;
  includeLow: boolean;
  includeHigh: boolean;
};

function numericBounds(value: string): Bounds | null {
  const normalized = normalizePrintedRangeText(value);
  const interval = INTERVAL.exec(normalized);
  if (interval) {
    const low = Number(interval[1]);
    const high = Number(interval[2]);
    return low <= high
      ? { low, high, includeLow: true, includeHigh: true }
      : null;
  }
  if (!LIMIT.test(normalized)) return null;
  const limit = /^(<=|>=|<|>|≤|≥)\s*(-?\d+(?:\.\d+)?)$/.exec(normalized)!;
  const bound = Number(limit[2]);
  return limit[1].startsWith('<') || limit[1] === '≤'
    ? {
        low: -Infinity,
        high: bound,
        includeLow: false,
        includeHigh: limit[1] === '<=' || limit[1] === '≤',
      }
    : {
        low: bound,
        high: Infinity,
        includeLow: limit[1] === '>=' || limit[1] === '≥',
        includeHigh: false,
      };
}

function overlaps(a: Bounds, b: Bounds): boolean {
  const low = Math.max(a.low, b.low);
  const high = Math.min(a.high, b.high);
  if (low < high) return true;
  if (low > high) return false;
  const includes = (bounds: Bounds) =>
    (low > bounds.low || bounds.includeLow) &&
    (low < bounds.high || bounds.includeHigh);
  return includes(a) && includes(b);
}

export function validPrintedNumericRange(value: unknown): boolean {
  if (typeof value !== 'string' || value.length > 64) return false;
  return numericBounds(value) != null;
}

/** Accept only complete category lists with one explicitly preferred label. */
export function preferredPrintedRange(raw: string): string | null {
  const normalized = normalizePrintedRangeText(raw);
  const labels =
    'Near or Above Optimal|Above Optimal|Near Optimal|Borderline High|Borderline Low|Very High|Very Low|Desirable|Normal|Optimal|Borderline|High|Low';
  const range = `(?:(?:<=|>=|<|>|≤|≥)\\s*${NUMBER}|${NUMBER}\\s*(?:[-–—]|to)\\s*${NUMBER})`;
  const category = new RegExp(
    `(?:Adult\\s+)?(${labels})\\s*:\\s*(${range})(?=$|[\\s;|])`,
    'gi',
  );
  const matches = [...normalized.matchAll(category)];
  if (matches.length === 0 || matches.length > 12) return null;
  // Reject unknown qualifiers, prose, incomplete categories, or extra numbers.
  if (normalized.replace(category, '').replace(/[\s;|]/g, '') !== '')
    return null;
  const bounds = matches.map((match) =>
    validPrintedNumericRange(match[2]) ? numericBounds(match[2]) : null,
  );
  if (bounds.some((item) => item == null)) return null;
  for (let i = 0; i < bounds.length; i++) {
    for (let j = i + 1; j < bounds.length; j++) {
      if (overlaps(bounds[i]!, bounds[j]!)) return null;
    }
  }
  const preferred = matches.filter((match) =>
    /^(?:Desirable|Normal|Optimal)$/i.test(match[1]),
  );
  return preferred.length === 1 ? preferred[0][2].trim() : null;
}
