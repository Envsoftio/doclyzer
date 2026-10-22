import type { PaddlePageOutput } from './paddle-ocr.client';

export interface PdfResultRow {
  parameterName: string;
  value: string;
  unit: string;
  referenceRange: string | null;
}

type Token = { text: string; x: number; y: number; height: number };

/** Read only values printed in an explicitly headed patient result column. */
export function extractPdfResultColumn(
  pages: Array<PaddlePageOutput | null>,
): PdfResultRow[] {
  if (
    !pages.length ||
    pages.some((page) => !page?.parsedJson?.paddlePage?.paddle)
  )
    return [];
  const results: PdfResultRow[] = [];
  let headedPages = 0;
  for (const page of pages) {
    const raw = page!.parsedJson.paddlePage.paddle;
    const tokens: Token[] = raw.rec_texts
      .flatMap((text, index) => {
        const polygon = raw.rec_polys[index];
        if (
          !Array.isArray(polygon) ||
          polygon.length !== 4 ||
          !polygon.every(
            (point) =>
              Array.isArray(point) &&
              point.length === 2 &&
              point.every(
                (number) =>
                  typeof number === 'number' && Number.isFinite(number),
              ),
          )
        )
          return [];
        const xs = polygon.map((point) => point[0] as number);
        const ys = polygon.map((point) => point[1] as number);
        return [
          {
            text: text.trim(),
            x: (Math.min(...xs) + Math.max(...xs)) / 2,
            y: (Math.min(...ys) + Math.max(...ys)) / 2,
            height: Math.max(...ys) - Math.min(...ys),
          },
        ];
      })
      .filter((token) => token.text);
    const header = (pattern: RegExp) =>
      tokens.find((token) => pattern.test(token.text));
    const name = header(/^test\s*name$/i);
    const result = header(/^results?$/i);
    const unit = header(/^units?$/i);
    const range = header(
      /^(?:bio\.?\s*ref\.?\s*interval|reference\s*(?:range|interval))$/i,
    );
    if (
      !name ||
      !result ||
      !unit ||
      !range ||
      !(name.x < result.x && result.x < unit.x && unit.x < range.x) ||
      Math.max(name.y, result.y, unit.y, range.y) -
        Math.min(name.y, result.y, unit.y, range.y) >
        45
    )
      return [];
    headedPages++;
    const resultLeft = (name.x + result.x) / 2;
    const resultRight = (result.x + unit.x) / 2;
    const unitLeft = resultRight;
    const unitRight = (unit.x + range.x) / 2;
    const rangeLeft = unitRight;
    const cutoff = Math.min(
      ...tokens
        .filter(
          (token) =>
            token.y > result.y &&
            /^(?:interpretation\b|treatment goals\b|recommended\s+hs\b|note\b)/i.test(
              token.text,
            ),
        )
        .map((token) => token.y),
      Infinity,
    );
    for (const value of tokens) {
      if (
        value.y <= result.y + value.height ||
        value.x < resultLeft ||
        value.x >= resultRight ||
        !/^(?:[<>]=?|[≤≥])?\s*[+-]?\d+(?:\.\d+)?$/.test(value.text)
      )
        continue;
      const sameLine = tokens.filter(
        (token) =>
          Math.abs(token.y - value.y) <= Math.max(16, value.height * 0.65),
      );
      const labels = sameLine.filter(
        (token) =>
          token.x < resultLeft &&
          token.x > name.x - 100 &&
          /[A-Za-z]/.test(token.text) &&
          !/^\(.*\)$/.test(token.text),
      );
      const units = sameLine.filter(
        (token) =>
          token.x >= unitLeft &&
          token.x < unitRight &&
          /^(?:[%µμA-Za-z][\wµμ%./^\-]*)$/.test(token.text),
      );
      if (!labels.length || !units.length) {
        // A numeric token in the result column above the explanatory text
        // could be a missed patient value. Keep the page in review.
        if (value.y < cutoff && labels.length) return [];
        continue;
      }
      const reference = sameLine
        .filter((token) => token.x >= rangeLeft)
        .sort((a, b) => a.x - b.x)
        .map((token) => token.text)
        .join(' ');
      // A later explanation can reuse the same horizontal columns. Require
      // the patient table's reference column when a result follows one.
      if (value.y >= cutoff && !reference) continue;
      results.push({
        parameterName: labels.map((token) => token.text).join(' '),
        value: value.text,
        unit: units[0].text,
        referenceRange: reference && reference.length <= 256 ? reference : null,
      });
    }
  }
  return headedPages === pages.length ? results : [];
}
