import assert from 'node:assert/strict';
import { PDFDocument } from 'pdf-lib';
import {
  ReportOcrCascade,
  CascadeProgress,
} from '../src/modules/reports/report-ocr-cascade';
import { DoclingOcrClient } from '../src/modules/reports/docling-ocr.client';
import { UnlimitedOcrClient } from '../src/modules/reports/unlimited-ocr.client';
import { ReportsService } from '../src/modules/reports/reports.service';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
const doc = (value: string, page = 1, unit = 'mg/dL', incomplete = false) => ({
  type: 'document',
  kids: [
    {
      type: 'table',
      'page number': page,
      rows: [
        ['Test Name', 'Result', 'Unit'],
        ['Glucose', value, unit],
        ...(incomplete ? [['Hemoglobin', '', 'g/dL']] : []),
      ].map((row) => ({ cells: row.map((content) => ({ content })) })),
    },
  ],
});
const out = (value = '90', unit = 'mg/dL', incomplete = false) => ({
  text: 'fixture',
  parsedJson: doc(value, 1, unit, incomplete),
});
const noDocling = {
  parsePdf: async () => {
    throw new Error('No extra Docling OCR allowed');
  },
} as unknown as DoclingOcrClient;
async function main() {
  // Exercise the actual reconciliation gate, with fabricated non-patient data.
  const single = await PDFDocument.create();
  single.addPage();
  const singleBytes = Buffer.from(await single.save());
  const evidence = (
    method: string,
    range: string,
    patient: string,
    value = '90',
    unit = 'mg/dL',
  ) => ({
    text: 'fixture',
    parsedJson: {
      type: 'document',
      kids: [
        {
          type: 'text',
          content: `Patient Information Name : ${patient} Lab Id : SYNTHETIC`,
          'page number': 1,
        },
        {
          type: 'table',
          'page number': 1,
          rows: [
            ['Test', 'Result', 'Unit', 'Reference Range'],
            [`Glucose ${method}`, value, unit, range],
          ].map((row) => ({ cells: row.map((content) => ({ content })) })),
        },
      ] as Record<string, unknown>[],
    },
  });
  for (const scenario of [
    'formatting',
    'method',
    'reference',
    'value',
    'unit',
    'patient',
    'missing-patient',
  ]) {
    const native = evidence(
      'Calculated',
      'Children :>16 Adult : 20–50',
      'Example Person',
    );
    // An unknown table requires visual verification.
    native.parsedJson.kids.push({
      type: 'table',
      'page number': 1,
      rows: [
        { cells: [{ content: 'unknown header' }] },
        { cells: [{ content: 'unknown data' }] },
      ],
    });
    const visual = evidence(
      scenario === 'method' ? 'CLIA' : 'Calculated',
      scenario === 'reference'
        ? 'Children:<16Adult:20-50'
        : 'Children:>16Adult:20-50',
      scenario === 'patient' ? 'Example Persom' : 'Example Person',
      scenario === 'value' ? '9.0' : '90',
      scenario === 'unit' ? 'mmol/L' : 'mg/dL',
    );
    if (scenario === 'missing-patient') visual.parsedJson.kids.shift();
    const result = await new ReportOcrCascade(noDocling, {
      parsePdf: async () => visual,
    } as unknown as UnlimitedOcrClient).run(
      singleBytes,
      new AbortController().signal,
      { ...native, nativeOnly: true },
    );
    const data = result.parsedJson as {
      unresolvedPages: number[];
      reviewPages: Record<string, { reason: string }>;
    };
    assert.deepEqual(
      data.unresolvedPages,
      scenario === 'formatting' ? [] : [1],
      scenario,
    );
    if (scenario.includes('patient'))
      assert.equal(data.reviewPages['1'].reason, 'patient_identity_conflict');
  }
  const pdf = await PDFDocument.create();
  for (let i = 0; i < 5; i++) pdf.addPage();
  const bytes = Buffer.from(await pdf.save());
  const initial = {
    text: 'native',
    nativeOnly: true,
    parsedJson: {
      type: 'document',
      kids: Array.from(
        { length: 5 },
        (_, i) => doc('90', i + 1, 'mg/dL', i === 0).kids,
      ).flat(),
    },
  };
  for (const scenario of [
    'success',
    'conflict',
    'unit-conflict',
    'unavailable',
    'incomplete',
  ]) {
    let calls = 0;
    const cascade = new ReportOcrCascade(noDocling, {
      parsePdf: async (part: Buffer) => {
        calls++;
        assert.equal((await PDFDocument.load(part)).getPageCount(), 1);
        if (scenario === 'unavailable') return null;
        const result = out(
          scenario === 'conflict' ? '80' : '90',
          scenario === 'unit-conflict' ? 'mmol/L' : 'mg/dL',
          scenario === 'incomplete',
        );
        if (scenario !== 'incomplete')
          result.parsedJson.kids[0].rows.push({
            cells: [
              { content: 'Hemoglobin' },
              { content: '14' },
              { content: 'g/dL' },
            ],
          });
        return result;
      },
    } as unknown as UnlimitedOcrClient);
    const result = await cascade.run(
      bytes,
      new AbortController().signal,
      initial,
    );
    const data = result.parsedJson as {
      unresolvedPages: number[];
      kids: Record<string, unknown>[];
      ocrVerificationFailed: boolean;
    };
    assert.equal(
      calls,
      1,
      'Large native report cannot bypass an incomplete page',
    );
    assert.deepEqual(
      data.unresolvedPages,
      scenario === 'success' ? [] : [1],
      scenario,
    );
    assert.equal(data.ocrVerificationFailed, scenario !== 'success');
    assert.equal(data.kids.length, scenario === 'success' ? 5 : 4);
    if (scenario === 'success') assert.equal(data.kids[0]['page number'], 1);
  }
  const saved: CascadeProgress = {};
  let calls = 0;
  const cascade = new ReportOcrCascade(noDocling, {
    parsePdf: async () => {
      calls++;
      return out();
    },
  } as unknown as UnlimitedOcrClient);
  const blank = {
    text: '',
    nativeOnly: true,
    parsedJson: { type: 'document', kids: [] },
  };
  const controller = new AbortController();
  await assert.rejects(
    cascade.run(bytes, controller.signal, blank, {
      progress: saved,
      save: async (page, engine, output) => {
        saved[String(page)] = { [engine]: output };
        controller.abort();
      },
    }),
  );
  await cascade.run(bytes, new AbortController().signal, blank, {
    progress: saved,
  });
  assert.equal(calls, 5, 'Completed page reused after interruption');
  const aborted = new AbortController();
  aborted.abort();
  await assert.rejects(cascade.run(bytes, aborted.signal, blank));
  // Legacy cache is not reused with the new model/adapter contract.
  let freshCalls = 0;
  await new ReportOcrCascade(noDocling, {
    parsePdf: async () => {
      freshCalls++;
      return out();
    },
  } as unknown as UnlimitedOcrClient).run(
    bytes,
    new AbortController().signal,
    blank,
    { progress: { '1': { surya: out() } } as unknown as CascadeProgress },
  );
  assert.equal(freshCalls, 5);
  const service = Object.assign(Object.create(ReportsService.prototype), {
    odlJsonParser: new OpenDataLoaderJsonParser(),
    logger: { log: () => {}, warn: () => {} },
  });
  const parsed = await service.extractLabValuesFromOdlJsonWithFallback({
    opendataloaderJson: { ...doc('90'), ocrVerificationFailed: true },
    reportId: 'fixture',
    trigger: 'upload',
    transcript: 'Glucose 90',
  });
  assert.equal(parsed.extractionReview.required, true);
  console.log(
    'PASS native page targeting, no large-report bypass, conflicts, missing rows, unavailable OCR, resume, legacy cache isolation, cancellation, publication gate',
  );
}
void main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
