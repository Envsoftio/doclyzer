# Story 2.13: Real AI Report Summary Pipeline (Replace Stub)

Status: backlog

## Story

As an authenticated user,
I want each parsed report to have a real AI-generated summary (not stub text),
so that I get meaningful, report-specific summaries to quickly understand my results.

## Context

Story 2.9 added the `summary` column and UI with safe framing. The API currently sets a **stub** string when status is `parsed` and `null` otherwise. This story replaces that with a real AI summarisation step so `report.summary` is populated by an AI pipeline when parsing succeeds.

## Acceptance Criteria

1. **Given** a report is successfully parsed (status becomes `parsed`)
   **When** the parse pipeline completes
   **Then** the system invokes the AI summariser with the report content (extracted text and/or structured lab values)
   **And** the returned summary is persisted to `report.summary`
   **And** the same summary is returned via `GET /reports/:id` and list endpoints (no API contract change)

2. **Given** the AI summariser fails (timeout, error, or unavailable)
   **When** the parse pipeline completes with status `parsed`
   **Then** `report.summary` is set to `null` (or a defined fallback, e.g. "Summary unavailable") and the report remains in `parsed` state
   **And** no PHI is logged; only non-identifying error/correlation info may be logged

3. **Given** parsing fails (status is not `parsed`)
   **When** the report is saved
   **Then** `report.summary` remains `null` (no AI call for unparsed reports)

4. **Given** retry-parse succeeds and status becomes `parsed`
   **When** the pipeline runs
   **Then** the AI summariser is invoked and the new summary is persisted (overwriting any previous stub or prior summary)

5. **Given** the AI summariser is configured (e.g. API key or model endpoint)
   **When** the service starts
   **Then** summarisation is enabled; if misconfigured or disabled by config, persist `null` and do not fail the parse flow

## Tasks / Subtasks

- [ ] Backend: summariser abstraction and config (AC: 1, 2, 5)
  - [ ] Add config (env) for AI summarisation: e.g. `REPORT_SUMMARY_ENABLED`, provider-specific keys (e.g. `OPENAI_API_KEY` or local model URL). Document in `.env.example`.
  - [ ] Introduce a small abstraction (e.g. `ReportSummaryService` or `Summariser` interface) with method `generateSummary(input: ReportSummaryInput): Promise<string | null>`. Input: extracted text and/or lab values (from report) so the model has context without re-reading the file.
  - [ ] When disabled or config missing: `generateSummary` returns `null`; parse flow continues and sets `entity.summary = null`.

- [ ] Backend: wire summariser into parse flow (AC: 1, 3, 4)
  - [ ] After `runParseStub` (or real parser) returns `status: 'parsed'`, call the summariser with report content. If parser returns extracted text/lab JSON, pass that; otherwise pass minimal context (e.g. report id, no raw PDF in prompt).
  - [ ] In `uploadReport`: after setting status and (if applicable) lab values, set `entity.summary = await summariser.generateSummary(...)` (or null on failure). Then save.
  - [ ] In `retryParse`: same — on parsed outcome, call summariser and set `entity.summary` before save.
  - [ ] Ensure summarisation does not block or fail the parse lifecycle: catch errors and set `summary = null`; do not set report status to failed due to summary failure.

- [ ] Backend: remove stub summary from parse stub (AC: 1)
  - [ ] Change `runParseStub` (or equivalent) so it no longer returns a hardcoded summary string. Parse layer returns only status (and any extraction); summary is assigned in the service after calling the summariser when status is `parsed`.

- [ ] Tests (AC: 1–5)
  - [ ] Unit: summariser returns string when enabled and mock succeeds; returns null when disabled or mock throws.
  - [ ] Unit: uploadReport / retryParse set `entity.summary` from summariser when parsed; set null when not parsed or summariser fails.
  - [ ] E2E: upload a report that parses successfully → GET report returns non-null summary when summariser is mocked to return text; returns null when summariser is disabled or returns null.

## Dev Notes

- **No Flutter changes.** Story 2.9 already displays `report.summary` with disclaimer; once the API returns real content, it will show automatically.
- **PHI-safe:** Do not log report content or summaries in plain text. Log only correlation IDs, error codes, and non-PHI metadata.
- **Input to summariser:** Prefer extracted text or structured lab data (from `report_lab_values` / parser output) rather than raw PDF bytes to keep prompts smaller and avoid sending large binaries to external services.
- **Provider-agnostic:** Implementation can use OpenAI, a local model (e.g. Hugging Face), or another provider behind the abstraction; config and env determine which is used.
- **Epic:** Epic 2 — Report Ingestion, Processing Recovery & Timeline Insights. FR20 (report-level summaries) is fully satisfied once this story is done.
