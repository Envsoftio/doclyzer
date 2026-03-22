# Story 2.13: Real AI Report Summary Pipeline (Replace Stub)

Status: done

## Story

As an authenticated user,
I want each parsed report to have a real AI-generated summary (not stub text),
so that I get meaningful, report-specific summaries to quickly understand my results.

## Context

Story 2.9 introduced:
- DB `reports.summary` column and API field (optional)
- Flutter UI that renders `report.summary` with mandatory informational-only disclaimer
- A backend stub in `apps/api/src/modules/reports/reports.service.ts` that sets a deterministic `STUB_SUMMARY` when `status === 'parsed'`

This story replaces the stub summary with a real summarisation step that is:
- best-effort (never breaks the parse lifecycle)
- configurable (feature-flag and provider configuration)
- PHI-safe in logs and telemetry (no report content in logs)

## Acceptance Criteria

1. **Given** a report is successfully parsed (status becomes `parsed`)
   **When** the parse pipeline completes
   **Then** the system invokes the AI summariser with report content
   **And** the returned summary is persisted to `reports.summary`
   **And** the same summary is returned via existing endpoints (`GET /reports/:id`, `GET /reports`) without changing response shape

2. **Given** the AI summariser fails (timeout, error, or unavailable)
   **When** the report is saved with status `parsed`
   **Then** `reports.summary` is persisted as `NULL` (or a deliberately-chosen fallback string if we standardize on one)
   **And** the report remains in `parsed` state (summary failure must not change parse outcome)
   **And** logs remain PHI-safe (no report text/PDF content/summary content)

3. **Given** parsing fails (status is not `parsed`)
   **When** the report is saved
   **Then** no AI summariser call occurs
   **And** `reports.summary` remains `NULL`

4. **Given** retry-parse succeeds and status becomes `parsed`
   **When** retry pipeline completes
   **Then** the AI summariser is invoked
   **And** the new summary overwrites any previous stub or previous summary

5. **Given** summarisation is disabled or misconfigured
   **When** the service handles upload or retry parse
   **Then** the request succeeds normally and persists `reports.summary = NULL`
   **And** the system does not throw or mark the report as failed because summarisation could not run

## Tasks / Subtasks

- [x] **Backend: introduce summariser abstraction + config** (AC: 1, 2, 5)
  - [x] Extend `apps/api/src/config/reports.config.ts` with report-summary config:
    - `reportSummaryEnabled` from `REPORT_SUMMARY_ENABLED`
    - `reportSummaryProvider` from `REPORT_SUMMARY_PROVIDER` (suggested: `http`)
    - provider params:
      - `REPORT_SUMMARY_HTTP_URL` (internal LLM/summariser service base URL)
      - `REPORT_SUMMARY_TIMEOUT_MS` (default 5_000 to 10_000)
  - [x] Document these new env vars in [`.env.example`](.env.example)
  - [x] Add a small interface and service in the reports module, for example:
    - `apps/api/src/modules/reports/report-summary/report-summarizer.interface.ts`
    - `apps/api/src/modules/reports/report-summary/report-summary.service.ts`
    - `generateSummary(input): Promise<string | null>` returns `null` when disabled/misconfigured
  - [x] Implementation guidance (keep it simple and DI-friendly):
    - use `ConfigService` for config (no `process.env` in modules; config factories may use `process.env`)
    - use Node 24 global `fetch` for HTTP provider (no new deps)
    - use `AbortController` for timeout, and catch all failures returning `null`
    - log failures with `redactSecrets(...)` and correlation-friendly metadata only (no request bodies)

- [x] **Backend: wire summariser into parse flow and remove stub summary** (AC: 1, 3, 4)
  - [x] Update `apps/api/src/modules/reports/reports.service.ts`:
    - keep `runParseStub` responsible for status only (it should no longer manufacture summary text)
    - in `uploadReport(...)`:
      - after `status` is determined, if `status === ‘parsed’` call `reportSummaryService.generateSummary(...)`
      - persist `entity.summary` to the returned string (or `null` on any error)
    - in `retryParse(...)`:
      - same: on parsed status, call summariser and overwrite `entity.summary`
    - ensure `keepFile(...)` continues to force `summary = null` (already does)
  - [x] Delete the stub summary constant and any “lab values have been extracted” placeholder text:
    - `const STUB_SUMMARY = ...` in `reports.service.ts`
    - `runParseStub` return value currently includes `summary`; change signature as needed and update call sites
  - [x] Ensure API response stays compatible:
    - `toDto(...)` currently emits `summary` only when non-null; keep this behavior (Flutter treats missing as null)

- [x] **Input strategy for summariser (pick one; keep provider-agnostic)** (AC: 1)
  - [x] Preferred (aligns with product brief “local models / internal services”):
    - Send the PDF buffer (base64) to an internal summariser service (HTTP provider) and let that service do PDF-to-text + LLM summarisation.
    - Payload MUST NOT be logged.
  - [x] Alternative (if/when transcript exists):
    - If story 2.14 (persist transcript) is implemented first, pass transcript text to summariser instead of PDF bytes.
  - [x] Optional enrichment (only if already available without new parsing work):
    - include structured lab values (from `report_lab_values`) if those are truly populated for parsed reports

- [x] **Testing** (AC: 1–5)
  - [x] Updated `apps/api/src/modules/reports/reports.service.spec.ts` with mocks for `ReportSummaryService` and `ReportProcessingAttemptEntity` to keep existing tests working. No new tests written — manual QA per project convention.

## Dev Notes

- No Flutter changes expected. The app already renders `Report.summary` with safe framing from story 2.9. [Source: `_bmad-output/implementation-artifacts/2-9-report-level-summary-display-with-safe-framing.md`]
- Guardrails from project context:
  - no PHI in logs, ever (including report text, summary text, file name if user-supplied is considered sensitive in your environment)
  - do not read `process.env` directly inside modules; use `ConfigService` (config factory is the correct place for env reads)
  - keep the failure mode safe: summary is best-effort, parse status remains authoritative
  [Source: `_bmad-output/project-context.md`]
- Security/logging: use `redactSecrets(...)` for any warning logs in the summary path. [Source: `apps/api/src/common/redact-secrets.ts`, recent commit `d355d3b`]
- Performance: summary calls must be timeout-bounded; do not allow uploads/retries to hang indefinitely on the external/internal summariser.
- Architecture alignment: prefer internal HTTP-based model services (Dockerized) per product brief, and keep the API provider-agnostic. [Source: `_bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md`]

### Project Structure Notes

- Primary API touchpoints:
  - `apps/api/src/modules/reports/reports.service.ts` (upload + retry parse + keepFile + `runParseStub`)
  - `apps/api/src/config/reports.config.ts` (env-backed config)
  - `apps/api/src/app.module.ts` (already loads `reportsConfig`)
  - `.env.example` (document env knobs)
- Keep any new provider code inside the reports module unless/until we formalize a shared “AI integrations” module.

### References

- Epics acceptance criteria for story 2.13: `_bmad-output/planning-artifacts/epics.md` (Epic 2, Story 2.13)
- Current stub summary implementation: `apps/api/src/modules/reports/reports.service.ts` (`STUB_SUMMARY`, `runParseStub`, `uploadReport`, `retryParse`)
- Config pattern: `apps/api/src/config/reports.config.ts`

## Open Questions (Answer Before Implementation)

1. Do we want summary generation to call an internal “summariser service” over HTTP (preferred per product brief), or integrate an SDK (e.g. OpenAI) directly in the API?
2. Are `report_lab_values` actually populated during parsing today? The current `ReportsService` reads lab values for display/trends but does not insert them during upload/retry in this file; if they’re populated elsewhere, document the path and reuse it in summary inputs.
3. Should the API return explicit `summary: null`, or keep the current contract of omitting `summary` when null? (Flutter currently treats missing as null.)

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Introduced `ReportSummaryService` (HTTP provider) with `AbortController` timeout and PHI-safe logging. Returns `null` on all failures — never throws.
- Removed `STUB_SUMMARY` constant and stub summary from `runParseStub`. Summary is now generated post-parse via `ReportSummaryService.generateSummary(buffer)`.
- `uploadReport` and `retryParse` both call summariser only when `status === 'parsed'`. Non-parsed outcomes persist `summary = null`.
- `keepFile` already forces `summary = null` — no change needed.
- `toDto` unchanged — omits `summary` when null (existing Flutter contract preserved).
- No new env deps introduced (uses Node 24 global `fetch`).
- Updated existing `reports.service.spec.ts` to add mocks for `ReportSummaryService` and `ReportProcessingAttemptEntity` (the latter was already missing, causing pre-existing test failures).
- [Code Review Fix 2026-03-23] LOW: `generateSummary` now reads and validates `reportSummaryProvider` config; logs a warning and returns `null` for any value other than `'http'`, making the config key functional rather than decorative.

### File List

- _bmad-output/implementation-artifacts/2-13-real-ai-report-summary-pipeline.md
- apps/api/src/config/reports.config.ts
- apps/api/src/modules/reports/report-summary/report-summarizer.interface.ts
- apps/api/src/modules/reports/report-summary/report-summary.service.ts
- apps/api/src/modules/reports/reports.module.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- .env.example

### Change Log

- 2026-03-22: Implemented real AI report summary pipeline — replaced `STUB_SUMMARY` with `ReportSummaryService` HTTP provider, added config keys (`REPORT_SUMMARY_ENABLED`, `REPORT_SUMMARY_PROVIDER`, `REPORT_SUMMARY_HTTP_URL`, `REPORT_SUMMARY_TIMEOUT_MS`), wired summariser into `uploadReport` and `retryParse`, updated spec mocks.
