import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddSelectedReportsToShareLinks1730818900000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" ADD COLUMN "report_ids" UUID[] NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" DROP COLUMN "report_ids"`,
    );
  }
}
