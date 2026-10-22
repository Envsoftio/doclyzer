import assert from 'node:assert/strict';
import { ReportsService } from '../src/modules/reports/reports.service';
import type { PaddlePageOutput } from '../src/modules/reports/paddle-ocr.client';
import { extractAutoImageLabRows } from '../src/modules/reports/geometry/image-auto-parser';

async function main() {
  const names = ['Marker A', 'Marker B', 'Marker C', 'Marker D', 'Marker E'];
  const values = ['12.4', '4.4', '40.3', '92.1', '28.3'];
  const words = [
    { text: 'Test Name', x: 20, y: 70 },
    { text: 'Obtained Value', x: 180, y: 50 },
    { text: 'Units Bio.Ref. Intervals', x: 340, y: 35 },
    ...names.flatMap((name, index) => [
      { text: name, x: 20, y: 100 + index * 30 },
      { text: values[index], x: 180, y: 112 + index * 30 },
      { text: '% 0-100', x: 340, y: 94 + index * 30 },
    ]),
  ];
  const visual: PaddlePageOutput = {
    text: words.map((word) => word.text).join('\n'),
    parsedJson: {
      type: 'document',
      kids: [],
      extractionIncomplete: true,
      paddlePage: {
        page_width: 600,
        page_height: 800,
        dpi: 72,
        native_words: [],
        model_version: 'synthetic',
        paddleocr_version: 'synthetic',
        docling_parse_version: 'synthetic',
        paddle: {
          rec_texts: words.map((word) => word.text),
          rec_scores: words.map(() => 0.99),
          rec_polys: words.map(({ x, y }) => [
            [x, y],
            [x + 55, y],
            [x + 55, y + 12],
            [x, y + 12],
          ]),
        },
      },
    },
  };
  const service = Object.create(ReportsService.prototype) as ReportsService;
  Object.assign(service, {
    paddleOcrClient: { parseImage: async () => visual },
    labExtractor: { extract: () => [] },
    labDetailsExtractor: { extractFromTranscript: () => ({}) },
    reportRepo: { manager: { query: async () => [] } },
  });
  const output = await service.extractImageWithPaddle(
    Buffer.from('synthetic'),
    'image/jpeg',
    new AbortController().signal,
  );
  const imageJson = output.parsedJson as {
    autoImageLabRows: Array<{ parameterName: string; value: string }>;
    ocrVerificationFailed: boolean;
  };
  assert.equal(imageJson.ocrVerificationFailed, false);
  assert.equal(imageJson.autoImageLabRows.length, 5);
  const prepared = await service.prepareWorkerResult(
    '00000000-0000-4000-8000-000000000001',
    'image',
    output.text,
    output.parsedJson,
  );
  assert.equal(prepared.outcome, 'ready');
  type Saved = {
    parameterName: string;
    value: string;
    unit: string | null;
    referenceRange: string | null;
  };
  let saved: Saved[] = [];
  const repository = {
    delete: async () => {},
    create: (row: Saved) => row,
    save: async (rows: Saved[]) => {
      saved = rows;
    },
  };
  await prepared.persist({
    query: async () => [],
    getRepository: () => repository,
  } as never);
  assert.deepEqual(
    saved.map((row) => [
      row.parameterName,
      row.value,
      row.unit,
      row.referenceRange,
    ]),
    names.map((name, index) => [name, values[index], '%', '0-100']),
  );
  const corroborated = structuredClone(visual.parsedJson.paddlePage);
  corroborated.paddle.rec_texts[11] = '%0-100';
  corroborated.paddle.rec_scores[11] = 0.89;
  const corroboratedRows = extractAutoImageLabRows(corroborated);
  assert.equal(corroboratedRows[2].unit, '%');
  assert.equal(corroboratedRows[2].referenceRange, '0-100');
  const categorical = structuredClone(visual.parsedJson.paddlePage);
  const categoryText = 'Optimal: <100 Above Optimal: 100-129 High: >129';
  categorical.paddle.rec_texts[11] = `% ${categoryText}`;
  const categoricalRows = extractAutoImageLabRows(categorical);
  assert.equal(categoricalRows[2].referenceRange, categoryText);
  const invalidCategory = structuredClone(categorical);
  invalidCategory.paddle.rec_texts[11] =
    '% Optimal: <100 Unknown category: 100-129 High: >129';
  assert.equal(extractAutoImageLabRows(invalidCategory)[2].referenceRange, null);
  corroborated.paddle.rec_texts[14] = 'fl 0-100';
  corroborated.paddle.rec_scores[14] = 0.88;
  const uncorroboratedRows = extractAutoImageLabRows(corroborated);
  assert.equal(uncorroboratedRows[3].unit, null);
  assert.equal(uncorroboratedRows[3].referenceRange, null);
  const fallbackWords = [
    ...words.slice(0, 3),
    ...names.flatMap((name, index) => [
      { text: name, x: 20, y: 100 + index * 30 },
      { text: values[index], x: 180, y: 112 + index * 30 },
      {
        text: index === 2 ? 'fl' : index === 3 ? '10~9/L' : index === 4 ? '%' : '10^9/L',
        x: 340,
        y: 94 + index * 30,
      },
      { text: index === 4 ? '00' : '0-100', x: 410, y: 94 + index * 30 },
    ]),
  ];
  const fallback = structuredClone(visual.parsedJson.paddlePage);
  fallback.paddle.rec_texts = fallbackWords.map((word) => word.text);
  fallback.paddle.rec_scores = fallbackWords.map((_, index) =>
    index === 13 ? 0.65 : index === 17 ? 0.85 : index === 22 ? 0.88 : 0.99,
  );
  fallback.paddle.rec_polys = fallbackWords.map(({ x, y }) => [
    [x, y],
    [x + 55, y],
    [x + 55, y + 12],
    [x, y + 12],
  ]);
  const fallbackRows = extractAutoImageLabRows(fallback);
  assert.equal(fallbackRows[2].unit, 'fl');
  assert.equal(fallbackRows[3].unit, '10^9/L');
  assert.equal(fallbackRows[4].referenceRange, '00');
  console.log('PASS clear image table becomes ready with five saved values');
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
