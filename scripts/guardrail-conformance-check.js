'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const REPORT_PATH = path.join(
  ROOT,
  'docs',
  'compliance',
  'guardrail-conformance-report.md',
);
const WRITE_REPORT = process.argv.includes('--report');

const results = [];
let failures = 0;

function check(name, evidence, condition, hint) {
  const status = condition ? 'PASS' : 'FAIL';
  if (!condition) failures++;
  results.push({ name, status, evidence, hint });
  const icon = condition ? '✅' : '❌';
  console.log(`  ${icon} ${status}: ${name}`);
  if (!condition) {
    console.error(`     ↳ ${hint}`);
  }
}

function filePath(rel) {
  return path.join(ROOT, rel);
}

function fileExists(rel) {
  return fs.existsSync(filePath(rel));
}

function fileContains(rel, text) {
  if (!fileExists(rel)) return false;
  const content = fs.readFileSync(filePath(rel), 'utf8');
  return content.includes(text);
}

function ciContainsJob(jobName) {
  const ciRel = '.github/workflows/ci.yml';
  if (!fileExists(ciRel)) return false;
  const ci = fs.readFileSync(filePath(ciRel), 'utf8');
  const escapedJobName = jobName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const topLevelJobPattern = new RegExp(`^\\s{2}${escapedJobName}:\\s*$`, 'm');
  return topLevelJobPattern.test(ci);
}

function ensureReportDir() {
  const reportDir = path.dirname(REPORT_PATH);
  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }
}

function toMarkdownReport() {
  const nowIso = new Date().toISOString();
  const overall =
    failures === 0
      ? '**PASS**'
      : `**FAIL — ${failures} check(s) failed**`;

  const tableHeader = [
    '| # | Check | Status | Evidence |',
    '|---|-------|--------|----------|',
  ];

  const rows = results.map((item, index) => {
    const statusCell = item.status === 'PASS' ? '✅ PASS' : '❌ FAIL';
    return `| ${index + 1} | ${item.name} | ${statusCell} | \`${item.evidence}\` |`;
  });

  return [
    '# Guardrail Conformance Report',
    '',
    `Generated: ${nowIso}`,
    `Overall: ${overall}`,
    '',
    '## Check Results',
    '',
    ...tableHeader,
    ...rows,
    '',
    '## Guardrail Coverage',
    '',
    '- **Epic 7.1 — AI Disclaimer Enforcement:** Checks 1–2',
    '- **Epic 7.2 — PHI-Safe Telemetry:** Checks 3–4, 9',
    '- **Epic 7.3 — CI Compliance Gates:** Checks 5–8',
    '',
  ].join('\n');
}

function writeReport() {
  ensureReportDir();
  fs.writeFileSync(REPORT_PATH, toMarkdownReport(), 'utf8');
  console.log(`\n📝 Report written: ${path.relative(ROOT, REPORT_PATH)}`);
}

console.log('\n🔍 Running guardrail conformance checks...\n');

check(
  'AI Disclaimer — Web component',
  'apps/web/app/components/AiDisclaimerNote.vue',
  fileContains(
    'apps/web/app/components/AiDisclaimerNote.vue',
    'Informational only',
  ),
  'Create/update apps/web/app/components/AiDisclaimerNote.vue with canonical "Informational only" text.',
);

check(
  'AI Disclaimer — Mobile widget',
  'apps/mobile/lib/shared/ai_disclaimer_note.dart',
  fileContains(
    'apps/mobile/lib/shared/ai_disclaimer_note.dart',
    'Informational only',
  ),
  'Create/update apps/mobile/lib/shared/ai_disclaimer_note.dart with canonical "Informational only" text.',
);

check(
  'PHI Telemetry static scan script',
  'apps/api/scripts/phi-telemetry-check.ts',
  fileExists('apps/api/scripts/phi-telemetry-check.ts'),
  'Create apps/api/scripts/phi-telemetry-check.ts (Story 7.2).',
);

check(
  'PHI Telemetry CI job (phi-telemetry-check)',
  '.github/workflows/ci.yml → phi-telemetry-check',
  ciContainsJob('phi-telemetry-check'),
  'Add phi-telemetry-check job to .github/workflows/ci.yml (Story 7.2).',
);

check(
  'Security Policy static scan script',
  'apps/api/scripts/security-policy-check.ts',
  fileExists('apps/api/scripts/security-policy-check.ts'),
  'Create apps/api/scripts/security-policy-check.ts (Story 7.3).',
);

check(
  'Security Policy CI job (security-policy-check)',
  '.github/workflows/ci.yml → security-policy-check',
  ciContainsJob('security-policy-check'),
  'Add security-policy-check job to .github/workflows/ci.yml (Story 7.3).',
);

check(
  'Migration Check CI job (migration-check)',
  '.github/workflows/ci.yml → migration-check',
  ciContainsJob('migration-check'),
  'Add migration-check job to .github/workflows/ci.yml (Story 7.3).',
);

check(
  'SEO Quality CI job (seo-quality-check)',
  '.github/workflows/ci.yml → seo-quality-check',
  ciContainsJob('seo-quality-check'),
  'Add seo-quality-check job to .github/workflows/ci.yml (Story 7.3).',
);

check(
  'PHI Governance CI job (phi-governance-gate)',
  '.github/workflows/ci.yml → phi-governance-gate',
  ciContainsJob('phi-governance-gate'),
  'Add phi-governance-gate job to .github/workflows/ci.yml (Story 5.6/7.2).',
);

if (WRITE_REPORT || failures === 0) {
  writeReport();
}

if (failures === 0) {
  console.log('\n✅ Guardrail conformance check passed — all checks clean.\n');
  process.exit(0);
}

console.error(`\n🚫 Guardrail conformance check FAILED — ${failures} check(s) failed.\n`);
process.exit(1);
