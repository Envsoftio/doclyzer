import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddReportResultCorrections1730817400000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "report_lab_values" ADD "reference_range" varchar(256) NULL`);
    await queryRunner.query(`ALTER TABLE "report_lab_values" ADD "review_version" integer NOT NULL DEFAULT 0`);
    await queryRunner.query(`ALTER TABLE "report_lab_values" ADD "source_snapshot" jsonb NULL`);
    await queryRunner.query(`CREATE TABLE "report_lab_value_corrections" (
      "id" uuid NOT NULL DEFAULT gen_random_uuid(),
      "report_id" uuid NOT NULL,
      "lab_value_id" uuid NOT NULL,
      "user_id" uuid NOT NULL,
      "version" integer NOT NULL,
      "previous_value" jsonb NOT NULL,
      "corrected_value" jsonb NOT NULL,
      "created_at" timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT "PK_report_lab_value_corrections" PRIMARY KEY ("id"),
      CONSTRAINT "UQ_report_lab_value_correction_version" UNIQUE ("lab_value_id", "version"),
      CONSTRAINT "FK_report_lab_value_correction_report" FOREIGN KEY ("report_id") REFERENCES "reports" ("id") ON DELETE CASCADE,
      CONSTRAINT "FK_report_lab_value_correction_value" FOREIGN KEY ("lab_value_id") REFERENCES "report_lab_values" ("id") ON DELETE CASCADE,
      CONSTRAINT "FK_report_lab_value_correction_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE
    )`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "report_lab_value_corrections"`);
    await queryRunner.query(`ALTER TABLE "report_lab_values" DROP COLUMN "source_snapshot"`);
    await queryRunner.query(`ALTER TABLE "report_lab_values" DROP COLUMN "review_version"`);
    await queryRunner.query(`ALTER TABLE "report_lab_values" DROP COLUMN "reference_range"`);
  }
}
