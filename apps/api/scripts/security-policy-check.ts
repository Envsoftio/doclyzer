/**
 * Security Policy Static Scanner
 *
 * Scans TypeScript source files in apps/api/src for security policy violations:
 *   A. process.env used directly in NestJS modules/services (not in config factories, data-source, main, or scripts)
 *   B. TypeORM Active Record pattern (extends BaseEntity) — use Data Mapper
 *   C. TypeORM synchronize: true — forbidden outside pg-mem test adapter
 *   D. Hardcoded secret literals (password/secret/apikey with literal non-placeholder values)
 *
 * Exits 1 with file:line:violation-type output per finding; exits 0 if clean.
 *
 * Run via: npm run security:policy-check
 */

import * as fs from 'fs';
import * as path from 'path';

interface Check {
  name: string;
  pattern: RegExp;
  /** Optional: skip the line if it also matches this pattern (false-positive guard) */
  skipIfLine?: RegExp;
  /** Optional: skip the line if any of the surrounding N lines match this pattern */
  skipIfContext?: { pattern: RegExp; lines: number };
  message: string;
  hint: string;
  excludeFiles?: string[];
  excludeDirs?: string[];
}

const CHECKS: Check[] = [
  {
    name: 'process.env-in-module',
    pattern: /process\.env\.[A-Z_]+/,
    message: 'Direct process.env access in NestJS module — use ConfigService instead',
    hint: 'Inject ConfigService and use configService.get<string>("KEY") instead of process.env.KEY',
    // Allowed exceptions per project-context.md:
    //   - data-source.ts: TypeORM CLI requires process.env directly (no NestJS DI available)
    //   - src/config/: registerAs() factory functions — the canonical NestJS config pattern
    //   - main.ts: bootstrapper, NestJS app is not yet initialized when process.env is read here
    //   - migrations/: migration files may reference process.env for SQL interpolation
    excludeFiles: ['data-source.ts', 'main.ts'],
    excludeDirs: ['config', 'scripts', 'migrations', 'seeds', 'storage'],
  },
  {
    name: 'active-record-entity',
    pattern: /extends\s+BaseEntity\b/,
    message: 'TypeORM Active Record pattern detected — use Data Mapper (inject Repository)',
    hint: 'Remove "extends BaseEntity"; inject repository via @InjectRepository(Entity)',
  },
  {
    name: 'synchronize-true',
    pattern: /synchronize\s*:\s*true/,
    // Skip if the surrounding context (±3 lines) mentions pg-mem / in-memory test adapter
    skipIfContext: { pattern: /pg.mem|createTypeormDataSource|test.adapter|Never run migrations/i, lines: 3 },
    message: 'TypeORM synchronize:true detected — forbidden outside controlled migrations',
    hint: 'Set synchronize: false and use explicit migrations via migration:run',
  },
  {
    name: 'hardcoded-secret',
    // Match: keyword immediately followed by = or : then a quote and 6+ non-placeholder chars
    // Exclude: values that are clearly column/field names (ending in _hash, _key, _id, _token, _col)
    // Exclude: values that look like placeholders (containing 'placeholder', 'example', 'your_')
    pattern: /\b(password|secret|apikey|api_key)\s*[=:]\s*['"](?!.*(?:_hash|_key|_id|_token|placeholder|example|your_|Demo@|test_))[^${\s'"]{6,}['"]/i,
    message: 'Potential hardcoded secret literal detected',
    hint: 'Move secrets to environment variables and load via ConfigService',
    excludeDirs: ['seeds', 'migrations'],
  },
];

interface Violation {
  file: string;
  line: number;
  text: string;
  checkName: string;
  message: string;
  hint: string;
}

function getSourceFiles(rootDir: string): string[] {
  const results: string[] = [];

  function walk(dir: string): void {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (entry.name === 'node_modules' || entry.name === 'dist') continue;
        walk(full);
      } else if (
        entry.isFile() &&
        entry.name.endsWith('.ts') &&
        !entry.name.endsWith('.spec.ts') &&
        !entry.name.endsWith('.d.ts')
      ) {
        results.push(full);
      }
    }
  }

  walk(rootDir);
  return results;
}

function isExcluded(filePath: string, check: Check): boolean {
  const basename = path.basename(filePath);
  const parts = filePath.split(path.sep);

  if (check.excludeFiles?.includes(basename)) return true;
  if (check.excludeDirs?.some((dir) => parts.includes(dir))) return true;

  return false;
}

function scanFile(filePath: string): Violation[] {
  const violations: Violation[] = [];
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  for (const check of CHECKS) {
    if (isExcluded(filePath, check)) continue;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (!check.pattern.test(line)) continue;
      // Skip known false-positive patterns (same-line guard)
      if (check.skipIfLine && check.skipIfLine.test(line)) continue;
      // Skip if surrounding context lines indicate a known-valid use
      if (check.skipIfContext) {
        const { pattern: ctxPattern, lines: ctxRange } = check.skipIfContext;
        const start = Math.max(0, i - ctxRange);
        const end = Math.min(lines.length - 1, i + ctxRange);
        const context = lines.slice(start, end + 1).join('\n');
        if (ctxPattern.test(context)) continue;
      }

      violations.push({
        file: filePath,
        line: i + 1,
        text: line.trim(),
        checkName: check.name,
        message: check.message,
        hint: check.hint,
      });
    }
  }

  return violations;
}

function run(): void {
  const srcRoot = path.resolve(__dirname, '..', 'src');

  if (!fs.existsSync(srcRoot)) {
    console.error(`❌ Source directory not found: ${srcRoot}`);
    process.exit(1);
  }

  console.log(`🔍 Scanning ${srcRoot} for security policy violations...\n`);
  console.log(`   Checks: ${CHECKS.map((c) => c.name).join(', ')}\n`);

  const files = getSourceFiles(srcRoot);
  const allViolations: Violation[] = [];

  for (const file of files) {
    const violations = scanFile(file);
    allViolations.push(...violations);
  }

  console.log(`   Scanned ${files.length} TypeScript source files.`);

  if (allViolations.length === 0) {
    console.log('\n✅ Security policy check passed — no violations found.');
    process.exit(0);
  }

  console.error(
    `\n🚫 Security policy check FAILED — ${allViolations.length} violation(s) found:\n`,
  );

  for (const v of allViolations) {
    const relativePath = path.relative(
      path.resolve(__dirname, '..', '..', '..'),
      v.file,
    );
    console.error(`  [${v.checkName}]  ${relativePath}:${v.line}`);
    console.error(`    ${v.text}`);
    console.error(`    💡 ${v.hint}`);
    console.error('');
  }

  process.exit(1);
}

run();
