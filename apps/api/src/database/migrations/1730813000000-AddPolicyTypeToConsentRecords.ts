import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPolicyTypeToConsentRecords1730813000000 implements MigrationInterface {
  name = 'AddPolicyTypeToConsentRecords1730813000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "consent_records" ADD COLUMN IF NOT EXISTS "policy_type" character varying(32)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "consent_records" DROP COLUMN IF EXISTS "policy_type"`,
    );
  }
}
