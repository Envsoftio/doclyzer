import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserRoleColumn1730815400000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN "role" varchar(32) NOT NULL DEFAULT 'user'
    `);

    await queryRunner.query(`
      UPDATE "users"
      SET "role" = 'superadmin'
      WHERE "email" IN ('admin@doclyzer.local', 'vishnu@envsoft.io')
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN "role"
    `);
  }
}
