# Story 3.6: Doctor-Friendly Share Page (Timeline + Trends, Print-Friendly)

Status: review

## Story

As a recipient,
I want a readable doctor-friendly page,
So that consultation usage is practical.

## Acceptance Criteria

1. **Given** the share page renders, **When** viewed, **Then** reports are displayed in chronological timeline order (oldest → newest) with the report date prominently shown as a section header.
2. **Given** a report has extracted lab values, **When** the share page loads, **Then** each report section displays a table of lab values (parameter name, value, unit) sorted by `sortOrder ASC, parameterName ASC`.
3. **Given** a report has a summary, **When** displayed, **Then** the full summary text is shown (not truncated) in a visually distinct area.
4. **Given** any number of reports, **When** the page is printed, **Then** print styles apply: navigation and the Print button are hidden, all report sections are fully expanded, content is black text on white background, page breaks are avoided within a single report section.
5. **Given** the share page, **When** a Print button is clicked, **Then** `window.print()` is triggered.
6. **Given** a profile with multiple reports sharing the same lab parameter, **When** the share page loads, **Then** a "Trends at a Glance" section is rendered above the timeline showing each repeated parameter with its values and dates in chronological order.
7. **Given** the share page, **When** rendered, **Then** the `<meta name="robots" content="noindex, nofollow">` is present (inherited from 3.5 — do not remove).
8. **Given** the public API endpoint `GET /v1/sharing/public/:token`, **When** called, **Then** each report in the response includes a `labValues` array with `{ parameterName, value, unit }` objects.

## Tasks / Subtasks

- [x] Task 1: Extend public API to include lab values per report (AC: #8)
  - [x] Add `PublicLabValueDto` interface to `sharing.service.ts`: `{ parameterName: string; value: string; unit: string | null }`
  - [x] Add `labValues: PublicLabValueDto[]` field to `PublicReportDto` in `sharing.service.ts`
  - [x] In `getPublicShareData()`, after fetching reports, batch-fetch lab values for all report IDs from `reportLabValueRepo`; attach them per report ordered by `sortOrder ASC, parameterName ASC`
  - [x] `ReportLabValueEntity` repository was NOT yet injected (story 3.5 did not add it); added to both `sharing.module.ts` and `sharing.service.ts` constructor

- [x] Task 2: Revamp share page for doctor-friendly timeline view (AC: #1, #2, #3, #7)
  - [x] Update `PublicReportDto` and `PublicLabValueDto` interfaces in `apps/web/app/pages/share/[token].vue`
  - [x] Display reports sorted chronologically (oldest first — reverse current order): `[...shareData.reports].sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())`
  - [x] Each report renders as a card: date as `<h2>` or section heading, original filename as subtitle, full summary in a `<blockquote>` or styled `<p>`, lab values in an HTML `<table>` with columns: Parameter | Value | Unit
  - [x] Empty state: if `report.labValues` is empty, omit the lab table for that report

- [x] Task 3: Add "Trends at a Glance" section (AC: #6)
  - [x] Compute trends client-side: group all `labValues` across all reports by `parameterName`; keep only parameters appearing in ≥2 reports
  - [x] Sort trend parameters alphabetically; sort each parameter's data points by report `createdAt` ascending
  - [x] Render a "Trends at a Glance" section above the timeline; for each trend parameter: show parameter name as row label, then each value+unit with its date
  - [x] If no trend parameters exist, omit the section entirely (no empty header)

- [x] Task 4: Add print styles and Print button (AC: #4, #5)
  - [x] Add a `<style>` block in `[token].vue` with `@media print` rules:
    - `.no-print { display: none !important }` — apply class to Print button and any chrome
    - `body { color: #000; background: #fff }`
    - `.report-card { break-inside: avoid; page-break-inside: avoid }`
    - Remove box-shadows and rounded border styles in print (borders only)
    - Expand all content (no truncation, no overflow hidden)
  - [x] Add Print button above the report list (inside `v-else-if="shareData"` block) with `class="no-print"` and `@click="printPage"` — label: "Print / Save as PDF"
  - [x] Add `<a href="#top" class="no-print">Back to top</a>` at the bottom per UX spec

## Dev Notes

### Current Share Page State (from Story 3.5)

File: `apps/web/app/pages/share/[token].vue`

The existing page already has:
- Token extraction via `useRoute().params.token`
- `$fetch` call to `config.public.apiBaseUrl + '/sharing/public/' + token`
- Loading/404/410/error/success states — **do not remove these**
- `useHead` with `robots: noindex, nofollow` — **do not remove**
- `formatDate()` helper for ISO → human date
- Reports displayed as `<ul>` with truncated summary

This story **replaces** the success-state template (the `v-else-if="shareData"` block) and adds the `labValues` field to the interface. Do not touch loading/error states.

### API: Lab Values Already Available — Repository Already Injected

`ReportLabValueEntity` repository was injected into `SharingService` in story 3.5. Check `sharing.service.ts` constructor — `@InjectRepository(ReportLabValueEntity) private readonly reportLabValueRepo`. No module change needed.

Batch-fetch pattern (mirrors authenticated reports service in `reports.service.ts`):

```typescript
// After fetching reports[]...
const reportIds = reports.map((r) => r.id);
let labValues: ReportLabValueEntity[] = [];
if (reportIds.length > 0) {
  labValues = await this.reportLabValueRepo.find({
    where: { reportId: In(reportIds) },
    order: { sortOrder: 'ASC', parameterName: 'ASC' },
  });
}
// Group by reportId
const labByReport = new Map<string, ReportLabValueEntity[]>();
for (const lv of labValues) {
  if (!labByReport.has(lv.reportId)) labByReport.set(lv.reportId, []);
  labByReport.get(lv.reportId)!.push(lv);
}
// Include In import from 'typeorm' — already imported in the file
```

`PublicReportDto` extension:
```typescript
export interface PublicLabValueDto {
  parameterName: string;
  value: string;
  unit: string | null;
}

export interface PublicReportDto {
  id: string;
  originalFileName: string;
  status: string;
  summary: string | null;
  createdAt: string;
  labValues: PublicLabValueDto[];  // NEW
}
```

Return mapping:
```typescript
reports: reports.map((r) => ({
  id: r.id,
  originalFileName: r.originalFileName,
  status: r.status,
  summary: r.summary,
  createdAt: r.createdAt.toISOString(),
  labValues: (labByReport.get(r.id) ?? []).map((lv) => ({
    parameterName: lv.parameterName,
    value: lv.value,
    unit: lv.unit,
  })),
})),
```

**PHI Safety:** Do NOT include `parsedTranscript` in the public response. Lab values and AI summary are safe to expose (they are the sharing purpose). Do NOT log `token` values.

### Nuxt App: Nuxt 4 with `app/` srcDir

Story 3.5 scaffolded Nuxt 4 (`^4.4.2`). The srcDir convention places pages at `apps/web/app/pages/` (not `apps/web/pages/`). The single file to modify for the web surface is `apps/web/app/pages/share/[token].vue`.

Runtime config API base: `config.public.apiBaseUrl` defaults to `http://localhost:3000/v1`.

Use `$fetch` (not `useFetch`) — `onMounted` pattern works fine for a non-SEO page (share routes are noindex by design). This avoids SSR data-fetching complexity.

### Trends Computation (Client-Side)

The trends section groups lab values across all reports. This is purely client-side — no new API endpoint needed:

```typescript
// Compute trends: only parameters appearing in ≥2 distinct reports
function computeTrends(reports: PublicReportDto[]) {
  const paramMap = new Map<string, { date: string; value: string; unit: string | null }[]>()
  const sorted = [...reports].sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
  for (const report of sorted) {
    for (const lv of report.labValues) {
      if (!paramMap.has(lv.parameterName)) paramMap.set(lv.parameterName, [])
      paramMap.get(lv.parameterName)!.push({ date: report.createdAt, value: lv.value, unit: lv.unit })
    }
  }
  // Keep only params with ≥2 data points
  return [...paramMap.entries()]
    .filter(([, points]) => points.length >= 2)
    .sort(([a], [b]) => a.localeCompare(b))
}
```

Render as a `<table>` with columns: Parameter | then one column per report date. Or simpler: a flat list with each parameter on its own row showing all its values.

### Print Styles Pattern

Use a scoped `<style>` block in the `.vue` file. Since Nuxt 4 uses Vite, `@media print` works in scoped styles but selectors must be correctly scoped. For global print behavior, use unscoped styles or `:deep()`.

Recommended: use an unscoped `<style>` block for print rules to avoid scoping issues:

```vue
<style>
@media print {
  .no-print { display: none !important; }
  body { color: #000 !important; background: #fff !important; }
  .report-card { break-inside: avoid; page-break-inside: avoid; }
}
</style>
```

Add scoped styles for visual design in a separate `<style scoped>` block.

### UX Requirements Summary

From `ux-design-specification.md`:
- "Doctor-view success: Recipient sees **timeline + summary + key values**; first meaningful paint <3s on 3G; **print preserves layout** (one page or paginated); **no critical content behind JS**"
- "Share page on low bandwidth or print: Share page minimal (critical content in HTML, minimal JS); print styles (hide nav, expand content)"
- "Profile/patient context (e.g. 'Reports for [Name]') in a consistent, prominent position (e.g. top of content)"
- Optional "Print" and "Back to top" links per UX nav pattern for web share page

**Visual direction (architecture):** "No primary-colour CTAs; text and subtle borders so it reads as a report, not an app." Use neutral/monochrome styling. The page should feel like a printed document.

### Project Structure Notes

- Only 2 files change: `apps/api/src/modules/sharing/sharing.service.ts` and `apps/web/app/pages/share/[token].vue`
- No new files needed; no module registrations; no migrations (lab values table exists from story 2.7)
- Do not touch `apps/mobile` — this is web + API only
- The `apps/web/app/` directory structure is: `app.vue`, `pages/share/[token].vue`
- No `composables/` directory exists yet — keep all logic in the single page component

### References

- `SharingService.getPublicShareData()` [Source: apps/api/src/modules/sharing/sharing.service.ts#L78]
- `ReportLabValueEntity` fields: `reportId`, `parameterName`, `value`, `unit`, `sampleDate`, `sortOrder` [Source: apps/api/src/database/entities/report-lab-value.entity.ts]
- Lab value batch-fetch pattern [Source: apps/api/src/modules/reports/reports.service.ts#L328]
- Existing share page [Source: apps/web/app/pages/share/[token].vue]
- `nuxt.config.ts` runtime config [Source: apps/web/nuxt.config.ts]
- UX: doctor-view success criteria [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Section 2.7]
- UX: share page print requirement [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Section 2.6]
- Architecture: share page is non-indexable [Source: _bmad-output/planning-artifacts/architecture.md#L381]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

Note: `ReportLabValueEntity` repo was not injected in story 3.5 as the dev notes claimed — added it in both `sharing.module.ts` and `sharing.service.ts`.

### Completion Notes List

- Task 1: Added `PublicLabValueDto` interface; extended `PublicReportDto` with `labValues`; added `ReportLabValueEntity` to `SharingModule` forFeature and injected into `SharingService`; batch-fetches lab values per report in `getPublicShareData()` ordered by `sortOrder ASC, parameterName ASC`.
- Task 2: Replaced success-state template with doctor-friendly timeline; reports sorted oldest→newest via `sortedReports` computed; each report card shows date header, filename subtitle, full summary in blockquote, lab values table. Loading/error states preserved. `noindex` meta preserved.
- Task 3: `computeTrends()` groups lab values across all reports; keeps params with ≥2 data points; sorted alphabetically. "Trends at a Glance" table rendered above timeline only when trends exist. `trendDates` computed used for safe header column generation.
- Task 4: Unscoped `@media print` block hides `.no-print` elements, sets black-on-white, adds `break-inside: avoid` on `.report-card`. Print button calls `printPage()` (window-safe). "Back to top" link at bottom. All with `no-print` class.
- Nuxt `nuxt prepare` run to generate `.nuxt` types directory; all TS errors in story files resolved.

### File List

- apps/api/src/modules/sharing/sharing.module.ts
- apps/api/src/modules/sharing/sharing.service.ts
- apps/web/app/pages/share/[token].vue

## Change Log

- 2026-03-23: Implemented story 3.6 — extended public API with labValues per report; revamped share page to doctor-friendly timeline with trends section and print styles.
