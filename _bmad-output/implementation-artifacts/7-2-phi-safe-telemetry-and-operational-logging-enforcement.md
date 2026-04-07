# Story 7.2: PHI-Safe Telemetry and Operational Logging Enforcement

Status: review

## Story

As a platform owner,
I want PHI-safe telemetry enforcement,
so that observability does not leak sensitive data.

## Acceptance Criteria

1. **Given** any operational log is emitted by the API
   **When** the log message is inspected
   **Then** no PHI fields (report content, summary text, transcript, lab values, profile names, user emails beyond userId references) appear in the payload.
2. **Given** a PHI-bearing endpoint (reports, profiles, sharing) processes a request
   **When** the request body or response body could be logged
   **Then** request/response body logging is default-deny (bodies are never logged verbatim).
3. **Given** `redactSecrets()` is used in the codebase
   **When** PHI-sensitive field names are encountered in log strings
   **Then** those fields are covered by the redaction utility (or a new `redactPhi()` utility enforces it).
4. **Given** a scan of all `this.logger.*` call sites across all API service files
   **When** the scan runs
   **Then** zero log messages interpolate PHI field values (summary, transcript, parsedText, displayName in non-audit context, email outside enumeration-safe paths, labResult, diagnosis).
5. **Given** the CI pipeline executes on any push/PR
   **When** the phi-telemetry static scan step runs
   **Then** any new logger call containing banned PHI field patterns causes the build to fail with actionable output.

## Tasks / Subtasks

- [x] Task 1: Audit all `this.logger.*` call sites across API modules for PHI field interpolation (AC: 1, 4)
  - [x] Scan `apps/api/src/modules/**/*.ts` for logger calls that include PHI field names
  - [x] Document any violations found (expected: zero or near-zero based on prior review)
  - [x] Fix any violations by removing the PHI value or replacing with a safe identifier (e.g., `reportId`, `profileId`)
- [x] Task 2: Extend `redactSecrets()` or create `redactPhi()` to cover PHI field names (AC: 3)
  - [x] Add PHI field name patterns to `apps/api/src/common/redact-secrets.ts` OR create `apps/api/src/common/redact-phi.ts`
  - [x] Patterns to cover: `summary`, `transcript`, `parsedText`, `displayName`, `labValue`, `diagnosis`, `reportContent`
  - [x] Ensure the utility strips the value portion (e.g. `summary=***REDACTED***`) without breaking existing safe log messages
- [x] Task 3: Add a phi-telemetry static scan script (AC: 5)
  - [x] Create `apps/api/scripts/phi-telemetry-check.ts` (standalone, no NestJS context needed)
  - [x] Script scans TypeScript source files for `logger.(log|warn|error|debug)` calls containing banned PHI field names
  - [x] Exit code 1 with actionable output if violations found; exit code 0 if clean
  - [x] Add npm script `"telemetry:phi-check": "ts-node scripts/phi-telemetry-check.ts"` to `apps/api/package.json`
- [x] Task 4: Wire the phi-telemetry check into CI (AC: 5)
  - [x] Add a `phi-telemetry-check` job to `.github/workflows/ci.yml`
  - [x] Job runs `npm run telemetry:phi-check` (no database or Docker required)
  - [x] Job fails CI on non-zero exit
- [x] Task 5: Confirm body-logging default-deny is documented and enforced (AC: 2)
  - [x] Verify `ApiExceptionFilter` does not log request/response bodies
  - [x] Verify no middleware or interceptor logs raw request/response body
  - [x] Add a code comment in `api-exception.filter.ts` and `main.ts` noting the default-deny policy

## Dev Notes

### Existing Redaction Infrastructure

- **`apps/api/src/common/redact-secrets.ts`** — already handles env key secrets (DB URLs, API keys, Bearer tokens). EXTEND this (or create a sibling `redact-phi.ts`) to cover PHI field name patterns.
- `redactSecrets()` is already called in: `api-exception.filter.ts`, `main.ts`, `report-summary.service.ts`, `reports.service.ts`, `docling.client.ts`.
- Pattern for existing secret redaction: regex replaces `KEY=value` → `KEY=***REDACTED***`. Apply same approach for PHI field names.

### Current Logger Usage — Audit Findings

Based on code scan, the following patterns are SAFE (already using `redactSecrets()` or safe identifiers only):

- `auth.service.ts` — logs `userId=`, `Auth registration/login/logout success` — **safe**
- `reports.service.ts` — logs `existingReportId=`, `newReportId=`, storage key via `redactSecrets()` — **safe**
- `report-summary.service.ts` — all warns wrapped in `redactSecrets()`, `"Summariser response missing summary field"` (no value) — **safe**
- `docling.client.ts` — all errors wrapped in `redactSecrets()` — **safe**
- `billing.service.ts` — logs `order.id`, `subscription.id`, `razorpay_order_id` (billing identifiers, not PHI) — **safe**
- `api-exception.filter.ts` — logs `status`, `path`, `correlationId`, `code` only — **safe**

**No active PHI leakage violations found in current code.** Story's value is: (a) adding a utility to prevent future regressions, and (b) adding a CI gate that keeps it enforced.

### PHI Field Patterns to Block in Scan Script

```
summary     — report AI summary text
transcript  — parsed report transcript
parsedText  — raw parsed document content  
displayName — user/profile display name (PII, not structural ID)
labValue    — lab test result value
diagnosis   — clinical diagnosis text
reportContent — any raw report body content
```

**NOT blocked** (safe structural identifiers):
```
userId, reportId, profileId, subscriptionId, orderId, correlationId, requestId, sessionId
```

### Phi-Telemetry Check Script Pattern

Model after `apps/api/scripts/analytics-governance-phi-rejection-test.ts`:
- **No NestJS bootstrap** — pure Node/ts-node, reads `.ts` source files with `fs.readFileSync`
- Scan `apps/api/src/**/*.ts` (excluding `node_modules`, `*.spec.ts`, `*.d.ts`)
- For each file, regex-search for logger call lines containing banned PHI field names
- Output: file path + line number + matched text for each violation
- Exit 1 if any violations, exit 0 if clean

### CI Job Pattern

Model after the existing `phi-governance-gate` job in `.github/workflows/ci.yml`:
- New job: `phi-telemetry-check` (runs independently, no Docker/DB needed)
- Steps: checkout → setup-node → npm ci → `npm run telemetry:phi-check`
- Keep it lightweight; this is a static analysis job

### Architecture Rules to Enforce

From `_bmad-output/planning-artifacts/architecture.md`:
- "PHI is forbidden in analytics/logging payloads."
- "Logging payload bodies on PHI-bearing endpoints is default-deny."
- "Redaction rules are mandatory for all operational logs."
- "Traceability: correlation propagation across API and worker boundaries with **no PHI in logs**."
- Architecture anticipates `infra/ci/phi-telemetry-check.yml` — the CI job in this story fulfills that.

### File Locations

```
apps/api/src/common/redact-secrets.ts          ← extend with PHI field patterns (or create sibling)
apps/api/scripts/phi-telemetry-check.ts        ← new static scan script
apps/api/package.json                          ← add "telemetry:phi-check" npm script
.github/workflows/ci.yml                       ← add phi-telemetry-check job
```

Do NOT create new NestJS modules, entities, or migrations — this story is purely observability hardening.

### Project Structure Notes

- `apps/api/scripts/` already contains `analytics-governance-ci.ts` and `analytics-governance-phi-rejection-test.ts` — follow the same file style.
- `apps/api/src/common/` is the right home for shared logging utilities.
- CI jobs live in `.github/workflows/ci.yml` — append the new job, do not create a separate file (there is only `ci.yml` today).
- This story is **API-only** — no Flutter or Nuxt changes needed.

### Testing Requirements

- **Skip all automated tests** per project Dev Agent Testing Policy.
- Manual validation: run `npm run telemetry:phi-check` locally, confirm exit 0; introduce a test logger call with a banned field name, confirm exit 1.

### References

- Existing redaction utility: [apps/api/src/common/redact-secrets.ts](apps/api/src/common/redact-secrets.ts)
- Existing exception filter: [apps/api/src/common/api-exception.filter.ts](apps/api/src/common/api-exception.filter.ts)
- Existing CI workflow: [.github/workflows/ci.yml](.github/workflows/ci.yml)
- Reference scan script: [apps/api/scripts/analytics-governance-phi-rejection-test.ts](apps/api/scripts/analytics-governance-phi-rejection-test.ts)
- Architecture PHI/logging rules: `_bmad-output/planning-artifacts/architecture.md` §Security & Telemetry Guardrails
- Epic 7 story definition: `_bmad-output/planning-artifacts/epics.md` §Story 7.2
- Story 7.1 (previous): `_bmad-output/implementation-artifacts/7-1-ai-informational-only-disclaimer-enforcement-across-surfaces.md`

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Code scan: all `apps/api/src/modules/**/*.service.ts` for logger PHI leakage
- Architecture PHI/telemetry guardrail section
- `ci.yml` existing job structure for CI pattern reference

### Completion Notes List

- Task 1 (Audit): Full scan of all `this.logger.*` call sites across `apps/api/src`. Zero PHI leakage violations found. The one match (`'Summariser response missing "summary" field'`) is a safe string literal logging the field name, not a value.
- Task 2 (redactPhi): Extended `apps/api/src/common/redact-secrets.ts` with a new exported `redactPhi()` function covering all 7 banned PHI field names (`summary`, `transcript`, `parsedText`, `displayName`, `labValue`, `diagnosis`, `reportContent`). Uses regex to redact both `field=value` and `"field":"value"` patterns → `***REDACTED***`.
- Task 3 (Scan script): Created `apps/api/scripts/phi-telemetry-check.ts` — pure Node/ts-node, no NestJS bootstrap. Walks `apps/api/src/**/*.ts` (excludes spec/d.ts/node_modules/dist), matches logger call lines containing PHI field interpolation patterns (template literals, property access, assignment). Exits 1 with file:line:text violation output. Added `"telemetry:phi-check"` npm script to `package.json`.
- Task 4 (CI): Added `phi-telemetry-check` job to `.github/workflows/ci.yml` — checkout → setup-node → npm ci → `npm run telemetry:phi-check`. No DB or Docker required.
- Task 5 (Default-deny): Confirmed `ApiExceptionFilter`, all `.middleware.ts` and `.interceptor.ts` files log zero request/response body content. Added DEFAULT-DENY BODY LOGGING POLICY comments to `api-exception.filter.ts` and `main.ts`.

### File List

- apps/api/src/common/redact-secrets.ts (modified — added PHI_FIELD_NAMES constant and redactPhi() export)
- apps/api/scripts/phi-telemetry-check.ts (new — static scan script)
- apps/api/package.json (modified — added telemetry:phi-check script)
- .github/workflows/ci.yml (modified — added phi-telemetry-check job)
- apps/api/src/common/api-exception.filter.ts (modified — added default-deny policy comment)
- apps/api/src/main.ts (modified — added default-deny policy comment)

## Change Log

- 2026-04-07: Full implementation — PHI telemetry enforcement: redactPhi() utility, phi-telemetry-check static scan script, CI gate, default-deny body logging documentation. All 5 tasks complete, zero violations found in existing codebase.
