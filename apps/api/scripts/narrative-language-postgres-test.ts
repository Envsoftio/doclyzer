import { AddPunjabiLanguage1730819700000 } from '../src/database/migrations/1730819700000-AddPunjabiLanguage';
import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { ConfigService } from '@nestjs/config';
import { config } from 'dotenv';
import { DataSource, type QueryRunner, type Repository } from 'typeorm';
import { AddPreferredLanguageAndNarrativeTranslations1730819500000 } from '../src/database/migrations/1730819500000-AddPreferredLanguageAndNarrativeTranslations';
import { ExtendIndianLanguages1730819600000 } from '../src/database/migrations/1730819600000-ExtendIndianLanguages';
import { SUPPORTED_LANGUAGES } from '../src/common/language';
import { NarrativeTranslationService } from '../src/modules/reports/narrative-translation.service';
import { ReportResultInsightUsageEntity } from '../src/database/entities/report-result-insight-usage.entity';

async function main() {
  config({ path: '../../.env', quiet: true });
  const db = await new DataSource({ type: 'postgres', url: process.env.REPORT_PROCESSING_TEST_DATABASE_URL ?? process.env.DATABASE_URL }).initialize();
  const runner = db.createQueryRunner();
  const originalFetch = global.fetch;
  try {
    // Every mutation is confined to this connection's temporary schema.
    await runner.query('SET search_path TO pg_temp');
    await runner.query('CREATE TEMP TABLE users (id uuid PRIMARY KEY)');
    await runner.query('CREATE TEMP TABLE reports (id uuid PRIMARY KEY)');
    const migration = new AddPreferredLanguageAndNarrativeTranslations1730819500000();
    await migration.up({ query: (sql: string) => runner.query(sql.replace('CREATE TABLE report_narrative_translations', 'CREATE TEMP TABLE report_narrative_translations')) } as QueryRunner);
    const extension = new ExtendIndianLanguages1730819600000();
    await extension.up(runner);
    const punjabi = new AddPunjabiLanguage1730819700000();
    await punjabi.up(runner);
    const userId = randomUUID(), reportId = randomUUID();
    await runner.query('INSERT INTO users(id) VALUES($1)', [userId]);
    await runner.query('INSERT INTO reports(id) VALUES($1)', [reportId]);
    const usage = { insert: async () => undefined } as unknown as Repository<ReportResultInsightUsageEntity>;
    const settings = new ConfigService({ reports: { labAiFallbackOpenaiApiKey: 'synthetic-key', reportNarrativeOpenaiModel: 'test-model' } });
    const service = new NarrativeTranslationService(settings, runner as unknown as DataSource, usage);
    assert.equal(await service.resolveLanguage(userId, undefined), 'en');
    await runner.query("UPDATE users SET preferred_language='hi' WHERE id=$1", [userId]);
    assert.equal(await service.resolveLanguage(userId, undefined), 'hi');
    await assert.rejects(runner.query("UPDATE users SET preferred_language='fr' WHERE id=$1", [userId]));
    await runner.query("UPDATE users SET preferred_language='pa' WHERE id=$1", [userId]);
    await assert.rejects(punjabi.down(runner), /Punjabi is in use/);
    await runner.query("UPDATE users SET preferred_language='hi' WHERE id=$1", [userId]);
    let calls = 0;
    global.fetch = async (_url, init) => {
      const body = JSON.parse(String(init?.body));
      const input = JSON.parse(body.input);
      if (body.text.format.name === 'narrative_review') {
        return new Response(JSON.stringify({ output_text: JSON.stringify({ segments: input.source.map((_: string, index: number) => ({ index, faithful: true, correctLanguage: true, patientFriendly: true })) }) }));
      }
      calls++;
      const prefix = body.instructions.includes('Punjabi') ? 'ਇਹ ਨਤੀਜਾ ਹੈ।' : 'यह परिणाम है।';
      const segments = input.segments.map((text: string) => `${prefix} ${ (text.match(/\[\[KEEP_[A-Z]+\]\]/g) ?? []).join(' ') }`);
      return new Response(JSON.stringify({ output_text: JSON.stringify({ segments }) }), { status: 200 });
    };
    const args = { userId, reportId, locale: 'hi' as const, kind: 'summary' as const, source: { summary: 'Hb is 10 g/dL.' }, terms: ['Hb', 'g/dL'], revision: 'first' };
    const result = await service.translate(args);
    assert.ok(result.summary.includes('10'));
    const reloaded = new NarrativeTranslationService(settings, runner as unknown as DataSource, usage);
    assert.deepEqual(await reloaded.translate(args), result); assert.equal(calls, 1);
    await reloaded.translate({ ...args, revision: 'corrected' }); assert.equal(calls, 2);
    await runner.query("UPDATE report_narrative_translations SET status='pending', lease_expires_at=now()+interval '1 minute'");
    await assert.rejects(reloaded.translate(args), /being prepared/); assert.equal(calls, 2);
    await runner.query("UPDATE report_narrative_translations SET lease_expires_at=now()-interval '1 second'");
    await reloaded.translate(args); assert.equal(calls, 3);
    const punjabiArgs = { ...args, locale: 'pa' as const };
    const punjabiResult = await service.translate(punjabiArgs);
    assert.match(String(punjabiResult.summary), /\p{Script=Gurmukhi}/u);
    assert.ok(String(punjabiResult.summary).includes('10 g/dL'));
    const freshService = new NarrativeTranslationService(settings, runner as unknown as DataSource, usage);
    assert.deepEqual(await freshService.translate(punjabiArgs), punjabiResult);
    assert.equal(calls, 4, 'Punjabi is cached separately and survives service reload');
    await runner.query('DELETE FROM reports WHERE id=$1', [reportId]);
    assert.equal((await runner.query('SELECT * FROM report_narrative_translations')).length, 0);
    for (const locale of SUPPORTED_LANGUAGES) {
      await runner.query('UPDATE users SET preferred_language=$2 WHERE id=$1', [userId, locale]);
      assert.equal(await service.resolveLanguage(userId, undefined), locale);
      if (locale !== 'en') {
        await runner.query('INSERT INTO reports(id) VALUES($1)', [reportId]);
        await runner.query(`INSERT INTO report_narrative_translations(report_id,cache_key,locale,kind,status,claim_id,lease_expires_at)
          VALUES($1,$2,$3,'summary','ready',$4,now())`, [reportId, locale, locale, randomUUID()]);
        if (locale === 'pa') {
          // Check rollback guards for preferences and cached prose independently.
          await assert.rejects(punjabi.down(runner), /Punjabi is in use/);
          await runner.query("UPDATE users SET preferred_language='en'");
          await assert.rejects(punjabi.down(runner), /Punjabi is in use/);
        }
        if (locale !== 'hi') await assert.rejects(extension.down(runner), /New languages are in use/);
        await runner.query('DELETE FROM reports WHERE id=$1', [reportId]);
      }
    }
    await runner.query("UPDATE users SET preferred_language='en'");
    await punjabi.down(runner);
    await assert.rejects(runner.query("UPDATE users SET preferred_language='pa'"));
    await extension.down(runner);
    await assert.rejects(runner.query("UPDATE users SET preferred_language='kn'"));
    await migration.down(runner);
    console.log('PASS PostgreSQL migration, language persistence, saved translation reload, atomic lease/recovery, source revision invalidation, report deletion cascade, rollback');
  } finally { global.fetch = originalFetch; await runner.release(); await db.destroy(); }
}
main().catch((error) => { console.error('Narrative PostgreSQL test failed:', error instanceof Error ? error.message : 'unknown'); process.exitCode = 1; });
