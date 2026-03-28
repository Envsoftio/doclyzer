import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddReportLabValuesTable1730813400000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "report_lab_values" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "report_id" uuid NOT NULL,
        "parameter_name" varchar(256) NOT NULL,
        "value" varchar(512) NOT NULL,
        "unit" varchar(64) NULL,
        "sample_date" date NULL,
        "sort_order" integer NOT NULL DEFAULT 0,
        CONSTRAINT "PK_report_lab_values" PRIMARY KEY ("id"),
        CONSTRAINT "FK_report_lab_values_report" FOREIGN KEY ("report_id") REFERENCES "reports" ("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_report_lab_values_report_id" ON "report_lab_values" ("report_id")`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_report_lab_values_report_id"`);
    await queryRunner.query(`DROP TABLE "report_lab_values"`);
  }
}
