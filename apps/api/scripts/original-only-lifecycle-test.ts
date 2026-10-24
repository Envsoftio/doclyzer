import assert from 'node:assert/strict';
import { ConflictException } from '@nestjs/common';
import type { DataSource, EntityManager } from 'typeorm';
import { cancelReportProcessing } from '../src/modules/reports/processing/report-lifecycle';

async function exercise(status: string) {
  const statements: string[] = [];
  const manager = {
    queryRunner: { isTransactionActive: true },
    query: async (sql: string) => {
      statements.push(sql);
      if (sql.includes('SELECT * FROM reports')) {
        return [{
          id: 'report-1',
          profile_id: 'profile-1',
          processing_generation: 2,
          processing_state: 'failed',
          status,
        }];
      }
      if (sql.includes('count(*)::integer')) return [{ count: 0 }];
      if (sql.includes('RETURNING processing_version')) {
        return [[{ processing_version: '3' }], 1];
      }
      if (sql.includes('RETURNING last_cursor')) return [{ last_cursor: '1' }];
      if (sql.includes('RETURNING cursor')) return [{ cursor: '1' }];
      return [];
    },
  } as unknown as EntityManager;
  const db = {
    transaction: async (callback: (m: EntityManager) => Promise<void>) => callback(manager),
  } as unknown as DataSource;
  if (status === 'parsed') {
    await assert.rejects(
      cancelReportProcessing(db, 'owner', 'report-1', false, true),
      ConflictException,
    );
    assert.equal(statements.some((sql) => sql.includes('UPDATE reports SET')), false);
  } else {
    await cancelReportProcessing(db, 'owner', 'report-1', false, true);
    assert.ok(statements.some((sql) => sql.includes("status=CASE WHEN $3 THEN 'unparsed'")));
    assert.ok(statements.some((sql) => sql.includes('DELETE FROM report_lab_values')));
    assert.ok(statements.some((sql) => sql.includes('DELETE FROM report_result_insights')));
    assert.ok(statements.some((sql) => sql.includes('INSERT INTO report_processing_events')));
  }
}

void (async () => {
  await exercise('failed_terminal');
  await exercise('parsed');
  process.stdout.write('Original-only lifecycle contract passed\n');
})().catch((error) => {
  process.stderr.write(`${error}\n`);
  process.exitCode = 1;
});
