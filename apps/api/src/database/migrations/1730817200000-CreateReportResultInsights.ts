import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportResultInsights1730817200000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "report_result_insights" (
        "report_id" uuid NOT NULL,
        "cache_key" varchar(64) NOT NULL,
        "insight" jsonb NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "PK_report_result_insights" PRIMARY KEY ("report_id", "cache_key"),
        CONSTRAINT "FK_report_result_insights_report" FOREIGN KEY ("report_id") REFERENCES "reports" ("id") ON DELETE CASCADE
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "report_result_insights"`);
  }
}
