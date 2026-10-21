import assert from 'node:assert/strict';
import { PDFDocument } from 'pdf-lib';
import {
  ReportOcrCascade,
  type CascadeProgress,
  OcrServiceUnavailableError,
} from '../src/modules/reports/report-ocr-cascade';
import type { DoclingOcrClient } from '../src/modules/reports/docling-ocr.client';

function table(rows: string[][]) {
  return {
    text: rows.map((row) => row.join(' | ')).join('\n'),
    parsedJson: {
      type: 'document',
      kids: [
        {
          type: 'table',
          'page number': 1,
          rows: rows.map((row) => ({
            cells: row.map((content) => ({ content })),
          })),
        },
      ],
    },
  };
}

async function main() {
  const pdf = await PDFDocument.create();
  pdf.addPage();
  const bytes = Buffer.from(await pdf.save());
  const emptyNative = {
    text: '',
    nativeOnly: true,
    parsedJson: { type: 'document', kids: [] },
  };
  const tesseract = table([
    ['Test', 'Result', 'Unit'],
    ['Glucose', '90', 'mg/dL'],
  ]);
  let calls = 0;
  const docling = {
    parsePdf: async (part: Buffer, options: Record<string, unknown>) => {
      calls++;
      assert.equal((await PDFDocument.load(part)).getPageCount(), 1);
      assert.equal(options.engine, 'tesseract');
      assert.equal(options.forceOcr, true);
      return tesseract;
    },
  } as unknown as DoclingOcrClient;
  const saved: CascadeProgress = {};
  const cascade = new ReportOcrCascade(docling);
  const recovered = await cascade.run(
    bytes,
    new AbortController().signal,
    emptyNative,
    {
      save: async (page, engine, output) => {
        saved[String(page)] = { [engine]: output };
      },
    },
  );
  assert.equal(calls, 1);
  assert.deepEqual(
    (recovered.parsedJson as { unresolvedPages: number[] }).unresolvedPages,
    [],
  );
  assert.equal((recovered.parsedJson as { kids: unknown[] }).kids.length, 1);
  assert.match(recovered.text, /Glucose/);
  await cascade.run(bytes, new AbortController().signal, emptyNative, {
    progress: saved,
  });
  assert.equal(calls, 1, 'Tesseract page checkpoint reused');

  let autoFallbackCalls = 0;
  const playgroundResult = await new ReportOcrCascade({
    parsePdf: async () => {
      autoFallbackCalls++;
      throw new Error('Complete auto OCR must not be converted again');
    },
  } as unknown as DoclingOcrClient).run(
    bytes,
    new AbortController().signal,
    tesseract,
  );
  assert.equal(autoFallbackCalls, 0);
  assert.deepEqual(
    (playgroundResult.parsedJson as { unresolvedPages: number[] })
      .unresolvedPages,
    [],
  );

  const nativeWithOneRow = { ...tesseract, nativeOnly: true };
  const extraRow = table([
    ['Test', 'Result', 'Unit'],
    ['Glucose', '90', 'mg/dL'],
    ['Sodium', '140', 'mmol/L'],
  ]);
  const completed = await new ReportOcrCascade({
    parsePdf: async () => extraRow,
  } as unknown as DoclingOcrClient).run(
    bytes,
    new AbortController().signal,
    nativeWithOneRow,
  );
  assert.match(completed.text, /Sodium/);

  const conflicting = table([
    ['Test', 'Result', 'Unit'],
    ['Glucose', '91', 'mg/dL'],
    ['Sodium', '140', 'mmol/L'],
  ]);
  const guarded = await new ReportOcrCascade({
    parsePdf: async () => conflicting,
  } as unknown as DoclingOcrClient).run(
    bytes,
    new AbortController().signal,
    nativeWithOneRow,
  );
  assert.match(guarded.text, /Glucose \| 90/);
  assert.doesNotMatch(guarded.text, /Sodium/);

  const incomplete = {
    ...tesseract,
    parsedJson: { ...tesseract.parsedJson, extractionIncomplete: true },
  };
  const review = await new ReportOcrCascade({
    parsePdf: async () => incomplete,
  } as unknown as DoclingOcrClient).run(
    bytes,
    new AbortController().signal,
    emptyNative,
  );
  assert.deepEqual(
    (review.parsedJson as { unresolvedPages: number[] }).unresolvedPages,
    [1],
  );
  assert.deepEqual((review.parsedJson as { kids: unknown[] }).kids, []);
  assert.equal(
    (review.parsedJson as { reviewPages: Record<string, { reason: string }> })
      .reviewPages['1'].reason,
    'visual_incomplete',
  );

  const peakTable = table([
    ['Peak Name', 'Retention Time(s)', 'Absorbance', 'Area', 'Result (Area %)'],
    ['HbA0', '87.2', 'sec', '141714', '92.1'],
    ['HbA1c', '52.6', 'sec', '7440', '5.2'],
  ]);
  let peakOcrCalls = 0;
  const peakPage = await new ReportOcrCascade({
    parsePdf: async () => {
      peakOcrCalls++;
      return null;
    },
  } as unknown as DoclingOcrClient).run(
    bytes,
    new AbortController().signal,
    { ...peakTable, nativeOnly: true },
  );
  assert.equal(peakOcrCalls, 0);
  assert.deepEqual(
    (peakPage.parsedJson as { unresolvedPages: number[] }).unresolvedPages,
    [],
  );

  const unavailableDocling = {
    parsePdf: async () => null,
  } as unknown as DoclingOcrClient;
  await assert.rejects(
    new ReportOcrCascade(unavailableDocling).run(
      bytes,
      new AbortController().signal,
      emptyNative,
    ),
    OcrServiceUnavailableError,
  );
  const longPdf = await PDFDocument.create();
  for (let page = 0; page < 4; page++) longPdf.addPage();
  const longBytes = Buffer.from(await longPdf.save());
  let pageAttempt = 0;
  const isolated = await new ReportOcrCascade({
    parsePdf: async () => (++pageAttempt === 2 ? null : tesseract),
  } as unknown as DoclingOcrClient).run(
    longBytes,
    new AbortController().signal,
    emptyNative,
  );
  assert.equal(pageAttempt, 4);
  assert.deepEqual(
    (isolated.parsedJson as { unresolvedPages: number[] }).unresolvedPages,
    [2],
  );
  let unavailableCalls = 0;
  await assert.rejects(
    new ReportOcrCascade({
      parsePdf: async () => {
        unavailableCalls++;
        return null;
      },
    } as unknown as DoclingOcrClient).run(
      longBytes,
      new AbortController().signal,
      emptyNative,
    ),
    OcrServiceUnavailableError,
  );
  assert.equal(
    unavailableCalls,
    3,
    'broad outage stops before the fourth page',
  );
  const aborted = new AbortController();
  aborted.abort();
  await assert.rejects(cascade.run(bytes, aborted.signal, emptyNative));
  console.log(
    'PASS Docling/Tesseract PDF routing, reconciliation, checkpoint, review, outage, cancellation',
  );
}

void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
