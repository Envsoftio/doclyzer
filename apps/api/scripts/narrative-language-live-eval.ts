/** Opt-in paid provider evaluation using synthetic text only, never real reports. */
import 'reflect-metadata';
import assert from 'node:assert/strict';
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { config } from 'dotenv';
import { ConfigService } from '@nestjs/config';
import type { DataSource, Repository } from 'typeorm';
import { LANGUAGES, SUPPORTED_LANGUAGES } from '../src/common/language';
import { NarrativeTranslationService } from '../src/modules/reports/narrative-translation.service';
import { ReportResultInsightUsageEntity } from '../src/database/entities/report-result-insight-usage.entity';

async function main() {
  if (process.env.RUN_LANGUAGE_LIVE_EVAL !== '1') throw new Error('Set RUN_LANGUAGE_LIVE_EVAL=1 to authorize paid synthetic provider calls.');
  config({ path: '../../.env', quiet: true });
  const settings = new ConfigService({ reports: {
    labAiFallbackOpenaiApiKey: process.env.REPORT_LAB_AI_FALLBACK_OPENAI_API_KEY,
    labAiFallbackOpenaiBaseUrl: process.env.REPORT_LAB_AI_FALLBACK_OPENAI_BASE_URL,
    reportNarrativeOpenaiModel: process.env.REPORT_NARRATIVE_OPENAI_MODEL,
  } });
  const source = {
    numericComparison: 'Haemoglobin is 10.5 g/dL. The printed reference range is 12–16 g/dL. This value is below this laboratory’s printed range. This result alone does not diagnose a condition or establish its cause.',
    uncertainty: 'A result within the reference range does not guarantee health. The comparison may not apply if the unit or range was extracted incorrectly. The available report does not include symptoms or medical history. Discuss these limitations with your clinician.',
    negation: 'A negative result does not always rule out a condition. A possible explanation is not a confirmed diagnosis. Do not change medicines based only on this explanation.',
  };
  const terms = ['Haemoglobin', 'g/dL', '12–16'];
  const rows = new Map<string, { claim: string; status: string; content?: object }>();
  const db = { query: async (sql: string, args: string[]) => {
    const key = `${args[0]}:${args[1]}`, row = rows.get(key);
    if (sql.startsWith('SELECT content')) return row?.status === 'ready' ? [{ content: row.content }] : [];
    if (sql.startsWith('INSERT')) {
      if (row && row.status !== 'failed') return [];
      rows.set(key, { claim: args[4], status: 'pending' }); return [{ claim_id: args[4] }];
    }
    if (sql.includes('SET content=') && row?.claim === args[2]) {
      row.content = JSON.parse(args[3]); row.status = 'ready'; return [[], 1];
    }
    if (row?.claim === args[2]) row.status = 'failed';
    return [[], 1];
  } } as unknown as DataSource;
  let providerCalls = 0;
  const usage = { insert: async () => { providerCalls++; } } as unknown as Repository<ReportResultInsightUsageEntity>;
  const results: object[] = [];
  const requested = process.argv.slice(2);
  const locales = SUPPORTED_LANGUAGES.filter(locale => locale !== 'en' && (!requested.length || requested.includes(locale)));
  let failures = 0;
  for (const locale of locales) {
    const service = new NarrativeTranslationService(settings, db, usage);
    const args = { userId: 'synthetic-user', reportId: 'synthetic-report', kind: 'summary' as const, locale, source, terms, revision: 'synthetic-v1' };
    try {
      const translation = await service.translate(args);
      const calls = providerCalls;
      assert.deepEqual(await new NarrativeTranslationService(settings, db, usage).translate(args), translation);
      assert.equal(providerCalls, calls);
      results.push({ locale, language: LANGUAGES[locale].name, automatedReview: 'accepted', humanClinicalReview: 'pending', translation });
      console.log(`${locale}: accepted by automated checks; cached reload made no provider call`);
    } catch {
      failures++;
      results.push({ locale, language: LANGUAGES[locale].name, automatedReview: 'rejected-or-unavailable', humanClinicalReview: 'pending' });
      console.log(`${locale}: rejected or unavailable; no successful translation cached`);
    }
    writeFileSync(resolve('../../docs/localization/narrative-review-fixtures.json'), JSON.stringify({
      synthetic: true, note: 'Automated review is not a clinical accuracy certification. Native clinical review is pending.',
      model: process.env.REPORT_NARRATIVE_OPENAI_MODEL, generatedAt: new Date().toISOString(), source, results,
    }, null, 2) + '\n');
  }
  if (failures) process.exitCode = 1;
}
main().catch((error) => { console.error(error instanceof Error ? error.message : 'Evaluation failed'); process.exitCode = 1; });
