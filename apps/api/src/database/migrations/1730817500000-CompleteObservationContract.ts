import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CompleteObservationContract1730817500000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "report_lab_values"
      ADD "original_parameter_name" varchar(256),
      ADD "raw_result" varchar(512),
      ADD "original_unit" varchar(64),
      ADD "original_sample_date" date,
      ADD "canonical_test_id" varchar(64),
      ADD "parsed_numeric_value" numeric,
      ADD "normalized_numeric_value" numeric,
      ADD "comparison_qualifier" varchar(16),
      ADD "result_kind" varchar(16),
      ADD "normalized_unit" varchar(64),
      ADD "collection_date_source" varchar(24),
      ADD "extraction_source" varchar(32),
      ADD "review_state" varchar(24)`);

    // The source snapshot predates this migration for corrected rows. Never infer
    // a missing original from a report upload timestamp or a different row.
    await queryRunner.query(`UPDATE "report_lab_values" SET
      "original_parameter_name" = COALESCE("source_snapshot"->>'parameterName', "parameter_name"),
      "raw_result" = COALESCE("source_snapshot"->>'value', "value"),
      "original_unit" = COALESCE("source_snapshot"->>'unit', "unit"),
      "original_sample_date" = CASE WHEN "review_version" > 0 THEN NULL ELSE "sample_date" END,
      "canonical_test_id" = NULL,
      "collection_date_source" = CASE WHEN "sample_date" IS NULL THEN 'unknown'
        WHEN "review_version" > 0 THEN 'corrected' ELSE 'legacy_extracted' END,
      "extraction_source" = 'legacy_unknown',
      "review_state" = CASE WHEN "review_version" > 0 THEN 'corrected'
        ELSE 'needs_review' END`);

    await queryRunner.query(String.raw`WITH parsed AS (
      SELECT id,
        trim("value") AS v,
        regexp_replace(trim("value"), '^(<=|>=|<|>|≤|≥)[[:space:]]*', '') AS body,
        CASE WHEN trim("value") LIKE '<=%' OR trim("value") LIKE '≤%' THEN 'lte'
          WHEN trim("value") LIKE '>=%' OR trim("value") LIKE '≥%' THEN 'gte'
          WHEN trim("value") LIKE '<%' THEN 'lt'
          WHEN trim("value") LIKE '>%' THEN 'gt'
          ELSE 'exact' END AS qualifier
      FROM "report_lab_values"
    ), typed AS (
      SELECT id, qualifier,
        CASE WHEN body ~ '^[+-]?([0-9]+([.][0-9]+)?|[.][0-9]+)$'
          OR body ~ '^[+-]?[0-9]{1,3}(,[0-9]{3})+([.][0-9]+)?$'
          THEN replace(body, ',', '')::numeric ELSE NULL END AS number,
        v, body
      FROM parsed
    )
    UPDATE "report_lab_values" lv SET
      "parsed_numeric_value" = typed.number,
      "comparison_qualifier" = CASE WHEN typed.number IS NOT NULL THEN typed.qualifier ELSE NULL END,
      "result_kind" = CASE WHEN typed.number IS NOT NULL AND typed.qualifier = 'exact' THEN 'numeric'
        WHEN typed.number IS NOT NULL THEN 'qualified'
        WHEN typed.v ~ '^[+-]?[0-9.,[:space:]]+$' OR typed.qualifier <> 'exact' THEN 'ambiguous'
        ELSE 'qualitative' END,
      "normalized_unit" = NULL
    FROM typed WHERE typed.id = lv.id`);
    await queryRunner.query(`UPDATE "report_lab_values" SET
      "normalized_numeric_value" = NULL,
      "review_state" = 'needs_review'`);
    await queryRunner.query(`ALTER TABLE "report_lab_values"
      ALTER COLUMN "original_parameter_name" SET NOT NULL,
      ALTER COLUMN "raw_result" SET NOT NULL,
      ALTER COLUMN "result_kind" SET NOT NULL,
      ALTER COLUMN "collection_date_source" SET NOT NULL,
      ALTER COLUMN "extraction_source" SET NOT NULL,
      ALTER COLUMN "review_state" SET NOT NULL`);
    await queryRunner.query(`CREATE INDEX "IDX_report_lab_values_canonical_test"
      ON "report_lab_values" ("canonical_test_id", "normalized_unit")`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_report_lab_values_canonical_test"`);
    await queryRunner.query(`ALTER TABLE "report_lab_values"
      DROP COLUMN "review_state", DROP COLUMN "extraction_source",
      DROP COLUMN "collection_date_source", DROP COLUMN "normalized_unit",
      DROP COLUMN "result_kind", DROP COLUMN "comparison_qualifier",
      DROP COLUMN "normalized_numeric_value", DROP COLUMN "parsed_numeric_value",
      DROP COLUMN "canonical_test_id", DROP COLUMN "original_sample_date",
      DROP COLUMN "original_unit", DROP COLUMN "raw_result",
      DROP COLUMN "original_parameter_name"`);
  }
}
