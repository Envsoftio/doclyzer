import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportJobExecutions1730818000000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(`CREATE TABLE report_job_executions (
      id uuid PRIMARY KEY,
      job_id uuid NOT NULL REFERENCES report_processing_jobs(id) ON DELETE CASCADE,
      attempt_number integer NOT NULL CHECK (attempt_number > 0),
      lease_token uuid NOT NULL UNIQUE,
      started_at timestamptz NOT NULL DEFAULT clock_timestamp(),
      finished_at timestamptz,
      outcome varchar(32) NOT NULL DEFAULT 'running' CHECK (outcome IN ('running','succeeded','needs_attention','retry_scheduled','failed','cancelled','lease_expired')),
      error_code varchar(64),
      UNIQUE (job_id,attempt_number)
    )`);
    await q.query(`CREATE INDEX report_source_identity ON reports(user_id,profile_id,source_hash,created_at DESC)
      WHERE source_hash IS NOT NULL AND deleted_at IS NULL`);
  }
  async down(q: QueryRunner): Promise<void> {
    await q.query('DROP INDEX report_source_identity');
    await q.query('DROP TABLE report_job_executions');
  }
}
