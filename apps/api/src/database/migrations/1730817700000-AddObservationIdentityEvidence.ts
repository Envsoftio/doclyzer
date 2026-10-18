import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddObservationIdentityEvidence1730817700000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "report_lab_values" ADD "identity_evidence" jsonb`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "report_lab_values" DROP COLUMN "identity_evidence"`);
  }
}
