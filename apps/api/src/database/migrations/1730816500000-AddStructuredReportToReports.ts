import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddStructuredReportToReports1730816500000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" ADD COLUMN "structured_report" jsonb NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" DROP COLUMN "structured_report"`,
    );
  }
}
