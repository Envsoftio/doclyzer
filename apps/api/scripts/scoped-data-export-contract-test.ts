import 'reflect-metadata';
import assert from 'node:assert/strict';
import { gunzipSync } from 'node:zlib';
import { ReportEntity } from '../src/database/entities/report.entity';
import { AccountService } from '../src/modules/account/account.service';

const userId = '11111111-1111-4111-8111-111111111111';
const profileId = '22222222-2222-4222-8222-222222222222';
const reportId = '33333333-3333-4333-8333-333333333333';
const requestId = '44444444-4444-4444-8444-444444444444';
let saved: Record<string, unknown> | null = null;
let uploaded: Buffer | null = null;

const report = {
  id: reportId,
  userId,
  profileId,
  originalFileName: 'CBC.pdf',
  originalFileStorageKey: 'reports/original.pdf',
  status: 'parsed',
  createdAt: new Date('2026-10-10T00:00:00Z'),
};
const service = new AccountService(
  {
    findOne: async () => ({ id: userId, email: 'user@example.test', createdAt: new Date() }),
    manager: {
      getRepository: (entity: unknown) => ({
        find: async (options?: { where?: { profileId?: string } }) => entity === ReportEntity
          ? [report, { ...report, id: 'outside', profileId: 'another' }]
              .filter((item) => !options?.where?.profileId || item.profileId === options.where.profileId)
          : [{ reportId, parameterName: 'Hemoglobin', value: '13.2', unit: 'g/dL',
              sampleDate: '2026-10-10', referenceRange: '12-15', reviewState: 'verified' }],
      }),
    },
  } as never,
  {} as never,
  {} as never,
  {
    create: (value: Record<string, unknown>) => ({ ...value, id: requestId, createdAt: new Date() }),
    save: async (value: Record<string, unknown>) => { saved = value; return value; },
    findOne: async () => saved,
  } as never,
  {} as never,
  {
    findOne: async () => ({ id: profileId, userId }),
    find: async () => [{ id: profileId, name: 'Ada', createdAt: new Date() }],
  } as never,
  { find: async () => [] } as never,
  {} as never,
  {} as never,
  {
    get: async () => Buffer.from('original PDF'),
    upload: async (_key: string, data: Buffer) => { uploaded = data; return _key; },
    getSignedUrl: async () => 'https://example.test/export.tar.gz',
  } as never,
  {} as never,
  {} as never,
);

async function main() {
  const request = await service.createDataExportRequest(userId, 'test', {
    profileId,
    from: '2026-10-01T00:00:00Z',
    to: '2026-10-31T23:59:59Z',
    includeOriginals: false,
    includeResults: true,
  });
  assert.equal(request.status, 'pending');
  const completed = await service.getDataExportRequest(userId, requestId);
  assert.equal(completed?.status, 'completed');
  assert.equal(completed?.downloadUrl, 'https://example.test/export.tar.gz');
  assert(uploaded);
  const archive = gunzipSync(uploaded as Buffer).toString('latin1');
  assert(archive.includes('account.json'));
  assert(archive.includes('results.csv'));
  assert(!archive.includes('original PDF'));
  assert(!archive.includes('outside'));
  assert(archive.includes('Hemoglobin'));
  console.log('Scoped data export contract passed');
}

void main();
