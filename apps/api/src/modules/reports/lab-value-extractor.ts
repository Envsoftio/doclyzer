const MAX_EXTRACTED_VALUES = 100;

export interface ExtractedLabValue {
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
}

function toTitleCase(s: string): string {
  return s
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim()
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

function isValidNumber(s: string): boolean {
  return !isNaN(parseFloat(s)) && isFinite(Number(s));
}

export class LabValueExtractor {
  extract(transcript: string): ExtractedLabValue[] {
    const results: ExtractedLabValue[] = [];

    // Pattern 1: "Name: value unit" — e.g. "Glucose: 95 mg/dL"
    const colonPattern = /([\w\s/()-]+):\s*([\d.]+)\s*([\w/%]+)?/g;
    // Pattern 2: pipe-delimited — "Name | value | unit"
    const pipePattern = /^([^|]+)\|\s*([\d.]+)\s*\|\s*([\w/%]*)/gm;
    // Pattern 3: tab-separated table rows — "Name\tvalue\tunit"
    const tabPattern = /^([\w\s/()-]+)\t([\d.]+)\t([\w/%]*)/gm;

    const seen = new Set<string>();

    const add = (name: string, value: string, unit: string | null): void => {
      if (results.length >= MAX_EXTRACTED_VALUES) return;
      if (!isValidNumber(value)) return;
      const cleaned = toTitleCase(name);
      if (!cleaned || cleaned.length < 2) return;
      const key = `${cleaned}:${value}`;
      if (seen.has(key)) return;
      seen.add(key);
      results.push({
        parameterName: cleaned,
        value,
        unit: unit || null,
        sampleDate: null,
      });
    };

    // Run pipe pattern first (more specific)
    let m: RegExpExecArray | null;
    while ((m = pipePattern.exec(transcript)) !== null) {
      add(m[1], m[2], m[3] || null);
    }

    // Tab pattern
    while ((m = tabPattern.exec(transcript)) !== null) {
      add(m[1], m[2], m[3] || null);
    }

    // Colon pattern (broad, run last to avoid duplicates)
    while ((m = colonPattern.exec(transcript)) !== null) {
      add(m[1], m[2], m[3] || null);
    }

    return results.slice(0, MAX_EXTRACTED_VALUES);
  }
}
