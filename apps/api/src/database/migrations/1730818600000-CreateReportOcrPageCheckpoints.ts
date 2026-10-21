import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportOcrPageCheckpoints1730818600000 implements MigrationInterface {
  async up(q: QueryRunner): Promise<void> {
    await q.query(`CREATE TABLE report_ocr_page_checkpoints (
      job_id uuid NOT NULL REFERENCES report_processing_jobs(id) ON DELETE CASCADE,
      page_number integer NOT NULL CHECK (page_number > 0),
      engine varchar(32) NOT NULL,
      output jsonb NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (job_id, page_number, engine)
    )`);
    await q.query(`ALTER TABLE reports ADD COLUMN source_page_count integer
      CHECK (source_page_count IS NULL OR source_page_count BETWEEN 1 AND 1000)`);
  }

  async down(q: QueryRunner): Promise<void> {
    await q.query('ALTER TABLE reports DROP COLUMN source_page_count');
    await q.query('DROP TABLE report_ocr_page_checkpoints');
  }
}
