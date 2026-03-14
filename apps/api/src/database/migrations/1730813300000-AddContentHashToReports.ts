import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddContentHashToReports1730813300000
  implements MigrationInterface
{
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "reports"
      ADD COLUMN "content_hash" varchar(64) NULL
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_reports_profile_content_hash" ON "reports" ("profile_id", "content_hash")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "IDX_reports_profile_content_hash"`,
    );
    await queryRunner.query(`
      ALTER TABLE "reports"
      DROP COLUMN "content_hash"
    `);
  }
}
