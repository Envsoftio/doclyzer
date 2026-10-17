import assert from 'node:assert/strict';
import { ConflictException } from '@nestjs/common';
import { ReportEntity } from '../src/database/entities/report.entity';
import { ReportLabValueEntity } from '../src/database/entities/report-lab-value.entity';
import { ReportLabValueCorrectionEntity } from '../src/database/entities/report-lab-value-correction.entity';
import { ReportsService, type ReportDto } from '../src/modules/reports/reports.service';

const userId = '11111111-1111-4111-8111-111111111111';
const reportId = '22222222-2222-4222-8222-222222222222';
const labValueId = '33333333-3333-4333-8333-333333333333';
const report: ReportEntity = Object.assign(new ReportEntity(), {
  id: reportId,
  userId,
  profileId: '44444444-4444-4444-8444-444444444444',
  status: 'parsed' as const,
  summary: 'Old summary',
  createdAt: new Date('2026-01-01T00:00:00Z'),
  deletedAt: null,
  purgeAfterAt: null,
  structuredReport: {
    patientDetails: {},
    sections: [{ heading: 'Blood', tests: [{ parameterName: 'Hb', value: '10', unit: 'g/dL', referenceRange: '12-16' }] }],
  },
});
const row: ReportLabValueEntity = Object.assign(new ReportLabValueEntity(), {
  id: labValueId,
  reportId,
  parameterName: 'Hb',
  originalParameterName: 'Hb',
  value: '10',
  rawResult: '10',
  unit: 'g/dL',
  originalUnit: 'g/dL',
  sampleDate: null,
  referenceRange: null,
  reviewVersion: 0,
  sourceSnapshot: null,
});
const audit: Array<Record<string, unknown>> = [];
let cacheInvalidations = 0;
const manager = {
  getRepository: (entity: unknown) => {
    if (entity === ReportEntity) return {
      findOne: async (query: { where: { userId: string } }) =>
        query.where.userId === userId ? report : null,
      save: async () => report,
    };
    if (entity === ReportLabValueEntity) return {
      findOne: async () => row,
      save: async () => row,
    };
    if (entity === ReportLabValueCorrectionEntity) return {
      save: async (entry: Record<string, unknown>) => { audit.push(entry); },
    };
    throw new Error('Unexpected repository');
  },
  delete: async () => { cacheInvalidations++; },
  transaction: async (work: (transaction: unknown) => Promise<void>) => work(manager),
};
const service = Object.assign(Object.create(ReportsService.prototype) as object, {
  reportRepo: { manager: { ...manager, query: async (sql: string) =>
    sql.includes('lab_test_aliases')
      ? [{ alias_key: 'hemoglobin', canonical_test_id: 'hemoglobin', canonical_name: 'Hemoglobin' }]
      : [{ canonical_test_id: 'hemoglobin', source_unit_key: 'g/dl', target_unit: 'g/dL', decimal_exponent: 0 }] } },
  getReport: async (): Promise<ReportDto> => ({
    id: reportId, profileId: report.profileId, originalFileName: 'report.pdf',
    contentType: 'application/pdf', sizeBytes: 1, status: 'parsed',
    createdAt: report.createdAt.toISOString(), extractedLabValues: [],
  }),
}) as unknown as ReportsService;

async function run() {
  await service.correctLabValue(userId, reportId, labValueId, {
    expectedVersion: 0,
    parameterName: 'Hemoglobin',
    value: '11',
    unit: 'g/dL',
    sampleDate: '2026-01-02',
    referenceRange: '12-16',
  });
  assert.equal(row.reviewVersion, 1);
  assert.equal(row.value, '11');
  assert.equal(row.sampleDate, '2026-01-02');
  assert.equal(row.collectionDateSource, 'corrected');
  assert.equal(row.canonicalTestId, 'hemoglobin');
  assert.equal(row.parsedNumericValue, '11');
  assert.equal(row.normalizedNumericValue, '11');
  assert.equal(row.reviewState, 'corrected');
  assert.deepEqual(row.sourceSnapshot, {
    parameterName: 'Hb', value: '10', unit: 'g/dL', sampleDate: null, referenceRange: '12-16',
  });
  assert.equal(report.summary, null);
  assert.equal(audit.length, 1);
  assert.equal(cacheInvalidations, 1);

  await assert.rejects(
    service.correctLabValue(userId, reportId, labValueId, {
      expectedVersion: 0, parameterName: 'Hemoglobin', value: '12', unit: 'g/dL', sampleDate: '2026-01-03', referenceRange: '12-16',
    }),
    ConflictException,
  );
  assert.equal(row.value, '11');
  assert.equal(audit.length, 1);

  await assert.rejects(
    service.correctLabValue('55555555-5555-4555-8555-555555555555', reportId, labValueId, {
      expectedVersion: 1, parameterName: 'Hemoglobin', value: '12', unit: 'g/dL', sampleDate: '2026-01-03', referenceRange: '12-16',
    }),
  );
  assert.equal(audit.length, 1);

  await service.correctLabValue(userId, reportId, labValueId, {
    expectedVersion: 1, parameterName: 'Hemoglobin', value: '12', unit: 'g/dL', sampleDate: '2026-01-03', referenceRange: '12-16',
  });
  assert.equal(row.reviewVersion, 2);
  assert.equal(audit.length, 2);
  assert.equal(row.sourceSnapshot?.value, '10');
  assert.equal(row.rawResult, '10', 'correction must not rewrite the immutable source field');
  assert.equal(row.originalParameterName, 'Hb');
  const dto = (service as unknown as {
    toDto(report: ReportEntity, values: ReportLabValueEntity[], transcript: boolean, structured: boolean): ReportDto;
  }).toDto(report, [row], false, true);
  assert.equal(dto.extractedLabValues[0].value, '12');
  assert.equal(dto.extractedLabValues[0].referenceRange, '12-16');
  assert.equal(dto.extractedLabValues[0].reviewVersion, 2);
  assert.equal(dto.extractedLabValues[0].sourceSnapshot?.value, '10');
  const compare = (service as unknown as {
    evaluateAbnormalFromReference(value: string, range: string): boolean | null;
  }).evaluateAbnormalFromReference.bind(service);
  assert.equal(compare('1,2', '10-20'), null);
  assert.equal(compare('<12', '10-20'), null);
  console.log('PASS correction provenance, version conflict, and cache invalidation');
}

void run().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
