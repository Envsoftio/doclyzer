# Story 2.9: Report-Level Summary Display with Safe Framing

Status: done

## Story

As an authenticated user,
I want to see a concise summary for a parsed report on the report detail screen,
so that I can quickly understand the report's content without reading the full PDF.

## Acceptance Criteria

1. **Given** a report with status `parsed` and a non-null summary
   **When** I open the report detail screen
   **Then** a summary section is displayed above the lab values
   **And** a clearly visible "Informational only — not medical advice. Discuss with your doctor." disclaimer is shown directly below the summary text

2. **Given** a report with no summary (null or empty) — e.g. status `unparsed`, `content_not_recognized`, or `failed_*`
   **When** I open the report detail screen
   **Then** no summary section is shown (no empty card or placeholder)

3. **Given** a report is processed by the parse stub and result is `parsed`
   **When** the API returns the report via `GET /reports/:id`
   **Then** the response includes a non-null `summary` string

4. **Given** a report has a summary
   **When** `listReports` returns the report
   **Then** the API includes `summary` in the response (Flutter may ignore it in list view for now)

## Tasks / Subtasks

- [x] Backend: DB migration — add `summary` column (AC: 3, 4)
  - [x] Create `apps/api/src/database/migrations/1730813500000-AddSummaryToReports.ts`
  - [x] SQL: `ALTER TABLE "reports" ADD COLUMN "summary" text NULL`
  - [x] Register migration in `apps/api/src/database/migrations/index.ts`

- [x] Backend: Entity + DTO + service (AC: 3, 4)
  - [x] Add `@Column({ type: 'text', nullable: true }) summary!: string | null` to `ReportEntity`
  - [x] Add `summary?: string` to `ReportDto` interface in `reports.service.ts`
  - [x] Change `runParseStub` to return `{ status: ReportStatus; summary: string | null }` instead of `ReportStatus`
  - [x] In `uploadReport`: destructure `{ status, summary }` from `runParseStub`; set `entity.summary = summary`
  - [x] In `retryParse`: destructure `{ status, summary }` from `runParseStub`; set `entity.summary = summary` before save
  - [x] Update `toDto` to include `...(e.summary && { summary: e.summary })`
  - [x] Stub summary text when `status === 'parsed'`: `"This report has been processed. Lab values have been extracted and are listed below."`; `null` for all other statuses

- [x] Flutter: model + API client (AC: 1, 2)
  - [x] Add `summary` (`String? summary`) field to `Report` class in `reports_repository.dart`
  - [x] Update `ApiReportsRepository.getReport()` in `api_reports_repository.dart` to parse `summary` from `d['summary'] as String?`
  - [x] Update `Report` constructor in `api_reports_repository.getReport()` to pass `summary`

- [x] Flutter: UI — summary + safe framing in ReportDetailScreen (AC: 1, 2)
  - [x] In `_buildBody()`, after the file info Card and before the "View PDF" button, conditionally show summary section when `report.summary != null && report.summary!.isNotEmpty`
  - [x] Summary section: `Card` with `Key('report-detail-summary')` containing summary text + disclaimer row
  - [x] Disclaimer row: `Icon(Icons.info_outline, size: 14)` + Text("Informational only — not medical advice. Discuss with your doctor.") styled with `textTheme.bodySmall` and `colorScheme.onSurfaceVariant`
  - [x] Disclaimer widget key: `Key('report-detail-summary-disclaimer')`

## Dev Notes

### Scope and constraints

- **Summary is stub for now**: Real AI pipeline not built yet. `runParseStub` sets a hardcoded deterministic string when returning `parsed`; null for all other statuses. This field will be populated by the real AI summariser in a future story.
- **No new endpoint**: Summary is returned as part of `GET /reports/:id` (existing `getReport`) and `GET /reports` (existing `listReports` via shared `toDto`). No new API surface.
- **Display only in report detail**: Flutter timeline cards (story 2.6) do NOT need to show summary. Only `ReportDetailScreen` renders it.
- **Safe framing is mandatory**: FR40 (PRD) + architecture NFR compliance: every AI-derived output must show "informational only" language. No summary display without the disclaimer visible.

### Migration pattern

Follow the exact pattern from `1730813400000-AddReportLabValuesTable.ts`:

```typescript
// 1730813500000-AddSummaryToReports.ts
export class AddSummaryToReports1730813500000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "reports" ADD COLUMN "summary" text NULL`);
  }
  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "summary"`);
  }
}
```

Register in `migrations/index.ts` by importing and appending to the `migrations` array.

### `runParseStub` refactor

Current signature: `private runParseStub(_buffer: Buffer, isRetry = false): ReportStatus`
New signature: `private runParseStub(_buffer: Buffer, isRetry = false): { status: ReportStatus; summary: string | null }`

```typescript
private runParseStub(_buffer: Buffer, isRetry = false): { status: ReportStatus; summary: string | null } {
  const fail = this.configService.get<boolean>('reports.parseStubFail') ?? false;
  const retrySucceeds = this.configService.get<boolean>('reports.parseStubRetrySucceeds') ?? false;
  const contentNotRecognized = this.configService.get<boolean>('reports.parseStubContentNotRecognized') ?? false;
  if (isRetry && retrySucceeds) return { status: 'parsed', summary: STUB_SUMMARY };
  if (fail) return { status: contentNotRecognized ? 'content_not_recognized' : 'unparsed', summary: null };
  return { status: 'parsed', summary: STUB_SUMMARY };
}
```

Define at module level (outside class or as a const in the file):
```typescript
const STUB_SUMMARY = 'This report has been processed. Lab values have been extracted and are listed below.';
```

### `uploadReport` and `retryParse` changes

In `uploadReport`, replace:
```typescript
const status = this.runParseStub(file.buffer);
const entity = this.reportRepo.create({ ..., status, ... });
```
With:
```typescript
const { status, summary } = this.runParseStub(file.buffer);
const entity = this.reportRepo.create({ ..., status, summary, ... });
```

In `retryParse`, replace:
```typescript
const status = this.runParseStub(buffer, true);
entity.status = status;
```
With:
```typescript
const { status, summary } = this.runParseStub(buffer, true);
entity.status = status;
entity.summary = summary;
```

### `toDto` change

```typescript
private toDto(e: ReportEntity, labValues: ReportLabValueEntity[] = []): ReportDto {
  return {
    id: e.id,
    profileId: e.profileId,
    originalFileName: e.originalFileName,
    contentType: e.contentType,
    sizeBytes: e.sizeBytes,
    status: e.status,
    createdAt: e.createdAt.toISOString(),
    ...(e.summary && { summary: e.summary }),
    extractedLabValues: labValues.map(...),
  };
}
```

### `ReportEntity` column

Add after `status` column:
```typescript
@Column({ type: 'text', nullable: true })
summary!: string | null;
```

### Flutter `Report` class change

In `reports_repository.dart`, update `Report`:
```dart
class Report {
  const Report({
    required this.id,
    required this.profileId,
    required this.originalFileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    required this.createdAt,
    this.summary,                      // ADD THIS
    this.extractedLabValues = const [],
  });
  // ... existing fields ...
  final String? summary;               // ADD THIS
  final List<ExtractedLabValue> extractedLabValues;
}
```

### Flutter `api_reports_repository.dart` `getReport` change

In the `getReport` method, update `Report(...)` constructor call to add:
```dart
summary: d['summary'] as String?,
```

### Flutter `ReportDetailScreen` summary UI

Place this block in `_buildBody()` after the file info `Card` and before the "View PDF" `FilledButton.icon`:

```dart
if (report.summary != null && report.summary!.isNotEmpty) ...[
  const SizedBox(height: 16),
  Card(
    key: const Key('report-detail-summary'),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            report.summary!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            key: const Key('report-detail-summary-disclaimer'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Informational only — not medical advice. Discuss with your doctor.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
],
```

### Architecture compliance

- DB: `summary` column snake_case, TEXT nullable (architecture.md)
- API: `summary` returned in camelCase in response envelope (architecture.md: DB snake_case, API JSON camelCase)
- PHI: no PHI in stub summary text; no PHI in logs (project-context.md)
- `successResponse` + `AuthGuard` already in place — no changes needed
- No new endpoints, no new modules, no new dependencies

### Project Structure Notes

- All report entity/service/controller files stay in their existing locations:
  - `apps/api/src/database/entities/report.entity.ts`
  - `apps/api/src/database/migrations/` (new file here)
  - `apps/api/src/modules/reports/reports.service.ts`
  - `apps/mobile/lib/features/reports/reports_repository.dart`
  - `apps/mobile/lib/features/reports/api_reports_repository.dart`
  - `apps/mobile/lib/features/reports/screens/report_detail_screen.dart`
- No new files needed except the migration

### Previous Story Intelligence (2.8)

- Pattern: `runParseStub` is a private method used in `uploadReport` and `retryParse` — same two callsites to update
- Pattern: `toDto` is the single serialisation point — update once
- Flutter: `Report` is a plain Dart class with `const` constructor — add field with default `null`; all existing instantiations in `ApiReportsRepository` need the new param
- `listReports` in `ApiReportsRepository` constructs `Report` with `extractedLabValues: const []` — add `summary: null` there too (or it will be a compile error once `summary` is required... but since we're making it optional with default null via named param it won't be required)
- Widget key convention: kebab-case strings (e.g. `report-detail-summary`)
- `ThrowIfAlreadyParsed` guard — not relevant here; `keepFile` sets status to `unparsed` with null summary (already handled since `keepFile` doesn't call `runParseStub` and entity.summary remains whatever it was — but for `keepFile`, summary should be cleared: set `entity.summary = null` to match the unparsed state)

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.9]
- [Source: _bmad-output/planning-artifacts/prd.md#FR20, FR40]
- [Source: _bmad-output/planning-artifacts/prd.md#Risk Mitigations] — "prominently display informational only language near AI output"
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md] — "every AI-generated summary paired with visible disclaimer"; disclaimer banner pattern; Card-based insight layout
- [Source: _bmad-output/project-context.md] — no PHI in logs; successResponse; TypeORM Data Mapper; Flutter Material 3; widget test keys kebab-case; no force-unwrap
- [Source: _bmad-output/planning-artifacts/architecture.md] — DB snake_case, API camelCase; profile-scoped data; NFR compliance

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Created migration `1730813500000-AddSummaryToReports.ts` with `ALTER TABLE "reports" ADD COLUMN "summary" text NULL`; registered in `migrations/index.ts`.
- Added `summary!: string | null` column to `ReportEntity`.
- Added `summary?: string` to `ReportDto` interface.
- Added `STUB_SUMMARY` module-level constant with the hardcoded parsed summary text.
- Refactored `runParseStub` to return `{ status, summary }` — returns `STUB_SUMMARY` on `parsed`, `null` on all other statuses.
- Updated `uploadReport` and `retryParse` to destructure and persist `summary` from `runParseStub`.
- Updated `keepFile` to explicitly set `entity.summary = null` when reverting to `unparsed`.
- Updated `toDto` to include `summary` in response via spread when truthy.
- Added `String? summary` field to Flutter `Report` class (optional, defaults null).
- Updated `ApiReportsRepository.getReport()` to parse and pass `summary: d['summary'] as String?`.
- Added conditional summary `Card` with `Key('report-detail-summary')` in `ReportDetailScreen._buildBody()`, shown only when `report.summary != null && report.summary!.isNotEmpty`, with mandatory disclaimer row keyed `Key('report-detail-summary-disclaimer')`.

### File List

apps/api/src/database/entities/report.entity.ts
apps/api/src/database/migrations/1730813500000-AddSummaryToReports.ts
apps/api/src/database/migrations/index.ts
apps/api/src/modules/reports/reports.service.ts
apps/mobile/lib/features/reports/reports_repository.dart
apps/mobile/lib/features/reports/api_reports_repository.dart
apps/mobile/lib/features/reports/screens/report_detail_screen.dart

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-15 | AI (claude-sonnet-4-6) | Story created: report-level summary display with safe framing; DB migration for summary column; runParseStub refactor; Flutter Report model + API client + ReportDetailScreen summary section with informational-only disclaimer. |
| 2026-03-15 | AI (claude-sonnet-4-6) | Implemented: DB migration, ReportEntity column, ReportDto field, runParseStub refactored to return { status, summary }, uploadReport/retryParse/keepFile updated, toDto updated, Flutter Report model + getReport() + ReportDetailScreen summary UI with safe-framing disclaimer. |
| 2026-03-15 | AI Code Review (claude-sonnet-4-6) | Code review complete. Fixed 1 HIGH (TypeScript type error in toDto spread: `e.summary &&` → `e.summary != null &&`). Fixed 1 LOW (Dart force-unwrap: extracted local `summary` variable in ReportDetailScreen). All ACs verified. Status: done. |

## Senior Developer Review (AI)

**Date:** 2026-03-15
**Outcome:** Approve (after fixes)
**Reviewer:** claude-sonnet-4-6

### Summary

All 4 Acceptance Criteria are implemented and verified. Git matches story File List exactly (0 discrepancies). 1 High and 1 Low issue found and fixed in-session.

### Action Items

- [x] **[High]** `reports.service.ts:440` — `...(e.summary && { summary: e.summary })` where `e.summary: string | null` produces type `null | string | { summary: string }`. Spreading `string` in an object literal is a TypeScript strict-mode error. Existing pattern in same file uses boolean condition `!= null &&`. **Fixed:** changed to `...(e.summary != null && { summary: e.summary })`.
- [x] **[Low]** `report_detail_screen.dart` — Force-unwrap `report.summary!` used twice in production code, violating project-context.md rule ("no `!` in production code"). **Fixed:** extracted `final summary = report.summary;` local variable; Dart promotes local `String?` to `String` after null check, eliminating all `!` uses.
