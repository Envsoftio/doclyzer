export interface ExtractedLabValue {
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange?: string | null;
  isAbnormal?: boolean | null;
  identityEvidence?: {
    panelName?: string;
    specimen?: string;
    method?: string;
    testCode?: string;
    sourceText?: string;
  };
}

function cleanName(s: string): string {
  return s.replace(/\s+/g, ' ').trim();
}

function observedNumber(raw: string): string | null {
  const value = raw.trim().replace(/\s+/g, ' ');
  // Keep the source notation. Decimal commas and comparison operators require
  // review downstream; converting them here would invent a precise value.
  return /^(?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?$/.test(value)
    ? value
    : null;
}

function isLikelyNoiseName(name: string): boolean {
  const n = name.toLowerCase().trim();
  return [
    'reference range',
    'normal range',
    'range',
    'result',
    'image',
    'png',
    'jpeg',
    'value',
    'unit',
    'test',
    'investigation',
    'specimen',
    'method',
    'remarks',
    'comment',
  ].includes(n);
}

export class LabValueExtractor {
  extract(transcript: string): ExtractedLabValue[] {
    const results: ExtractedLabValue[] = [];
    const normalized = transcript
      .replace(/\r\n/g, '\n')
      .replace(/ +/g, ' ')
      .trim();

    // Name comes from the row itself; no analyte vocabulary is required.
    const colonPattern =
      /(^|\n)[ \t]*([A-Za-z][A-Za-z0-9 /(),._-]{1,80})[ \t]*:[ \t]*((?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*([A-Za-zµ/%^0-9._-]+)?(?=\n|$)/g;
    // Pattern 2: pipe-delimited tables (supports markdown rows with leading/trailing pipes)
    const pipePattern =
      /^[ \t]*\|?[ \t]*([^|\n]{2,90})[ \t]*\|[ \t]*((?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*\|[ \t]*([^|\n]{0,40})(?:\|[^|\n]*)?\|?[ \t]*$/gm;
    // Pattern 3: tab-separated table rows — "Name\tvalue\tunit"
    const tabPattern =
      /^([A-Za-z][A-Za-z0-9 /(),._-]{1,80})\t((?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?)\t([A-Za-zµ/%^0-9._-]*)/gm;

    const linePattern =
      /^([A-Za-z][A-Za-z0-9 /(),._%-]{2,90})[ \t]+((?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*([A-Za-z/%µ^0-9._-]{0,20})(?:[ \t]|$)/gm;

    const seen = new Set<string>();

    const add = (name: string, value: string, unit: string | null): void => {
      const cleaned = cleanName(name);
      if (!cleaned || cleaned.length < 2) return;
      if (isLikelyNoiseName(cleaned)) return;
      const normalizedValue = observedNumber(value);
      if (!normalizedValue) return;
      const key = `${cleaned}:${normalizedValue}`;
      if (seen.has(key)) return;
      seen.add(key);
      results.push({
        parameterName: cleaned,
        value: normalizedValue,
        unit: unit || null,
        sampleDate: null,
      });
    };

    // Run pipe pattern first (more specific)
    let m: RegExpExecArray | null;
    while ((m = pipePattern.exec(normalized)) !== null) {
      const unit = (m[3] ?? '').replace(/\s+/g, ' ').trim();
      add(m[1], m[2], unit || null);
    }

    // Tab pattern
    while ((m = tabPattern.exec(normalized)) !== null) {
      add(m[1], m[2], m[3] || null);
    }

    // Colon pattern (broad, run last to avoid duplicates)
    while ((m = colonPattern.exec(normalized)) !== null) {
      add(m[2], m[3], m[4] || null);
    }

    // Generic line pattern for markdown/text rows — "Name 12.2 g/dL ..."
    while ((m = linePattern.exec(normalized)) !== null) {
      add(m[1], m[2], m[3] || null);
    }

    // Pattern 5: vertical OCR blocks:
    // INVESTIGATION -> <name> -> RESULTS -> <value> -> UOM -> <unit>
    const lines = normalized
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);
    for (let i = 0; i < lines.length; i++) {
      if (!/^investigation$/i.test(lines[i])) continue;
      const name = lines[i + 1] ?? '';
      if (!name || /^results$/i.test(name) || isLikelyNoiseName(name)) continue;

      let value: string | null = null;
      let unit: string | null = null;
      for (let j = i + 2; j < Math.min(i + 12, lines.length); j++) {
        if (
          /^results$/i.test(lines[j]) &&
          lines[j + 1] &&
          observedNumber(lines[j + 1]) !== null
        ) {
          value = lines[j + 1];
        }
        if (/^uom$/i.test(lines[j]) && lines[j + 1]) {
          unit = lines[j + 1];
        }
      }
      if (value) {
        add(name, value, unit);
      }
    }

    return results;
  }
}
