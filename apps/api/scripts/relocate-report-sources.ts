import 'reflect-metadata';
import { ConfigService } from '@nestjs/config';
import { AppDataSource } from '../src/database/data-source';
import { storageConfig } from '../src/config/storage.config';
import { B2FileStorageService } from '../src/common/storage/b2-file-storage.service';
import { reportSourceStorageKey } from '../src/modules/reports/processing/report-storage-key';

interface LegacyReport {
  id: string;
  user_id: string;
  profile_id: string;
  content_type: string;
  original_file_storage_key: string;
}

async function main(): Promise<void> {
  const apply = process.argv.includes('--apply');
  const limitArg = process.argv.find((arg) => arg.startsWith('--limit='));
  const limit = limitArg ? Number(limitArg.slice('--limit='.length)) : 100;
  if (!Number.isInteger(limit) || limit < 1 || limit > 1000)
    throw new Error('--limit must be an integer from 1 to 1000');

  await AppDataSource.initialize();
  try {
    const reports: LegacyReport[] = await AppDataSource.query(
      `SELECT id,user_id,profile_id,content_type,original_file_storage_key
       FROM reports WHERE original_file_storage_key LIKE 'report-sources/v1/%'
       ORDER BY created_at,id LIMIT $1`,
      [limit],
    );
    console.log(
      `Found ${reports.length} legacy report sources (limit ${limit}).`,
    );
    if (!apply) {
      console.log(
        'Dry run. Pass --apply to copy, verify, and relocate these reports.',
      );
      return;
    }

    const storage = new B2FileStorageService(
      new ConfigService({ storage: storageConfig() }),
    );
    let moved = 0;
    for (const report of reports) {
      const nextKey = reportSourceStorageKey(
        report.user_id,
        report.profile_id,
        report.id,
        report.content_type,
      );
      let committed = false;
      try {
        committed = await AppDataSource.transaction(async (manager) => {
          // Serialize against account purge and other relocation runs.
          const [user] = await manager.query(
            'SELECT id FROM users WHERE id=$1 FOR UPDATE',
            [report.user_id],
          );
          if (!user) return false;
          const [current]: LegacyReport[] = await manager.query(
            `SELECT id,user_id,profile_id,content_type,original_file_storage_key
             FROM reports WHERE id=$1 FOR UPDATE`,
            [report.id],
          );
          if (
            !current ||
            current.original_file_storage_key !==
              report.original_file_storage_key
          )
            return false;

          const bytes = await storage.get(report.original_file_storage_key);
          await storage.upload(nextKey, bytes, report.content_type, {
            singleVersion: true,
          });
          if (!(await storage.get(nextKey)).equals(bytes))
            throw new Error('Copied report source did not match');
          await manager.query(
            'UPDATE reports SET original_file_storage_key=$1 WHERE id=$2',
            [nextKey, report.id],
          );
          // The original upload intent retains the old key. The orphan sweeper
          // can finish removal if this process stops after the commit.
          return true;
        });
        if (!committed) continue;
        moved++;
        await storage.delete(report.original_file_storage_key, {
          allVersions: true,
        });
      } catch (error) {
        // A failed COMMIT can have an unknown outcome. Never delete the new
        // copy here: it may already be the report's only referenced source.
        console.error(
          `Report ${report.id}: ${error instanceof Error ? error.message : String(error)}`,
        );
        process.exitCode = 1;
      }
    }
    console.log(`Relocated ${moved} of ${reports.length} selected reports.`);
  } finally {
    await AppDataSource.destroy();
  }
}

void main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
