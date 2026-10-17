import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportResultInsightUsage1730817300000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(`CREATE TABLE "report_result_insight_usage" (
      "id" uuid NOT NULL DEFAULT gen_random_uuid(), "user_id" uuid NOT NULL,
      "report_id" uuid NOT NULL, "cache_key" varchar(64) NOT NULL, "model" varchar(128) NOT NULL,
      "input_tokens" integer NOT NULL DEFAULT 0, "output_tokens" integer NOT NULL DEFAULT 0,
      "total_tokens" integer NOT NULL DEFAULT 0, "estimated_cost_usd" numeric(12,8) NOT NULL DEFAULT 0,
      "cache_hit" boolean NOT NULL DEFAULT false, "created_at" timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT "PK_report_result_insight_usage" PRIMARY KEY ("id"),
      CONSTRAINT "FK_report_result_insight_usage_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
      CONSTRAINT "FK_report_result_insight_usage_report" FOREIGN KEY ("report_id") REFERENCES "reports"("id") ON DELETE CASCADE
    ); CREATE INDEX "IDX_report_result_insight_usage_created" ON "report_result_insight_usage" ("created_at");`);
  }
  async down(q: QueryRunner): Promise<void> { await q.query('DROP TABLE "report_result_insight_usage"'); }
}
