/** Synthetic geometry fixtures. These are invariants, not measured report accuracy. */
import assert from 'node:assert/strict';
import {
  adaptPaddle,
  adaptNativeWords,
  adaptTesseractTsv,
  IDENTITY,
  type EvidenceToken,
  type PageEvidence,
} from '../src/modules/reports/geometry/evidence';
import {
  applyVerification,
  parseGeometry,
  recoverStaggeredReviewCandidates,
  type LabTemplate,
} from '../src/modules/reports/geometry/lab-parser';
import { evaluate } from '../src/modules/reports/geometry/evaluation';
import { validateCandidate } from '../src/modules/reports/geometry/validation';
import { extractAutoImageLabRows } from '../src/modules/reports/geometry/image-auto-parser';

function tok(
  id: string,
  raw: string,
  x: number,
  y: number,
  page = 'p1',
): EvidenceToken {
  return {
    token_id: id,
    document_id: 'd1',
    page_id: page,
    text_raw: raw,
    polygon_original: [
      [x, y],
      [x + 55, y],
      [x + 55, y + 12],
      [x, y + 12],
    ],
    engine: 'paddleocr',
    engine_version: 'synthetic',
    model_version: 'synthetic',
    confidence_raw: 0.8,
    preprocessing_id: null,
    crop_id: null,
  };
}
function page(tokens: EvidenceToken[], pageId = 'p1'): PageEvidence {
  return {
    document_id: 'd1',
    page_id: pageId,
    page_number: Number(pageId.slice(1)),
    width: 600,
    height: 800,
    source_ref: 'synthetic',
    render_ref: 'synthetic',
    route: 'ocr',
    tokens,
    failed_regions: [],
    raw_output_ref: null,
  };
}
const head = [
  tok('h1', 'Test', 20, 10),
  tok('h2', 'Result', 200, 10),
  tok('h3', 'Unit', 300, 10),
  tok('h4', 'Reference', 400, 10),
];
function parse(tokens: EvidenceToken[]) {
  return parseGeometry([page([...head, ...tokens])], ['p1']);
}
{
  const names = ['Marker A', 'Marker B', 'Marker C', 'Marker D', 'Marker E'];
  const values = ['12.4', '4.4', '40.3', '92.1', '28.3'];
  const tokens = [
    tok('test-header', 'Test Name', 20, 70),
    tok('result-header', 'Obtained Value', 180, 50),
    tok('unit-header', 'Units Bio.Ref. Intervals', 340, 35),
    ...names.flatMap((name, index) => [
      tok(`name-${index}`, name, 20, 100 + index * 30),
      tok(`value-${index}`, values[index], 180, 112 + index * 30),
    ]),
  ];
  const paddle = {
    page_width: 600,
    page_height: 800,
    dpi: 72,
    native_words: [],
    model_version: 'synthetic',
    paddleocr_version: 'synthetic',
    docling_parse_version: 'synthetic',
    paddle: {
      rec_texts: tokens.map((t) => t.text_raw),
      rec_scores: tokens.map(() => 0.99),
      rec_polys: tokens.map((t) => t.polygon_original),
    },
  };
  assert.deepEqual(
    extractAutoImageLabRows(paddle).map((row) => [
      row.parameterName,
      row.value,
    ]),
    names.map((name, index) => [name, values[index]]),
  );
  paddle.paddle.rec_scores[4] = 0.6;
  assert.deepEqual(
    extractAutoImageLabRows(paddle),
    [],
    'low-confidence row stays in review',
  );
  paddle.paddle.rec_scores[4] = 0.99;
  paddle.paddle.rec_texts.push('75');
  paddle.paddle.rec_scores.push(0.99);
  paddle.paddle.rec_polys.push(tok('extra', '75', 180, 172).polygon_original);
  assert.deepEqual(
    extractAutoImageLabRows(paddle),
    [],
    'unpaired result stays in review',
  );
}
{
  const evidence = page([
    tok('unit-head', 'Units Bio.Ref. Intervals', 300, 35),
    tok('result-head', 'Obtained Value', 180, 50),
    tok('test-head', 'Test Name', 20, 70),
    tok('test-a', 'Marker A', 20, 100),
    tok('value-a', '90', 180, 112),
    tok('test-b', 'Marker B', 20, 130),
    tok('value-b', '95', 180, 142),
  ]);
  const recovered = recoverStaggeredReviewCandidates(evidence);
  assert.deepEqual(
    recovered.map((row) => [row.testRaw, row.resultRaw]),
    [
      ['Marker A', '90'],
      ['Marker B', '95'],
    ],
  );
  assert(
    recovered.every(
      (row) => row.status === 'needs_review' && !row.machineEligible,
    ),
  );
  assert.deepEqual(
    recoverStaggeredReviewCandidates(
      page([
        tok('test-head', 'Test Name', 20, 70),
        tok('result-head', 'Obtained Value', 180, 50),
        tok('test-a', 'Marker A', 20, 100),
        tok('value-a', '90', 180, 112),
      ]),
    ),
    [],
  );
}
{
  // A photographed table tilts the value column above the test column.
  // Any label-only panel heading or footer must not consume a result.
  const evidenceFor = (
    heading: string,
    names: [string, string, string],
    results: [string, string, string],
  ) =>
    page([
      tok('unit-head', 'Units Bio.Ref. Intervals', 340, 35),
      tok('result-head', 'Obtained Value', 200, 48),
      tok('test-head', 'Test Name', 20, 62),
      tok('panel', heading, 20, 100),
      tok('test-a', names[0], 20, 132),
      tok('value-a', results[0], 200, 119),
      tok('test-b', names[1], 20, 160),
      tok('value-b', results[1], 200, 147),
      tok('test-c', names[2], 20, 190),
      tok('value-c', results[2], 200, 177),
      tok('remarks', 'Laboratory comment', 20, 223),
      tok('remarks-text', 'Result rechecked and verified', 200, 210),
    ]);
  const examples: Array<{
    heading: string;
    names: [string, string, string];
    results: [string, string, string];
  }> = [
    {
      heading: 'Complete Blood Count (CBC)',
      names: ['Haemoglobin', 'RBC Count', 'Platelet Count'],
      results: ['12.4', '4.4', '70'],
    },
    {
      heading: 'Lipid Profile',
      names: ['Total Cholesterol', 'HDL Cholesterol', 'Triglycerides'],
      results: ['182', '42', '136'],
    },
    {
      heading: 'Unfamiliar Panel Name',
      names: ['Marker A', 'Marker B', 'Marker C'],
      results: ['8.1', '2.3', '91'],
    },
  ];
  for (const { heading, names, results } of examples) {
    assert.deepEqual(
      recoverStaggeredReviewCandidates(
        evidenceFor(heading, names, results),
      ).map((row) => [row.testRaw, row.resultRaw]),
      names.map((name, i) => [name, results[i]]),
    );
  }
  const cbc = examples[0];
  const missingValue = page(
    evidenceFor(cbc.heading, cbc.names, cbc.results).tokens.filter(
      (token) => token.token_id !== 'value-b',
    ),
  );
  assert.deepEqual(
    recoverStaggeredReviewCandidates(missingValue).map((row) => [
      row.testRaw,
      row.resultRaw,
    ]),
    [
      ['Haemoglobin', '12.4'],
      ['Platelet Count', '70'],
    ],
  );
}
{
  const out = parseGeometry(
    [
      page([
        tok('test-head', 'Test Name', 20, 10),
        tok('result-head', 'Results', 200, 10),
        tok('unit-head', 'Units', 300, 10),
        tok('range-head', 'Bio. Ref. Interval', 400, 10),
        tok('test', 'Marker A', 20, 40),
        tok('value', '90', 200, 40),
        tok('unit', 'mg/dL', 300, 40),
        tok('range', '70-99', 400, 40),
      ]),
    ],
    ['p1'],
  );
  assert.equal(out.candidates[0].resultRaw, '90');
  assert.equal(out.candidates[0].rangeRaw, '70-99');
}
{
  const out = parse([
    tok('a', 'Sodium', 20, 40),
    tok('av', '140', 200, 40),
    tok('b', 'Potassium', 20, 65),
    tok('c', 'Chloride', 20, 90),
    tok('cv', '102', 200, 90),
  ]);
  assert.deepEqual(
    out.candidates.map((c) => [c.testRaw, c.resultRaw]),
    [
      ['Sodium', '140'],
      ['Chloride', '102'],
    ],
  );
  assert(out.ledger.some((r) => r.reasons.includes('missing_result')));
  assert.equal(out.documentStatus, 'partial');
}
{
  const out = parseGeometry(
    [
      page([
        tok('h1', 'Test', 20, 10),
        tok('h1b', 'Name', 80, 10),
        tok('h2', 'Result', 200, 10),
        tok('h3', 'Unit', 300, 10),
        tok('h4', 'Reference', 400, 10),
        tok('h4b', 'Range', 460, 10),
        tok('n', 'Glucose', 20, 40),
        tok('v', '12.8', 200, 40),
        tok('u', 'mg/dL', 300, 40),
        tok('r', '70-99', 400, 40),
      ]),
    ],
    ['p1'],
  );
  assert.equal(out.candidates[0].resultRaw, '12.8');
  assert.equal(out.candidates[0].rangeRaw, '70-99');
}
{
  const out = parse([
    tok('a', 'Glucose', 20, 40),
    tok('av', '12.8', 200, 40),
    tok('ar', '70-99', 400, 40),
  ]);
  assert.equal(out.candidates[0].resultRaw, '12.8');
  assert.equal(out.candidates[0].rangeRaw, '70-99');
  assert.equal(out.candidates[0].unitRaw, null);
  const conflict = applyVerification(out.candidates[0], {
    engine: 'tesseract',
    raw: '128',
    cropId: 'crop1',
  });
  assert(conflict.reviewReasons.includes('ambiguous_decimal'));
  assert.equal(conflict.machineEligible, false);
  assert.equal(conflict.readings.length, 2);
  assert(
    applyVerification(out.candidates[0], null, true).reviewReasons.includes(
      'verification_timeout',
    ),
  );
  for (const alternate of ['<12.8', '-12.8', '1.28e1'])
    assert(
      applyVerification(out.candidates[0], {
        engine: 'tesseract',
        raw: alternate,
        cropId: 'c',
      }).reviewReasons.includes('reading_disagreement'),
    );
}
{
  const out = parse([
    tok('unknown', 'NovelMarker', 20, 40),
    tok('value', 'Positive', 200, 40),
  ]);
  assert.equal(out.candidates[0].testRaw, 'NovelMarker');
  assert.equal(out.candidates[0].resultKind, 'qualitative');
  assert.equal(out.candidates[0].status, 'needs_review');
}
{
  const tpl: LabTemplate = {
    id: 'synthetic',
    version: '1',
    anchors: ['Lab A', 'Report B'],
    panels: [
      {
        id: 'pA',
        rect: [0, 0, 600, 350],
        columns: [
          { role: 'test', x: [0, 150] },
          {
            role: 'result',
            x: [150, 250],
            resultColumn: 'current',
            date: '2026-01-02',
          },
          {
            role: 'result',
            x: [250, 350],
            resultColumn: 'previous',
            date: '2025-12-01',
          },
          { role: 'unit', x: [350, 450] },
        ],
      },
      {
        id: 'pB',
        rect: [0, 350, 600, 700],
        columns: [
          { role: 'test', x: [0, 150] },
          {
            role: 'result',
            x: [150, 250],
            resultColumn: 'current',
            date: '2026-01-02',
          },
        ],
      },
    ],
  };
  const tokens = [
    tok('anchor1', 'Lab A', 450, 5),
    tok('anchor2', 'Report B', 450, 25),
    tok('a', 'CRP', 20, 50),
    tok('v1', '2.0', 170, 50),
    tok('v2', '3.0', 270, 50),
    tok('u', 'mg/L', 370, 50),
    tok('b', 'CRP', 20, 400),
    tok('v3', '4.0', 170, 400),
  ];
  const out = parseGeometry([page(tokens)], ['p1'], [tpl]);
  assert.deepEqual(
    out.candidates.map((c) => [c.panelId, c.resultColumn, c.date, c.resultRaw]),
    [
      ['pA', 'current', '2026-01-02', '2.0'],
      ['pA', 'previous', '2025-12-01', '3.0'],
      ['pB', 'current', '2026-01-02', '4.0'],
    ],
  );
  assert.equal(new Set(out.candidates.map((c) => c.id)).size, 3);
  assert.equal(out.candidates[2].unitRaw, null);
}
{
  const raw = {
    rec_texts: ['12.8'],
    rec_scores: [0.7],
    rec_polys: [
      [
        [1, 2],
        [3, 2],
        [3, 4],
        [1, 4],
      ],
    ],
  };
  const adapted = adaptPaddle(raw, {
    documentId: 'd1',
    pageId: 'p1',
    engineVersion: 'test',
    modelVersion: 'test',
    preprocessingId: 'rotate',
    workingToOriginal: [2, 0, 0, 2, 5, 7],
  });
  assert.deepEqual(adapted[0].polygon_original[0], [7, 11]);
  assert.throws(() =>
    adaptPaddle(
      { ...raw, rec_scores: [] },
      {
        documentId: 'd1',
        pageId: 'p1',
        engineVersion: 'test',
        modelVersion: 'test',
        preprocessingId: null,
        workingToOriginal: IDENTITY,
      },
    ),
  );
  assert.equal(
    adaptNativeWords(
      [{ text: '12.8', bbox: [1, 2, 3, 4], coord_origin: 'BOTTOMLEFT' }],
      {
        documentId: 'd1',
        pageId: 'p1',
        pageHeight: 100,
        engineVersion: 'test',
      },
    )[0].confidence_raw,
    null,
  );
  const tsv =
    'level\tleft\ttop\twidth\theight\tconf\ttext\n5\t1\t2\t3\t4\t80\t12.8';
  assert.deepEqual(
    adaptTesseractTsv(tsv, {
      documentId: 'd1',
      pageId: 'p1',
      engineVersion: 'test',
      cropId: 'c',
      cropToOriginal: [1, 0, 0, 1, 10, 20],
    })[0].polygon_original[0],
    [11, 22],
  );
}
{
  const failed = parseGeometry([page([], 'p1')], ['p1', 'p2']);
  assert.equal(failed.documentStatus, 'partial');
  assert.equal(failed.pageStatus[1].accounted, false);
}
{
  const p = parse([tok('a', 'Glucose', 20, 40), tok('v', '128', 200, 40)])
    .candidates[0];
  const verifiedReading = applyVerification(p, {
    engine: 'tesseract',
    raw: '128',
    cropId: 'field',
  });
  const eligible = validateCandidate(verifiedReading, {
    patientResolved: true,
    reportDateResolved: true,
    specimenResolved: true,
    sourceVisible: true,
    sourceQualityAccepted: true,
    parsingProfileValidated: true,
    associationCount: 1,
    tokenReuse: false,
    normalizationSupported: true,
    verificationRequired: true,
    verificationCompleted: true,
  });
  assert.equal(eligible.machineEligible, true);
  assert.equal(eligible.status, 'needs_review');
  const report = evaluate([
    {
      documentId: 'd1',
      truth: [
        {
          documentId: 'd1',
          pageId: p.pageId,
          panelId: p.panelId,
          rowId: p.rowId,
          resultColumn: p.resultColumn,
          date: null,
          specimen: null,
          test: 'Glucose',
          result: '12.8',
          unit: null,
          range: null,
          flag: null,
        },
      ],
      predictions: [eligible],
      pages: [
        {
          pageId: 'p1',
          queueDelayMs: 7,
          processingMs: 30,
          timedOut: true,
          failed: false,
          peakContainerBytes: 1024,
        },
      ],
      documentProcessingMs: 40,
      coldStart: true,
    },
  ]);
  assert.equal(report.wrongValue, 1);
  assert.equal(report.eligibleErrors, 1);
  assert.equal(report.timeouts, 1);
  assert.equal(report.eligibleCoverage, 1);
}
console.log(
  'PASS synthetic geometry, missing value, panel/date isolation, verification, evidence transforms, incomplete page',
);
