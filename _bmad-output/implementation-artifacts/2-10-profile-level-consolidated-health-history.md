# Story 2.10: Profile-Level Consolidated Health History

Status: done

## Story

As an authenticated user,
I want a consolidated health history view for the active profile,
so that I can see the latest value for every tracked parameter across all my reports in one place.

## Acceptance Criteria

1. **Given** a profile has at least one parsed report with extracted lab values
   **When** I open the health history screen for that profile
   **Then** I see a list of parameters showing the most recent value, unit (if present), and date for each unique parameter
   **And** parameters are sorted alphabetically by parameterName
   **And** tapping a parameter navigates to `TrendChartScreen` for that parameter and profileId

2. **Given** a parameter appears in multiple reports for the same profile
   **When** the consolidated view loads
   **Then** only the most recent value (latest date — sampleDate when present, else report date) is shown per parameter
   **And** the date shown is the date of that most recent measurement

3. **Given** the health history screen displays lab data extracted from parsed reports (AI-derived)
   **When** the screen is visible (even with zero parameters)
   **Then** a disclaimer is shown: "Informational only — not medical advice. Discuss with your doctor."
   **And** the disclaimer is always visible, not hidden behind a scroll

4. **Given** a profile has no parsed reports, or reports exist but have no extracted lab values
   **When** I open the health history screen
   **Then** an empty state is displayed: "No health data yet. Upload a report to see your health history."
   **And** no parameter list or partially-loaded state is shown

5. **Given** data is loading from the API
   **When** the health history screen first mounts
   **Then** a loading indicator is shown
   **And** no stale or partial data is visible during loading

6. **Given** health history data is scoped to the active profile
   **When** the API is called
   **Then** only data from reports belonging to the authenticated user's active profile is returned
   **And** no cross-profile data leakage occurs (enforced by existing `getLabTrends` ownership check)

## Tasks / Subtasks

- [x] Flutter: create `HealthHistoryScreen` (AC: 1, 2, 3, 4, 5)
  - [x] Create `apps/mobile/lib/features/reports/screens/health_history_screen.dart`
  - [x] Screen accepts `profileId` (required) as constructor parameter
  - [x] On `initState`, call `reportsRepository.getLabTrends(profileId)` (existing method from story 2.8)
  - [x] Loading state: show `CircularProgressIndicator` centered in body (key: `Key('health-history-loading')`)
  - [x] From `LabTrendsResult.parameters`, compute latest value per parameter: for each `TrendParameter`, take `dataPoints.last` (already sorted ascending by date from API). If `dataPoints` is empty, exclude that parameter from display.
  - [x] Show parameter list sorted alphabetically by `parameterName`
  - [x] Each row: `ListTile` showing `parameterName` as title, `"${latestPoint.value} ${param.unit ?? ''}"` as subtitle, date as trailing text
  - [x] Each row is tappable → `Navigator.push` to `TrendChartScreen(profileId: profileId, parameterName: param.parameterName)` (reuse existing screen from story 2.8)
  - [x] Empty state: when `parameters` is empty after filtering → show centered `Text` with `Key('health-history-empty')`: "No health data yet. Upload a report to see your health history."
  - [x] Disclaimer: always visible in the body above or below the parameter list; use `Row(Icon(Icons.info_outline, size: 14), Text(...))` with `Key('health-history-disclaimer')` matching story 2.9 pattern; show even in empty state
  - [x] Error state: show inline error text with retry button when API call fails; `Key('health-history-error')`
  - [x] Full `Scaffold` with `AppBar(title: Text('Health History'))` and `Padding(16)`

- [x] Flutter: add entry point from `TimelineScreen` (AC: 1)
  - [x] In `apps/mobile/lib/features/reports/screens/timeline_screen.dart`, add an action in the `AppBar` (e.g. `IconButton(icon: Icon(Icons.health_and_safety), tooltip: 'Health History')`) or a `ListTile`/`Card` button above the report list
  - [x] Tap navigates via `Navigator.push` to `HealthHistoryScreen(profileId: resolvedProfileId)`
  - [x] Use the same `profileId` already in scope in `TimelineScreen`

- [x] Flutter: wire `HealthHistoryScreen` into `ReportsRepository` (AC: 6)
  - [x] No new repository method needed — `getLabTrends(profileId)` already exists in `ReportsRepository` (story 2.8); `HealthHistoryScreen` calls it directly via the injected `reportsRepository`
  - [x] Confirm `InMemoryReportsRepository` already implements `getLabTrends` (check `reports_repository.dart`)

## Dev Notes

### Scope and key decisions

- **No new backend endpoint.** `GET /reports/lab-trends?profileId=...` (story 2.8) already returns all parameters with all numeric data points sorted by date ascending per parameter. The "latest value" = `dataPoints.last` for each parameter. This avoids duplicating ownership logic and adding API surface.
- **No new migrations or backend changes.** This story is Flutter-only.
- **Parameter deduplication is already done server-side** — the trends endpoint groups by exact `parameterName` match. One entry per unique parameter name in the response.
- **Data for the view**: `LabTrendsResult.parameters` → `List<TrendParameter>`. Each has `parameterName`, `unit?`, `dataPoints: List<TrendDataPoint>({date, value})`. Use `dataPoints.last` for the latest value.
- **Disclaimer is mandatory** (FR40 + architecture NFR): every screen showing AI-extracted data must show "Informational only — not medical advice. Discuss with your doctor." Make it always visible, not conditional on having data.

### Existing types and models (no changes needed)

From `reports_repository.dart` (story 2.8):
```dart
class TrendDataPoint { final String date; final double value; }
class TrendParameter { final String parameterName; final String? unit; final List<TrendDataPoint> dataPoints; }
class LabTrendsResult { final List<TrendParameter> parameters; }

abstract class ReportsRepository {
  // existing:
  Future<LabTrendsResult> getLabTrends(String profileId, {String? parameterName});
  // ...
}
```

`HealthHistoryScreen` calls `getLabTrends(profileId)` with no `parameterName` filter → gets all parameters.

### Latest value derivation (Flutter)

```dart
// Within HealthHistoryScreen, after fetch:
final allParams = result.parameters
    .where((p) => p.dataPoints.isNotEmpty)
    .toList()
  ..sort((a, b) => a.parameterName.compareTo(b.parameterName));

// Per row:
final latest = param.dataPoints.last; // sorted ascending by API
// Display: latest.value, param.unit, latest.date
```

### Screen structure

```
Scaffold
  AppBar(title: 'Health History')
  body: Padding(16)
    Column(
      [DISCLAIMER ROW — always visible]
      [SizedBox(8)]
      if loading → CircularProgressIndicator(key: 'health-history-loading')
      else if error → error text + retry (key: 'health-history-error')
      else if allParams.isEmpty → Text(key: 'health-history-empty')
      else → Expanded(ListView(children: [...ListTile rows]))
    )
```

### Navigation from TimelineScreen

The `TimelineScreen` already receives `profileId` (or active profile context). Add to the `AppBar`:
```dart
actions: [
  IconButton(
    key: const Key('timeline-health-history-button'),
    icon: const Icon(Icons.health_and_safety_outlined),
    tooltip: 'Health History',
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HealthHistoryScreen(
          profileId: profileId,
          reportsRepository: widget.reportsRepository,
        ),
      ),
    ),
  ),
],
```

### Row tap navigation (to TrendChartScreen)

Reuse `TrendChartScreen` exactly as story 2.8 did from `ReportDetailScreen`:
```dart
ListTile(
  key: Key('health-history-param-${param.parameterName}'),
  title: Text(param.parameterName),
  subtitle: Text('${latest.value} ${param.unit ?? ''}  ·  ${latest.date}'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TrendChartScreen(
        profileId: profileId,
        parameterName: param.parameterName,
        reportsRepository: widget.reportsRepository,
      ),
    ),
  ),
)
```

### Disclaimer widget (matches story 2.9 pattern)

```dart
Row(
  key: const Key('health-history-disclaimer'),
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(Icons.info_outline, size: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant),
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
)
```

### Project rules to follow

- No `!` force-unwrap — use `param.unit ?? ''`, `dataPoints.isEmpty` check before `.last`
- Full `Scaffold` with `AppBar` and `Padding(16)` body
- Widget keys use kebab-case strings: `Key('health-history-loading')`, `Key('health-history-empty')`, `Key('health-history-disclaimer')`, `Key('health-history-error')`, `Key('health-history-param-${param.parameterName}')`
- `reportsRepository` injected via constructor (not instantiated inside widget)
- `Navigator.push` for secondary screen navigation (not state enum — that's only for top-level app flow)
- No business logic in widgets — compute `allParams` in `setState`/`initState`, not inside `build`

### Files to create/modify

**Create:**
- `apps/mobile/lib/features/reports/screens/health_history_screen.dart`

**Modify:**
- `apps/mobile/lib/features/reports/screens/timeline_screen.dart` — add `IconButton` in AppBar to navigate to `HealthHistoryScreen`

**No changes needed:**
- `reports_repository.dart` — `getLabTrends` already exists
- `api_reports_repository.dart` — already implements `getLabTrends`
- Backend (`reports.service.ts`, `reports.controller.ts`) — reusing existing endpoint

### Previous story intelligence (2.9)

- Disclaimer `Row` pattern: `Icon(Icons.info_outline, size: 14)` + `Text(...)` with `bodySmall` + `onSurfaceVariant` color. Copy exact structure.
- Force-unwrap `!` in production was a code-review issue in 2.9 — use local variable extraction and null-safe access throughout.
- `toDto` spread pattern not relevant here (Flutter-only story).

### Previous story intelligence (2.8)

- `TrendChartScreen` constructor: accepts `profileId`, `parameterName`, `reportsRepository`. Pass all three when navigating.
- `getLabTrends` in `ApiReportsRepository` calls `GET /reports/lab-trends?profileId=&parameterName=`. When `parameterName` omitted → returns all parameters.
- `dataPoints` are sorted ascending by date (from API). `.last` is safe after checking `dataPoints.isNotEmpty`.
- Chart bounds issue: `minY == maxY` edge case. Not relevant in health history list view, but remember this if any chart is added.
- `fl_chart ^1.2.0` already in `pubspec.yaml` — no new dependencies needed.

### Architecture compliance

- Profile-scoped data: `getLabTrends` already validates user owns the profile (existing ownership guard in API).
- No PHI in logs.
- Informational disclaimer mandatory per FR40.
- Material 3 components; no hardcoded colors.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.10]
- [Source: _bmad-output/planning-artifacts/epics.md#FR21]
- [Source: _bmad-output/implementation-artifacts/2-8-trend-chart-rendering-for-chartable-parameters.md] — `getLabTrends` contract, `TrendChartScreen`, `ReportsRepository` models
- [Source: _bmad-output/implementation-artifacts/2-9-report-level-summary-display-with-safe-framing.md] — disclaimer `Row` pattern, force-unwrap fix
- [Source: _bmad-output/project-context.md] — no `!` in production, full Scaffold, widget keys kebab-case, Navigator.push for secondary screens, Material 3, repository injection pattern
- [Source: _bmad-output/planning-artifacts/architecture.md] — profile-scoped data, NFR compliance
- [Source: _bmad-output/planning-artifacts/prd.md#FR40] — informational-only disclaimer enforcement

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Created `HealthHistoryScreen` with loading/error/empty/list states, always-visible disclaimer, and alphabetically-sorted parameter list using `getLabTrends` (no new API).
- Each list row taps into `TrendChartScreen` reusing existing screen (required `onBack` callback provided via `Navigator.of(ctx).pop()`).
- `TrendDataPoint.date` is `DateTime`; formatted as `yyyy-MM-dd` for display.
- Added `IconButton` with `Icons.health_and_safety_outlined` to `TimelineScreen` AppBar actions, navigating to `HealthHistoryScreen`. Fixed pre-existing `unnecessary_const` lint warning in same file.
- All 6 ACs satisfied. No new dependencies, no backend changes.

### File List

- `apps/mobile/lib/features/reports/screens/health_history_screen.dart` (created)
- `apps/mobile/lib/features/reports/screens/timeline_screen.dart` (modified)

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-15 | AI (claude-sonnet-4-6) | Story created: profile-level consolidated health history; Flutter-only (reuses existing lab-trends API); HealthHistoryScreen showing latest value per parameter; entry from TimelineScreen; disclaimer and empty/loading/error states. |
| 2026-03-15 | AI (claude-sonnet-4-6) | Implemented: created HealthHistoryScreen with all states and disclaimer; wired into TimelineScreen AppBar; no backend changes; flutter analyze passes with no issues. |
| 2026-03-16 | AI Code Review (claude-sonnet-4-6) | Code review complete. Fixed 2 LOW issues: trailing space in subtitle when unit is null (health_history_screen.dart:160); retryParse in api_reports_repository.dart missing summary parse from response. All 6 ACs verified. Status: done. |

## Senior Developer Review (AI)

**Date:** 2026-03-16
**Outcome:** Approve (after fixes)
**Reviewer:** claude-sonnet-4-6

### Summary

All 6 Acceptance Criteria are implemented and verified. Git matches story File List exactly (0 discrepancies). 2 Low issues found and fixed in-session.

### Action Items

- [x] **[Low]** `health_history_screen.dart:160` — Trailing space in subtitle when unit is null: `'${latest.value} ${param.unit ?? ''} · ...'` rendered as `"5.5  · date"`. **Fixed:** changed to `'${latest.value}${param.unit != null ? ' ${param.unit}' : ''} · ...'`.
- [x] **[Low]** `api_reports_repository.dart:81` — `retryParse` did not parse `summary` from the API response. After a successful retry the summary would not appear until the user navigated away and back. **Fixed:** added `summary: d['summary'] as String?` to the returned `Report`.
