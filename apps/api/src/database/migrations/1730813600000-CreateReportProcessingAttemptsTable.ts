import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportProcessingAttemptsTable1730813600000
  implements MigrationInterface
{
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "report_processing_attempts" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "report_id" uuid NOT NULL,
        "trigger" character varying(32) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "attempted_at" TIMESTAMPTZ NOT NULL,
        CONSTRAINT "PK_report_processing_attempts" PRIMARY KEY ("id"),
        CONSTRAINT "FK_report_processing_attempts_report_id" FOREIGN KEY ("report_id")
          REFERENCES "reports"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_report_processing_attempts_report_id" ON "report_processing_attempts" ("report_id")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "report_processing_attempts"`);
  }
}
