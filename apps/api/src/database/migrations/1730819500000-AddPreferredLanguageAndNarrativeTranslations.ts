import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPreferredLanguageAndNarrativeTranslations1730819500000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE users ADD COLUMN preferred_language varchar(10) NOT NULL DEFAULT 'en'
      CHECK (preferred_language IN ('en', 'hi'))`);
    await queryRunner.query(`CREATE TABLE report_narrative_translations (
      report_id uuid NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
      cache_key varchar(64) NOT NULL,
      locale varchar(10) NOT NULL CHECK (locale IN ('hi')),
      kind varchar(16) NOT NULL CHECK (kind IN ('summary', 'insight')),
      content jsonb,
      status varchar(16) NOT NULL CHECK (status IN ('pending', 'ready', 'failed')),
      claim_id uuid NOT NULL,
      lease_expires_at timestamptz NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (report_id, cache_key)
    )`);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE report_narrative_translations');
    await queryRunner.query('ALTER TABLE users DROP COLUMN preferred_language');
  }
}
