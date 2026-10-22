import 'reflect-metadata';
import { strict as assert } from 'node:assert';
import { randomUUID } from 'node:crypto';
import { ConfigService } from '@nestjs/config';
import { ListObjectVersionsCommand, S3Client } from '@aws-sdk/client-s3';
import { DataSource } from 'typeorm';
import { B2FileStorageService } from '../src/common/storage/b2-file-storage.service';
import { AppDataSource } from '../src/database/data-source';
import { ReportEntity } from '../src/database/entities/report.entity';
import { ReportNotFoundException } from '../src/modules/reports/exceptions/report-not-found.exception';
import { ReportsService } from '../src/modules/reports/reports.service';

async function main(): Promise<void> {
  process.loadEnvFile('../../.env');
  const databaseUrl = process.env.RECYCLE_BIN_TEST_DATABASE_URL;
  if (!databaseUrl)
    throw new Error(
      'RECYCLE_BIN_TEST_DATABASE_URL is required for isolated-schema testing',
    );
  assert.notEqual(process.env.B2_DISABLED, 'true', 'B2 must be enabled');
  const config = {
    b2KeyId: process.env.B2_KEY_ID!,
    b2ApplicationKey: process.env.B2_APPLICATION_KEY!,
    b2Bucket: process.env.B2_BUCKET_NAME!,
    b2Endpoint: process.env.B2_ENDPOINT!,
    b2Region: process.env.B2_REGION ?? 'us-west-002',
  };
  const storage = new B2FileStorageService(
    new ConfigService({ storage: config }),
  );
  const b2 = new S3Client({
    endpoint: config.b2Endpoint,
    region: config.b2Region,
    forcePathStyle: true,
    credentials: {
      accessKeyId: config.b2KeyId,
      secretAccessKey: config.b2ApplicationKey,
    },
  });
  const schema = `recycle_test_${randomUUID().replaceAll('-', '')}`;
  const prefix = `reports/verification-${randomUUID()}/`;
  const keys: string[] = [];
  const admin = await new DataSource({
    type: 'postgres',
    url: databaseUrl,
  }).initialize();
  let db: DataSource | undefined;
  const versions = async (key: string): Promise<number> => {
    const page = await b2.send(
      new ListObjectVersionsCommand({ Bucket: config.b2Bucket, Prefix: key }),
    );
    return [...(page.Versions ?? []), ...(page.DeleteMarkers ?? [])].filter(
      (item) => item.Key === key,
    ).length;
  };
  try {
    await admin.query(`CREATE SCHEMA "${schema}"`);
    await admin.query(
      `CREATE TABLE "${schema}".reports (LIKE public.reports INCLUDING ALL)`,
    );
    db = await new DataSource({
      type: 'postgres',
      url: databaseUrl,
      entities: AppDataSource.options.entities,
      extra: { options: `-c search_path=${schema}` },
    }).initialize();
    const service = Object.assign(Object.create(ReportsService.prototype), {
      reportRepo: db.getRepository(ReportEntity),
      fileStorage: storage,
      logger: { warn: () => undefined },
    }) as ReportsService;
    const userId = randomUUID();
    const otherUserId = randomUUID();
    const profileId = randomUUID();
    const insertReport = async (
      expired: boolean,
    ): Promise<{ id: string; key: string }> => {
      const id = randomUUID();
      const key = `${prefix}${id}.pdf`;
      keys.push(key);
      await storage.upload(
        key,
        Buffer.from('synthetic report'),
        'application/pdf',
      );
      await db!.query(
        `INSERT INTO reports(id,user_id,profile_id,original_file_name,content_type,size_bytes,original_file_storage_key,status,deleted_at,purge_after_at)
         VALUES ($1,$2,$3,'synthetic.pdf','application/pdf',16,$4,'unparsed',now()-interval '1 day',now()+$5*interval '1 day')`,
        [id, userId, profileId, key, expired ? -1 : 1],
      );
      return { id, key };
    };
    const one = await insertReport(false);
    await assert.rejects(
      service.permanentlyDeleteReport(otherUserId, one.id),
      ReportNotFoundException,
    );
    assert.equal(await versions(one.key), 1);
    await service.permanentlyDeleteReport(userId, one.id);
    assert.equal(
      (await db.query('SELECT id FROM reports WHERE id=$1', [one.id])).length,
      0,
    );
    assert.equal(await versions(one.key), 0);

    const bulkOne = await insertReport(false);
    const bulkTwo = await insertReport(false);
    assert.deepEqual(await service.emptyRecycleBin(userId), {
      deletedCount: 2,
      failedCount: 0,
    });
    assert.equal((await db.query('SELECT id FROM reports')).length, 0);
    assert.equal(await versions(bulkOne.key), 0);
    assert.equal(await versions(bulkTwo.key), 0);

    const overdue = await insertReport(true);
    assert.equal(await service.purgeExpiredRecycleBinReports(), 1);
    assert.equal(
      (await db.query('SELECT id FROM reports WHERE id=$1', [overdue.id]))
        .length,
      0,
    );
    assert.equal(await versions(overdue.key), 0);
    process.stdout.write('PostgreSQL and B2 report deletion paths passed\n');
  } finally {
    if (db) await db.destroy();
    await admin.query(`DROP SCHEMA IF EXISTS "${schema}" CASCADE`);
    await admin.destroy();
    for (const key of keys) await storage.delete(key, { allVersions: true });
    b2.destroy();
  }
}

main().catch(() => {
  process.stderr.write('PostgreSQL and B2 report deletion check failed\n');
  process.exitCode = 1;
});
