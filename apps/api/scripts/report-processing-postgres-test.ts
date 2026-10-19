import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { DataSource, type QueryRunner } from 'typeorm';
import { CreateDurableReportProcessing1730817800000 } from '../src/database/migrations/1730817800000-CreateDurableReportProcessing';
import { appendReportEvent } from '../src/modules/reports/processing/report-event.store';

async function main() {
  const url = process.env.REPORT_PROCESSING_TEST_DATABASE_URL;
  if (!url)
    throw new Error(
      'Set REPORT_PROCESSING_TEST_DATABASE_URL to a disposable PostgreSQL database',
    );
  const db = await new DataSource({
    type: 'postgres',
    url,
    extra: { max: 5 },
  }).initialize();
  const schema = `processing_test_${randomUUID().replaceAll('-', '')}`;
  const a = db.createQueryRunner(),
    b = db.createQueryRunner(),
    observer = db.createQueryRunner();
  const migration = new CreateDurableReportProcessing1730817800000();
  const user = randomUUID(),
    profile = randomUUID(),
    report = randomUUID(),
    second = randomUUID();
  try {
    await a.query(`CREATE SCHEMA ${schema}`);
    for (const runner of [a, b, observer])
      await runner.query(`SET search_path TO ${schema}`);
    await a.query('CREATE TABLE users (id uuid PRIMARY KEY)');
    await a.query(
      'CREATE TABLE reports (id uuid PRIMARY KEY, user_id uuid NOT NULL, profile_id uuid NOT NULL)',
    );
    await a.query('INSERT INTO users VALUES ($1)', [user]);
    await a.query('INSERT INTO reports VALUES ($1,$2,$3),($4,$2,$3)', [
      report,
      user,
      profile,
      second,
    ]);
    await migration.up(a);
    assert.equal(
      (await a.query('SELECT processing_state FROM reports LIMIT 1'))[0]
        .processing_state,
      null,
    );
    const insertJob = (r: QueryRunner, generation: number) =>
      r.query(
        `INSERT INTO report_processing_jobs
      (id,report_id,generation,trigger,max_attempts,deadline_at) VALUES ($1,$2,$3,'initial_upload',3,now()+interval '1 hour')`,
        [randomUUID(), report, generation],
      );
    await insertJob(a, 1);
    await assert.rejects(insertJob(b, 2), /report_processing_one_active_job/);
    const claim = (r: QueryRunner, id: string) =>
      r.query(
        `INSERT INTO report_processing_content_claims
      VALUES ($1,$2,$3,1,$4)`,
        [user, profile, 'a'.repeat(64), id],
      );
    const [{ pid }] = await b.query('SELECT pg_backend_pid() AS pid');
    const waitForBlock = async () => {
      for (let i = 0; i < 100; i++) {
        const [row] = await observer.query(
          'SELECT cardinality(pg_blocking_pids($1)) > 0 AS blocked',
          [pid],
        );
        if (row.blocked) return;
        await new Promise((resolve) => setTimeout(resolve, 20));
      }
      throw new Error('Expected competing transaction to block');
    };
    await a.startTransaction();
    await claim(a, report);
    const loser = assert.rejects(
      claim(b, second),
      /report_processing_content_claims_pkey/,
    );
    await waitForBlock();
    await a.commitTransaction();
    await loser;
    await a.query('DELETE FROM report_processing_content_claims');
    await a.startTransaction();
    await claim(a, report);
    const winner = claim(b, second);
    await waitForBlock();
    await a.rollbackTransaction();
    await winner;
    await assert.rejects(
      a.query(
        `INSERT INTO report_upload_requests VALUES
      ($1,'report_upload_v2','key',$2,$3,$4,now(),now()+interval '1 day')`,
        [randomUUID(), 'b'.repeat(64), profile, report],
      ),
      /foreign key/,
    );
    await a.query(
      `INSERT INTO report_upload_requests VALUES
      ($1,'report_upload_v2','same-key',$2,$3,$4,now(),now()+interval '1 day')`,
      [user, 'b'.repeat(64), profile, report],
    );
    await assert.rejects(
      a.query(
        `INSERT INTO report_upload_requests VALUES
      ($1,'report_upload_v2','same-key',$2,$3,$4,now(),now()+interval '1 day')`,
        [user, 'c'.repeat(64), profile, second],
      ),
      /report_upload_requests_pkey/,
    );
    await assert.rejects(
      a.query(`UPDATE report_processing_jobs SET state='leased'`),
      /check constraint/,
    );
    await a.query(
      `UPDATE reports SET processing_state='queued',processing_stage='queued',processing_generation=1,processing_version=1`,
    );
    const event = (id: string) => ({
      schemaVersion: 1 as const,
      reportId: id,
      profileId: profile,
      generation: 1,
      version: '1',
      status: 'queued' as const,
      stage: 'queued' as const,
    });
    await assert.rejects(
      appendReportEvent(a.manager, user, event(report)),
      /active transaction/,
    );
    await a.startTransaction();
    await b.startTransaction();
    assert.equal(await appendReportEvent(a.manager, user, event(report)), '1');
    const pendingCursor = appendReportEvent(b.manager, user, event(second));
    await waitForBlock();
    assert.equal(
      (await observer.query('SELECT * FROM report_processing_events')).length,
      0,
    );
    await a.commitTransaction();
    assert.equal(await pendingCursor, '2');
    assert.deepEqual(
      (
        await observer.query(
          'SELECT cursor FROM report_processing_events ORDER BY cursor',
        )
      ).map((r: { cursor: string }) => r.cursor),
      ['1'],
    );
    await b.commitTransaction();
    assert.deepEqual(
      (
        await observer.query(
          'SELECT cursor FROM report_processing_events ORDER BY cursor',
        )
      ).map((r: { cursor: string }) => r.cursor),
      ['1', '2'],
    );
    await a.startTransaction();
    await a.query('UPDATE reports SET processing_version=2 WHERE id=$1', [
      report,
    ]);
    assert.equal(
      await appendReportEvent(a.manager, user, {
        ...event(report),
        version: '2',
      }),
      '3',
    );
    await a.rollbackTransaction();
    assert.equal(
      (await a.query('SELECT last_cursor FROM report_event_cursors'))[0]
        .last_cursor,
      '2',
    );
    await a.startTransaction();
    await assert.rejects(
      appendReportEvent(a.manager, user, { ...event(report), version: '99' }),
      /authoritative/,
    );
    await a.rollbackTransaction();
    await migration.down(a);
    assert.equal((await a.query('SELECT * FROM reports')).length, 2);
    await migration.up(a);
    console.log(
      'PostgreSQL migration, active job uniqueness, claim commit/rollback races, ownership, event ordering and rollback tests passed',
    );
  } finally {
    for (const runner of [a, b])
      if (runner.isTransactionActive) await runner.rollbackTransaction();
    await observer.query(`DROP SCHEMA IF EXISTS ${schema} CASCADE`);
    await Promise.all([a.release(), b.release(), observer.release()]);
    await db.destroy();
  }
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
