import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddShareAccessCode1730819000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" ADD COLUMN "access_code_hash" VARCHAR(72) NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" DROP COLUMN "access_code_hash"`,
    );
  }
}
