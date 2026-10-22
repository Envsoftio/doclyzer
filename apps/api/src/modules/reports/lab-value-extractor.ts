import {
  preferredPrintedRange,
  validPrintedNumericRange,
} from './report-reference-range';

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
    rawValue?: string;
    reportedFlag?: string;
    sourcePage?: string;
    sourceRegion?: string;
    extractionEngine?: string;
  };
}

function cleanName(s: string): string {
  return s.replace(/\s+/g, ' ').trim();
}

function isCategoryRangeLine(text: string): boolean {
  const match = text.match(/^[A-Za-z][A-Za-z /()_-]{0,60}:\s*(.+)$/);
  return Boolean(match && validPrintedNumericRange(match[1]));
}

function printedRange(text: string | undefined): string | undefined {
  const value = text?.trim();
  if (!value) return undefined;
  if (
    validPrintedNumericRange(value) ||
    isCategoryRangeLine(value) ||
    preferredPrintedRange(value)
  )
    return value;
  return undefined;
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
    'optimal',
    'above optimal',
    'near optimal',
    'near or above optimal',
    'normal',
    'borderline',
    'borderline high',
    'borderline low',
    'high',
    'very high',
    'very low',
    'low',
    'desirable',
  ].includes(n);
}

export class LabValueExtractor {
  extract(transcript: string): ExtractedLabValue[] {
    const results: ExtractedLabValue[] = [];
    const normalized = transcript
      .replace(/\r\n/g, '\n')
      // Markdown tables use HTML breaks inside one reference cell.
      .replace(/^.*\|.*$/gm, (line) => line.replace(/<br\s*\/?\s*>/gi, '; '))
      .replace(/<br\s*\/?\s*>/gi, '\n')
      .replace(/&(?:nbsp|#32|#x20);/gi, ' ')
      .replace(/&lt;/gi, '<')
      .replace(/&gt;/gi, '>')
      .replace(/\*\*/g, '')
      .replace(/\\\n/g, '\n')
      .replace(/ +/g, ' ')
      .trim();

    // Name comes from the row itself; no analyte vocabulary is required.
    const colonPattern =
      /(^|\n)[ \t]*([A-Za-z][A-Za-z0-9 /(),._-]{1,80})[ \t]*:[ \t]*((?:[<>]=?|[≤≥])?[ \t]*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*((?:\d+\^\d+\/[A-Za-zµμ]+|[A-Za-zµμ/%][A-Za-zµμ/%^0-9._-]*))?(?:[ \t]+([^\n]+))?(?=\n|$)/g;
    const colonRowPattern = new RegExp(colonPattern.source);
    // Pattern 2: pipe-delimited tables (supports markdown rows with leading/trailing pipes)
    const pipePattern =
      /^[ \t]*\|?[ \t]*([^|\n]{2,90})[ \t]*\|[ \t]*((?:[<>]=?|[≤≥])?[ \t]*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*\|[ \t]*([^|\n]{0,40})(?:\|([^|\n]*))?\|?[ \t]*$/gm;
    // Pattern 3: tab-separated table rows — "Name\tvalue\tunit"
    const tabPattern =
      /^([A-Za-z][A-Za-z0-9 /(),._-]{1,80})\t((?:[<>]=?|[≤≥])?[ \t]*[-+]?\d[\d,]*(?:\.\d+)?)\t([A-Za-zµμ/%^0-9._-]*)(?:\t([^\n]*))?/gm;

    const linePattern =
      /^([A-Za-z][A-Za-z0-9 /(),._%-]{2,90}?)[ \t]+((?:[<>]=?|[≤≥])?[ \t]*[-+]?\d[\d,]*(?:\.\d+)?)[ \t]*((?:\d+\^\d+\/[A-Za-zµμ]+|[A-Za-zµμ/%][A-Za-zµμ/%^0-9._-]{0,20}))?(?:[ \t]+([^\n]*))?$/gm;

    const seen = new Map<string, ExtractedLabValue>();

    const add = (
      name: string,
      value: string,
      unit: string | null,
      referenceRange?: string,
      method?: string,
    ): void => {
      const cleaned = cleanName(name);
      if (!cleaned || cleaned.length < 2) return;
      if (isLikelyNoiseName(cleaned)) return;
      const normalizedValue = observedNumber(value);
      if (!normalizedValue) return;
      const key = JSON.stringify([cleaned, normalizedValue, unit || null]);
      const previous = seen.get(key);
      if (previous) {
        if (!previous.referenceRange && referenceRange)
          previous.referenceRange = referenceRange.trim();
        return;
      }
      const result: ExtractedLabValue = {
        parameterName: cleaned,
        value: normalizedValue,
        unit: unit || null,
        sampleDate: null,
        ...(referenceRange?.trim()
          ? { referenceRange: referenceRange.trim() }
          : {}),
        ...(method ? { identityEvidence: { method } } : {}),
      };
      seen.set(key, result);
      results.push(result);
    };

    const rangeLines = new Set<string>();
    const lines = normalized
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);
    // Unlabelled OCR blocks keep a value, unit and printed range on adjacent
    // lines. Require the complete block so a result cannot borrow a later
    // test's interval or an unrelated explanatory number.
    for (let i = 0; i < lines.length; i++) {
      const name = lines[i];
      if (!/^[A-Za-z][A-Za-z0-9 /(),._-]{1,80}$/.test(name)) continue;
      if (isLikelyNoiseName(name) || /^method\b/i.test(name)) continue;
      let valueIndex = i + 1;
      const method = lines[valueIndex]?.match(/^Method\s*:\s*(.+)$/i)?.[1];
      if (method) valueIndex++;
      const value = lines[valueIndex];
      const unit = lines[valueIndex + 1];
      const firstRange = printedRange(lines[valueIndex + 2]);
      if (
        !value ||
        observedNumber(value) === null ||
        !unit ||
        !/^(?:\d+\^\d+\/[A-Za-zµμ]+|[A-Za-zµμ/%][A-Za-zµμ/%^0-9._-]{0,30})$/.test(
          unit,
        ) ||
        !firstRange
      )
        continue;
      const ranges = [firstRange];
      if (isCategoryRangeLine(firstRange)) {
        let end = valueIndex + 3;
        // Keep unreadable/unknown continuation categories as source evidence;
        // dropping one would turn a partial category list into a clear range.
        while (
          end < lines.length &&
          /^[A-Za-z][A-Za-z /()_-]{0,60}:/.test(lines[end])
        ) {
          // A following colon-style test with its own value/unit starts a new
          // observation, even when the preceding reference list is vertical.
          const nextResult = colonRowPattern.exec(lines[end]);
          if (
            !isCategoryRangeLine(lines[end]) &&
            nextResult?.[4] &&
            !isLikelyNoiseName(nextResult[2])
          )
            break;
          ranges.push(lines[end++]);
        }
      }
      ranges.forEach((range) => rangeLines.add(range));
      add(name, value, unit, ranges.join('\n'), method);
    }
    // Run pipe pattern first (more specific)
    let m: RegExpExecArray | null;
    while ((m = pipePattern.exec(normalized)) !== null) {
      const unit = (m[3] ?? '').replace(/\s+/g, ' ').trim();
      add(m[1], m[2], unit || null, m[4]);
    }

    // Tab pattern
    while ((m = tabPattern.exec(normalized)) !== null) {
      add(m[1], m[2], m[3] || null, m[4]);
    }

    // Generic line pattern for markdown/text rows — "Name 12.2 g/dL ..."
    const inlineRows = new Set<string>();
    while ((m = linePattern.exec(normalized)) !== null) {
      inlineRows.add(m[0].trim());
      add(m[1], m[2], m[3] || null, printedRange(m[4]));
    }

    // A colon in an already parsed reference category is not a second result.
    while ((m = colonPattern.exec(normalized)) !== null) {
      if (rangeLines.has(m[0].trim()) || inlineRows.has(m[0].trim())) continue;
      add(m[2], m[3], m[4] || null, printedRange(m[5]));
    }

    // Labelled vertical OCR blocks:
    // INVESTIGATION -> <name> -> RESULTS -> <value> -> UOM -> <unit>
    for (let i = 0; i < lines.length; i++) {
      if (!/^investigation$/i.test(lines[i])) continue;
      const name = lines[i + 1] ?? '';
      if (!name || /^results$/i.test(name) || isLikelyNoiseName(name)) continue;

      let value: string | null = null;
      let unit: string | null = null;
      let referenceRange: string | undefined;
      for (let j = i + 2; j < Math.min(i + 12, lines.length); j++) {
        if (/^investigation$/i.test(lines[j])) break;
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
        if (/^(?:reference|normal) (?:range|interval)$/i.test(lines[j])) {
          referenceRange = printedRange(lines[j + 1]);
        }
      }
      if (value) {
        add(name, value, unit, referenceRange);
      }
    }

    return results;
  }
}
