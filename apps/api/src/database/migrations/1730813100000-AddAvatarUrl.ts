import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddAvatarUrl1730813100000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "avatar_url" varchar(1024)`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" DROP COLUMN IF EXISTS "avatar_url"`,
    );
  }
}
