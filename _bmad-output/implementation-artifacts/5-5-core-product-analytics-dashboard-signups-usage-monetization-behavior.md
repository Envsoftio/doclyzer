# Story 5.5: Core Product Analytics Dashboard (Signups/Usage/Monetization/Behavior)

Status: done
<!-- Reviewed and verified 2026-03-30 -->

## Story

As a superadmin,
I want core dashboard metrics,
so that product/business health is monitorable.

## Acceptance Criteria

1. Given analytics data is available, when dashboard loads, then signups/usage/monetization/behavior metrics render consistently.
2. Given funnel and retention slices, when date ranges change, then metric deltas and baseline comparisons update deterministically.
3. Given data latency in async pipelines, when dashboard shows values, then freshness timestamps and partial-state indicators are visible.
4. Given unauthorized requests, when admin metrics endpoints are called, then strict RBAC and MFA posture checks are enforced.

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

- Story focus files/modules: apps/api/src/modules (new analytics_admin), apps/web/pages/admin (future), apps/web/server/api/admin (future)
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.5]
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

### Completion Notes List

- Implemented the analytics_admin surface (DTOs, controller, service, and types) plus AppModule wiring so the core product metrics endpoint can deliver signups/usage/monetization/behavior metrics along with funnel and retention slices.
- Hardened the endpoint with a new MFA-aware `AdminActionTokenGuard`, extended `SuperadminAuthService` to validate admin action tokens, and recorded PHI-safe superadmin audit events per request.
- Added the analytics contract stub to the admin page, updated sprint-status for story 5-5, and captured the manual QA checklist; automated tests were skipped per the “Manual QA only” rule.
- Manual QA covered response schema sanity, delta/baseline logic, partial-state messaging, and guard enforcement.

### File List

- _bmad-output/implementation-artifacts/5-5-core-product-analytics-dashboard-signups-usage-monetization-behavior.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/admin-action-token.guard.ts
- apps/api/src/modules/auth/superadmin-auth.service.ts
- apps/api/src/modules/analytics-admin/analytics-admin.controller.ts
- apps/api/src/modules/analytics-admin/analytics-admin.dto.ts
- apps/api/src/modules/analytics-admin/analytics-admin.module.ts
- apps/api/src/modules/analytics-admin/analytics-admin.service.ts
- apps/api/src/modules/analytics-admin/analytics-admin.types.ts
- apps/web/app/pages/admin/index.vue

## Change Log

- 2026-03-30: Added analytics_admin module with MFA-gated metrics API, recorded audit events, updated admin contract stub + sprint status, and logged manual QA (no automated tests per policy).
- 2026-03-30: Code review fixes — corrected `resolveFreshnessTimestamp` to return actual latest DB timestamp instead of always `Date.now()` (AC3 correctness); fixed `usage` metric description to accurately reflect all-session count rather than misleading "paid users" label.
- 2026-03-30: Code review round 2 fixes — corrected monetization metric currency from hardcoded `'USD'` to `'INR'` (orders are INR-denominated); wrapped `recordAudit` call in try/catch so audit persistence failure no longer propagates as a 500 to the dashboard consumer.
