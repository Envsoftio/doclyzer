import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { DataSource } from 'typeorm';
import { ReportProcessingController } from '../src/modules/reports/processing/report-processing.controller';

async function main() {
  const db = await new DataSource({
    type: 'postgres',
    url: process.env.REPORT_PROCESSING_TEST_DATABASE_URL,
  }).initialize();
  const runner = db.createQueryRunner();
  try {
    // Temporary tables shadow application tables only on this connection.
    await runner.query(`CREATE TEMP TABLE reports (
      id uuid, user_id uuid, profile_id uuid, processing_version bigint DEFAULT 1,
      processing_generation integer DEFAULT 1, processing_state text DEFAULT 'ready',
      processing_stage text DEFAULT 'complete', processing_error_code text,
      processing_retry_at timestamptz, summary_status text, deleted_at timestamptz,
      processing_acknowledged_at timestamptz)`);
    await runner.query(
      `CREATE TEMP TABLE report_inbox (report_id uuid,user_id uuid,generation integer,read_at timestamptz)`,
    );
    const id = randomUUID(),
      user = randomUUID();
    await runner.query(
      'INSERT INTO reports(id,user_id,profile_id) VALUES($1,$2,$3)',
      [id, user, randomUUID()],
    );
    await runner.query(
      'INSERT INTO report_inbox(report_id,user_id,generation) VALUES($1,$2,1),($1,$2,0)',
      [id, user],
    );
    const controller = Object.assign(
      Object.create(ReportProcessingController.prototype),
      { db: runner },
    );
    const req = { user: { id: user } };
    await assert.rejects(
      controller.acknowledge({ user: { id: randomUUID() } }, id),
    );
    await controller.acknowledge(req, id);
    let [row] = await runner.query(
      'SELECT processing_acknowledged_at FROM reports',
    );
    assert.ok(row.processing_acknowledged_at);
    const timestamp = row.processing_acknowledged_at.toISOString();
    // A fresh controller/read represents reload; the acknowledgment is durable.
    await Object.assign(Object.create(ReportProcessingController.prototype), {
      db: runner,
    }).acknowledge(req, id);
    [row] = await runner.query(
      'SELECT processing_acknowledged_at FROM reports',
    );
    assert.equal(row.processing_acknowledged_at.toISOString(), timestamp);
    const inbox = await runner.query(
      'SELECT generation,read_at FROM report_inbox ORDER BY generation',
    );
    assert.equal(inbox[0].read_at, null);
    assert.ok(inbox[1].read_at);
    await runner.query(
      "UPDATE reports SET processing_state='queued',processing_generation=2,processing_acknowledged_at=NULL",
    );
    await controller.acknowledge(req, id);
    [row] = await runner.query(
      'SELECT processing_acknowledged_at FROM reports',
    );
    assert.equal(row.processing_acknowledged_at, null);
    console.log(
      'PASS durable acknowledgment, repeat/reload, ownership, generation-scoped inbox and queued-state guard',
    );
  } finally {
    await runner.release();
    await db.destroy();
  }
}
main().catch(() => {
  console.error('Acknowledgment PostgreSQL test failed (details suppressed)');
  process.exitCode = 1;
});
