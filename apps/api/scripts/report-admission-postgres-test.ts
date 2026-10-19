import {
  ReportJobStore,
  ReportLeaseLostError,
} from '../src/modules/reports/processing/report-job.store';
import { CreateReportJobExecutions1730818000000 } from '../src/database/migrations/1730818000000-CreateReportJobExecutions';
import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { mkdtemp, readFile, writeFile, rm, readdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DataSource } from 'typeorm';
import { CreateDurableReportProcessing1730817800000 } from '../src/database/migrations/1730817800000-CreateDurableReportProcessing';
import { CreateReportUploadIntents1730817900000 } from '../src/database/migrations/1730817900000-CreateReportUploadIntents';
import {
  ReportAdmissionService,
  type ReportAdmissionInput,
} from '../src/modules/reports/processing/report-admission.service';
import type { FileStorageService } from '../src/common/storage/file-storage.interface';

async function main() {
  const url = process.env.REPORT_PROCESSING_TEST_DATABASE_URL;
  if (!url)
    throw new Error(
      'Set REPORT_PROCESSING_TEST_DATABASE_URL to a disposable PostgreSQL database',
    );
  const schema = `admission_test_${randomUUID().replaceAll('-', '')}`;
  const admin = await new DataSource({ type: 'postgres', url }).initialize();
  await admin.query(`CREATE SCHEMA ${schema}`);
  const db = await new DataSource({
    type: 'postgres',
    url,
    extra: {
      max: 8,
      options: `-c search_path=${schema} -c statement_timeout=10000`,
    },
  }).initialize();
  const dir = await mkdtemp(join(tmpdir(), 'report-admission-'));
  let unavailable = false;
  let afterUpload: (() => Promise<void>) | undefined;
  const path = (key: string) => join(dir, key.replaceAll('/', '_'));
  const storage: FileStorageService = {
    durability: 'durable', // Test-only filesystem adapter, never registered in the API.
    async upload(key, bytes) {
      if (unavailable) throw new Error('storage unavailable');
      await writeFile(path(key), bytes);
      await afterUpload?.();
      return key;
    },
    async delete(key) {
      await rm(path(key), { force: true });
    },
    async get(key) {
      return readFile(path(key));
    },
    async getSignedUrl() {
      throw new Error('unused');
    },
  };
  const policy = {
    maxAttempts: 3,
    processingDeadlineMs: 600000,
    uploadDeadlineMs: 60000,
    idempotencyRetentionMs: 86400000,
    cleanupRetryMs: 60000,
  };
  const service = new ReportAdmissionService(db, storage, policy);
  const user = randomUUID(),
    profile = randomUUID(),
    plan = randomUUID();
  const make = (key: string, bytes = 'one'): ReportAdmissionInput => ({
    userId: user,
    profileId: profile,
    idempotencyKey: key,
    file: {
      buffer: Buffer.from(bytes),
      originalname: 'scan.pdf',
      mimetype: 'application/pdf',
    },
  });
  const age = () =>
    db.query(`UPDATE report_upload_intents SET created_at=now()-interval '2 hours',
    abandon_after=now()-interval '1 hour',cleanup_after=now()-interval '1 hour' WHERE state <> 'accepted'`);
  const q = db.createQueryRunner();
  try {
    await db.query(`CREATE TABLE users(id uuid PRIMARY KEY);
      CREATE TABLE profiles(id uuid PRIMARY KEY,user_id uuid NOT NULL);
      CREATE TABLE plans(id uuid PRIMARY KEY,limits jsonb NOT NULL);
      CREATE TABLE user_entitlements(user_id uuid PRIMARY KEY,plan_id uuid NOT NULL);
      CREATE TABLE reports(id uuid PRIMARY KEY,user_id uuid NOT NULL,profile_id uuid NOT NULL,
        original_file_name varchar(512),content_type varchar(128),size_bytes integer,
        original_file_storage_key varchar(1024),status varchar(32),deleted_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now());`);
    await new CreateDurableReportProcessing1730817800000().up(q);
    const migration = new CreateReportUploadIntents1730817900000();
    await migration.up(q);
    await migration.down(q);
    await migration.up(q);
    await new CreateReportJobExecutions1730818000000().up(q);
    await db.query(
      'CREATE TABLE report_lab_values (id uuid PRIMARY KEY,report_id uuid,review_version integer NOT NULL DEFAULT 0)',
    );
    await db.query('INSERT INTO users VALUES ($1)', [user]);
    await db.query('INSERT INTO profiles VALUES ($1,$2)', [profile, user]);
    await db.query(`INSERT INTO plans VALUES ($1,'{"maxReports":10}')`, [plan]);
    await db.query('INSERT INTO user_entitlements VALUES ($1,$2)', [
      user,
      plan,
    ]);
    assert.throws(
      () =>
        new ReportAdmissionService(
          db,
          { ...storage, durability: 'ephemeral' },
          policy,
        ),
      /persistent/,
    );
    // Simultaneous original-byte duplicates use one report/job/reservation.
    const [first, second] = await Promise.all([
      service.accept(make('a')),
      service.accept(make('b')),
    ]);
    assert.equal(first.reportId, second.reportId);
    assert.equal(
      (await db.query('SELECT * FROM report_processing_jobs')).length,
      1,
    );
    assert.equal(
      (await db.query('SELECT * FROM report_processing_events')).length,
      1,
    );
    assert.equal(
      (await db.query('SELECT * FROM report_upload_requests')).length,
      2,
    );
    const [accepted] = await db.query('SELECT * FROM reports WHERE id=$1', [
      first.reportId,
    ]);
    assert.deepEqual(
      await storage.get(accepted.original_file_storage_key),
      Buffer.from('one'),
    );
    // Lost response: no storage dependency and no duplicate job.
    unavailable = true;
    assert.equal((await service.accept(make('a'))).reportId, first.reportId);
    await assert.rejects(service.accept(make('a', 'different')), (e) =>
      (e as Error).message.includes('different upload'),
    );
    unavailable = false;
    await assert.rejects(
      service.accept({ ...make('unauthorized'), profileId: randomUUID() }),
    );
    // Separate new bytes competing for one remaining quota slot.
    await db.query(`UPDATE plans SET limits='{"maxReports":2}'`);
    const quota = await Promise.allSettled([
      service.accept(make('c', 'two')),
      service.accept(make('d', 'three')),
    ]);
    assert.equal(quota.filter((r) => r.status === 'fulfilled').length, 1);
    assert.equal(quota.filter((r) => r.status === 'rejected').length, 1);
    // Existing duplicate still resolves when allowance is full.
    assert.equal((await service.accept(make('e'))).reportId, first.reportId);
    await db.query(`UPDATE plans SET limits='{"maxReports":10}'`);
    // Force event failure after the report/job/request writes: all roll back.
    await db.query(`CREATE FUNCTION reject_event() RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN RAISE EXCEPTION 'injected event failure'; END $$;
      CREATE TRIGGER reject_event BEFORE INSERT ON report_processing_events FOR EACH ROW EXECUTE FUNCTION reject_event()`);
    await assert.rejects(
      service.accept(make('rollback', 'rollback')),
      /injected event failure/,
    );
    assert.equal(
      (
        await db.query(
          "SELECT * FROM report_upload_requests WHERE idempotency_key='rollback'",
        )
      ).length,
      0,
    );
    assert.equal((await db.query('SELECT * FROM reports')).length, 2);
    await db.query('DROP TRIGGER reject_event ON report_processing_events');
    // Storage fails: no accepted rows, but cleanup obligation survives.
    unavailable = true;
    await assert.rejects(
      service.accept(make('storage-fail', 'storage-fail')),
      /storage unavailable/,
    );
    unavailable = false;
    // Sweeper fences slow admission even if a PUT finishes after cleanup.
    afterUpload = async () => {
      afterUpload = undefined;
      await age();
      await service.sweepOrphans();
    };
    await assert.rejects(service.accept(make('slow', 'slow')), (e) =>
      (e as Error).message.includes('expired'),
    );
    await age();
    const cleanup = await service.sweepOrphans();
    assert.ok(cleanup.deleted > 0);
    assert.equal(cleanup.failed, 0);
    assert.equal((await readdir(dir)).length, 2);
    // Repeated sweeps remove a late object PUT for an abandoned intent.
    const [abandoned] = await db.query(
      `SELECT * FROM report_upload_intents WHERE state='abandoned' LIMIT 1`,
    );
    await storage.upload(abandoned.storage_key, Buffer.from('late'));
    await age();
    await service.sweepOrphans();
    assert.equal((await readdir(dir)).length, 2);
    assert.deepEqual(
      await storage.get(accepted.original_file_storage_key),
      Buffer.from('one'),
    );
    // Queue claims commit before execution; SKIP LOCKED gives distinct jobs.
    const jobs = new ReportJobStore(db, 60000);
    const leases = await Promise.all([jobs.claim(), jobs.claim()]);
    const old = leases[0]!,
      other = leases[1]!;
    assert.ok(old && other);
    assert.notEqual(old.jobId, other.jobId);
    assert.equal(await jobs.claim(), null);
    assert.equal(await jobs.heartbeat(old), true);
    await db.query(
      "UPDATE report_processing_jobs SET lease_expires_at=now()-interval '1 second' WHERE id=$1",
      [old.jobId],
    );
    const takeover = (await jobs.claim())!;
    assert.equal(takeover.jobId, old.jobId);
    assert.equal(takeover.attempt, 2);
    assert.notEqual(takeover.token, old.token);
    assert.equal(await jobs.heartbeat(old), false);
    await assert.rejects(
      jobs.complete(old, 'ready', async () => {}),
      ReportLeaseLostError,
    );
    assert.equal(
      (
        await db.query(
          'SELECT outcome FROM report_job_executions WHERE lease_token=$1',
          [old.token],
        )
      )[0].outcome,
      'lease_expired',
    );
    // Result persistence failure must roll back results, state and completion.
    const beforeEvents = (
      await db.query('SELECT * FROM report_processing_events')
    ).length;
    await assert.rejects(
      jobs.complete(takeover, 'ready', async (manager) => {
        await manager.query('INSERT INTO report_lab_values VALUES ($1,$2,0)', [
          randomUUID(),
          takeover.reportId,
        ]);
        throw new Error('injected result failure');
      }),
      /injected result failure/,
    );
    assert.equal((await db.query('SELECT * FROM report_lab_values')).length, 0);
    assert.equal(
      (await db.query('SELECT * FROM report_processing_events')).length,
      beforeEvents,
    );
    await assert.rejects(
      jobs.complete(takeover, 'ready', async (manager) => {
        await manager.query('INSERT INTO report_lab_values VALUES ($1,$2,0)', [
          randomUUID(),
          takeover.reportId,
        ]);
        await manager.query(
          "UPDATE report_processing_jobs SET lease_expires_at=clock_timestamp()-interval '1 second' WHERE id=$1",
          [takeover.jobId],
        );
      }),
      ReportLeaseLostError,
    );
    assert.equal((await db.query('SELECT * FROM report_lab_values')).length, 0);
    await db.query('INSERT INTO report_lab_values VALUES ($1,$2,1)', [
      randomUUID(),
      takeover.reportId,
    ]);
    await assert.rejects(
      jobs.complete(takeover, 'ready', async () => {}),
      /Reviewed/,
    );
    await db.query('DELETE FROM report_lab_values');
    await jobs.complete(takeover, 'ready', async (manager) => {
      await manager.query('INSERT INTO report_lab_values VALUES ($1,$2,0)', [
        randomUUID(),
        takeover.reportId,
      ]);
    });
    assert.equal(
      (
        await db.query('SELECT processing_state FROM reports WHERE id=$1', [
          takeover.reportId,
        ])
      )[0].processing_state,
      'ready',
    );
    assert.equal(
      (
        await db.query(
          'SELECT * FROM report_processing_content_claims WHERE report_id=$1',
          [takeover.reportId],
        )
      ).length,
      0,
    );
    await assert.rejects(
      jobs.complete(takeover, 'ready', async () => {}),
      ReportLeaseLostError,
    );
    await jobs.fail(other, 'PROVIDER_UNAVAILABLE', 60000);
    assert.equal(await jobs.claim(), null);
    await db.query(
      "UPDATE report_processing_jobs SET available_at=now()-interval '1 second' WHERE id=$1",
      [other.jobId],
    );
    const retry = (await jobs.claim())!;
    assert.equal(retry.jobId, other.jobId);
    await jobs.fail(retry, 'INVALID_CONTENT', null);
    assert.equal(
      (
        await db.query('SELECT processing_state FROM reports WHERE id=$1', [
          other.reportId,
        ])
      )[0].processing_state,
      'failed',
    );
    // Crashed worker with exhausted budget becomes an actionable terminal state.
    const exhausted = await service.accept(make('exhausted', 'exhausted'));
    await db.query(
      'UPDATE report_processing_jobs SET max_attempts=1 WHERE report_id=$1',
      [exhausted.reportId],
    );
    const last = (await jobs.claim())!;
    await db.query(
      "UPDATE report_processing_jobs SET lease_expires_at=now()-interval '1 second' WHERE id=$1",
      [last.jobId],
    );
    assert.equal(await jobs.claim(), null);
    assert.equal(
      (
        await db.query(
          'SELECT processing_error_code FROM reports WHERE id=$1',
          [exhausted.reportId],
        )
      )[0].processing_error_code,
      'ATTEMPTS_EXHAUSTED',
    );
    // Deletion wins over a worker holding a previously valid token.
    const deleting = await service.accept(make('deleted', 'deleted'));
    const deletingLease = (await jobs.claim())!;
    assert.equal(deletingLease.reportId, deleting.reportId);
    await db.query('UPDATE reports SET deleted_at=now() WHERE id=$1', [
      deleting.reportId,
    ]);
    await assert.rejects(
      jobs.complete(deletingLease, 'ready', async () => {}),
      ReportLeaseLostError,
    );
    await db.query(
      "UPDATE report_processing_jobs SET lease_expires_at=now()-interval '1 second' WHERE id=$1",
      [deletingLease.jobId],
    );
    assert.equal(await jobs.claim(), null);
    assert.equal(
      (
        await db.query('SELECT state FROM report_processing_jobs WHERE id=$1', [
          deletingLease.jobId,
        ])
      )[0].state,
      'cancelled',
    );
    const deadline = await service.accept(make('deadline', 'deadline'));
    await db.query(
      "UPDATE report_processing_jobs SET created_at=now()-interval '2 hours',deadline_at=now()-interval '1 hour' WHERE report_id=$1",
      [deadline.reportId],
    );
    assert.equal(await jobs.claim(), null);
    assert.equal(
      (
        await db.query(
          'SELECT processing_error_code FROM reports WHERE id=$1',
          [deadline.reportId],
        )
      )[0].processing_error_code,
      'PROCESSING_DEADLINE',
    );
    const superseded = await service.accept(make('superseded', 'superseded'));
    const staleGeneration = (await jobs.claim())!;
    await db.query(
      "UPDATE reports SET processing_generation=2,processing_state='queued' WHERE id=$1",
      [superseded.reportId],
    );
    await assert.rejects(
      jobs.complete(staleGeneration, 'ready', async () => {}),
      ReportLeaseLostError,
    );
    await db.query(
      "UPDATE report_processing_jobs SET lease_expires_at=now()-interval '1 second' WHERE id=$1",
      [staleGeneration.jobId],
    );
    assert.equal(await jobs.claim(), null);
    assert.equal(
      (
        await db.query('SELECT processing_state FROM reports WHERE id=$1', [
          superseded.reportId,
        ])
      )[0].processing_state,
      'queued',
    );
    // Concurrent calls with the SAME key also bind to exactly one request.
    const sameKey = await Promise.all([
      service.accept(make('same-key', 'same-key')),
      service.accept(make('same-key', 'same-key')),
    ]);
    assert.equal(sameKey[0].reportId, sameKey[1].reportId);
    afterUpload = async () => {
      afterUpload = undefined;
      throw new Error('PUT response lost');
    };
    await assert.rejects(
      service.accept(make('put-lost', 'put-lost')),
      /PUT response lost/,
    );
    assert.equal(
      (
        await db.query(
          "SELECT * FROM report_upload_requests WHERE idempotency_key='put-lost'",
        )
      ).length,
      0,
    );
    await age();
    await service.sweepOrphans();
    // Retained identity survives hard deletion and cannot silently accept again.
    await db.query('DELETE FROM reports WHERE id=$1', [first.reportId]);
    await assert.rejects(service.accept(make('a')), (e) =>
      (e as Error).message.includes('no longer available'),
    );
    assert.equal(
      (
        await db.query(
          "SELECT * FROM report_upload_requests WHERE idempotency_key='a'",
        )
      ).length,
      1,
    );
    await db.query(
      `UPDATE report_upload_requests SET created_at=now()-interval '2 days',expires_at=now()-interval '1 day' WHERE idempotency_key='a'`,
    );
    await assert.rejects(service.accept(make('a')), (e) =>
      (e as Error).message.includes('request expired'),
    );
    console.log(
      'PASS admission: concurrent deduplication, lost-response replay, key conflict, authorization, quota reservations, transaction rollback, storage failure, orphan/late-write fencing, tombstones, claims, heartbeat, lease takeover/fencing, result rollback, review/deletion protections, retry/exhaustion and migration up/down/up',
    );
  } finally {
    await q.release();
    await db.destroy();
    await admin.query(`DROP SCHEMA ${schema} CASCADE`);
    await admin.destroy();
    await rm(dir, { recursive: true, force: true });
  }
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
