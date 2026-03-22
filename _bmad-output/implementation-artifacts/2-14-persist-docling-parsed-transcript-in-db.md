# Story 2.14: Persist Docling Parsed Report Transcript in DB

Status: done

## Story

As a developer,
I want the parsed report transcript (Docling output) stored in the database,
so that we have a durable record for summarisation, re-use without re-parsing, and optional future display.

## Acceptance Criteria

1. **Given** a report is successfully parsed
   **When** the parser returns a transcript
   **Then** the transcript is persisted to `parsed_transcript` column on `reports`
   **And** the same transcript is returned via `GET /reports/:id` with no transcript content in any logs (PHI-safe)

2. **Given** parsing fails or no transcript is returned
   **When** the report is saved
   **Then** the `parsed_transcript` column remains `NULL`

3. **Given** retry-parse succeeds
   **When** the parser returns a new transcript
   **Then** the stored transcript is overwritten with the new result
   **And** if retry fails, the existing transcript is preserved (not cleared)

4. **Given** a report has a stored transcript
   **When** the API returns the report via `GET /reports/:id`
   **Then** the response includes a `parsedTranscript` field
   **And** no transcript content appears in any logs (PHI-safe)

5. **Given** transcript content is sensitive health data
   **When** storing or logging
   **Then** no transcript content is written to application logs; only metadata (presence/length) may appear in diagnostics

## Tasks / Subtasks

- [x] **Backend: Add parsed_transcript column to reports table** (AC: 1, 2)
  - [x] Add `parsedTranscript: string | null` to `ReportEntity` in `apps/api/src/database/entities/report.entity.ts`
    - Use `@Column({ type: 'text', nullable: true, name: 'parsed_transcript' })` — mirror the `summary` column pattern exactly; place after `summary`
  - [x] Create `apps/api/src/database/migrations/1730813700000-AddParsedTranscriptToReports.ts`
    - `up`: `ALTER TABLE "reports" ADD COLUMN "parsed_transcript" text NULL`
    - `down`: `ALTER TABLE "reports" DROP COLUMN "parsed_transcript"`
  - [x] Register in `apps/api/src/database/migrations/index.ts` — import and append after `CreateReportProcessingAttemptsTable1730813600000`

- [x] **Backend: Extend runParseStub to return transcript and wire into upload/retry/keepFile** (AC: 1, 2, 3)
  - [x] Change `runParseStub()` return type from `{ status: ReportStatus }` to `{ status: ReportStatus; transcript: string | null }`
    - When status resolves to `'parsed'`: return `transcript: 'Stub transcript: lab values extracted.'`
    - When status is `'unparsed'` or `'content_not_recognized'`: return `transcript: null`
  - [x] Update `uploadReport()`: destructure `{ status, transcript }` from `runParseStub`; set `entity.parsedTranscript = status === 'parsed' ? transcript : null` before `reportRepo.save(entity)`
  - [x] Update `retryParse()`: destructure `{ status, transcript }` from `runParseStub`; when `status === 'parsed'` set `entity.parsedTranscript = transcript`; when status is not `'parsed'` **do NOT overwrite** `entity.parsedTranscript` (preserve last successful transcript per AC3)
  - [x] Update `keepFile()`: set `entity.parsedTranscript = null` (mirrors `entity.summary = null`; user explicitly gave up on parsing)

- [x] **Backend: Include parsedTranscript in GET /reports/:id response** (AC: 4, 5)
  - [x] Add optional `parsedTranscript?: string` to the `ReportDto` interface in `reports.service.ts`
  - [x] Update `toDto()` to accept a third param `includeTranscript = false`
    - Add `...(includeTranscript && e.parsedTranscript != null && { parsedTranscript: e.parsedTranscript })` to the returned object (follow the `summary` spread-conditional pattern)
    - List endpoint calls use default `includeTranscript = false` — transcript NOT in list responses (large payload)
  - [x] Update `getReport()`: call `this.toDto(entity, labValues, true)`
  - [x] Update `retryParse()`: call `this.toDto(entity, [], true)` (client may need transcript after a successful retry)
  - [x] Verify no log statement logs `parsedTranscript` content or `entity.parsedTranscript` anywhere in the reports module

- [x] **Mobile: Add parsedTranscript to Report model and parse from API response** (AC: 4)
  - [x] Add `final String? parsedTranscript;` to the `Report` class in `apps/mobile/lib/features/reports/reports_repository.dart`
    - Add to constructor as optional: `this.parsedTranscript,`; add field declaration after `summary`
  - [x] Update `getReport()` in `apps/mobile/lib/features/reports/api_reports_repository.dart`:
    - Add `parsedTranscript: d['parsedTranscript'] as String?,` to `Report(...)` constructor
  - [x] Update `retryParse()` in `api_reports_repository.dart`:
    - Add `parsedTranscript: d['parsedTranscript'] as String?,` to `Report(...)` constructor
  - [x] No changes to `report_detail_screen.dart` — transcript display is future work; field stored in model only

## Dev Notes

### Architecture Requirements (Critical)

- **NO PHI in logs** — `parsedTranscript` is PHI. NEVER log transcript content, even at debug level. Log only metadata (e.g. `"transcript saved, length=${entity.parsedTranscript?.length}"`) if diagnostics are needed. [Source: `_bmad-output/project-context.md` Security Rules]
- **No `process.env` in modules** — all config via `ConfigService`; only `src/database/data-source.ts` is exempt. [Source: `_bmad-output/project-context.md`]
- **Migration required** — `synchronize: false`; every schema change needs a committed migration registered in `index.ts` only. [Source: `_bmad-output/project-context.md`]
- **No tests** — per project-context.md, skip all tests; manual QA only.
- **TypeScript strict mode** — no `async` on non-awaiting methods; `import type` for interface-only imports. [Source: `_bmad-output/project-context.md`]

### Migration Pattern — Copy from AddSummaryToReports

```typescript
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddParsedTranscriptToReports1730813700000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reports" ADD COLUMN "parsed_transcript" text NULL`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "parsed_transcript"`);
  }
}
```

### Entity Column Pattern — Mirror summary

```typescript
// In ReportEntity, after the summary column:
@Column({ type: 'text', nullable: true })
summary!: string | null;

@Column({ type: 'text', nullable: true, name: 'parsed_transcript' })
parsedTranscript!: string | null;
```

### Extended runParseStub Pattern

```typescript
private runParseStub(
  _buffer: Buffer,
  isRetry = false,
): { status: ReportStatus; transcript: string | null } {
  const fail = this.configService.get<boolean>('reports.parseStubFail') ?? false;
  const retrySucceeds = this.configService.get<boolean>('reports.parseStubRetrySucceeds') ?? false;
  const contentNotRecognized = this.configService.get<boolean>('reports.parseStubContentNotRecognized') ?? false;
  if (isRetry && retrySucceeds) return { status: 'parsed', transcript: 'Stub transcript: lab values extracted.' };
  if (fail) {
    return {
      status: contentNotRecognized ? 'content_not_recognized' : 'unparsed',
      transcript: null,
    };
  }
  return { status: 'parsed', transcript: 'Stub transcript: lab values extracted.' };
}
```

### retryParse Transcript Handling (Preserve on Failure)

```typescript
async retryParse(userId: string, reportId: string): Promise<ReportDto> {
  // ...existing find/throw logic...
  const buffer = await this.fileStorage.get(entity.originalFileStorageKey);
  const { status, transcript } = this.runParseStub(buffer, true);
  entity.status = status;
  entity.summary = status === 'parsed'
    ? await this.reportSummaryService.generateSummary(buffer)
    : null;
  // Only overwrite transcript on success; preserve existing on failure (AC3)
  if (status === 'parsed') {
    entity.parsedTranscript = transcript;
  }
  await this.reportRepo.save(entity);
  await this.recordAttempt(entity.id, 'retry', entity.status);
  return this.toDto(entity, [], true);
}
```

### toDto with includeTranscript

```typescript
interface ReportDto {
  // ...existing fields...
  summary?: string;
  parsedTranscript?: string;  // new
  extractedLabValues: ExtractedLabValueDto[];
}

private toDto(
  e: ReportEntity,
  labValues: ReportLabValueEntity[] = [],
  includeTranscript = false,
): ReportDto {
  return {
    id: e.id,
    profileId: e.profileId,
    originalFileName: e.originalFileName,
    contentType: e.contentType,
    sizeBytes: e.sizeBytes,
    status: e.status,
    createdAt: e.createdAt.toISOString(),
    ...(e.summary != null && { summary: e.summary }),
    ...(includeTranscript && e.parsedTranscript != null && { parsedTranscript: e.parsedTranscript }),
    extractedLabValues: labValues.map((lv) => ({
      parameterName: lv.parameterName,
      value: lv.value,
      ...(lv.unit != null && lv.unit !== '' && { unit: lv.unit }),
      ...(lv.sampleDate != null && { sampleDate: lv.sampleDate }),
    })),
  };
}
```

### Why Transcript Excluded from List Endpoint

- Transcript is full extracted PDF text — can be thousands of words per report
- `GET /reports` feeds the Flutter timeline list view; returning transcript for every report would be a large unnecessary payload
- Only `GET /reports/:id` and the `POST /reports/:id/retry` response need transcript per AC4
- List calls continue to pass default `includeTranscript = false` — no change to list callers needed

### Why keepFile Clears parsedTranscript

- `keepFile()` sets `status = 'unparsed'` and `summary = null`; transcript should follow the same reset
- In practice, transcript would already be null for failed reports; the explicit `null` assignment is defensive and consistent with how `summary` is handled

### Transcript Preserve on Retry Failure

- AC3 says "if retry fails, existing transcript preserved" (vs. summary which is always cleared on retry)
- Rationale: transcript from a previous successful parse is still valid; don't discard it just because a re-parse attempt failed
- `summary` is always regenerated on re-parse because it derives from the fresh PDF buffer via the summariser; transcript comes directly from the parser result

### Relationship to Story 2.13

Story 2.13 (Real AI Summary Pipeline — currently in review) sends the PDF buffer to an internal HTTP summariser (`REPORT_SUMMARY_HTTP_URL/summarise`). After this story, the transcript column will be populated. A future iteration could update `ReportSummaryService` to pass `parsedTranscript` text instead of PDF bytes (per the "alternative input strategy" noted in 2.13). **Do NOT make that change in this story.**

### Flutter Report Model Update Pattern

```dart
// reports_repository.dart — Report class
class Report {
  const Report({
    required this.id,
    required this.profileId,
    required this.originalFileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    required this.createdAt,
    this.summary,
    this.parsedTranscript,   // new
    this.extractedLabValues = const [],
  });

  final String id;
  final String profileId;
  final String originalFileName;
  final String contentType;
  final int sizeBytes;
  final String status;
  final DateTime createdAt;
  final String? summary;
  final String? parsedTranscript;   // new
  final List<ExtractedLabValue> extractedLabValues;
}
```

```dart
// api_reports_repository.dart — getReport and retryParse
return Report(
  // ...existing fields...
  summary: d['summary'] as String?,
  parsedTranscript: d['parsedTranscript'] as String?,  // new
  extractedLabValues: extractedLabValues,
);
```

### Project Structure Notes

- Migration timestamp: `1730813700000` (next after `CreateReportProcessingAttemptsTable1730813600000`)
- Entity files: `apps/api/src/database/entities/`
- `migrations/index.ts` is the ONLY registration point for migrations
- No new module, service, or interface files needed — all changes are to existing files

### References

- [Source: `apps/api/src/database/entities/report.entity.ts`] — current entity; `summary` column is the model to follow
- [Source: `apps/api/src/database/migrations/1730813500000-AddSummaryToReports.ts`] — migration pattern to copy
- [Source: `apps/api/src/database/migrations/index.ts`] — migration registration; append after `CreateReportProcessingAttemptsTable1730813600000`
- [Source: `apps/api/src/modules/reports/reports.service.ts`] — `runParseStub`, `uploadReport`, `retryParse`, `keepFile`, `toDto`, `ReportDto`
- [Source: `apps/mobile/lib/features/reports/reports_repository.dart`] — `Report` class structure
- [Source: `apps/mobile/lib/features/reports/api_reports_repository.dart`] — `getReport`, `retryParse` response parsing patterns
- [Source: `_bmad-output/implementation-artifacts/2-13-real-ai-report-summary-pipeline.md`] — related story; do not change summariser in this story
- [Source: `_bmad-output/project-context.md`] — PHI-safe logging, migration rules, no-tests policy, TypeScript rules
- [Source: `_bmad-output/planning-artifacts/epics.md` Epic 2, Story 2.14]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Added `parsedTranscript` column to `ReportEntity` using `@Column({ type: 'text', nullable: true, name: 'parsed_transcript' })`, mirroring the `summary` column pattern.
- Created migration `1730813700000-AddParsedTranscriptToReports.ts` with up/down SQL; registered in `migrations/index.ts`.
- Extended `runParseStub()` return type to `{ status: ReportStatus; transcript: string | null }`. Returns stub transcript string on `'parsed'`, `null` otherwise.
- Updated `uploadReport()` to destructure `{ status, transcript }` and set `entity.parsedTranscript = status === 'parsed' ? transcript : null`.
- Updated `retryParse()` to only overwrite `parsedTranscript` when `status === 'parsed'`, preserving existing transcript on retry failure (AC3). Response now calls `toDto(entity, [], true)`.
- Updated `keepFile()` to set `entity.parsedTranscript = null` (consistent with summary reset).
- Added `parsedTranscript?: string` to `ReportDto` interface.
- Updated `toDto()` to accept optional `includeTranscript = false` param; transcript included only when flag is true and `parsedTranscript != null`. List endpoints use default (no transcript in payloads).
- Updated `getReport()` to call `toDto(entity, labValues, true)`.
- Verified no log statement logs transcript content — PHI-safe.
- Added `parsedTranscript` field to Flutter `Report` class in `reports_repository.dart`.
- Updated `getReport()` and `retryParse()` in `api_reports_repository.dart` to parse `parsedTranscript` from API response.

### File List

- `apps/api/src/database/entities/report.entity.ts`
- `apps/api/src/database/migrations/1730813700000-AddParsedTranscriptToReports.ts` (new)
- `apps/api/src/database/migrations/index.ts`
- `apps/api/src/modules/reports/reports.service.ts`
- `apps/mobile/lib/features/reports/reports_repository.dart`
- `apps/mobile/lib/features/reports/api_reports_repository.dart`

### Change Log

- 2026-03-22: Implemented story 2.14 — persisted Docling parsed transcript in DB. Added `parsed_transcript` column to reports table (entity + migration), extended `runParseStub` to return transcript, wired transcript into upload/retry/keepFile flows, exposed `parsedTranscript` in `GET /reports/:id` response (PHI-safe, excluded from list endpoint), updated Flutter `Report` model to store field.
