import { config } from 'dotenv';
import { join } from 'path';
import { Client } from 'pg';
import { AppDataSource } from '../src/database/data-source';

function quoteIdentifier(identifier: string): string {
  return `"${identifier.replace(/"/g, '""')}"`;
}

const defaultTestUrl =
  'postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer_test';

async function ensureDatabaseExists(
  databaseName: string,
  url: string,
): Promise<void> {
  const u = new URL(url);
  const adminClient = new Client({
    user: decodeURIComponent(u.username),
    password: decodeURIComponent(u.password),
    host: u.hostname,
    port: Number(u.port || 5432),
    database: 'postgres',
  });

  await adminClient.connect();
  try {
    const existing = await adminClient.query<{ datname: string }>(
      'SELECT datname FROM pg_database WHERE datname = $1',
      [databaseName],
    );

    if (existing.rowCount === 0) {
      const user = decodeURIComponent(u.username);
      await adminClient.query(
        `CREATE DATABASE ${quoteIdentifier(databaseName)} OWNER ${quoteIdentifier(user)}`,
      );
    }
  } finally {
    await adminClient.end();
  }
}

export default async function globalSetup(): Promise<void> {
  // Resolve .env.test from api root (same as setup-env) so cwd doesn't break the path
  const apiRoot = join(__dirname, '..');
  config({ path: join(apiRoot, '.env.test') });
  const databaseUrl = process.env.DATABASE_URL ?? defaultTestUrl;

  const dbNameFromUrl = new URL(databaseUrl).pathname.replace(/^\//, '');
  const testDatabaseName = dbNameFromUrl || 'doclyzer_test';

  await ensureDatabaseExists(testDatabaseName, databaseUrl);

  if (AppDataSource.isInitialized) {
    await AppDataSource.destroy();
  }

  process.env.DATABASE_URL = databaseUrl;
  await AppDataSource.initialize();
  try {
    await AppDataSource.runMigrations();
  } finally {
    await AppDataSource.destroy();
  }
}
