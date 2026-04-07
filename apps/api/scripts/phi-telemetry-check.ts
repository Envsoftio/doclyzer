/**
 * PHI Telemetry Static Scan
 *
 * Scans TypeScript source files for logger calls that interpolate banned PHI
 * field names. Exits 1 with actionable output if violations are found, 0 if clean.
 *
 * PHI-bearing endpoints must never log request/response bodies verbatim
 * (default-deny policy). Operational logs must use safe identifiers only
 * (reportId, profileId, userId — never summary, transcript, parsedText, etc.).
 *
 * Run via: npm run telemetry:phi-check
 */

import * as fs from 'fs';
import * as path from 'path';

// Banned PHI field names — values of these must never appear in log output
const BANNED_PHI_FIELDS = [
  'summary',
  'transcript',
  'parsedText',
  'displayName',
  'labValue',
  'diagnosis',
  'reportContent',
];

// Matches logger method calls: this.logger.log/warn/error/debug/verbose(
const LOGGER_CALL_RE =
  /\bthis\.logger\.(log|warn|error|debug|verbose)\s*\(/;

// Builds a regex that matches a banned field name used as a value interpolation
// e.g. ${summary}, summary=..., .summary, ["summary"], ['summary']
function buildPhiPattern(field: string): RegExp {
  return new RegExp(
    // Template literal interpolation: ${...summary...} or ${summary}
    `\\$\\{[^}]*\\b${field}\\b[^}]*\\}` +
    `|` +
    // Property access in template/string: .summary or ?.summary
    `\\.\\??\\b${field}\\b` +
    `|` +
    // Assignment in log string: summary= (as interpolated value, not the word)
    `\\b${field}\\b\\s*=\\s*(?!['"\`]?field|['"\`]?name)`,
    'i',
  );
}

interface Violation {
  file: string;
  line: number;
  text: string;
  field: string;
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

function scanFile(filePath: string): Violation[] {
  const violations: Violation[] = [];
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (!LOGGER_CALL_RE.test(line)) continue;

    for (const field of BANNED_PHI_FIELDS) {
      const phiPattern = buildPhiPattern(field);
      if (phiPattern.test(line)) {
        violations.push({
          file: filePath,
          line: i + 1,
          text: line.trim(),
          field,
        });
      }
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

  console.log(`🔍 Scanning ${srcRoot} for PHI field interpolation in logger calls...`);
  console.log(`   Banned PHI fields: ${BANNED_PHI_FIELDS.join(', ')}\n`);

  const files = getSourceFiles(srcRoot);
  const allViolations: Violation[] = [];

  for (const file of files) {
    const violations = scanFile(file);
    allViolations.push(...violations);
  }

  console.log(`   Scanned ${files.length} TypeScript source files.`);

  if (allViolations.length === 0) {
    console.log('\n✅ PHI telemetry check passed — no PHI field interpolation found in logger calls.');
    process.exit(0);
  }

  console.error(`\n🚫 PHI telemetry check FAILED — ${allViolations.length} violation(s) found:\n`);

  for (const v of allViolations) {
    const relativePath = path.relative(path.resolve(__dirname, '..', '..', '..'), v.file);
    console.error(`  [PHI-FIELD: ${v.field}]  ${relativePath}:${v.line}`);
    console.error(`    ${v.text}`);
    console.error('');
  }

  console.error('💡 Remediation: Replace PHI field values with safe identifiers.');
  console.error('   Use reportId, profileId, userId instead of summary, transcript, displayName, etc.');
  console.error('   See apps/api/src/common/redact-secrets.ts for the redactPhi() utility.\n');

  process.exit(1);
}

run();
