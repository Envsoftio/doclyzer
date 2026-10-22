import assert from 'node:assert/strict';
import { ReportsService } from '../src/modules/reports/reports.service';
import { ConfigService } from '@nestjs/config';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
import { DoclingOcrClient } from '../src/modules/reports/docling-ocr.client';
import { adaptDoclingDocument } from '../src/modules/reports/docling-document-adapter';
import { LabValueExtractor } from '../src/modules/reports/lab-value-extractor';
import {
  comparisonNotation,
  splitAssayAnnotation,
} from '../src/modules/reports/lab-method-notation';

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
{
  const parsed = parser.parseWithDiagnostics(
    table([
      ['Test', 'Result', 'Unit', 'Reference Range'],
      ['Vitamin B12CLIA', '< 148', 'pg/mL', '187–833'],
      ['Urine Glucose', 'Present (+)', '', 'Absent'],
      ['GOD-POD', '', '', ''],
      ['Unknown analyte Unknown assay', '2', 'mg/dL', '1–3'],
    ]),
  );
  assert.deepEqual(
    parsed.extractedLabValues.map((r) => r.parameterName),
    ['Vitamin B12', 'Urine Glucose', 'Unknown analyte Unknown assay'],
  );
  assert.equal(parsed.extractedLabValues[0].identityEvidence?.method, 'CLIA');
  assert.equal(
    parsed.extractedLabValues[1].identityEvidence?.method,
    'GOD-POD',
  );
  assert.match(
    parsed.extractedLabValues[1].identityEvidence?.sourceText ?? '',
    /GOD-POD/,
  );
  assert.equal(parsed.diagnostics.candidateRows, 3);
  assert.deepEqual(splitAssayAnnotation('CLIA'), { name: 'CLIA' });
  assert.equal(
    comparisonNotation('Children :>16 Adult : 20–50'),
    comparisonNotation('Children:>16Adult:20-50'),
  );
  for (const [a, b] of [
    ['1 20', '120'],
    ['1.20', '120'],
    ['<5', '>5'],
    ['1,5', '1.5'],
  ])
    assert.notEqual(comparisonNotation(a), comparisonNotation(b));
  const conflict = parser.parseWithDiagnostics(
    table([
      ['Test', 'Result', 'Method'],
      ['Vitamin B12 CLIA', '148', 'Enzymatic'],
    ]),
  );
  assert.equal(conflict.diagnostics.candidateRows, 1);
  assert.equal(conflict.diagnostics.parsedRows, 0);
  const distinctMethods = parser.parse(
    table([
      ['Test', 'Result', 'Unit', 'Reference Range'],
      ['Vitamin B12 CLIA', '148', 'pg/mL', '187-833'],
      ['Vitamin B12 Method: Enzymatic', '148', 'pg/mL', '187-833'],
      ['Vitamin B12 CLIA', '148', 'pg/mL', '200-900'],
    ]),
  );
  assert.equal(
    distinctMethods.extractedLabValues.length,
    3,
    'Moving methods out of names must not merge different assays or reference intervals',
  );
  console.log(
    'PASS assay separation, continuation provenance, unknown suffix preservation, numeric-safe notation and conflicting methods',
  );
}
// Source flags and non-scalar observations must survive the shared parser.
{
  const fixture = table([
    ['Test Name', 'Result', 'Unit', 'Reference Range'],
    ['25-OH Vitamin D', 'L <20', 'ng/mL', '30 - 100'],
    ['Triglycerides', 'H 168.0', 'mg/dL', '<150'],
    ['ABO Type', '\"A\"', '', ''],
    ['Urine Glucose', 'Present (+)', '', 'Absent'],
    ['RBC Morphology', 'Normochromic Normocytic', '', ''],
    ['Novel count', '2', '%', ''],
    ['Novel count', '2', '/cmm', ''],
  ]);
  Object.assign(fixture.kids[0], {
    'page number': 7,
    extractionEngine: 'paddleocr-v5',
  });
  const parsed = parser.parseWithDiagnostics(fixture);
  assert.equal(parsed.extractedLabValues.length, 7);
  assert.equal(parsed.extractedLabValues[0].value, '<20');
  assert.equal(parsed.extractedLabValues[0].isAbnormal, true);
  assert.equal(
    parsed.extractedLabValues[0].identityEvidence?.rawValue,
    'L <20',
  );
  assert.equal(
    parsed.extractedLabValues[0].identityEvidence?.reportedFlag,
    'L',
  );
  assert.equal(parsed.extractedLabValues[0].identityEvidence?.sourcePage, '7');
  assert.equal(parsed.diagnostics.parsedRows, parsed.diagnostics.candidateRows);
  console.log(
    'PASS explicit flags, digit-leading analytes, blood group, morphology, graded qualitative values, distinct unit scales and source provenance',
  );
}
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
        ['Unfamiliar calculation', '2.5-3.5', 'Low', '', '1.7'],
      ]),
    ).extractedLabValues;
    assert.equal(rows.length, 2);
    assert.deepEqual(
      [rows[0].value, rows[0].unit, rows[0].referenceRange],
      ['105', 'mg/dL', '70-99'],
    );
    assert.deepEqual(
      [rows[1].value, rows[1].unit, rows[1].referenceRange],
      ['1.7', null, '2.5-3.5'],
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
    assert.equal(rows[0].identityEvidence?.method, 'Enzymatic');
    assert.match(
      rows[0].identityEvidence?.sourceText ?? '',
      /Creatinine Method : Enzymatic/,
    );
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
    assert.equal(rows.length, 3);
    assert.equal(rows[0].value, '<=5');
    assert.equal(rows[0].isAbnormal, undefined);
    assert.equal(rows[1].value, '1,200');
    assert.equal(rows[2].value, '9,4');
    assert.equal(rows[2].isAbnormal, undefined);
  },
);
check('Unseen test names are extracted from mapped result columns', () => {
  const rows = parser.parse(
    table([
      ['Observed Result', 'Assay', 'Units of Measurement'],
      ['<0.04', 'Novel marker ZX-47', 'ng/mL'],
      ['Detected', 'Rare antibody Q', ''],
    ]),
  ).extractedLabValues;
  assert.deepEqual(
    rows.map((r) => [r.parameterName, r.value]),
    [
      ['Novel marker ZX-47', '<0.04'],
      ['Rare antibody Q', 'Detected'],
    ],
  );
});
check(
  'Explicit identity evidence is preserved without a test vocabulary',
  () => {
    const row = parser.parse(
      table([
        ['Test Name', 'Result', 'Unit', 'Specimen', 'Method', 'Test Code'],
        ['Unseen Panel', '', '', '', '', ''],
        ['Novel marker ZX-47', '2.4', 'ng/mL', 'Serum', 'Immunoassay', 'ZX47'],
      ]),
    ).extractedLabValues[0];
    assert.deepEqual(
      [
        row.identityEvidence?.panelName,
        row.identityEvidence?.specimen,
        row.identityEvidence?.method,
        row.identityEvidence?.testCode,
      ],
      ['Unseen Panel', 'Serum', 'Immunoassay', 'ZX47'],
    );
    assert.match(row.identityEvidence?.sourceText ?? '', /Novel marker ZX-47/);
  },
);
check('Distinct explicit specimens survive deduplication', () => {
  const rows = parser.parse(
    table([
      ['Test Name', 'Result', 'Unit', 'Specimen'],
      ['Novel marker ZX-47', '2.4', 'ng/mL', 'Serum'],
      ['Novel marker ZX-47', '2.4', 'ng/mL', 'Urine'],
    ]),
  ).extractedLabValues;
  assert.deepEqual(
    rows.map((row) => row.identityEvidence?.specimen),
    ['Serum', 'Urine'],
  );
});
check(
  'Merged extractors retain distinct specimens without duplicating unknown context',
  () => {
    const service = ReportsService.prototype as unknown as {
      selectBestLabValues: (
        parsed: object[],
        transcript: object[],
      ) => Array<{
        identityEvidence?: { specimen?: string };
      }>;
    };
    const base = {
      parameterName: 'Novel marker ZX-47',
      value: '2.4',
      unit: 'ng/mL',
      sampleDate: null,
      referenceRange: null,
      isAbnormal: null,
    };
    const rows = service.selectBestLabValues(
      [
        { ...base, identityEvidence: { specimen: 'Serum' } },
        { ...base, identityEvidence: { specimen: 'Urine' } },
      ],
      [{ ...base }],
    );
    assert.deepEqual(
      rows.map((row) => row.identityEvidence?.specimen),
      ['Serum', 'Urine'],
    );
  },
);
check(
  'Text fallback keeps unseen names, qualifiers, and decimal notation',
  () => {
    const rows = new LabValueExtractor().extract(
      [
        'Novel marker ZX-47: <0.04 ng/mL',
        '| Rare antibody Q | 1,2 | AU/mL |',
        'Unknown enzyme Z\t1,200\tU/L',
      ].join('\n'),
    );
    assert.deepEqual(
      rows.map((r) => [r.parameterName, r.value, r.unit]),
      [
        ['Rare antibody Q', '1,2', 'AU/mL'],
        ['Unknown enzyme Z', '1,200', 'U/L'],
        ['Novel marker ZX-47', '<0.04', 'ng/mL'],
      ],
    );
  },
);
check('Printed albumin intervals survive table and text extraction', () => {
  const explicit = parser.parse(
    table([
      ['Test Name', 'Result', 'Unit', 'Reference Range'],
      ['Albumin Method : BCG Method', '4.06', 'g/dL', '3.50-5.20'],
    ]),
  ).extractedLabValues;
  assert.equal(explicit[0].parameterName, 'Albumin');
  assert.equal(explicit[0].referenceRange, '3.50-5.20');
  assert.equal(explicit[0].isAbnormal, false);
  for (const transcript of [
    '| Albumin | 4.06 | g/dL | 3.50-5.20 |',
    'Albumin\t4.06\tg/dL\t3.50-5.20',
    'Albumin: 4.06 g/dL 3.50-5.20',
    'Albumin 4.06 g/dL 3.50-5.20',
    '**Albumin&#x20;**\nMethod : BCG Method&#x20;\n4.06&#x20;\ng/dL&#x20;\n3.50-5.20',
    'Albumin\n4.06\ng/dL\n3.50-5.20',
    'INVESTIGATION\nAlbumin\nRESULTS\n4.06\nUOM\ng/dL\nREFERENCE RANGE\n3.50-5.20',
  ]) {
    const rows = new LabValueExtractor().extract(transcript);
    assert.equal(rows.length, 1, transcript);
    assert.deepEqual(
      [
        rows[0].parameterName,
        rows[0].value,
        rows[0].unit,
        rows[0].referenceRange,
      ],
      ['Albumin', '4.06', 'g/dL', '3.50-5.20'],
      transcript,
    );
    if (transcript.includes('BCG'))
      assert.equal(rows[0].identityEvidence?.method, 'BCG Method');
  }
});
check('Mapped ranges reject reversed bounds and compare complete categories', () => {
  const rows = parser.parse(table([
    ['Test', 'Result', 'Unit', 'Reference Range'],
    ['LDL cholesterol', '98.48', 'mg/dL', 'Optimal: <100 Above Optimal: 100-129 High: >129'],
    ['Another marker', '115', 'mg/dL', 'Optimal: <100 Above Optimal: 100-129 High: >129'],
    ['Albumin', '14', 'g/dL', '16-12'],
  ])).extractedLabValues;
  assert.equal(rows[0].isAbnormal, false);
  assert.equal(rows[1].isAbnormal, true);
  assert.equal(rows[2].isAbnormal, undefined);
});
check('Vertical category ranges remain attached to their result', () => {
  const range = [
    'Optimal: <100',
    'Above Optimal: 100-129',
    'Borderline: 130-159',
    'High: 160-189',
    'Very High: >190',
  ].join('\n');
  const rows = new LabValueExtractor().extract(
    [
      'LDL Cholesterol',
      '135',
      'mg/dL',
      range,
      'Albumin',
      '4.06',
      'g/dL',
      '3.50-5.20',
    ].join('\n'),
  );
  assert.deepEqual(
    rows.map((row) => [row.parameterName, row.referenceRange]),
    [
      ['LDL Cholesterol', range],
      ['Albumin', '3.50-5.20'],
    ],
  );
  const partialRange = 'Optimal: <100\nUnexpected category: <130\nHigh: >';
  const partialRows = new LabValueExtractor().extract(
    `LDL Cholesterol\n135\nmg/dL\n${partialRange}`,
  );
  assert.equal(partialRows.length, 1);
  assert.equal(partialRows[0].referenceRange, partialRange);
  const tableRows = new LabValueExtractor().extract(
    `| LDL Cholesterol | 135 | mg/dL | ${range.replace(/\n/g, '<br>')} |`,
  );
  assert.equal(tableRows.length, 1);
  assert.equal(tableRows[0].referenceRange, range.replace(/\n/g, '; '));
  const mixedRange = `${range}\nOther category: 130 to 159`;
  const mixedRows = new LabValueExtractor().extract(
    `LDL Cholesterol\n135\nmg/dL\n${mixedRange}\nMCV: 90 fL 80-100\nAlbumin: 4.06 g/dL 3.50-5.20`,
  );
  assert.deepEqual(
    mixedRows.map((row) => [row.parameterName, row.referenceRange]),
    [
      ['LDL Cholesterol', mixedRange],
      ['MCV', '80-100'],
      ['Albumin', '3.50-5.20'],
    ],
  );
  const flattened = range.replace(/\n/g, ' ');
  assert.equal(
    new LabValueExtractor().extract(`LDL Cholesterol 135 mg/dL ${flattened}`)[0]
      .referenceRange,
    flattened,
  );
  for (const label of [
    'Normal',
    'Very Low',
    'Borderline Low',
    'Near or Above Optimal',
  ]) {
    assert.equal(new LabValueExtractor().extract(`${label}: <5`).length, 0);
  }
});
check('Fallback range enrichment keeps different unit scales separate', () => {
  const rows = new LabValueExtractor().extract(
    '| Novel count | 2 | % | |\n| Novel count | 2 | /cmm | 1-3 |',
  );
  assert.equal(rows.length, 2);
  assert.equal(rows[0].referenceRange, undefined);
  assert.equal(rows[1].referenceRange, '1-3');
  for (const transcript of [
    'Novel count: 4.06 10^9/L 3.50-5.20',
    'Novel count 4.06 10^9/L 3.50-5.20',
    'Novel count\n4.06\n10^9/L\n3.50-5.20',
  ]) {
    const [row] = new LabValueExtractor().extract(transcript);
    assert.equal(row.unit, '10^9/L');
    assert.equal(row.referenceRange, '3.50-5.20');
  }
});
check('Vertical text does not borrow ranges from another test or prose', () => {
  for (const transcript of [
    'Albumin\nMethod : BCG Method\n4.06\ng/dL\nCalcium\n9.4\nmg/dL\n8.6-10.2',
    'Albumin\n4.06\ng/dL\nSee interpretation\n3.50-5.20',
  ]) {
    const albumin = new LabValueExtractor()
      .extract(transcript)
      .find((row) => row.parameterName === 'Albumin');
    assert.equal(albumin?.referenceRange, undefined);
  }
});
check('Single unknown assay is recognized from report structure', () => {
  const classify = ReportsService.prototype as unknown as {
    isLikelyLabReport: (
      transcript: string | null,
      rows: Array<{ parameterName: string; value: string }>,
    ) => boolean;
  };
  const rows = [{ parameterName: 'Novel marker ZX-47', value: '<0.04' }];
  assert.equal(
    classify.isLikelyLabReport('Test Name | Result | Unit', rows),
    true,
  );
  assert.equal(classify.isLikelyLabReport('Invoice total 100', rows), false);
});
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
check('Microscopy and culture descriptions retain their raw wording', () => {
  const rows = parser.parse(
    table([
      ['Test Name', 'Result', 'Unit'],
      ['Urine bacteria', 'Moderate bacteria', '/hpf'],
      ['Culture', 'Growth of Escherichia coli', ''],
    ]),
  ).extractedLabValues;
  assert.deepEqual(
    rows.map((r) => r.value),
    ['Moderate bacteria', 'Growth of Escherichia coli'],
  );
  assert.ok(rows.every((r) => r.isAbnormal === undefined));
});
check('Unmapped tables are reported alongside mapped lab rows', () => {
  const result = parser.parseWithDiagnostics({
    type: 'document',
    kids: [
      table([
        ['Test Name', 'Result'],
        ['Glucose', '90'],
      ]).kids[0],
      table([
        ['Analyte', 'Finding'],
        ['Other organism', 'See note'],
      ]).kids[0],
    ],
  });
  assert.equal(result.extractedLabValues.length, 1);
  assert.equal(result.diagnostics.hasUnmappedTables, true);
});
check('Patient metadata tables do not force review of complete lab results', () => {
  const result = parser.parseWithDiagnostics({
    type: 'document',
    kids: [
      table([
        ['Test Name', 'Result', 'Unit'],
        ['Glucose', '90', 'mg/dL'],
      ]).kids[0],
      table([
        ['Patient Name', 'Example Person'],
        ['Age', '42'],
        ['Lab ID', 'ABC123'],
      ]).kids[0],
    ],
  });
  assert.equal(result.extractedLabValues.length, 1);
  assert.equal(result.diagnostics.hasUnmappedTables, false);
  assert.equal(result.diagnostics.parsedRows, result.diagnostics.candidateRows);
});
check('Merged panel titles and reference tables do not create missing results', () => {
  const panel = 'Complete Blood Count,Sample TypeWHOLE BLOOD';
  const merged = {
    type: 'table',
    rows: [
      { cells: ['Test Name', 'Result', 'Unit'].map((content) => ({ content })) },
      { cells: Array.from({ length: 3 }, () => ({ content: panel, ambiguous: true })) },
      { cells: ['Haemoglobin', '13.3', 'g/dL'].map((content) => ({ content })) },
    ],
  };
  const reference = [
    table([
      ['eGFR Range', 'Stage', 'Interpretation'],
      ['60-89', 'G2', 'Mildly decreased'],
    ]).kids[0],
    table([
      ['Peak Name', 'Retention Time(s)', 'Area', 'Result (Area %)'],
      ['HbA0', '87.2', '141714', '92.1'],
    ]).kids[0],
    table([
      ['Ist Trimester', '0.18 -2.99'],
      ['2nd Trimester', '0.11 -3.98'],
    ]).kids[0],
  ];
  const result = parser.parseWithDiagnostics({
    type: 'document',
    kids: [merged, ...reference],
  });
  assert.equal(result.extractedLabValues.length, 1);
  assert.equal(result.diagnostics.candidateRows, 1);
  assert.equal(result.diagnostics.parsedRows, 1);
  assert.equal(result.diagnostics.hasUnmappedTables, false);
});
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
      extractWithOcrCascade: async () => {
        calls.push(true);
        return { text: 'Glucose 90', parsedJson: doc };
      },
      extractImageWithPaddle: () => {
        calls.push(true);
        return Promise.resolve({ text: 'Glucose 90', parsedJson: doc });
      },
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
      imageInput?: { buffer: Buffer; contentType: 'image/png' },
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
    { buffer: Buffer.from('test'), contentType: 'image/png' },
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
async function checkPartialExtractionReview() {
  const service = Object.assign(
    Object.create(ReportsService.prototype) as object,
    {
      odlJsonParser: parser,
      logger: { log: () => undefined },
      reportLabAiFallbackService: { tryExtract: () => Promise.resolve(null) },
    },
  ) as unknown as {
    extractLabValuesFromOdlJsonWithFallback(input: {
      opendataloaderJson: unknown;
      reportId: string;
      trigger: 'upload';
      transcript: string;
    }): Promise<{
      extractedLabValues: Array<{ parameterName: string }>;
      extractionReview: {
        required: boolean;
        candidateRows: number;
        parsedRows: number;
      };
    }>;
  };
  const result = await service.extractLabValuesFromOdlJsonWithFallback({
    opendataloaderJson: table([
      ['Test Name', 'Result', 'Unit'],
      ['Glucose', '90', 'mg/dL'],
      ['Urine sediment', 'See susceptibility panel', ''],
    ]),
    reportId: 'synthetic',
    trigger: 'upload',
    transcript:
      'Test Name Result Unit Glucose 90 Urine sediment See susceptibility panel',
  });
  assert.equal(result.extractedLabValues.length, 1);
  assert.deepEqual(
    [
      result.extractionReview.required,
      result.extractionReview.candidateRows,
      result.extractionReview.parsedRows,
    ],
    [true, 2, 1],
  );
  console.log('PASS partial table extraction requires report-level review');
}
void Promise.all([checkPdfRouting(), checkPartialExtractionReview()]).catch(
  (error: unknown) => {
    console.error(error);
    process.exitCode = 1;
  },
);
