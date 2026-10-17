import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateObservationRules1730817600000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "lab_tests" (
      "id" varchar(64) PRIMARY KEY,
      "display_name" varchar(256) NOT NULL,
      "approved_by" varchar(256) NOT NULL,
      "approved_at" timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE TABLE "lab_test_aliases" (
      "alias_key" varchar(256) PRIMARY KEY,
      "canonical_test_id" varchar(64) NOT NULL REFERENCES "lab_tests"("id") ON DELETE CASCADE,
      "approved_by" varchar(256) NOT NULL,
      "approved_at" timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE TABLE "lab_unit_rules" (
      "canonical_test_id" varchar(64) NOT NULL REFERENCES "lab_tests"("id") ON DELETE CASCADE,
      "source_unit_key" varchar(64) NOT NULL,
      "target_unit" varchar(64) NOT NULL,
      "decimal_exponent" integer NOT NULL CHECK ("decimal_exponent" BETWEEN -12 AND 12),
      "approved_by" varchar(256) NOT NULL,
      "approved_at" timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY ("canonical_test_id", "source_unit_key")
    )`);
    // The preceding migration may already have run with its old fixed aliases
    // in a development database. Remove those derived claims without touching
    // the original labels, results, units, dates, or correction history.
    await queryRunner.query(`UPDATE "report_lab_values" SET
      "canonical_test_id" = NULL,
      "normalized_unit" = NULL,
      "normalized_numeric_value" = NULL,
      "review_state" = 'needs_review'`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "lab_unit_rules"`);
    await queryRunner.query(`DROP TABLE "lab_test_aliases"`);
    await queryRunner.query(`DROP TABLE "lab_tests"`);
  }
}
