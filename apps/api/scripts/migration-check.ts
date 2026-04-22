/**
 * Migration Pending Check
 *
 * Detects any TypeORM migrations that have not been applied to the database.
 * Exits 1 with an actionable list of pending migration names if any are unapplied;
 * exits 0 if all migrations are applied.
 *
 * Run via: npm run migration:check-pending
 * Requires DATABASE_URL environment variable pointing to a database where migrations have been run.
 */

import { AppDataSource } from '../src/database/data-source';

async function run(): Promise<void> {
  console.log('🔍 Checking for pending TypeORM migrations...\n');

  await AppDataSource.initialize();

  try {
    const hasPending = await AppDataSource.showMigrations();

    if (!hasPending) {
      console.log('✅ Migration check passed — all migrations are applied.');
      return;
    }

    // List which specific migrations are pending for actionable output
    const applied: Array<{ name: string }> = await AppDataSource.query(
      `SELECT name FROM migrations ORDER BY id`,
    );
    const appliedNames = new Set(applied.map((r) => r.name));

    const pending = AppDataSource.migrations
      .map((m) => m.name)
      .filter((name): name is string => Boolean(name))
      .filter((name) => !appliedNames.has(name));

    console.error(`\n🚫 Migration check FAILED — ${pending.length} pending migration(s) detected:\n`);
    for (const name of pending) {
      console.error(`  - ${name}`);
    }
    console.error(
      '\n💡 Remediation: Run migrations before deploying or merging.',
    );
    console.error(
      '   Command: npm run migration:run (from apps/api with DATABASE_URL set)\n',
    );

    process.exit(1);
  } finally {
    await AppDataSource.destroy();
  }
}

run().catch((error: unknown) => {
  const err = error as Error;
  console.error('Migration check crashed:', err.message ?? error);
  process.exit(1);
});
