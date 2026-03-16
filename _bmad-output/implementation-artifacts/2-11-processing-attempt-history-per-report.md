# Story 2.11: Processing Attempt History per Report

Status: ready-for-dev

## Story

As an authenticated user,
I want to view the processing attempt history for a report,
so that retries and outcomes are transparent and I can understand what happened during parsing.

## Acceptance Criteria

1. **Given** a report has one or more processing attempts (initial upload, retries)
   **When** I tap "View attempt history" on the report detail screen
   **Then** I am navigated to the processing history screen showing all attempts in chronological order (oldest first)
   **And** each attempt shows: trigger (initial upload or retry), outcome status, and date/time

2. **Given** a report has only one attempt (initial upload)
   **When** I open attempt history
   **Then** one attempt row is shown

3. **Given** attempt history data is loading
   **When** the processing history screen first mounts
   **Then** a loading indicator is shown and no partial data is visible

4. **Given** the API returns an error when loading attempts
   **When** the processing history screen fails to load
   **Then** an error message is shown with a retry button

5. **Given** attempt records exist in the database
   **When** the API returns them
   **Then** attempts are returned in chronological order (ascending attemptedAt)
   **And** each attempt includes: id, trigger, outcome, attemptedAt

6. **Given** a user requests attempt history for a report they do not own
   **When** the API is called
   **Then** a 404 error is returned (same ownership check as `getReport`)

## Tasks / Subtasks

- [ ] Backend: migration — create `report_processing_attempts` table (AC: 5)
  - [ ] Create `apps/api/src/database/migrations/1730813600000-CreateReportProcessingAttemptsTable.ts`
  - [ ] SQL: create table with columns: `id` (uuid PK), `report_id` (uuid FK → reports), `trigger` (varchar 32), `outcome` (varchar 32), `attempted_at` (timestamptz); index on `report_id`
  - [ ] Register migration in `apps/api/src/database/migrations/index.ts`

- [ ] Backend: entity (AC: 5)
  - [ ] Create `apps/api/src/database/entities/report-processing-attempt.entity.ts`
  - [ ] Entity: `@Entity('report_processing_attempts')` with id, reportId, trigger, outcome, attemptedAt columns
  - [ ] No `@UpdateDateColumn` — rows are immutable (insert-only)

- [ ] Backend: register entity + service method (AC: 5, 6)
  - [ ] In `apps/api/src/modules/reports/reports.module.ts`: add `ReportProcessingAttemptEntity` to `TypeOrmModule.forFeature([...])`
  - [ ] Inject `@InjectRepository(ReportProcessingAttemptEntity)` in `ReportsService` constructor
  - [ ] Add private `recordAttempt(reportId, trigger, outcome)` — inserts one row; called after successful report save in `uploadReport` and `retryParse`
  - [ ] Add public `getProcessingAttempts(userId, reportId)` — verifies ownership via existing `reportRepo.findOne({ where: { id, userId } })`, then returns attempts ordered by `attemptedAt ASC`

- [ ] Backend: controller endpoint (AC: 5, 6)
  - [ ] In `apps/api/src/modules/reports/reports.controller.ts`: add `GET :id/attempts` endpoint
  - [ ] Call `reportsService.getProcessingAttempts(userId, reportId)`, wrap in `successResponse`
  - [ ] Must be declared BEFORE `GET :id` to avoid route shadowing (NestJS route order matters)

- [ ] Flutter: model + repository interface (AC: 1, 3, 4)
  - [ ] Add `ProcessingAttempt` class to `apps/mobile/lib/features/reports/reports_repository.dart`
    - Fields: `id` (String), `trigger` (String), `outcome` (String), `attemptedAt` (DateTime)
  - [ ] Add `getProcessingAttempts(String reportId)` → `Future<List<ProcessingAttempt>>` to abstract `ReportsRepository`

- [ ] Flutter: API implementation (AC: 1, 5)
  - [ ] Implement `getProcessingAttempts` in `apps/mobile/lib/features/reports/api_reports_repository.dart`
  - [ ] Calls `GET v1/reports/$reportId/attempts`; parses `data['attempts']` list into `List<ProcessingAttempt>`

- [ ] Flutter: ProcessingHistoryScreen (AC: 1, 2, 3, 4)
  - [ ] Create `apps/mobile/lib/features/reports/screens/processing_history_screen.dart`
  - [ ] Screen accepts `reportId` and `reportsRepository` as constructor parameters
  - [ ] `initState` calls `getProcessingAttempts(reportId)`
  - [ ] Loading: `CircularProgressIndicator` centered (`Key('processing-history-loading')`)
  - [ ] Error: inline message + retry button (`Key('processing-history-error')`)
  - [ ] Empty: centered text "No attempt history available." (`Key('processing-history-empty')`)
  - [ ] List: `ListView` of `ListTile` rows, each showing trigger label, outcome label, date (`Key('processing-history-attempt-$id')`)
  - [ ] Full `Scaffold` with `AppBar(title: Text('Attempt History'))` and `Padding(16)`

- [ ] Flutter: wire entry point from ReportDetailScreen (AC: 1)
  - [ ] In `apps/mobile/lib/features/reports/screens/report_detail_screen.dart`: add `OutlinedButton` "View attempt history" after the "View PDF" button (or after the retry/keep-file block)
  - [ ] Key: `Key('report-detail-view-attempts')`
  - [ ] Tapping pushes `ProcessingHistoryScreen(reportId: report.id, reportsRepository: widget.reportsRepository)`

## Dev Notes

### Data model decisions

**Table: `report_processing_attempts`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK, generated |
| report_id | uuid | FK → reports(id) ON DELETE CASCADE |
| trigger | varchar(32) | `'initial_upload'` or `'retry'` |
| outcome | varchar(32) | ReportStatus value at time of attempt |
| attempted_at | timestamptz | set to `new Date()` at insert time |

- Rows are **insert-only / immutable** — never update these rows
- `keepFile` does NOT record a processing attempt — it's a user file-access choice, not a parsing attempt
- `ON DELETE CASCADE` means attempts are cleaned up when a report is deleted (future use)
- Index on `report_id` for efficient lookup

### Migration pattern — follow exactly from previous migrations

```typescript
// 1730813600000-CreateReportProcessingAttemptsTable.ts
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReportProcessingAttemptsTable1730813600000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "report_processing_attempts" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "report_id" uuid NOT NULL,
        "trigger" character varying(32) NOT NULL,
        "outcome" character varying(32) NOT NULL,
        "attempted_at" TIMESTAMPTZ NOT NULL,
        CONSTRAINT "PK_report_processing_attempts" PRIMARY KEY ("id"),
        CONSTRAINT "FK_report_processing_attempts_report_id" FOREIGN KEY ("report_id")
          REFERENCES "reports"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_report_processing_attempts_report_id" ON "report_processing_attempts" ("report_id")`
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "report_processing_attempts"`);
  }
}
```

### Entity

```typescript
// src/database/entities/report-processing-attempt.entity.ts
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import type { ReportEntity } from './report.entity';

export type AttemptTrigger = 'initial_upload' | 'retry';

@Entity('report_processing_attempts')
export class ReportProcessingAttemptEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'report_id' })
  reportId!: string;

  @ManyToOne('ReportEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'report_id' })
  report!: ReportEntity;

  @Column({ type: 'varchar', length: 32 })
  trigger!: AttemptTrigger;

  @Column({ type: 'varchar', length: 32 })
  outcome!: string;

  @Column({ type: 'timestamptz', name: 'attempted_at' })
  attemptedAt!: Date;
}
```

### ReportsModule update

In `reports.module.ts`, find the `TypeOrmModule.forFeature([...])` call and add `ReportProcessingAttemptEntity`:
```typescript
TypeOrmModule.forFeature([ReportEntity, ReportLabValueEntity, ReportProcessingAttemptEntity])
```

### ReportsService changes

**New injection (add to constructor):**
```typescript
@InjectRepository(ReportProcessingAttemptEntity)
private readonly attemptRepo: Repository<ReportProcessingAttemptEntity>,
```

**New ProcessingAttemptDto interface (add to types section):**
```typescript
export interface ProcessingAttemptDto {
  id: string;
  trigger: string;
  outcome: string;
  attemptedAt: string;
}
```

**Private helper (add near end of class):**
```typescript
private async recordAttempt(
  reportId: string,
  trigger: AttemptTrigger,
  outcome: string,
): Promise<void> {
  const attempt = this.attemptRepo.create({
    reportId,
    trigger,
    outcome,
    attemptedAt: new Date(),
  });
  await this.attemptRepo.save(attempt);
}
```

**In `uploadReport`:** call after `await this.reportRepo.save(entity)` (inside the try block, after the successful save):
```typescript
await this.reportRepo.save(entity);
await this.recordAttempt(entity.id, 'initial_upload', entity.status);
```

**In `retryParse`:** call after `await this.reportRepo.save(entity)`:
```typescript
await this.reportRepo.save(entity);
await this.recordAttempt(entity.id, 'retry', entity.status);
return this.toDto(entity);
```

**New public method:**
```typescript
async getProcessingAttempts(
  userId: string,
  reportId: string,
): Promise<ProcessingAttemptDto[]> {
  if (!isUUID(reportId)) throw new ReportNotFoundException();
  const report = await this.reportRepo.findOne({ where: { id: reportId, userId } });
  if (!report) throw new ReportNotFoundException();
  const attempts = await this.attemptRepo.find({
    where: { reportId },
    order: { attemptedAt: 'ASC' },
  });
  return attempts.map((a) => ({
    id: a.id,
    trigger: a.trigger,
    outcome: a.outcome,
    attemptedAt: a.attemptedAt.toISOString(),
  }));
}
```

### ReportsController: route order is CRITICAL

NestJS matches routes top-to-bottom. `GET :id/attempts` must be declared BEFORE `GET :id` to avoid NestJS treating "attempts" as the `:id` param.

Current controller order (from `reports.controller.ts`):
1. `GET lab-trends` (line 47)
2. `GET /` listReports (line 68)
3. `POST /` uploadReport (line 78)
4. `GET :id/file` (line 138) ← already has a sub-path
5. `GET :id` getReport (line 158)
6. `POST :id/retry` (line 168)
7. `POST :id/keep-file` (line 178)

Add `GET :id/attempts` **before** `GET :id` (between `:id/file` and `:id`):

```typescript
@Get(':id/attempts')
async getProcessingAttempts(
  @Param('id') reportId: string,
  @Req() req: Request,
): Promise<object> {
  const { id: userId } = req.user as RequestUser;
  const data = await this.reportsService.getProcessingAttempts(userId, reportId);
  return successResponse({ attempts: data }, getCorrelationId(req));
}
```

### Flutter ProcessingAttempt model

Add to `reports_repository.dart`:
```dart
/// A single processing attempt record (immutable).
class ProcessingAttempt {
  const ProcessingAttempt({
    required this.id,
    required this.trigger,
    required this.outcome,
    required this.attemptedAt,
  });

  final String id;
  final String trigger;    // 'initial_upload' or 'retry'
  final String outcome;    // ReportStatus at time of attempt
  final DateTime attemptedAt;
}
```

Add to `ReportsRepository` abstract class:
```dart
/// Fetch processing attempt history for a report, oldest first.
Future<List<ProcessingAttempt>> getProcessingAttempts(String reportId);
```

### Flutter API implementation

Add to `ApiReportsRepository`:
```dart
@override
Future<List<ProcessingAttempt>> getProcessingAttempts(String reportId) async {
  final data = await _client.get('v1/reports/$reportId/attempts');
  final list = data['data']?['attempts'] as List<dynamic>? ?? [];
  return list.map((e) {
    final m = e as Map<String, dynamic>;
    final attemptedAt = m['attemptedAt'] as String?;
    return ProcessingAttempt(
      id: m['id'] as String,
      trigger: m['trigger'] as String,
      outcome: m['outcome'] as String,
      attemptedAt: attemptedAt != null ? DateTime.parse(attemptedAt) : DateTime.now(),
    );
  }).toList();
}
```

### Flutter ProcessingHistoryScreen structure

```
Scaffold
  AppBar(title: 'Attempt History')
  body: Padding(16)
    if loading → CircularProgressIndicator(key: 'processing-history-loading')
    else if error → error text + FilledButton('Retry') (key: 'processing-history-error')
    else if empty → Text('No attempt history available.', key: 'processing-history-empty')
    else → ListView(
        children: attempts.map((a) =>
          ListTile(
            key: Key('processing-history-attempt-${a.id}'),
            title: Text(_triggerLabel(a.trigger)),
            subtitle: Text(_outcomeLabel(a.outcome)),
            trailing: Text(_formatDateTime(a.attemptedAt), style: bodySmall),
          )
        )
      )
```

Human-readable labels:
```dart
static String _triggerLabel(String trigger) {
  switch (trigger) {
    case 'initial_upload': return 'Initial upload';
    case 'retry': return 'Retry';
    default: return trigger;
  }
}

static String _outcomeLabel(String outcome) {
  switch (outcome) {
    case 'parsed': return 'Parsed successfully';
    case 'unparsed': return 'Parsing failed';
    case 'content_not_recognized': return 'Not a health report';
    case 'failed_transient': return 'Transient failure';
    case 'failed_terminal': return 'Terminal failure';
    default: return outcome;
  }
}
```

DateTime formatting for display:
```dart
String _formatDateTime(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
```

### Entry point in ReportDetailScreen

In `report_detail_screen.dart`, after the existing "View PDF" `FilledButton.icon` block and before the retry/keep-file block, add:

```dart
const SizedBox(height: 12),
OutlinedButton.icon(
  key: const Key('report-detail-view-attempts'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ProcessingHistoryScreen(
        reportId: report.id,
        reportsRepository: widget.reportsRepository,
      ),
    ),
  ),
  icon: const Icon(Icons.history),
  label: const Text('View attempt history'),
),
```

Import: `import 'processing_history_screen.dart';`

### Project rules to follow (from project-context.md)

- **No `!` force-unwrap** — use `?? DateTime.now()` fallback, not `!` on nullable
- **No business logic in widgets** — fetch and transform in `initState`/`setState`; `_triggerLabel` and `_outcomeLabel` are static helper methods, not inline in `build`
- **Full `Scaffold` with `AppBar` and `Padding(16)`** — no bare `Column` as screen root
- **Widget keys use kebab-case strings**
- **`reportsRepository` injected via constructor** — not instantiated inside widget
- **Navigator.push** for secondary screen navigation
- **Material 3** — `FilledButton` for primary CTAs, `OutlinedButton` for secondary; no hardcoded colors
- **`@async` only when method `await`s something** — `getProcessingAttempts` is async (DB); private `recordAttempt` is async (DB insert)
- **No `process.env` inside modules** — already satisfied, no config needed for this feature
- **Controllers are thin** — one service method call, immediate `successResponse` return
- **`successResponse` + `getCorrelationId`** — always use, no direct `res.json()`
- **TypeORM Data Mapper** — inject repository, no Active Record; use `this.attemptRepo.create({...})` + `save()`

### Files to create/modify

**Create:**
- `apps/api/src/database/migrations/1730813600000-CreateReportProcessingAttemptsTable.ts`
- `apps/api/src/database/entities/report-processing-attempt.entity.ts`
- `apps/mobile/lib/features/reports/screens/processing_history_screen.dart`

**Modify:**
- `apps/api/src/database/migrations/index.ts` — register new migration
- `apps/api/src/modules/reports/reports.module.ts` — add entity to `forFeature`
- `apps/api/src/modules/reports/reports.service.ts` — add injection, `recordAttempt`, `getProcessingAttempts`, call `recordAttempt` in `uploadReport` and `retryParse`
- `apps/api/src/modules/reports/reports.controller.ts` — add `GET :id/attempts` endpoint (before `GET :id`)
- `apps/mobile/lib/features/reports/reports_repository.dart` — add `ProcessingAttempt` model + abstract method
- `apps/mobile/lib/features/reports/api_reports_repository.dart` — implement `getProcessingAttempts`
- `apps/mobile/lib/features/reports/screens/report_detail_screen.dart` — add "View attempt history" button + import

### Previous story intelligence (2.10 and 2.9)

- **Disclaimer pattern not needed here** — processing attempt history is metadata (trigger/outcome/timestamp), not AI-derived clinical data, so no "informational only" disclaimer required
- **`!` force-unwrap on `report.summary` was flagged as HIGH in 2.9 code review** — use null-safe access throughout; local variable extraction before use
- **API code review caught `retryParse` not parsing `summary`** — follow the same pattern: parse all fields that the API returns; don't leave partial parsing
- **`TrendDataPoint.date` is `DateTime` in Flutter** — similarly, `ProcessingAttempt.attemptedAt` must be `DateTime`, parsed in repository layer
- **`reportsRepository` injected via constructor pattern** — same as `HealthHistoryScreen` and `TrendChartScreen`; never instantiate inside widget
- **`onBack: () => Navigator.of(ctx).pop()` pattern** — some screens in this project pass an explicit `onBack` callback, but for screens pushed via `Navigator.push` we can just use `Navigator.pop` directly in the AppBar back button (or use the default `AppBar` back button from Flutter without an explicit `onBack` parameter — simpler)

### Architecture compliance

- **Profile-scoped data boundary**: ownership validated via `reportRepo.findOne({ where: { id, userId } })` in `getProcessingAttempts` — same pattern as `getReport`
- **No PHI in logs**: attempt table contains only trigger/outcome metadata; no patient data
- **DB snake_case, API JSON camelCase**: `report_id`, `attempted_at` → `reportId`, `attemptedAt`
- **Immutable records**: no `@UpdateDateColumn`; service never updates attempt rows
- **`autoLoadEntities: true`** in AppModule — entity auto-discovered after `forFeature` registration; no manual entity array update needed in AppModule

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.11]
- [Source: _bmad-output/implementation-artifacts/2-10-profile-level-consolidated-health-history.md] — constructor injection pattern, `Navigator.push`, Scaffold structure, widget keys
- [Source: _bmad-output/implementation-artifacts/2-9-report-level-summary-display-with-safe-framing.md] — force-unwrap code review lesson, `retryParse` parsing completeness
- [Source: _bmad-output/planning-artifacts/architecture.md] — DB naming conventions, API response envelope, profile-scoped ownership
- [Source: _bmad-output/project-context.md] — no `!`, no business logic in widgets, Material 3, navigator patterns, NestJS rules, TypeORM Data Mapper, `successResponse`, route order

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

### File List
