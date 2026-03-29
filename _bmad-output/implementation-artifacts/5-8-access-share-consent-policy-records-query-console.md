# Story 5.8: Access/Share/Consent/Policy Records Query Console

Status: review

## Story

As a superadmin,
I want governance records query,
so that investigations are efficient.

## Acceptance Criteria

1. Given authorized query parameters, when query runs, then access/share/consent/policy events are retrievable.
2. Given broad filters, when result volume is large, then cursor pagination and bounded windows prevent unscoped heavy scans.
3. Given query export requests, when generated, then output excludes PHI payload bodies and includes correlation metadata.
4. Given unauthorized scope access, when query is attempted, then request is denied and denial is audited.

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

- Story focus files/modules: apps/api/src/modules/sharing, apps/api/src/modules/consent, apps/api/src/modules/account, apps/api/src/modules (new audit_incident)
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.8]
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
- 2026-03-30: Implemented governance records query + export contracts, service aggregation, pagination/cursor guards, and audit events.
- 2026-03-30: Ran focused lint on changed analytics-admin files and API build (`npm run build`) successfully.

### Implementation Plan

- Extend `analytics-admin` governance surface with superadmin-guarded query + export endpoints.
- Aggregate records from share access, share link, consent, and share policy persistence surfaces via TypeORM repositories.
- Enforce bounded query windows, scope constraints, cursor pagination, and PHI-safe response/export shaping.
- Emit audit events for query/export success plus denied/failure conditions with correlation metadata.
- Add web admin contract stub routes for API-first consumer alignment.

### Completion Notes List

- Implemented `GET /admin/analytics/governance/records` and `POST /admin/analytics/governance/records/export` with superadmin-guarded stable response envelopes and correlation IDs.
- Added governance query DTO/type contracts and explicit error codes for invalid windows, oversized windows, invalid cursors, and unauthorized unscoped queries.
- Implemented deterministic repository-driven aggregation over share access events, share links, consent records, and user share policy records with cursor pagination.
- Added PHI-safe export shaping with correlation metadata and explicit excluded sensitive field declarations.
- Added audit event emission for query and export outcomes (success/failure/denied) with actor/action/target/outcome and sanitized metadata.
- Added web admin API contract stub for story 5.8 routes and state lifecycle alignment.
- Manual QA checklist:
  - Verified focused lint for changed files passes: `npx eslint src/modules/analytics-admin/analytics-admin.controller.ts src/modules/analytics-admin/analytics-admin.module.ts src/modules/analytics-admin/analytics-governance.dto.ts src/modules/analytics-admin/analytics-governance.types.ts src/modules/analytics-admin/analytics-governance.service.ts`
  - Verified API compiles: `npm run build`
  - Confirmed full repo lint currently has unrelated pre-existing failures outside this story scope.
- Manual edge cases reviewed:
  - Invalid/unsorted windows (`windowStart >= windowEnd`) return governance window validation errors.
  - Window length beyond max threshold is rejected.
  - Unscoped broad queries are denied and audited.
  - Invalid cursor payloads are rejected with explicit error code.
  - Export path strips audit metadata when not requested and never returns PHI payload bodies.

### File List

- _bmad-output/implementation-artifacts/5-8-access-share-consent-policy-records-query-console.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/modules/analytics-admin/analytics-admin.controller.ts
- apps/api/src/modules/analytics-admin/analytics-admin.module.ts
- apps/api/src/modules/analytics-admin/analytics-governance.dto.ts
- apps/api/src/modules/analytics-admin/analytics-governance.types.ts
- apps/api/src/modules/analytics-admin/analytics-governance.service.ts
- apps/web/server/api/admin/governance-records-query-contracts.get.ts

## Change Log

- 2026-03-30: Implemented governance records query console APIs, PHI-safe export behavior, scoped window/cursor protections, and auditable query/export outcomes.
