import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AccountDeletionLifecycle1730818300000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(
      `ALTER TABLE users ADD COLUMN deletion_requested_at timestamptz`,
    );
    await q.query(
      `ALTER TABLE closure_requests ADD COLUMN purge_after_at timestamptz`,
    );
    await q.query(`ALTER TABLE report_upload_intents ADD COLUMN user_id uuid`);
    await q.query(`UPDATE report_upload_intents i SET user_id = r.user_id
      FROM reports r WHERE r.original_file_storage_key = i.storage_key`);
    await q.query(
      `CREATE INDEX report_upload_intents_user ON report_upload_intents(user_id)`,
    );
    await q.query(`CREATE INDEX closure_requests_due ON closure_requests(purge_after_at)
      WHERE status = 'pending'`);
    await q.query(`CREATE TABLE account_deletion_records (
      user_id uuid PRIMARY KEY,
      email varchar(255) NOT NULL,
      requested_at timestamptz NOT NULL,
      purged_at timestamptz NOT NULL DEFAULT now()
    )`);
  }

  async down(q: QueryRunner): Promise<void> {
    await q.query(`DROP TABLE account_deletion_records`);
    await q.query(`DROP INDEX closure_requests_due`);
    await q.query(`DROP INDEX report_upload_intents_user`);
    await q.query(`ALTER TABLE report_upload_intents DROP COLUMN user_id`);
    await q.query(`ALTER TABLE closure_requests DROP COLUMN purge_after_at`);
    await q.query(`ALTER TABLE users DROP COLUMN deletion_requested_at`);
  }
}
