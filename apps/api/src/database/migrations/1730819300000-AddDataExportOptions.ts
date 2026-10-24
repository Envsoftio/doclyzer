import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddDataExportOptions1730819300000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "data_export_requests" ADD COLUMN "options" jsonb NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "data_export_requests" DROP COLUMN "options"`,
    );
  }
}
