import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateNotificationReads1730818800000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "notification_reads" (
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "source_type" varchar(16) NOT NULL,
        "source_id" uuid NOT NULL,
        "read_at" timestamptz NOT NULL,
        CONSTRAINT "PK_notification_reads" PRIMARY KEY ("user_id", "source_type", "source_id")
      )
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_notification_reads_user" ON "notification_reads" ("user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_email_queue_inbox_user" ON "email_queue_items" ((metadata ->> 'userId'), "created_at")
      WHERE "email_type" IN ('report.upload_complete', 'report.review_required', 'report.parse_failed')
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "IDX_email_queue_inbox_user"');
    await queryRunner.query('DROP TABLE "notification_reads"');
  }
}
