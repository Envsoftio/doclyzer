import assert from 'node:assert/strict';
import { buildLabTrends } from '../src/modules/reports/lab-trend-builder';
import { ReportsService } from '../src/modules/reports/reports.service';
import { ReportEntity } from '../src/database/entities/report.entity';
import { ReportLabValueEntity } from '../src/database/entities/report-lab-value.entity';

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
assert.equal(gramsPerDeciliter.observations.length, 6);
assert.deepEqual(gramsPerDeciliter.dataPoints.map((point) => point.referenceRange), ['12-16', '11-15', null]);
assert.equal(gramsPerDeciliter.observations.find((item) => item.id === 'o1')?.referenceRange, '12-16');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r5')?.notPlottedReason, 'non_numeric_value');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r7')?.notPlottedReason, 'collection_date_unknown');
assert.equal(gramsPerDeciliter.observations.find((item) => item.reportId === 'r7')?.date, null);
assert.equal(buildLabTrends([{ reportId: 'missing', parameterName: 'Hb', value: '<5', unit: 'g/dL', sampleDate: null }]).parameters[0].observations[0].notPlottedReason, 'collection_date_and_numeric_value_unknown');
assert.equal(gramsPerDeciliter.dataPoints[0].dateProvenance, 'collection');
assert.deepEqual(
  buildLabTrends(rows, 'Hb').parameters.map((series) => series.unit ?? null),
  [null, 'g/dL', 'g/L'],
);
assert.equal(buildLabTrends(rows, 'HbA1c').parameters.length, 1);
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
    reportRepo: { find: async () => [report] },
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
  console.log('PASS exact values, aliases, unit isolation, dates, and observation-specific ranges');
}).catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
