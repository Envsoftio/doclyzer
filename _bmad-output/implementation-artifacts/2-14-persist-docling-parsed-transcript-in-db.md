# Story 2.14: Persist Docling Parsed Report Transcript in DB

Status: backlog

## Story

As a developer,
I want the parsed report transcript (full extracted text from Docling) to be stored in the database,
so that we have a durable record of the parser output for summarisation (e.g. Story 2.13), re-use without re-parsing, and optional future display or search.

## Context

Docling (or the chosen document parser) returns a **transcript** — the extracted document text (e.g. markdown or plain text) — when parsing succeeds. Today this output is not persisted. This story adds storage so that (1) the AI report summary pipeline (Story 2.13) can consume it without re-calling the parser, (2) the transcript is available for audit/reproducibility, and (3) future features (e.g. "view transcript", search) can use it.

## Acceptance Criteria

1. **Given** a report is successfully parsed (Docling or parser returns transcript)
   **When** the parse pipeline completes with status `parsed`
   **Then** the transcript returned by the parser is persisted (e.g. in a `parsed_transcript` column or equivalent on `reports`)
   **And** the value is stored as text; encoding and size limits are documented (e.g. max length or use `text` type)

2. **Given** parsing fails or the parser does not return a transcript
   **When** the report is saved
   **Then** the transcript column remains `null` and the report lifecycle is unchanged

3. **Given** retry-parse succeeds and the parser returns a new transcript
   **When** the report is updated
   **Then** the stored transcript is overwritten with the new result

4. **Given** a report has a stored transcript
   **When** the API returns the report via `GET /reports/:id` (and optionally list)
   **Then** the response includes the transcript (e.g. `parsedTranscript` or `parsed_transcript` in JSON) so that backend summariser and future clients can use it
   **And** ownership and auth are unchanged (only returned for reports the user owns)

5. **Given** transcript content may be large or contain sensitive health data
   **When** storing or logging
   **Then** no transcript content is written to application logs (PHI-safe); only presence/absence or length may be logged for diagnostics if needed

## Tasks / Subtasks

- [ ] Backend: migration — add transcript column (AC: 1, 2)
  - [ ] Add migration (e.g. `AddParsedTranscriptToReports`) with column `parsed_transcript` type `text` NULL on `reports`
  - [ ] Register migration in `apps/api/src/database/migrations/index.ts`
  - [ ] Document in migration or project-context: column holds full parser output (Docling transcript); no size limit beyond DB `text` type

- [ ] Backend: entity and DTO (AC: 1, 4)
  - [ ] Add `@Column({ type: 'text', nullable: true }) parsedTranscript?: string | null` to `ReportEntity` (or equivalent name; keep snake_case in DB, camelCase in API)
  - [ ] Extend report DTO / `toDto()` to include `parsedTranscript` when present (omit or null when absent)
  - [ ] Ensure `GET /reports/:id` and list reports response include the field per existing ownership checks

- [ ] Backend: parse flow — capture and persist transcript (AC: 1, 2, 3)
  - [ ] Where the parser (Docling or stub) is invoked, capture the transcript from the parser response in addition to status and any structured lab data
  - [ ] In `uploadReport`: when parse succeeds, set `entity.parsedTranscript = parserResult.transcript ?? null` before save
  - [ ] In `retryParse`: when parse succeeds, set `entity.parsedTranscript = parserResult.transcript ?? null` before save; when parse fails, leave existing value or set null per product rule (e.g. clear on retry failure or leave last successful transcript — specify in dev notes)
  - [ ] If current implementation uses a stub: extend stub to return an optional `transcript` string so persistence and API can be tested; real Docling integration will supply the real transcript in a later or same iteration

- [ ] Tests (AC: 1–5)
  - [ ] Unit: when parser returns transcript, entity is saved with `parsedTranscript` set; when parser returns no transcript or fails, column remains null
  - [ ] Unit: retry-parse overwrites transcript on success
  - [ ] E2E: upload report that parses successfully with stub transcript → GET report returns `parsedTranscript`; report without transcript returns null or omitted field
  - [ ] Assert no transcript content in logs in tests where logging is verified

## Dev Notes

- **Naming:** Prefer `parsed_transcript` in DB and `parsedTranscript` in API (architecture: snake_case DB, camelCase JSON). Alternative: `extracted_text` if the team prefers that term.
- **Stub behaviour:** If Docling is not yet integrated, extend the parse stub to return e.g. `{ status, transcript: 'Stub transcript for report.' }` when status is `parsed`, and `transcript: null` when not parsed, so this story can be completed and 2.13 can later consume real transcript from the same column.
- **Retry and transcript:** On retry that succeeds, overwriting the transcript is the simplest rule. On retry that fails, keep existing transcript (if any) so we don’t lose the last good result.
- **PHI:** Transcript is PHI. Do not log its content. Log only metadata (e.g. "transcript saved", length) if needed for diagnostics.
- **Epic:** Epic 2. Enables Story 2.13 (summariser can read `parsedTranscript` from report instead of re-calling Docling).
