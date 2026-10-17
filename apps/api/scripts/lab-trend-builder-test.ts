import assert from 'node:assert/strict';
import { buildLabTrends } from '../src/modules/reports/lab-trend-builder';
import { ReportsService } from '../src/modules/reports/reports.service';
import { ReportEntity } from '../src/database/entities/report.entity';
import { ReportLabValueEntity } from '../src/database/entities/report-lab-value.entity';
import { normalizeObservation, type ObservationRules } from '../src/modules/reports/observation-normalizer';

const rules: ObservationRules = {
  aliases: new Map([
    ['hb', { id: 'hemoglobin', name: 'Hemoglobin' }],
    ['hemoglobin', { id: 'hemoglobin', name: 'Hemoglobin' }],
    ['hba1c', { id: 'hba1c', name: 'HbA1c' }],
  ]),
  units: new Map([
    ['hemoglobin\u0000g/dl', { targetUnit: 'g/dL', decimalExponent: 0 }],
    ['hemoglobin\u0000g/l', { targetUnit: 'g/dL', decimalExponent: -1 }],
    ['hba1c\u0000%', { targetUnit: '%', decimalExponent: 0 }],
  ]),
};

const rows = [
  { id: 'o1', reportId: 'r1', parameterName: 'Hb', value: '11', unit: 'g/dL', sampleDate: '2026-01-01', referenceRange: '12-16' },
  { reportId: 'r2', parameterName: 'Hemoglobin', value: '12', unit: 'g/dL', sampleDate: '2026-03-01', referenceRange: '11-15' },
  { reportId: 'r3', parameterName: 'Hb', value: '120', unit: 'g/L', sampleDate: '2026-04-01' },
  { reportId: 'r4', parameterName: 'HbA1c', value: '6.2', unit: '%', sampleDate: '2026-02-01' },
  { reportId: 'r5', parameterName: 'Hb', value: '<5', unit: 'g/dL', sampleDate: '2026-05-01' },
  { reportId: 'r6', parameterName: 'Hb', value: '1,200', unit: 'g/dL', sampleDate: '2026-06-01' },
  { reportId: 'r7', parameterName: 'Hb', value: '11', unit: 'g/dL', sampleDate: null },
  { reportId: 'r8', parameterName: 'Hb', value: '1,2', unit: 'g/dL', sampleDate: '2026-07-01' },
  { reportId: 'r9', parameterName: 'Hb', value: '10', unit: null, sampleDate: '2026-08-01' },
];

const all = buildLabTrends(rows, undefined, rules);
assert.equal(all.parameters.length, 3);
const hemoglobin = all.parameters.filter((series) => series.testId === 'hemoglobin');
assert.equal(hemoglobin.length, 2, 'validated g/L values combine with g/dL; unknown units stay separate');
const gramsPerDeciliter = hemoglobin.find((series) => series.unit === 'g/dL');
assert.ok(gramsPerDeciliter);
assert.deepEqual(
  gramsPerDeciliter.dataPoints.map((point) => [point.reportId, point.value]),
  [['r1', 11], ['r2', 12], ['r3', 12], ['r6', 1200]],
);
assert.equal(gramsPerDeciliter.unplottedCount, 3);
assert.equal(gramsPerDeciliter.observations.length, 7);
assert.deepEqual(gramsPerDeciliter.dataPoints.map((point) => point.referenceRange), ['12-16', '11-15', null, null]);
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r3')?.originalUnit, 'g/L');
assert.equal(gramsPerDeciliter.observations.find((item) => item.id === 'o1')?.referenceRange, '12-16');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r5')?.notPlottedReason, 'non_numeric_value');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r7')?.notPlottedReason, 'collection_date_unknown');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r7')?.date, null);
assert.equal(buildLabTrends([{ reportId: 'missing', parameterName: 'Hb', value: '<5', unit: 'g/dL', sampleDate: null }], undefined, rules).parameters[0].observations[0].notPlottedReason, 'collection_date_and_numeric_value_unknown');
assert.equal(gramsPerDeciliter.dataPoints[0].dateProvenance, 'extracted');
assert.deepEqual(
  buildLabTrends(rows, 'Hb', rules).parameters.map((series) => series.unit ?? null),
  [null, 'g/dL'],
);
assert.equal(buildLabTrends(rows, 'HbA1c', rules).parameters.length, 1);
assert.equal(normalizeObservation({ parameterName: 'Hb', value: '<5', unit: 'g/L' }, rules).comparisonQualifier, 'lt');
assert.equal(normalizeObservation({ parameterName: 'Hb', value: '<5', unit: 'g/L' }, rules).normalizedNumericValue, '0.5');
assert.equal(normalizeObservation({ parameterName: 'Hb', value: '1,2', unit: 'g/dL' }, rules).resultKind, 'ambiguous');
assert.equal(normalizeObservation({ parameterName: 'Hb', value: '1,2', unit: 'g/dL' }, rules).parsedNumericValue, null);
assert.equal(normalizeObservation({ parameterName: 'HbA1c', value: '6.2', unit: '%' }, rules).canonicalTestId, 'hba1c');
assert.equal(normalizeObservation({ parameterName: 'Mystery', value: '12', unit: 'g/dL' }, rules).reviewState, 'needs_review');
assert.equal(normalizeObservation({ parameterName: 'Creatinine', value: '1.2', unit: 'mg/dL' }).canonicalTestId, null);
assert.equal(buildLabTrends([{ reportId: 'new', parameterName: 'Creatinine', value: '1.2',
  unit: 'mg/dL', sampleDate: '2026-01-01' }]).parameters[0].testId, 'unmapped:creatinine');
const newlyApproved: ObservationRules = {
  aliases: new Map([
    ['creatinine', { id: 'creatinine', name: 'Creatinine' }],
    ['serum creatinine', { id: 'creatinine', name: 'Creatinine' }],
  ]),
  units: new Map([
    ['creatinine\u0000mg/dl', { targetUnit: 'mg/dL', decimalExponent: 0 }],
  ]),
};
assert.equal(buildLabTrends([
  { reportId: 'new-1', parameterName: 'Creatinine', value: '1.2', unit: 'mg/dL', sampleDate: '2026-01-01' },
  { reportId: 'new-2', parameterName: 'Serum Creatinine', value: '1.3', unit: 'mg/dL', sampleDate: '2026-02-01' },
], undefined, newlyApproved).parameters[0].dataPoints.length, 2);
assert.equal(buildLabTrends([{ reportId: 'unmapped', parameterName: 'Hb', canonicalTestId: null,
  value: '12', unit: 'g/dL', sampleDate: '2026-01-01', normalizedUnit: null }]).parameters[0].testId, 'unmapped:hb');
async function verifyReportSpecificRanges() {
  const report = Object.assign(new ReportEntity(), {
    id: 'report-1', profileId: 'profile-1', userId: 'user-1', deletedAt: null,
    structuredReport: {
      patientDetails: {},
      sections: [{ heading: 'Blood', tests: [
        { parameterName: 'Hb', value: '11', unit: 'g/dL', referenceRange: '12-16' },
        { parameterName: 'Hb', value: '11', unit: 'g/dL', referenceRange: '13-17' },
        { parameterName: 'Hb', value: '12', unit: 'g/dL', referenceRange: '11-15' },
      ] }],
    },
  });
  const labValues = [
    Object.assign(new ReportLabValueEntity(), { id: 'a', reportId: report.id, parameterName: 'Hb', value: '11', unit: 'g/dL', sampleDate: '2026-01-01', referenceRange: null, reviewVersion: 0 }),
    Object.assign(new ReportLabValueEntity(), { id: 'b', reportId: report.id, parameterName: 'Hb', value: '12', unit: 'g/dL', sampleDate: '2026-02-01', referenceRange: null, reviewVersion: 0 }),
    Object.assign(new ReportLabValueEntity(), { id: 'c', reportId: report.id, parameterName: 'Hb', value: '13', unit: 'g/dL', sampleDate: '2026-03-01', referenceRange: '10-14', reviewVersion: 1 }),
  ];
  const service = Object.assign(Object.create(ReportsService.prototype) as object, {
    profilesService: { getProfile: async () => ({ id: 'profile-1' }) },
    reportRepo: { find: async () => [report], manager: { query: async (sql: string) =>
      sql.includes('lab_test_aliases')
        ? [...rules.aliases].map(([alias_key, test]) => ({ alias_key, canonical_test_id: test.id, canonical_name: test.name }))
        : [...rules.units].map(([key, unit]) => ({ canonical_test_id: key.split('\u0000')[0],
            source_unit_key: key.split('\u0000')[1], target_unit: unit.targetUnit,
            decimal_exponent: unit.decimalExponent })) } },
    reportLabValueRepo: { createQueryBuilder: () => ({
      where: () => ({ getMany: async () => labValues }),
    }) },
  }) as unknown as ReportsService;
  const result = await service.getLabTrends('user-1', 'profile-1');
  const series = result.parameters[0];
  assert.equal(series.observations.find((item) => item.id === 'a')?.referenceRange, null);
  assert.equal(series.observations.find((item) => item.id === 'b')?.referenceRange, '11-15');
  assert.equal(series.observations.find((item) => item.id === 'c')?.referenceRange, '10-14');
}

void verifyReportSpecificRanges().then(() => {
  console.log('PASS exact values, aliases, validated unit conversion, dates, and observation-specific ranges');
}).catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
