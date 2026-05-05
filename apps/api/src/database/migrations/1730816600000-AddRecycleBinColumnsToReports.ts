import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddRecycleBinColumnsToReports1730816600000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" ADD COLUMN "deleted_at" timestamptz NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ADD COLUMN "purge_after_at" timestamptz NULL`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_reports_deleted_at" ON "reports" ("deleted_at")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_reports_purge_after_at" ON "reports" ("purge_after_at")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "public"."idx_reports_purge_after_at"`);
    await queryRunner.query(`DROP INDEX "public"."idx_reports_deleted_at"`);
    await queryRunner.query(
      `ALTER TABLE "reports" DROP COLUMN "purge_after_at"`,
    );
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "deleted_at"`);
  }
}
