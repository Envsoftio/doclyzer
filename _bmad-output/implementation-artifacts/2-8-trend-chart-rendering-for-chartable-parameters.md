# Story 2.8: Trend Chart Rendering for Chartable Parameters

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want to view trend charts for chartable lab parameters over time,
so that longitudinal changes (e.g. Hb, glucose) are visible in one place.

## Acceptance Criteria

1. **Given** a profile has at least two lab data points for the same parameter (same parameterName, numeric value, and sampleDate or report date)
   **When** I open the trend view for that parameter (from report detail or a trend entry point)
   **Then** a chart renders with time on the x-axis and value on the y-axis
   **And** points are ordered chronologically and labeled (date, value, unit if present)

2. **Given** a profile has only one data point for a parameter (or no numeric chartable points)
   **When** I open the trend view for that parameter
   **Then** a deterministic fallback is shown: e.g. "Add more reports to see trend" or single-value summary (no chart line)
   **And** no crash or broken chart; empty state is explicit and actionable

3. **Given** I am viewing a trend chart
   **When** data is loading
   **Then** a loading state is shown for the chart area; no flash of wrong or empty data

4. **Given** trend data is scoped to a profile I own
   **When** I request trend data for that profile (and optional parameter filter)
   **Then** the API returns only lab values from reports belonging to that profile
   **And** ownership is validated via existing profile/report ownership (no PHI in logs per project-context)

5. **Given** a parameter has mixed numeric and non-numeric values across reports
   **When** trend data is built
   **Then** only numeric parseable values are included in the chart series; non-numeric entries are excluded (deterministic, documented behavior)

## Tasks / Subtasks

- [x] API: trend data endpoint and contract (AC: 1, 2, 4, 5)
  - [x] Add endpoint `GET /reports/lab-trends?profileId=...` (profileId required). **Route must be registered before `GET /reports/:id`** in ReportsController so "lab-trends" is not matched as :id. Query: `parameterName` (optional) — if provided, return only that parameter's series. Use existing ProfilesService/ReportsService to enforce profile ownership (user owns profile).
  - [x] Aggregate from `report_lab_values` joined with reports where report.profileId = profileId. Group by parameterName (exact match; no normalisation in this story). For each parameter return `{ parameterName, unit?, dataPoints: { date, value }[] }`. Dates: use sampleDate when present, else report createdAt. Values: only include rows where parseFloat(value) is not NaN; exclude non-numeric. Note: values like ">10" parse as NaN and are excluded.
  - [x] Document "chartable" as: parameter with at least one numeric value; trend view shows chart only when ≥2 points exist for that parameter.
  - [x] Reuse AuthGuard, successResponse, correlation ID; no PHI in logs.

- [x] Flutter: trend chart screen and integration (AC: 1, 2, 3)
  - [x] Add a chart dependency (fl_chart ^1.2.0). Keep bundle size and accessibility in mind.
  - [x] Add trend API client: method to fetch trend data for profile (and optional parameter). Parse response into model (parameterName, unit, list of { date, value }).
  - [x] Add TrendChartScreen under `lib/features/reports/screens/`: accepts profileId and parameterName. Loading state while fetching; if ≥2 points render chart (time x, value y); if <2 points show empty state "Add more reports to see trend".
  - [x] Entry points: from ReportDetailScreen — each lab value row is tappable (InkWell with trailing chevron icon); tap navigates to TrendChartScreen with parameterName and profileId. Navigation: push TrendChartScreen; back returns to report detail.
  - [x] Chart: axes labeled (Date, Value + unit); points/line; Semantics widget for accessibility. On trend fetch failure, show error message with retry.

- [x] Integration and scope (AC: 4)
  - [x] Ensure profileId for trend request is always the active profile (or selected profile context); no cross-profile data leakage.

- [x] Tests
  - [x] API: unit test aggregation (numeric-only, date fallback, profile scoping); E2E: GET trend for own profile 200 and shape; GET for other profile 404.
  - [x] Flutter: widget test TrendChartScreen — loading state; chart when ≥2 points; empty state when <2 points; Semantics widget for a11y; ReportDetailScreen lab row tap navigates to TrendChartScreen.

## Dev Notes

### Scope and data boundary

- **Chartable:** A lab parameter is chartable when it has numeric values (parseFloat, exclude NaN) and a date (sampleDate or report date). Same `parameterName` across reports in one profile forms one series. Use exact parameterName match for grouping; no normalisation in this story.
- **Display only:** This story is about rendering trend from existing `report_lab_values` and report metadata. No new persistence; aggregation in API or client. Prefer API-side aggregation so profile ownership is enforced once and client gets ready-to-chart data. Reference ranges (UX spec) are out of scope for this story.
- Profile/report ownership: reuse existing patterns (report belongs to profile, user owns profile). NFR8: profile-scoped data enforced.

### API contract (recommended)

- **GET /reports/lab-trends?profileId=...** (profileId required; route before GET /reports/:id)
  - Query: `profileId` (required), `parameterName` (optional) — if provided, return only that parameter’s series.
  - Response (successResponse envelope): `{ parameters: Array<{ parameterName: string, unit?: string, dataPoints: Array<{ date: string (ISO), value: number }> }> }`. When parameterName filter used, return single object or array with one element. Sort dataPoints by date ascending. Include only parameters with at least one numeric value; exclude parameters with zero chartable points.
  - Unit: when same parameter has different units across reports, use first non-null unit for response; client may show per-point unit in tooltip.
- **Ownership:** Caller must be authenticated; profileId must belong to user (ProfilesService or existing guard). Return 403/404 if not owner.

### Architecture and project rules

- **Profile-scoped data:** Only return trend data for reports in profiles the user owns. No PHI in logs (project-context).
- **Response envelope:** Use `successResponse(data, correlationId)`; include trend payload in `data`.
- **Naming:** DB snake_case, API JSON camelCase (architecture.md).

### Files to touch

- **API:** New endpoint in ReportsController: `GET /reports/lab-trends?profileId=...` (register before :id route); `ReportsService.getLabTrends(userId, profileId, parameterName?)`; optional new DTO for trend response; reuse ReportLabValueEntity, ReportEntity, profile ownership check.
- **Flutter:** New dependency (fl_chart — check pub.dev for latest version); add `getLabTrends(profileId, parameterName?)` to ReportsRepository; model for trend parameter + dataPoints; `trend_chart_screen.dart`; report detail screen — make lab rows tappable or add "View trend" per row; navigation wiring.

### Previous story intelligence (2.7)

- **2.7:** Report_lab_values table (reportId, parameterName, value, unit, sampleDate, sortOrder). GET /reports/:id returns extractedLabValues. ReportDetailScreen shows lab list; timeline → report detail → View PDF. Reuse: AuthGuard, successResponse, profile ownership, repository pattern, Material 3, full Scaffold. Trend data can be built by querying report_lab_values joined with reports filtered by profileId; value must be parsed as number for charting.

## Technical Requirements

- **API:** Implement GET /reports/lab-trends?profileId=... (route before :id) that aggregates report_lab_values by profile and optional parameterName; return only numeric values (parseFloat, exclude NaN); date = sampleDate ?? report.createdAt; enforce profile ownership via existing patterns.
- **Flutter:** Add chart package; trend API client; TrendChartScreen with loading, chart (≥2 points), and empty state (&lt;2 points); entry from report detail (and optionally timeline); a11y-friendly labels.

## Architecture Compliance

- ADR: Profile-scoped data; reuse report → profile → user ownership. NFR8 enforced. DB snake_case, API camelCase. No PHI in logs. Use successResponse and AuthGuard.

## Library / Framework Requirements

- **Backend:** No new deps; TypeORM for querying ReportLabValueEntity + ReportEntity; reuse ProfilesService for ownership check, AuthGuard, successResponse.
- **Flutter:** Add one chart library (e.g. fl_chart); Material 3, Scaffold; reuse ApiClient and repository pattern; follow project-context (no force-unwrap, repository abstraction).

## Testing Requirements

- **API unit:** getLabTrends returns correct aggregation for numeric-only values; date fallback; filters by profileId; excludes other users’ data (mock repos + profile check).
- **API E2E:** GET lab-trends for own profile → 200 and shape; GET for other profile → 403 or 404.
- **Flutter:** TrendChartScreen — loading state; chart when ≥2 points; empty state when 0 or 1 point; widget test keys (e.g. Key('trend-chart-screen')), semantics for chart region.

## Previous Story Intelligence (2.7)

- ReportLabValueEntity and report_lab_values table; getReport returns extractedLabValues. ReportDetailScreen shows lab list; timeline → report detail → View PDF. For 2.8: add trend aggregation in API (query report_lab_values + reports by profileId); add TrendChartScreen and chart package; entry from report detail (tap parameter or "View trend"). Reuse same authz and response patterns.

## Git Intelligence Summary

- Recent work: report status handling (content_not_recognized), listReports by profileId, duplicate detection, B2 upload, avatar upload. Patterns: extend ReportsService/controller with new methods; Flutter repository + new screen; E2E with ownership checks; sprint status updates to review/done.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, ConfigService, no process.env in modules, error codes in types file, PHI-safe logging, successResponse envelope; Flutter repository pattern, no force-unwrap, full Scaffold, Material 3, widget test keys kebab-case.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.8]
- [Source: _bmad-output/planning-artifacts/epics.md#FR19]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md] — Trend chart: axes, points, reference range if available; states loading / ≥2 points / single point empty state; entry from report detail or timeline.
- [Source: _bmad-output/planning-artifacts/architecture.md] — API camelCase, profile-scoped data, project structure
- [Source: _bmad-output/implementation-artifacts/2-7-structured-lab-extraction-display.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

None — implementation was straightforward following existing patterns.

### Completion Notes List

- Implemented `GET /reports/lab-trends?profileId=&parameterName=` in ReportsController, registered before `GET /reports/:id` to prevent route shadowing.
- `ReportsService.getLabTrends()` uses query builder approach: fetches report IDs for profile first, then queries lab_values by those IDs — avoids TypeORM relation-based where issues and is more explicit.
- Only numeric values (parseFloat, excluding NaN) are included. Date = sampleDate when present, else report.createdAt ISO slice (YYYY-MM-DD).
- Values like ">10" parse as NaN and are correctly excluded (documented in story).
- fl_chart ^1.2.0 added to Flutter (latest compatible version resolved by pub).
- TrendChartScreen: loading/chart/empty/error states; LineChart with labeled axes (Date, Value+unit); Semantics widget for a11y; tooltip shows date+value per point.
- ReportDetailScreen: lab value rows wrapped in InkWell with Key `lab-row-{parameterName}` and trailing chevron; tapping pushes TrendChartScreen.
- 155 API unit tests pass (39 reports.service, 19 reports.controller, all others green).
- 13 Flutter widget tests in reports domain pass (6 report_detail, 7 trend_chart).

### File List

apps/api/src/modules/reports/reports.service.ts
apps/api/src/modules/reports/reports.service.spec.ts
apps/api/src/modules/reports/reports.controller.ts
apps/api/src/modules/reports/reports.controller.spec.ts
apps/api/test/app.e2e-spec.ts
apps/mobile/pubspec.yaml
apps/mobile/pubspec.lock
apps/mobile/lib/features/reports/reports_repository.dart
apps/mobile/lib/features/reports/api_reports_repository.dart
apps/mobile/lib/features/reports/screens/trend_chart_screen.dart
apps/mobile/lib/features/reports/screens/report_detail_screen.dart
apps/mobile/test/trend_chart_test.dart
apps/mobile/test/report_detail_test.dart

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-15 | AI     | Story created: trend chart rendering for chartable parameters; API lab-trends aggregation; Flutter TrendChartScreen and chart package; deterministic fallback for &lt;2 points. |
| 2026-03-15 | AI     | Review fixes: route order (lab-trends before :id); endpoint GET /reports/lab-trends; response shape; parameter normalisation; unit handling; parseFloat edge case; entry point (tappable rows); error state; reference range OOS; repository placement. |
| 2026-03-15 | AI (claude-sonnet-4-6) | Implemented: API lab-trends endpoint (query builder approach, profile ownership, numeric-only filter); Flutter TrendChartScreen (fl_chart ^1.2.0, loading/chart/empty/error states, a11y Semantics); ReportDetailScreen tappable lab rows; full unit + widget test coverage; 155 API tests + 13 Flutter tests pass. |
| 2026-03-15 | AI (code-review) | Code review fixes: [H1] Add profileId required validation in getLabTrends controller (prevents cross-profile data leak); [M1] Fix chartMinY==chartMaxY when all values equal (y-axis zero-range); [M2] Add bounds check in tooltip getTooltipItems before dataPoints[idx] access. Controller spec updated with missing-profileId test. |
