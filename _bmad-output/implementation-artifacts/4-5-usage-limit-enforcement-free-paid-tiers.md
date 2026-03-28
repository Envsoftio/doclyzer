# Story 4.5: Usage Limit Enforcement (Free/Paid Tiers)

Status: review

## Story

As a product user,
I want consistent tier-limit enforcement,
so that actions are predictably allowed/blocked.

## Acceptance Criteria

1. **Given** the user already stores the maximum number of reports allowed by their current plan (Free: 5, Pro: 100 per `plans.limits.maxReports`), **When** they upload another report, **Then** the API returns `REPORT_LIMIT_EXCEEDED` and the UI surfaces an inline warning + upgrade CTA mentioning how many reports are in use and what the plan allows.
2. **Given** the user already has the maximum number of *active* share links permitted by their plan (Free: 1, Pro: 10 per `plans.limits.maxShareLinks`), **When** they tap “Create share link,” **Then** the API returns `SHARE_LINK_LIMIT_EXCEEDED` and the Flutter screen displays the guidance from the UX spec (clear “limit hit” message plus manage/upgrade next steps).
3. **Given** any new plan row is seeded in `plans.limits`, **When** usage enforcement runs, **Then** it always reads `entitlement.plan.limits` rather than hard-coding numbers so every tier (free, paid, or future plan) is respected automatically.
4. **Given** two concurrent attempts to create a share link, **When** they race to exceed the limit, **Then** the limit guard counts active links inside a transaction (or with sufficient locking) before persisting the new link so the maximum is never exceeded.

## Tasks / Subtasks

- [x] **Task 1: Centralize entitlement limit metadata & guard logic (backend service)**
  - [x] Add a helper in the entitlements domain (e.g. `UsageLimitsService`) that can be injected into Reports/Sharing services.
  - [x] Expose a method such as `EntitlementsService.getPlanLimits(userId)` so the helper can read `PlanEntity.limits` after `findOrProvision` without duplicating logic.
  - [x] The helper should count stored reports (`ReportEntity.userId`) and active share links (`ShareLinkEntity.userId`, `isActive`, `expiresAt`) and return a typed payload with `limit`, `current`, `planName`, `tier`, and a friendly `upgradeHint` (e.g. “Buy credits or upgrade to Pro via the Billing screen”).
  - [x] Register the helper in `EntitlementsModule`, export it, and keep it self-contained so every limit check uses a single source of truth.

- [x] **Task 2: Enforce the report upload limit (backend + errors)**
  - [x] Extend `apps/api/src/modules/reports/reports.types.ts` with `REPORT_LIMIT_EXCEEDED` and craft a new `ReportLimitExceededException` (403) that bundles the helper’s metadata inside `exception.getResponse().data`.
  - [x] Inject the limit helper into `ReportsService` and call it right after `getActiveProfileId`/before heavy file storage so the user is blocked before sending bytes.
  - [x] When the limit guard indicates the quota is hit, throw `ReportLimitExceededException`, reuse the plan-name info in the message (e.g. “Free plan allows 5 reports. Upgrade to Pro for more.”), and make sure the exception payload includes `current`, `limit`, and `upgradeHint` for the Flutter client.
  - [x] Keep the exception’s message in sync with `ux-design-specification.md` guidance: “At cap (Free)… clear next steps + upgrade CTA.”

- [x] **Task 3: Enforce the share-link limit (backend + errors)**
  - [x] Add `SHARE_LINK_LIMIT_EXCEEDED` to `apps/api/src/modules/sharing/sharing.types.ts` and create a `ShareLinkLimitExceededException` that also carries the helper’s metadata.
  - [x] Import `EntitlementsModule` into `SharingModule` so `SharingService` can inject the limit helper and call it before persisting a new `ShareLinkEntity`.
  - [x] When the helper reports the share limit is exhausted, throw the exception from `createShareLink` (before `shareLinkRepo.save`) so the client never regenerates the token or stores the row.
  - [x] Count only `isActive`links whose `expiresAt` is null or in the future (reuse `isLinkValid`). Remember that revoking or expiring a link should drop the count so the guard frees up a slot.

- [x] **Task 4: Surface limit guidance in Flutter (tokens + upgrade path)**
  - [x] Update `UploadReportScreen` to accept an optional `VoidCallback? onUpgrade` and to reflect `REPORT_LIMIT_EXCEEDED` by showing a new `Text` + `FilledButton(key: Key('upload-limit-upgrade'))` referencing `upgradeHint` from `ApiException.data`. Use keys like `Key('upload-limit-warning')` so tests can locate the warning.
  - [x] When the limit banner is shown, offer `widget.onUpgrade?.call()` so the app can open the Billing screen (via `_authView = _AuthView.billing`). Update `DoclyzerApp` (main.dart) to pass `onUpgrade: () => setState(() => _authView = _AuthView.billing)` when building `_AuthView.uploadReport`.
  - [x] Extend `TimelineScreen` to take an `onUpgrade` callback, pass it through to the `CreateShareLinkScreen` builder, and call it from the limit warning UI.
  - [x] In `CreateShareLinkScreen`, catch `SHARE_LINK_LIMIT_EXCEEDED`, show a banner (`Key('share-limit-warning')`) with the friendly message, and include an `OutlinedButton(key: Key('share-limit-upgrade'), onPressed: widget.onUpgrade)` so users can tap straight into Billing or Credit Packs per the UX spec’s “upgrade/manage” guidance.
  - [x] Keep the default “Create share link” flow intact; the warning should only appear after the API response and should not hide the existing list of links (so people can revoke older links as recommended by the UX doc).

## Dev Notes

### Architecture Compliance
- **Use the entitlement plan limits as the single source of truth** (see `PlanEntity.limits` seeded in `1730814200000-CreateBillingTables` and `1730814400000-CreateSubscriptionsTable`). Do not bake `5` or `1` into service logic; every limit check must read `entitlement.plan.limits`. This keeps new tiers and price updates automatic.
- **Reports/sharing modules already follow the Data Mapper/TypeORM pattern** from `_bmad-output/project-context.md`. Inject repositories with `@InjectRepository`, do the limit check in the service layer, and keep controllers thin (they should still just call `successResponse`).
- **Build the limit guard inside the entitlements domain** so you can reuse `findOrProvision` and the eager-loaded `PlanEntity`. Register the helper in `EntitlementsModule` and export it so both reports and sharing services can inject it.
- **Handle limit errors with typed exceptions that follow the error-envelope pattern** (code + message + optional `data`). Use `ForbiddenException` (403) for quota violations, not `BadRequest` or `Conflict`.
- **Flutter screens must keep business logic out of widgets** — inject new callbacks (`onUpgrade`) and keep the warning UI declarative.
- **Testing policy:** No unit, widget, or integration tests per `_bmad-output/project-context.md#Dev Agent Testing Policy`; manual QA only.

### Previous Story Intelligence
- Story 4.4 (Promo codes) already added billing flows (`BillingService`, Razorpay) and the Entitlement summary is surfaced on the Billing landing page. Reuse the same `BillingRepository` + `DoclyzerApp` navigation hooks to send users into the “Buy credits” or “Upgrade” flows when a limit is hit.
- The sharing stories (3.1–3.4) set up the `CreateShareLinkScreen`, `SharingRepository`, `ShareLinkEntity`, and policy UX. Keep the existing `TimelineScreen` navigation intent unchanged — just sprinkle in the new warning UI and an upgrade button.

### Project Context Reference
- Respect `_bmad-output/project-context.md`: Node 24 + NestJS 11 + TypeORM Data Mapper; no `process.env` inside modules except `data-source.ts`; error codes must be constants in `<module>.types.ts`; tests are skipped.

### Project Structure Notes
- Entities live under `apps/api/src/database/entities/` (snake_case table names, UUID PKs). The limit guard will touch `ReportEntity`/`ShareLinkEntity` and reuse the existing `PlanEntity` + `UserEntitlementEntity`.
- Backend services follow the domain module pattern (e.g., `apps/api/src/modules/reports/`, `sharing/`, `entitlements/`). Add new helpers inside those modules and register them in `AppModule` via existing imports (no new global providers required).
- Flutter screens live under `apps/mobile/lib/features/<domain>/screens/`. Add the banner widgets alongside the existing `UploadReportScreen` and `CreateShareLinkScreen` UI; keep new callback parameters lean.
- Navigation flows for billing already exist in `apps/mobile/lib/main.dart` via `_AuthView.billing / creditPackList / planSelection`. Use those callbacks rather than reinventing navigation.

### References
- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.5: Usage Limit Enforcement (Free/Paid Tiers)]
- [Source: _bmad-output/planning-artifacts/prd.md#FR31 The system can enforce free-tier and paid-tier usage limits consistently]
- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Share link: recipient and flows]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Reduce friction at high-emotion moments]
- [Source: apps/api/src/database/migrations/1730814200000-CreateBillingTables.ts#Seed default free-tier plan limits]
- [Source: apps/api/src/database/migrations/1730814400000-CreateSubscriptionsTable.ts#Seed paid plan limits]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Open Questions (Save for End)

1. None — the entitlement data + UX spec give the upgrade path; there are no extra business clarifications needed.

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

None.

### Completion Notes List

- Implemented `UsageLimitsService` to centralize plan-limit lookups and usage counts for reports and share links.
- Added report/share-link limit exceptions (403) with `data` payloads and ensured the API error envelope forwards `data` to the client.
- Wired report and share-link limit enforcement in services (share links under transaction + lock) before any heavy work.
- Added Flutter limit banners and upgrade CTA wiring in upload/share flows and passed upgrade callbacks from `DoclyzerApp`.
- Tests intentionally skipped per `_bmad-output/project-context.md#Dev Agent Testing Policy`.

### Change Log

- 2026-03-29: Created Story 4.5 with acceptance criteria, tasks, and guardrails for backend limit enforcement and Flutter limit messaging.
- 2026-03-29: Implemented usage-limit enforcement and Flutter upgrade guidance for report uploads and share links.

### File List

- `_bmad-output/implementation-artifacts/4-5-usage-limit-enforcement-free-paid-tiers.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `apps/api/src/common/api-exception.filter.ts`
- `apps/api/src/modules/entitlements/entitlements.service.ts`
- `apps/api/src/modules/entitlements/entitlements.module.ts`
- `apps/api/src/modules/entitlements/usage-limits.service.ts` (new)
- `apps/api/src/modules/reports/reports.module.ts`
- `apps/api/src/modules/reports/reports.types.ts`
- `apps/api/src/modules/reports/reports.service.ts`
- `apps/api/src/modules/reports/exceptions/report-limit-exceeded.exception.ts` (new)
- `apps/api/src/modules/sharing/sharing.module.ts`
- `apps/api/src/modules/sharing/sharing.service.ts`
- `apps/api/src/modules/sharing/sharing.types.ts`
- `apps/api/src/modules/sharing/exceptions/share-link-limit-exceeded.exception.ts` (new)
- `apps/mobile/lib/features/reports/screens/upload_report_screen.dart`
- `apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart`
- `apps/mobile/lib/features/reports/screens/timeline_screen.dart`
- `apps/mobile/lib/main.dart`
- `apps/mobile/test/timeline_test.dart`
