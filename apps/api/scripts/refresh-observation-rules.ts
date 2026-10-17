import { MoreThan } from 'typeorm';
import { AppDataSource } from '../src/database/data-source';
import { ReportLabValueEntity } from '../src/database/entities/report-lab-value.entity';
import { loadObservationRules, normalizeObservation } from '../src/modules/reports/observation-normalizer';

async function main(): Promise<void> {
  const apply = process.argv.includes('--apply');
  await AppDataSource.initialize();
  try {
    const rules = await loadObservationRules((sql) => AppDataSource.query(sql));
    const repo = AppDataSource.getRepository(ReportLabValueEntity);
    let cursor = '';
    let scanned = 0;
    let changed = 0;
    while (true) {
      const rows = await repo.find({
        where: cursor ? { id: MoreThan(cursor) } : {},
        order: { id: 'ASC' },
        take: 500,
      });
      if (rows.length === 0) break;
      for (const row of rows) {
        scanned++;
        const next = normalizeObservation({
          parameterName: row.parameterName,
          value: row.value,
          unit: row.unit,
          corrected: row.reviewVersion > 0,
        }, rules);
        const differs = (Object.keys(next) as Array<keyof typeof next>)
          .some((key) => row[key] !== next[key]);
        if (!differs) continue;
        changed++;
        if (!apply) continue;
        await AppDataSource.transaction(async (manager) => {
          const locked = await manager.getRepository(ReportLabValueEntity).findOne({
            where: { id: row.id }, lock: { mode: 'pessimistic_write' },
          });
          if (!locked) return;
          const current = normalizeObservation({
            parameterName: locked.parameterName,
            value: locked.value,
            unit: locked.unit,
            corrected: locked.reviewVersion > 0,
          }, rules);
          await manager.getRepository(ReportLabValueEntity).update(locked.id, current);
        });
      }
      cursor = rows[rows.length - 1].id;
    }
    console.log(`${apply ? 'Updated' : 'Would update'} ${changed} of ${scanned} observations.`);
  } finally {
    await AppDataSource.destroy();
  }
}

void main().catch((error: unknown) => {
  console.error('Observation refresh failed:', error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
