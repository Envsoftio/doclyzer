import type { MigrationInterface, QueryRunner } from 'typeorm';

export class ExtendIndianLanguages1730819600000 implements MigrationInterface {
  async up(runner: QueryRunner): Promise<void> {
    await runner.query('ALTER TABLE users DROP CONSTRAINT users_preferred_language_check');
    await runner.query(`ALTER TABLE users ADD CONSTRAINT users_preferred_language_check CHECK (preferred_language IN ('en', 'hi', 'kn', 'te', 'ml', 'ta', 'bn', 'or', 'gu', 'mr'))`);
    await runner.query('ALTER TABLE report_narrative_translations DROP CONSTRAINT report_narrative_translations_locale_check');
    await runner.query(`ALTER TABLE report_narrative_translations ADD CONSTRAINT report_narrative_translations_locale_check CHECK (locale IN ('hi', 'kn', 'te', 'ml', 'ta', 'bn', 'or', 'gu', 'mr'))`);
  }

  async down(runner: QueryRunner): Promise<void> {
    // Refuse a lossy rollback. Operators must explicitly migrate preferences and
    // archive/remove translations before returning to the two-language schema.
    const [row] = await runner.query(`SELECT
      EXISTS(SELECT 1 FROM users WHERE preferred_language NOT IN ('en','hi')) OR
      EXISTS(SELECT 1 FROM report_narrative_translations WHERE locale <> 'hi') AS used`);
    if (row.used) throw new Error('New languages are in use; migrate their data before rollback.');
    await runner.query('ALTER TABLE users DROP CONSTRAINT users_preferred_language_check');
    await runner.query("ALTER TABLE users ADD CONSTRAINT users_preferred_language_check CHECK (preferred_language IN ('en','hi'))");
    await runner.query('ALTER TABLE report_narrative_translations DROP CONSTRAINT report_narrative_translations_locale_check');
    await runner.query("ALTER TABLE report_narrative_translations ADD CONSTRAINT report_narrative_translations_locale_check CHECK (locale IN ('hi'))");
  }
}
