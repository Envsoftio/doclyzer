import type { MigrationInterface, QueryRunner } from 'typeorm';

// Earlier local databases applied the runtime migration before its submission
// budget column was added. Migration history cannot detect edits to applied SQL.
export class RepairReportProviderSubmissionCount1730818200000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(
      'ALTER TABLE report_processing_jobs ADD COLUMN IF NOT EXISTS provider_submission_count integer NOT NULL DEFAULT 0',
    );
  }

  // The previous migration owns this column on a fresh database. A rollback of
  // this repair cannot safely remove it from databases where it already existed.
  async down(): Promise<void> {}
}
