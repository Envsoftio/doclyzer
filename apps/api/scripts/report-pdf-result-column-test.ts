import assert from 'node:assert/strict';
import { extractPdfResultColumn } from '../src/modules/reports/pdf-result-column';
import type { PaddlePageOutput } from '../src/modules/reports/paddle-ocr.client';

function page(rows: Array<[string, number, number]>): PaddlePageOutput {
  return {
    text: rows.map(([text]) => text).join('\n'),
    parsedJson: {
      type: 'document',
      kids: [],
      extractionIncomplete: true,
      paddlePage: {
        page_width: 1000,
        page_height: 1200,
        dpi: 300,
        native_words: [],
        model_version: 'test',
        paddleocr_version: 'test',
        docling_parse_version: 'test',
        paddle: {
          rec_texts: rows.map(([text]) => text),
          rec_scores: rows.map(() => 0.99),
          rec_polys: rows.map(([, x, y]) => [
            [x, y],
            [x + 60, y],
            [x + 60, y + 20],
            [x, y + 20],
          ]),
        },
      },
    },
  };
}

const heading: Array<[string, number, number]> = [
  ['Test Name', 20, 100],
  ['Results', 400, 100],
  ['Units', 600, 100],
  ['Bio. Ref. Interval', 800, 100],
];
const first = page([
  ...heading,
  ['Panel', 20, 150],
  ['Apolipoprotein B', 20, 200],
  ['46.00', 400, 200],
  ['mg/dL', 600, 200],
  ['46 - 174', 800, 200],
  ['Glucose fasting', 20, 250],
  ['mg/dL', 600, 250],
  ['70 - 100', 800, 250],
  ['Interpretation', 20, 300],
  ['Risk', 20, 350],
  ['>=50', 400, 350],
]);
const second = page([
  ...heading,
  ['Troponin I', 20, 200],
  ['4', 400, 200],
  ['ng/L', 600, 200],
]);
assert.deepEqual(extractPdfResultColumn([first, second]), [
  {
    parameterName: 'Apolipoprotein B',
    value: '46.00',
    unit: 'mg/dL',
    referenceRange: '46 - 174',
  },
  {
    parameterName: 'Troponin I',
    value: '4',
    unit: 'ng/L',
    referenceRange: null,
  },
]);
assert.deepEqual(extractPdfResultColumn([first, null]), []);
const uncertain = page([...heading, ['Glucose', 20, 200], ['90', 400, 200]]);
assert.deepEqual(extractPdfResultColumn([uncertain]), []);
const splitCategory = page([
  ...heading,
  ['LDL cholesterol', 20, 200],
  ['98.48', 400, 200],
  ['mg/dL', 600, 200],
  ['Optimal: <100', 800, 200],
  ['Above Optimal: 100-129', 900, 200],
  ['High: >129', 1000, 200],
]);
assert.equal(
  extractPdfResultColumn([splitCategory])[0].referenceRange,
  'Optimal: <100 Above Optimal: 100-129 High: >129',
);
console.log(
  'PASS headed PDF results, pending cells, interpretation charts, uncertainty',
);
