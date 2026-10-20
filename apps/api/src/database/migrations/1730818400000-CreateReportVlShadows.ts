import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportVlShadows1730818400000 implements MigrationInterface {
  name = 'CreateReportVlShadows1730818400000';
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE report_vl_shadows (
      report_id uuid PRIMARY KEY REFERENCES reports(id) ON DELETE CASCADE,
      processing_generation integer NOT NULL,
      candidates jsonb NOT NULL DEFAULT '[]'::jsonb,
      page_status jsonb NOT NULL DEFAULT '[]'::jsonb,
      raw_output jsonb NOT NULL DEFAULT '[]'::jsonb,
      reviews jsonb NOT NULL DEFAULT '{}'::jsonb,
      applied jsonb NOT NULL DEFAULT '{}'::jsonb,
      review_version integer NOT NULL DEFAULT 0,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )`);
  }
  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE report_vl_shadows');
  }
}
