import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportUploadIntents1730817900000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    // No account FK: deletion of an account must not lose cleanup obligations.
    await q.query(`CREATE TABLE report_upload_intents (
      id uuid PRIMARY KEY,
      storage_key varchar(1024) NOT NULL UNIQUE,
      state varchar(16) NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','accepted','abandoned')),
      created_at timestamptz NOT NULL DEFAULT now(),
      abandon_after timestamptz NOT NULL CHECK (abandon_after > created_at),
      cleanup_after timestamptz NOT NULL,
      cleanup_attempts integer NOT NULL DEFAULT 0,
      last_cleanup_at timestamptz
    )`);
    await q.query(`CREATE INDEX report_upload_intents_cleanup ON report_upload_intents(cleanup_after)
      WHERE state <> 'accepted'`);
    // Preserve key identity when a report is purged. A replay becomes Gone, not a new charge.
    await q.query(
      `ALTER TABLE report_upload_requests DROP CONSTRAINT report_upload_requests_report_id_user_id_profile_id_fkey`,
    );
    await q.query(`ALTER TABLE report_upload_requests ADD CONSTRAINT report_upload_requests_user_fk
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE`);
  }

  async down(q: QueryRunner): Promise<void> {
    // Expired/purged request tombstones cannot be represented by the old schema.
    await q.query(`DELETE FROM report_upload_requests u WHERE NOT EXISTS
      (SELECT 1 FROM reports r WHERE r.id=u.report_id AND r.user_id=u.user_id AND r.profile_id=u.profile_id)`);
    await q.query(
      `ALTER TABLE report_upload_requests DROP CONSTRAINT report_upload_requests_user_fk`,
    );
    await q.query(`ALTER TABLE report_upload_requests ADD CONSTRAINT report_upload_requests_report_id_user_id_profile_id_fkey
      FOREIGN KEY (report_id,user_id,profile_id) REFERENCES reports(id,user_id,profile_id) ON DELETE CASCADE`);
    await q.query(`DROP TABLE report_upload_intents`);
  }
}
