import { MigrationInterface, QueryRunner } from 'typeorm';

export class RepairReportVlShadowsApplied1730818500000 implements MigrationInterface {
  name = 'RepairReportVlShadowsApplied1730818500000';

  async up(queryRunner: QueryRunner): Promise<void> {
    // Some databases created this table before `applied` was added to its
    // original migration. TypeORM will not rerun an already recorded migration.
    await queryRunner.query(`ALTER TABLE report_vl_shadows
      ADD COLUMN IF NOT EXISTS applied jsonb NOT NULL DEFAULT '{}'::jsonb`);
  }

  async down(_queryRunner: QueryRunner): Promise<void> {
    // The original table migration also defines this column. Removing it here
    // would discard reviewed results on databases with the complete schema.
  }
}
