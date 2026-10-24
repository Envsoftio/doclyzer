import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddSelectedResultsToShareLinks1730819100000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" ADD COLUMN "lab_value_ids" UUID[] NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" DROP COLUMN "lab_value_ids"`,
    );
  }
}
