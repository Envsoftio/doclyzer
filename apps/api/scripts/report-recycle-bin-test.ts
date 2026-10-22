import { strict as assert } from 'node:assert';
import { ConfigService } from '@nestjs/config';
import { createFileStorage } from '../src/common/storage/storage.module';
import { ReportNotFoundException } from '../src/modules/reports/exceptions/report-not-found.exception';
import { ReportsRecycleBinCleanupService } from '../src/modules/reports/reports-recycle-bin-cleanup.service';
import { ReportsService } from '../src/modules/reports/reports.service';

const reportId = '00000000-0000-4000-8000-000000000001';
const userId = '00000000-0000-4000-8000-000000000002';

function makeService(fields: Record<string, unknown>): ReportsService {
  return Object.assign(
    Object.create(ReportsService.prototype),
    fields,
  ) as ReportsService;
}

async function testPurge(options: {
  restored?: boolean;
  storageFails?: boolean;
  notDue?: boolean;
}): Promise<void> {
  const deletedAt = new Date(Date.now() - 31 * 24 * 60 * 60 * 1000);
  const purgeAfterAt = new Date(
    Date.now() + (options.notDue ? 24 * 60 * 60 * 1000 : -1000),
  );
  let deletedFile = false;
  let deletedRow = false;
  const report = {
    id: reportId,
    deletedAt: options.restored ? null : deletedAt,
    purgeAfterAt: options.restored ? null : purgeAfterAt,
    originalFileStorageKey: 'reports/test.pdf',
  };
  const repository = {
    find: async () => [{ id: reportId }],
    manager: {
      transaction: async (run: (manager: object) => Promise<boolean>) =>
        run({
          getRepository: () => ({
            findOne: async () => report,
            delete: async () => {
              deletedRow = true;
            },
          }),
        }),
    },
  };
  const service = makeService({
    reportRepo: repository,
    fileStorage: {
      delete: async (
        _key: string,
        deleteOptions: { allVersions?: boolean },
      ) => {
        assert.equal(deleteOptions.allVersions, true);
        deletedFile = true;
        if (options.storageFails) throw new Error('storage unavailable');
      },
    },
    logger: { warn: () => undefined },
  });
  const count = await service.purgeExpiredRecycleBinReports();
  assert.equal(
    count,
    options.restored || options.storageFails || options.notDue ? 0 : 1,
  );
  assert.equal(deletedFile, !options.restored && !options.notDue);
  assert.equal(
    deletedRow,
    !options.restored && !options.storageFails && !options.notDue,
  );
}

async function testExpiredRestore(): Promise<void> {
  const service = makeService({
    reportRepo: {
      manager: {
        transaction: async (run: (manager: object) => Promise<unknown>) =>
          run({
            query: async () => [],
            getRepository: () => ({
              findOne: async () => ({
                id: reportId,
                userId,
                deletedAt: new Date(Date.now() - 31 * 24 * 60 * 60 * 1000),
                purgeAfterAt: new Date(Date.now() - 1000),
              }),
            }),
          }),
      },
    },
  });
  await assert.rejects(
    service.restoreFromRecycleBin(userId, reportId),
    ReportNotFoundException,
  );
}

async function testUserDeletion(): Promise<void> {
  const otherUserId = '00000000-0000-4000-8000-000000000003';
  const row = {
    id: reportId,
    userId,
    deletedAt: new Date() as Date | null,
    purgeAfterAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    originalFileStorageKey: 'reports/test.pdf',
  };
  let fileDeletes = 0;
  let rowDeletes = 0;
  let storageFails = false;
  const service = makeService({
    reportRepo: {
      manager: {
        transaction: async (run: (manager: object) => Promise<unknown>) =>
          run({
            getRepository: () => ({
              findOne: async ({ where }: { where: { userId?: string } }) =>
                where.userId && where.userId !== row.userId ? null : row,
              delete: async () => {
                rowDeletes += 1;
              },
            }),
          }),
      },
    },
    fileStorage: {
      delete: async (_key: string, options: { allVersions: boolean }) => {
        assert.equal(options.allVersions, true);
        fileDeletes += 1;
        if (storageFails) throw new Error('B2 unavailable');
      },
    },
  });
  await assert.rejects(
    service.permanentlyDeleteReport(otherUserId, reportId),
    ReportNotFoundException,
  );
  assert.equal(fileDeletes, 0);
  row.deletedAt = null;
  await assert.rejects(
    service.permanentlyDeleteReport(userId, reportId),
    ReportNotFoundException,
  );
  assert.equal(fileDeletes, 0);
  row.deletedAt = new Date();
  storageFails = true;
  await assert.rejects(service.permanentlyDeleteReport(userId, reportId));
  assert.equal(rowDeletes, 0);
  storageFails = false;
  await service.permanentlyDeleteReport(userId, reportId);
  assert.equal(fileDeletes, 2);
  assert.equal(rowDeletes, 1);
}

async function testEmptyRecycleBin(): Promise<void> {
  const secondId = '00000000-0000-4000-8000-000000000004';
  const rows = [reportId, secondId].map((id) => ({
    id,
    userId,
    deletedAt: new Date(),
    purgeAfterAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    originalFileStorageKey: `reports/${id}.pdf`,
  }));
  const deletedIds: string[] = [];
  const service = makeService({
    reportRepo: {
      find: async ({ where }: { where: { userId: string } }) => {
        assert.equal(where.userId, userId);
        return rows.map(({ id }) => ({ id }));
      },
      manager: {
        transaction: async (run: (manager: object) => Promise<unknown>) =>
          run({
            getRepository: () => ({
              findOne: async ({
                where,
              }: {
                where: { id: string; userId: string };
              }) => {
                assert.equal(where.userId, userId);
                return rows.find((row) => row.id === where.id);
              },
              delete: async ({ id }: { id: string }) => {
                deletedIds.push(id);
              },
            }),
          }),
      },
    },
    fileStorage: {
      delete: async (key: string) => {
        if (key.includes(secondId)) throw new Error('B2 unavailable');
      },
    },
    logger: { warn: () => undefined },
  });
  assert.deepEqual(await service.emptyRecycleBin(userId), {
    deletedCount: 1,
    failedCount: 1,
  });
  assert.deepEqual(deletedIds, [reportId]);
}

async function testCleanupStartup(): Promise<void> {
  for (const role of ['api', 'worker']) {
    let sweeps = 0;
    const cleanup = new ReportsRecycleBinCleanupService(
      {
        purgeExpiredRecycleBinReports: async () => {
          sweeps += 1;
          return 0;
        },
      } as unknown as ReportsService,
      { get: () => role } as unknown as ConfigService,
    );
    cleanup.onModuleInit();
    await new Promise<void>((resolve) => setImmediate(resolve));
    cleanup.onModuleDestroy();
    assert.equal(sweeps, role === 'api' ? 1 : 0);
  }
}

function testProductionStorage(): void {
  const previous = process.env.NODE_ENV;
  try {
    process.env.NODE_ENV = 'production';
    assert.throws(
      () =>
        createFileStorage(new ConfigService({ storage: { b2Disabled: true } })),
      /Production requires configured B2 storage/,
    );
  } finally {
    if (previous === undefined) delete process.env.NODE_ENV;
    else process.env.NODE_ENV = previous;
  }
}

async function main(): Promise<void> {
  await testPurge({});
  await testPurge({ restored: true });
  await testPurge({ notDue: true });
  await testPurge({ storageFails: true });
  await testExpiredRestore();
  await testUserDeletion();
  await testEmptyRecycleBin();
  await testCleanupStartup();
  testProductionStorage();
  process.stdout.write('Recycle bin retention checks passed\n');
}

void main();
