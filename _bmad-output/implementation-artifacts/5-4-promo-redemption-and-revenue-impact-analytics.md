# Story 5.4: Promo Redemption and Revenue Impact Analytics

Status: done

## Story

As a superadmin,
I want promo performance analytics,
so that campaign effectiveness is measurable.

## Acceptance Criteria

1. Given promo events are processed, when analytics are viewed, then redemption counts and attributed discount totals are visible by time range.
2. Given checkout outcomes (failed/reconciled), when metrics aggregate, then revenue impact reflects only finalized outcomes per policy.
3. Given filter parameters (promo, date window, product type), when query runs, then results are deterministic and paginated.
4. Given analytics exports are requested, when generated, then PHI is excluded and scope metadata is logged for audit.

## Tasks / Subtasks

- [x] Task 1: Define API/domain contracts and error codes for this story
  - [x] Add or extend module types/DTOs and controller routes with stable response envelopes
  - [x] Ensure role checks and correlation IDs are enforced on all endpoints
- [x] Task 2: Implement service and persistence logic using existing architecture patterns
  - [x] Use TypeORM repositories via dependency injection and injected repositories
  - [x] Keep business rules deterministic and idempotent for retriable operations
- [x] Task 3: Integrate UI/consumer surface for superadmin workflows (API-first if UI not scaffolded)
  - [x] Add route-level stubs/contracts in web/admin surface plan when implementation surface is pending
  - [x] Ensure output states are explicit (pending/success/failure/reverted)
- [x] Task 4: Add audit and governance protections
  - [x] Emit auditable events for actor/action/target/time/outcome
  - [x] Apply PHI-safe telemetry and logging guardrails
- [x] Task 5: Validate manually (no automated tests per project policy)
  - [x] Record manual QA checklist and edge cases in completion notes

## Dev Notes

- Story focus files/modules: apps/api/src/modules/billing, apps/api/src/database/entities/order.entity.ts, apps/api/src/database/entities/promo-redemption.entity.ts
- Keep domain separation from architecture baseline: PHI-bearing clinical/report domain must stay isolated from billing/entitlement and admin analytics domains.
- Follow project context rules: no direct environment reads inside modules; use ConfigService, keep thin controllers and service-owned business logic.
- Enforce superadmin access controls with explicit guards; avoid introducing global auth shortcuts.
- Keep telemetry and logs PHI-safe: do not include PHI payloads in audit/search/analytics streams.

### Project Structure Notes

- Primary backend surface: apps/api/src/modules (extend current modules; introduce analytics_admin and audit_incident only when needed by this story).
- Entity and migration changes live under apps/api/src/database/entities and apps/api/src/database/migrations.
- Web admin surface target (when scaffolded): apps/web/pages/admin and apps/web/server/api/admin.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 5: Superadmin Operations, Risk Controls & Product Analytics]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.4]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

- Generated via BMAD create-story equivalent workflow for Epic 5 batch.
- 2026-03-29: Updated sprint-status to in-progress before implementation; moved to review after completion gates.
- Validation runs:
  - `npm run build` (apps/api): passed
  - `npm run lint` (apps/api): failed due to pre-existing unrelated lint issues outside Story 5.4 scope

### Completion Notes List

- Implemented superadmin promo analytics contracts in billing module:
  - `GET /v1/billing/admin/promo-analytics` with deterministic filtering + pagination by promo/date range/product type
  - `POST /v1/billing/admin/promo-analytics/export` with PHI-safe CSV/JSON export payload
- Added analytics DTOs/types and explicit billing error code for invalid analytics date ranges.
- Implemented deterministic aggregation policy: only reconciled checkout outcomes contribute to attributed discount and finalized revenue totals.
- Added superadmin audit event persistence for analytics view/export actions with actor/action/target/outcome/correlation metadata (scope only, no PHI payloads).
- Added API-first web admin contract stub at `/api/admin/promo-analytics-contracts` and linked it from admin placeholder page.
- Manual QA checklist (no automated tests per project policy):
  - [x] Build compiles after changes (`apps/api`).
  - [x] Analytics endpoint guarded by `AuthGuard` + `SuperadminGuard`.
  - [x] Response envelope remains `successResponse(data, correlationId)`.
  - [x] Filters include promo/date window/product type and deterministic ordering.
  - [x] Export payload excludes PHI fields and logs scope metadata only.
  - [x] Edge case: invalid date range returns `BILLING_ANALYTICS_DATE_RANGE_INVALID`.
  - [x] Edge case: empty analytics result still returns deterministic pagination + summary.

### File List

- _bmad-output/implementation-artifacts/5-4-promo-redemption-and-revenue-impact-analytics.md
- apps/api/src/modules/billing/billing.types.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/web/server/api/admin/promo-analytics-contracts.get.ts
- apps/web/app/pages/admin/index.vue
- apps/api/src/modules/auth/admin-action-token.guard.ts
- apps/api/src/modules/auth/auth.module.ts
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-03-29: Implemented Story 5.4 promo analytics and export endpoints with superadmin audit logging and API-first web contract stub. Status moved to `review`.
- 2026-03-30: Code review fixes — replaced in-memory pagination with DB-level LIMIT/OFFSET; extracted base query builder; added `queryPromoAnalyticsCount` and `queryPromoAnalyticsGlobalSummary` (DB-level summary, not in-memory reduce); capped export at `EXPORT_ROW_CAP` (1000 rows); wrapped audit saves in try/catch to prevent audit failure blocking data response; fixed `PromoAnalyticsResponseDto.state` type from `PromoLifecycleState` to `'success'`; documented previously undocumented `admin-action-token.guard.ts` and `auth.module.ts` changes in File List.
- 2026-03-30: Code review round 2 — narrowed `PromoAnalyticsExportResponseDto.state` from `PromoLifecycleState` to `'success'` to match the query DTO and implementation.
