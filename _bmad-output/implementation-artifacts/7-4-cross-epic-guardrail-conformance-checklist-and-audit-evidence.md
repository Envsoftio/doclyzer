# Story 7.4: Cross-Epic Guardrail Conformance Checklist and Audit Evidence

Status: done

## Story

As a compliance stakeholder,
I want cross-epic conformance evidence,
so that audits can verify guardrail adoption across the entire product.

## Acceptance Criteria

1. **Given** all Epic 7 guardrail stories (7.1–7.3) are complete
   **When** the conformance checklist script runs
   **Then** it produces a human-readable report confirming each guardrail is in place (AI disclaimers present, PHI telemetry clean, CI gates active), with a final PASS/FAIL outcome.
2. **Given** the conformance script runs
   **When** any guardrail check fails (e.g., missing disclaimer component, PHI telemetry violation, CI job missing)
   **Then** the script exits non-zero with a specific, actionable failure message identifying which check failed and what remediation is needed.
3. **Given** the conformance report is produced
   **When** a developer or auditor inspects it
   **Then** it covers all three guardrail categories: (a) AI disclaimer presence, (b) PHI telemetry safety, (c) CI compliance gates — with per-check PASS/FAIL status and evidence (file path or check output).
4. **Given** the CI pipeline runs on any push or pull request
   **When** the guardrail conformance check step executes
   **Then** the build fails if any conformance check fails, with per-check output visible in CI logs.
5. **Given** the conformance report is produced
   **When** it is saved as a Markdown artifact
   **Then** it is written to `docs/compliance/guardrail-conformance-report.md` with a timestamp and per-check table of evidence.

## Tasks / Subtasks

- [x] Task 1: Create `scripts/guardrail-conformance-check.js` — conformance report generator (AC: 1, 2, 3, 5)
  - [x] Plain CommonJS Node.js script (no npm install required — mirrors `scripts/seo-quality-check.js` pattern)
  - [x] Check A (AI Disclaimer): Verify `apps/web/app/components/AiDisclaimerNote.vue` exists AND contains the canonical disclaimer text "Informational only"
  - [x] Check B (AI Disclaimer Mobile): Verify `apps/mobile/lib/shared/ai_disclaimer_note.dart` exists AND contains "Informational only"
  - [x] Check C (PHI Telemetry Script): Verify `apps/api/scripts/phi-telemetry-check.ts` exists
  - [x] Check D (PHI Telemetry CI): Verify `.github/workflows/ci.yml` contains `phi-telemetry-check` job
  - [x] Check E (Security Policy Script): Verify `apps/api/scripts/security-policy-check.ts` exists
  - [x] Check F (Security Policy CI): Verify `.github/workflows/ci.yml` contains `security-policy-check` job
  - [x] Check G (Migration Check CI): Verify `.github/workflows/ci.yml` contains `migration-check` job
  - [x] Check H (SEO Quality CI): Verify `.github/workflows/ci.yml` contains `seo-quality-check` job
  - [x] Check I (PHI Governance CI): Verify `.github/workflows/ci.yml` contains `phi-governance-gate` job
  - [x] Exits 0 if all checks pass; exits 1 if any fail — with per-check PASS/FAIL lines
- [x] Task 2: Generate Markdown audit report to `docs/compliance/guardrail-conformance-report.md` (AC: 5)
  - [x] Script writes the report when run with `--report` flag or when all checks pass
  - [x] Report includes: timestamp, per-check table (Check | Status | Evidence), overall verdict
  - [x] Create `docs/compliance/` folder if it doesn't exist
- [x] Task 3: Wire conformance check into CI as `guardrail-conformance` job (AC: 4)
  - [x] Add `guardrail-conformance` job to `.github/workflows/ci.yml`
  - [x] Job: checkout → `node scripts/guardrail-conformance-check.js` (no npm install, no DB/Docker — pure Node)
  - [x] Job fails CI on non-zero exit; outputs per-check table to CI log
- [x] Task 4: Seed initial conformance report into `docs/compliance/guardrail-conformance-report.md` (AC: 5)
  - [x] Run `node scripts/guardrail-conformance-check.js --report` from repo root locally
  - [x] Commit the generated `docs/compliance/guardrail-conformance-report.md` to the repository
  - [x] Confirm the report shows PASS for all checks given current codebase state

## Dev Notes

### What This Story Does

Story 7.4 is the **audit evidence capstone** for Epic 7. Stories 7.1–7.3 implemented the guardrails themselves (AI disclaimers, PHI telemetry enforcement, CI compliance gates). Story 7.4 creates a single runnable script that **verifies all three guardrails are in place** and produces a Markdown report suitable for audit/compliance review.

This is NOT a new feature — it is a conformance verification layer over existing work.

### File Locations

```
scripts/guardrail-conformance-check.js   ← new conformance verifier (plain CommonJS JS)
docs/compliance/guardrail-conformance-report.md  ← generated audit evidence report
.github/workflows/ci.yml                 ← add guardrail-conformance job
```

### Script Pattern — Follow `seo-quality-check.js` Exactly

The script must be plain CommonJS (`.js`, not `.ts`) — no root `tsconfig.json`, no npm install needed.

```javascript
// scripts/guardrail-conformance-check.js
'use strict';
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const REPORT_PATH = path.join(ROOT, 'docs', 'compliance', 'guardrail-conformance-report.md');
const WRITE_REPORT = process.argv.includes('--report');

const results = [];
let hasFailure = false;

function check(name, evidence, condition, hint) {
  const status = condition ? 'PASS' : 'FAIL';
  if (!condition) hasFailure = true;
  results.push({ name, status, evidence, hint });
  console.log(`  [${status}] ${name}`);
  if (!condition) console.error(`         ↳ ${hint}`);
}

function fileExists(rel) {
  return fs.existsSync(path.join(ROOT, rel));
}

function fileContains(rel, text) {
  if (!fileExists(rel)) return false;
  return fs.readFileSync(path.join(ROOT, rel), 'utf8').includes(text);
}

function ciContainsJob(jobName) {
  const ciPath = path.join(ROOT, '.github', 'workflows', 'ci.yml');
  if (!fs.existsSync(ciPath)) return false;
  return fs.readFileSync(ciPath, 'utf8').includes(jobName + ':');
}
```

Use `check()` for every AC point. Example checks:
```javascript
check(
  'AI Disclaimer — Web component',
  'apps/web/app/components/AiDisclaimerNote.vue',
  fileContains('apps/web/app/components/AiDisclaimerNote.vue', 'Informational only'),
  'Create apps/web/app/components/AiDisclaimerNote.vue with canonical disclaimer text'
);

check(
  'AI Disclaimer — Mobile widget',
  'apps/mobile/lib/shared/ai_disclaimer_note.dart',
  fileContains('apps/mobile/lib/shared/ai_disclaimer_note.dart', 'Informational only'),
  'Create apps/mobile/lib/shared/ai_disclaimer_note.dart with canonical disclaimer text'
);

check(
  'PHI Telemetry static scan script',
  'apps/api/scripts/phi-telemetry-check.ts',
  fileExists('apps/api/scripts/phi-telemetry-check.ts'),
  'Create apps/api/scripts/phi-telemetry-check.ts (Story 7.2)'
);

check(
  'PHI Telemetry CI job (phi-telemetry-check)',
  '.github/workflows/ci.yml → phi-telemetry-check',
  ciContainsJob('phi-telemetry-check'),
  'Add phi-telemetry-check job to .github/workflows/ci.yml (Story 7.2)'
);

check(
  'Security Policy static scan script',
  'apps/api/scripts/security-policy-check.ts',
  fileExists('apps/api/scripts/security-policy-check.ts'),
  'Create apps/api/scripts/security-policy-check.ts (Story 7.3)'
);

check(
  'Security Policy CI job (security-policy-check)',
  '.github/workflows/ci.yml → security-policy-check',
  ciContainsJob('security-policy-check'),
  'Add security-policy-check job to .github/workflows/ci.yml (Story 7.3)'
);

check(
  'Migration Check CI job (migration-check)',
  '.github/workflows/ci.yml → migration-check',
  ciContainsJob('migration-check'),
  'Add migration-check job to .github/workflows/ci.yml (Story 7.3)'
);

check(
  'SEO Quality CI job (seo-quality-check)',
  '.github/workflows/ci.yml → seo-quality-check',
  ciContainsJob('seo-quality-check'),
  'Add seo-quality-check job to .github/workflows/ci.yml (Story 7.3)'
);

check(
  'PHI Governance CI job (phi-governance-gate)',
  '.github/workflows/ci.yml → phi-governance-gate',
  ciContainsJob('phi-governance-gate'),
  'Add phi-governance-gate job to .github/workflows/ci.yml (Story 7.2/5.6)'
);
```

### Report Format

When `--report` is passed, generate `docs/compliance/guardrail-conformance-report.md`:

```markdown
# Guardrail Conformance Report

Generated: <ISO timestamp>
Overall: **PASS** (or **FAIL — N check(s) failed**)

## Check Results

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | AI Disclaimer — Web component | ✅ PASS | apps/web/app/components/AiDisclaimerNote.vue |
| 2 | AI Disclaimer — Mobile widget | ✅ PASS | apps/mobile/lib/shared/ai_disclaimer_note.dart |
...

## Guardrail Coverage

- **Epic 7.1 — AI Disclaimer Enforcement:** Checks 1–2
- **Epic 7.2 — PHI-Safe Telemetry:** Checks 3–4, 9
- **Epic 7.3 — CI Compliance Gates:** Checks 5–8
```

### CI Job for `guardrail-conformance`

Model after `seo-quality-check` — checkout only, Node.js available by default, no npm install:

```yaml
  guardrail-conformance:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Run guardrail conformance check
        run: node scripts/guardrail-conformance-check.js
```

### Current State of Guardrails (as of 2026-04-15)

All checks SHOULD pass with the current codebase:

| Check | Expected State | Source Story |
|-------|---------------|--------------|
| AiDisclaimerNote.vue | Exists with "Informational only" | Story 7.1 |
| ai_disclaimer_note.dart | Exists with "Informational only" | Story 7.1 |
| phi-telemetry-check.ts | Exists | Story 7.2 |
| phi-telemetry-check CI job | In ci.yml | Story 7.2 |
| security-policy-check.ts | Exists | Story 7.3 |
| security-policy-check CI job | In ci.yml | Story 7.3 |
| migration-check CI job | In ci.yml | Story 7.3 |
| seo-quality-check CI job | In ci.yml | Story 7.3 |
| phi-governance-gate CI job | In ci.yml | Story 5.6/7.2 |

If any check fails during Task 4 verification, investigate the relevant story (7.1–7.3) before proceeding.

### Project Structure Notes

- `scripts/` at repo root: currently has `setup-superadmin.sh`, `seo-quality-check.js` — add `guardrail-conformance-check.js` here
- `docs/compliance/` does not exist yet — create it; confirm `docs/` parent exists first
- Use **no external deps** in the script — only `fs`, `path` (built-in Node modules)
- This script must run with bare `node` — no ts-node, no transpilation
- The generated report is committed to the repo (it's audit evidence, not a build artifact)

### Testing Requirements

- **Skip all automated tests** per project Dev Agent Testing Policy.
- Manual validation:
  - Run `node scripts/guardrail-conformance-check.js` from repo root → expect exit 0 with all PASS
  - Run `node scripts/guardrail-conformance-check.js --report` → expect `docs/compliance/guardrail-conformance-report.md` generated
  - To test failure: temporarily rename one of the checked files and confirm exit 1 with correct message

### References

- SEO quality check (script pattern to model): [scripts/seo-quality-check.js](scripts/seo-quality-check.js)
- Existing CI workflow: [.github/workflows/ci.yml](.github/workflows/ci.yml)
- AI Disclaimer Web component: [apps/web/app/components/AiDisclaimerNote.vue](apps/web/app/components/AiDisclaimerNote.vue)
- AI Disclaimer Mobile widget: [apps/mobile/lib/shared/ai_disclaimer_note.dart](apps/mobile/lib/shared/ai_disclaimer_note.dart)
- PHI Telemetry script: [apps/api/scripts/phi-telemetry-check.ts](apps/api/scripts/phi-telemetry-check.ts)
- Security Policy script: [apps/api/scripts/security-policy-check.ts](apps/api/scripts/security-policy-check.ts)
- Epic 7 story definition: `_bmad-output/planning-artifacts/epics.md` §Story 7.4
- Story 7.3 (previous): `_bmad-output/implementation-artifacts/7-3-compliance-guardrail-test-gates-ci-cd-policy-checks.md`
- Architecture ADR-CX4: "Auditability Baseline — consent, policy acceptance, access, sharing, and incident actions must emit queryable audit events." `_bmad-output/planning-artifacts/architecture.md`
- Project context testing policy: `_bmad-output/project-context.md` §Dev Agent Testing Policy

## Dev Agent Record

### Agent Model Used

gpt-5 (Codex)

### Debug Log References

- `node scripts/guardrail-conformance-check.js`
- `node scripts/guardrail-conformance-check.js --report`

### Completion Notes List

- Implemented `scripts/guardrail-conformance-check.js` as a plain CommonJS verifier with 9 guardrail checks spanning AI disclaimers, PHI telemetry/safety checks, and CI compliance gates.
- Added actionable FAIL hints and non-zero exit behavior for any failed conformance check.
- Added report generation support to write `docs/compliance/guardrail-conformance-report.md` when `--report` is used or when all checks pass.
- Added `guardrail-conformance` CI job in `.github/workflows/ci.yml` that runs the script without dependency installation.
- Generated and seeded initial audit evidence report with all checks passing.
- Skipped automated test suite execution per project Dev Agent Testing Policy; performed manual script validation instead.
- Post-review hardening: tightened CI job detection to match top-level YAML job keys instead of raw substring matching.
- Post-review reconciliation: synchronized story file list with all currently staged workspace changes for audit traceability.

### File List

- scripts/guardrail-conformance-check.js
- docs/compliance/guardrail-conformance-report.md
- .github/workflows/ci.yml
- apps/api/src/modules/analytics-admin/analytics-admin.service.ts
- apps/web/app/pages/admin/dashboard/index.vue
- _bmad-output/implementation-artifacts/7-4-cross-epic-guardrail-conformance-checklist-and-audit-evidence.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-04-15: Implemented cross-epic guardrail conformance script, added CI `guardrail-conformance` job, generated and committed initial Markdown conformance report, and moved story to `review`.
- 2026-04-16: Completed AI code review follow-ups, hardened CI job key matching in conformance script, reconciled staged file-list coverage, and moved story to `done`.

## Senior Developer Review (AI)

### Reviewer

Vishnu

### Date

2026-04-16

### Outcome

Approved after fixes

### Summary

- AC validation: all acceptance criteria implemented and verified.
- Task audit: all `[x]` tasks have implementation evidence.
- Fix applied for review finding: replaced substring-based CI job detection with anchored top-level job-key matching.
- Story/Git transparency updated: file list now reflects all staged files in the current workspace state.
