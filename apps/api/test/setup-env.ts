import { config } from 'dotenv';
import { join } from 'path';

// Prefer .env.test; fallback to explicit E2E URL so Jest (any cwd/__dirname) always uses doclyzer_test
const apiRoot = join(__dirname, '..');
config({ path: join(apiRoot, '.env.test'), override: true });
if (!process.env.DATABASE_URL?.includes('doclyzer_test')) {
  process.env.DATABASE_URL =
    'postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer_test';
}
