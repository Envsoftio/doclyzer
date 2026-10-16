import assert from 'node:assert/strict';
import { ReportsService } from '../src/modules/reports/reports.service';
import { ConfigService } from '@nestjs/config';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
import { DoclingOcrClient } from '../src/modules/reports/docling-ocr.client';
import { adaptDoclingDocument } from '../src/modules/reports/docling-document-adapter';

const parser = new OpenDataLoaderJsonParser();
const table = (rows: string[][]) => ({
  type: 'document',
  kids: [
    {
      type: 'table',
      rows: rows.map((row) => ({ cells: row.map((content) => ({ content })) })),
    },
  ],
});
const native = (rows: string[][]) => ({
  schema_name: 'DoclingDocument',
  texts: [],
  pages: {},
  tables: [
    {
      data: {
        num_rows: rows.length,
        num_cols: rows[0].length,
        table_cells: rows.flatMap((row, y) =>
          row.map((text, x) => ({
            text,
            start_row_offset_idx: y,
            end_row_offset_idx: y + 1,
            start_col_offset_idx: x,
            end_col_offset_idx: x + 1,
          })),
        ),
      },
    },
  ],
});

let checks = 0;
function check(name: string, run: () => void) {
  run();
  checks++;
  console.log(`PASS ${name}`);
}
check(
  'Flag column is not a unit; reordered columns preserve associations',
  () => {
    const rows = parser.parse(
      table([
        ['Test Name', 'Ref Range', 'Flag', 'Unit', 'Result'],
        ['Glucose', '70-99', 'High', 'mg/dL', '105'],
      ]),
    ).extractedLabValues;
    assert.equal(rows.length, 1);
    assert.deepEqual(
      [rows[0].value, rows[0].unit, rows[0].referenceRange],
      ['105', 'mg/dL', '70-99'],
    );
  },
);
check(
  'Native Docling schema, sparse cells, method text, and one-test reports',
  () => {
    const rows = parser.parse(
      native([
        ['Test Name', 'Result', 'Flag', 'Unit', 'Ref Range'],
        ['Creatinine Method : Enzymatic', '0.83', '', 'mg/dL', '0.7-1.3'],
      ]),
    ).extractedLabValues;
    assert.equal(rows.length, 1);
    assert.equal(rows[0].parameterName, 'Creatinine');
    assert.equal(rows[0].unit, 'mg/dL');
  },
);
check('Interpretation tables do not become patient observations', () => {
  assert.equal(
    parser.parse(
      table([
        ['eGFR Range', 'Stage', 'Interpretation'],
        ['60-89', 'G2', 'Mildly decreased'],
      ]),
    ).extractedLabValues.length,
    0,
  );
});
check('Ambiguous multiple result columns are rejected', () => {
  assert.equal(
    parser.parse(
      table([
        ['Test Name', 'Result', 'Result', 'Unit'],
        ['Glucose', '90', '120', 'mg/dL'],
      ]),
    ).extractedLabValues.length,
    0,
  );
});
check('Merged results do not create duplicate observations', () => {
  const doc = native([
    ['Test Name', 'Result'],
    ['Glucose', '90'],
    ['Calcium', ''],
  ]);
  const cells = doc.tables[0].data.table_cells;
  cells.splice(cells.length - 1, 1);
  cells.find((c) => c.text === '90')!.end_row_offset_idx = 3;
  assert.equal(parser.parse(doc).extractedLabValues.length, 0);
});
check(
  'Comparators and thousands separators are preserved without guessing decimal commas',
  () => {
    const rows = parser.parse(
      table([
        ['Test Name', 'Result', 'Unit', 'Ref Range'],
        ['Glucose', '<=5', 'mg/dL', '3-7'],
        ['Platelet Count', '1,200', '/uL', '150-410'],
        ['Calcium', '9,4', 'mg/dL', '8.6-10.2'],
      ]),
    ).extractedLabValues;
    assert.equal(rows.length, 2);
    assert.equal(rows[0].value, '<=5');
    assert.equal(rows[0].isAbnormal, undefined);
    assert.equal(rows[1].value, '1200');
  },
);
check('Qualitative results ending in l are not truncated as Low flags', () => {
  const rows = parser.parse(
    table([
      ['Test Name', 'Result'],
      ['Urine Protein', 'Nil'],
    ]),
  ).extractedLabValues;
  assert.equal(rows[0].value, 'Nil');
});
check(
  'Explicit split method labels are rejoined; orphan method prose is rejected',
  () => {
    const result = parser.parseWithDiagnostics(
      table([
        ['Test Name', 'Result', 'Unit', 'Ref Range', ''],
        [': Enzymatic', '18', 'mg/dL', '10-20', 'Urea Method'],
        ['Haemoglobin : Colorimetric', '13', 'g/dL', '12-17', 'Method'],
        [': Enzymatic', '15', 'mg/dL', '10-20', ''],
      ]),
    );
    assert.deepEqual(
      result.extractedLabValues.map((v) => v.parameterName),
      ['Urea', 'Haemoglobin'],
    );
    assert.equal(result.diagnostics.candidateRows, 3);
    assert.equal(result.diagnostics.coverage, 0.667);
  },
);
check(
  'Unknown payloads and excessive native dimensions do not allocate a table',
  () => {
    assert.equal(parser.parse({ anything: true }).extractedLabValues.length, 0);
    const doc = native([['Test Name', 'Result']]);
    doc.tables[0].data.num_rows = 1e9;
    assert.equal(parser.parse(doc).extractedLabValues.length, 0);
  },
);
check('Top-left provenance is converted to bottom-left coordinates', () => {
  const doc = {
    ...native([['Test Name', 'Result']]),
    pages: { '1': { size: { height: 800 } } },
    texts: [
      {
        label: 'text',
        text: 'Example',
        prov: [
          {
            page_no: 1,
            bbox: { l: 10, t: 20, r: 50, b: 30, coord_origin: 'TOPLEFT' },
          },
        ],
      },
    ],
  };
  const out = adaptDoclingDocument(doc) as { kids: Record<string, unknown>[] };
  assert.deepEqual(out.kids[0]['bounding box'], [10, 780, 50, 770]);
});
check(
  'Current Docling response envelope and HTTP-200 failures are handled',
  () => {
    const client = new DoclingOcrClient(new ConfigService()) as unknown as {
      extractOutputs(input: unknown): { text: string; parsedJson?: unknown };
    };
    const doc = native([
      ['Test Name', 'Result'],
      ['Glucose', '90'],
    ]);
    const envelope = {
      status: 'success',
      document: { md_content: 'Glucose 90', json_content: doc },
    };
    assert.equal(client.extractOutputs(envelope).parsedJson, doc);
    assert.equal(client.extractOutputs(envelope).text, 'Glucose 90');
    for (const status of ['failure', 'partial_success']) {
      assert.deepEqual(client.extractOutputs({ ...envelope, status }), {
        text: '',
      });
    }
  },
);
check(
  'Spatial recovery uses same-page headers and preserves a standalone small table',
  () => {
    const text = (content: string, x: number, y: number, page = 1) => ({
      label: 'text',
      text: content,
      prov: [
        {
          page_no: page,
          bbox: {
            l: x,
            t: y,
            r: x + Math.min(content.length * 3, 100),
            b: y - 8,
            coord_origin: 'BOTTOMLEFT',
          },
        },
      ],
    });
    const doc = {
      schema_name: 'DoclingDocument',
      tables: [],
      pages: {},
      texts: [
        text('Test Name', 20, 700),
        text('Result', 250, 700),
        text('Flag Unit Ref Range', 340, 700),
        text('Vitamin B12', 20, 650),
        text('245', 250, 650),
        text('pg/mL', 390, 650),
        text('200-900', 470, 650),
        text('Calcium', 20, 600, 2),
        text('9.4', 250, 600, 2),
        text('mg/dL', 390, 600, 2),
        text('8-10', 470, 600, 2),
      ],
    };
    const rows = parser.parse(doc).extractedLabValues;
    assert.equal(rows.length, 1);
    assert.deepEqual(
      [rows[0].parameterName, rows[0].value, rows[0].unit],
      ['Vitamin B12', '245', 'pg/mL'],
    );
  },
);
check(
  'Diverse lab headers and non-scalar observations preserve meaning',
  () => {
    const rows = parser.parse(
      table([
        [
          'Reference Interval',
          'Units of Measurement',
          'Patient Result',
          'Test Description',
        ],
        ['0-5', '/hpf', '0-2', 'Urine RBC'],
        ['Negative', '', 'Not detected', 'Antigen'],
        ['<1:40', '', '1:80', 'Antibody'],
        ['Negative', '', '+++', 'Protein'],
        ['Sterile', '', 'No growth', 'Culture'],
      ]),
    ).extractedLabValues;
    assert.deepEqual(
      rows.map((r) => r.value),
      ['0-2', 'Not detected', '1:80', '+++', 'No growth'],
    );
    assert.ok(rows.every((r) => r.isAbnormal === undefined));
    assert.equal(rows[0].unit, '/hpf');
  },
);
check(
  'Historical result columns are not silently treated as current values',
  () => {
    const result = parser.parseWithDiagnostics(
      table([
        ['Test', 'Result', 'Previous Result'],
        ['Glucose', '80', '95'],
      ]),
    );
    assert.equal(result.extractedLabValues.length, 0);
    assert.equal(result.diagnostics.hasAmbiguousHeaders, true);
  },
);
console.log(`${checks} report parser regression checks passed.`);

async function checkPdfRouting() {
  const calls: boolean[] = [];
  let odlJson: unknown = { kids: [] };
  const doc = native([
    ['Test Name', 'Result', 'Unit'],
    ['Glucose', '90', 'mg/dL'],
  ]);
  const service = Object.assign(
    Object.create(ReportsService.prototype) as object,
    {
      odlJsonParser: parser,
      logger: { log: () => undefined },
      logParseQuality: () => undefined,
      evaluateParsedTranscript: (text: string) => ({ ok: Boolean(text), text }),
      openDataLoaderClient: {
        parsePdf: () =>
          Promise.resolve({ text: 'Readable text', parsedJson: odlJson }),
      },
      suryaOcrClient: { parsePdf: () => Promise.resolve(null) },
      doclingOcrClient: {
        parsePdf: (_: Buffer, options: { forceOcr: boolean }) => {
          calls.push(options.forceOcr);
          return Promise.resolve({ text: 'Glucose 90', parsedJson: doc });
        },
      },
    },
  ) as unknown as {
    parseReportBuffer(
      buffer: Buffer,
      trigger: string,
      id: string,
      source?: string,
    ): Promise<unknown>;
  };
  await service.parseReportBuffer(Buffer.from('test'), 'upload', 'synthetic');
  assert.deepEqual(
    calls,
    [false],
    'Readable text without structured rows must reach native PDF parsing',
  );
  odlJson = table([
    ['Test Name', 'Result', 'Unit'],
    ['Glucose', '90', 'mg/dL'],
  ]);
  await service.parseReportBuffer(Buffer.from('test'), 'upload', 'synthetic');
  assert.deepEqual(calls, [false], 'Usable digital tables should avoid OCR');
  await service.parseReportBuffer(
    Buffer.from('test'),
    'upload',
    'synthetic',
    'image',
  );
  assert.deepEqual(calls, [false, true], 'Images still require OCR');
  const normalize = (
    ReportsService.prototype as unknown as {
      normalizeComparableValue(this: void, value: string): string;
    }
  ).normalizeComparableValue;
  assert.notEqual(normalize('<5'), normalize('5'));
  assert.notEqual(normalize('<=5'), normalize('<5'));
  assert.equal(normalize('1,200'), '1200');
  console.log('PASS PDF/image routing and comparator-preserving deduplication');
}
void checkPdfRouting().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
