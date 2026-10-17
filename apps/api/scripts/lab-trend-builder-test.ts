import assert from 'node:assert/strict';
import { buildLabTrends } from '../src/modules/reports/lab-trend-builder';

const rows = [
  { reportId: 'r1', parameterName: 'Hb', value: '11', unit: 'g/dL', sampleDate: '2026-01-01' },
  { reportId: 'r2', parameterName: 'Hemoglobin', value: '12', unit: 'g/dL', sampleDate: '2026-03-01' },
  { reportId: 'r3', parameterName: 'Hb', value: '120', unit: 'g/L', sampleDate: '2026-04-01' },
  { reportId: 'r4', parameterName: 'HbA1c', value: '6.2', unit: '%', sampleDate: '2026-02-01' },
  { reportId: 'r5', parameterName: 'Hb', value: '<5', unit: 'g/dL', sampleDate: '2026-05-01' },
  { reportId: 'r6', parameterName: 'Hb', value: '1,200', unit: 'g/dL', sampleDate: '2026-06-01' },
  { reportId: 'r7', parameterName: 'Hb', value: '11', unit: 'g/dL', sampleDate: null },
  { reportId: 'r8', parameterName: 'Hb', value: '1,2', unit: 'g/dL', sampleDate: '2026-07-01' },
  { reportId: 'r9', parameterName: 'Hb', value: '10', unit: null, sampleDate: '2026-08-01' },
];

const all = buildLabTrends(rows);
assert.equal(all.parameters.length, 4);
const hemoglobin = all.parameters.filter((series) => series.testId === 'hemoglobin');
assert.equal(hemoglobin.length, 3, 'incompatible and unknown units remain separate');
const gramsPerDeciliter = hemoglobin.find((series) => series.unit === 'g/dL');
assert.ok(gramsPerDeciliter);
assert.deepEqual(
  gramsPerDeciliter.dataPoints.map((point) => [point.reportId, point.value]),
  [['r1', 11], ['r2', 12], ['r6', 1200]],
);
assert.equal(gramsPerDeciliter.unplottedCount, 3);
assert.equal(gramsPerDeciliter.dataPoints[0].dateProvenance, 'collection');
assert.deepEqual(
  buildLabTrends(rows, 'Hb').parameters.map((series) => series.unit ?? null),
  [null, 'g/dL', 'g/L'],
);
assert.equal(buildLabTrends(rows, 'HbA1c').parameters.length, 1);
console.log('PASS exact values, aliases, unit isolation, and collection dates');
