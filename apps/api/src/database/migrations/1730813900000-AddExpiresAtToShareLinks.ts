import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddExpiresAtToShareLinks1730813900000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" ADD COLUMN "expires_at" TIMESTAMPTZ NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" DROP COLUMN "expires_at"`,
    );
  }
}
