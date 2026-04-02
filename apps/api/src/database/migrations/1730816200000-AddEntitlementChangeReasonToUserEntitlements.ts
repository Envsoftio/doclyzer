import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddEntitlementChangeReasonToUserEntitlements1730816200000
  implements MigrationInterface
{
  name = 'AddEntitlementChangeReasonToUserEntitlements1730816200000';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "user_entitlements"
      ADD COLUMN "last_change_reason" character varying(64)
    `);
    await queryRunner.query(`
      ALTER TABLE "user_entitlements"
      ADD COLUMN "last_change_at" TIMESTAMP WITH TIME ZONE
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "user_entitlements"
      DROP COLUMN "last_change_at"
    `);
    await queryRunner.query(`
      ALTER TABLE "user_entitlements"
      DROP COLUMN "last_change_reason"
    `);
  }
}
