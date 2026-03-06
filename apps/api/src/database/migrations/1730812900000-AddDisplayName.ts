import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddDisplayName1730812900000 implements MigrationInterface {
  name = 'AddDisplayName1730812900000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "display_name" character varying(255)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN IF EXISTS "display_name"`);
  }
}
