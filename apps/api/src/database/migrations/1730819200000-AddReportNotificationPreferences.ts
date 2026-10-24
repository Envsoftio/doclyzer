import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddReportNotificationPreferences1730819200000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "account_preferences"
      ADD COLUMN "report_ready_enabled" boolean NOT NULL DEFAULT true,
      ADD COLUMN "upload_updates_enabled" boolean NOT NULL DEFAULT true,
      ADD COLUMN "share_reminders_enabled" boolean NOT NULL DEFAULT true`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "account_preferences"
      DROP COLUMN "share_reminders_enabled",
      DROP COLUMN "upload_updates_enabled",
      DROP COLUMN "report_ready_enabled"`);
  }
}
