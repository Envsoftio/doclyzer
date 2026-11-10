import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportResultInsightClaims1730819800000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE report_result_insight_claims (
      report_id uuid NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
      cache_key varchar(64) NOT NULL,
      claim_id uuid NOT NULL,
      lease_expires_at timestamptz NOT NULL,
      PRIMARY KEY (report_id, cache_key)
    )`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE report_result_insight_claims');
  }
}
