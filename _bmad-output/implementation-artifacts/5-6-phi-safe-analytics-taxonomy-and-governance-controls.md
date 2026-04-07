# Story 5.6: PHI-Safe Analytics Taxonomy and Governance Controls

Status: done

## Story

As a platform owner,
I want PHI-safe taxonomy governance,
so that analytics never leak sensitive data.

## Acceptance Criteria

1. Given event instrumentation changes, when governance validation runs, then PHI violations are blocked and surfaced.
2. Given analytics schemas evolve, when new fields are proposed, then allow-list policy and data classification review are required.
3. Given blocked payloads, when rejection occurs, then violation reason codes and remediation hints are returned without exposing payload content.
4. Given CI/CD quality gates execute, when PHI-safe checks fail, then release pipeline is blocked with actionable diagnostics.

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

### Review Follow-ups (AI)
- [x] [AI-Review][HIGH] AC4 not implemented: CI/CD quality gate that blocks pipeline when PHI-safe governance check fails is missing. No `.github/workflows` or equivalent pipeline configuration was added. Requires a workflow job that calls `POST /admin/analytics/governance/validate` or a standalone script invokable from CI with actionable exit codes. [apps/api/src/modules/analytics-admin/analytics-governance.service.ts]
- [x] [AI-Review][MEDIUM] CI gate happy-path only: proposed.json only contains non_phi approved fields so the gate never exercises the PHI rejection path. A dedicated test (separate from the live gate file) should verify that a phi-classified field causes exit=1. Cannot add PHI fields to proposed.json directly as that would break CI on every run. [.github/analytics-governance/proposed.json]
- [x] [AI-Review][MEDIUM] `app.close()` in finally block could swallow exit code if it threw; wrapped in `.catch()` to prevent masking CI failure signal. [apps/api/scripts/analytics-governance-ci.ts]
- [x] [AI-Review][LOW] `AnalyticsGovernanceFieldDto.type` field was declared and validated but never used by the service; removed to avoid misleading API surface. [apps/api/src/modules/analytics-admin/analytics-governance.dto.ts]
- [x] [AI-Review][LOW] `getReviewStateSummary()` was implemented in service but had no controller endpoint; wired up at `GET /admin/analytics/governance/review-summary`. [apps/api/src/modules/analytics-admin/analytics-admin.controller.ts]

## Dev Notes

- Story focus files/modules: apps/api/src/common, apps/api/src/modules (analytics instrumentation), .github/workflows or CI checks for phi-telemetry
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.6]
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

### Implementation Plan

- Seed the PHI-safe allow-list before running a CI-only governance validation script.
- Add a CI workflow job that runs the governance gate with actionable exit codes.
- Provide baseline allow-list/proposed payload files so the gate is reproducible.

### Completion Notes List

- Added governance DTOs/types, controller wiring, and `AnalyticsGovernanceService` logic so PHI-safe instrumentation proposals run through allow-list validation, surface violations with sanitized hints, persist reviews, and emit audit events without leaking sensitive data.
- Created taxonomy (`analytics_taxonomy_fields`) and review (`analytics_governance_reviews`) tables plus migration/data-source entries so the governance service can persist approved fields and pending requests while remaining available to TypeORM-driven contexts.
- Added the admin contract stub at `/api/admin/phi-analytics-governance-contracts` so the UI plans the governance validation endpoint before the surface is built.
- Manual QA checklist (no automated tests per project policy):
  - [x] Confirmed the POST `/admin/analytics/governance/validate` route shares the existing Auth/Superadmin/AdminActionToken guard stack and continues returning `successResponse(data, correlationId)`.
  - [x] Reviewed governance service logic to ensure PHI violations raise `AnalyticsGovernancePhiViolationException` with reason codes/hints while new fields that pass classification updates spin up review entries.
  - [x] Checked migration/index.data-source updates so taxonomy/review entities are registered for TypeORM and the schema includes allow-list metadata without logging PHI payload data.
  - [x] Automated tests skipped (per policy) to honor the manual QA requirement while still verifying flow via code inspection and reasoning.
- Added a CI governance gate script that seeds the allow-list, validates proposed analytics payloads, and fails the pipeline on PHI violations or review-required payloads.
- Added a GitHub Actions job to run the governance gate with a Postgres-backed schema and explicit exit codes.
- ✅ Resolved review finding [HIGH]: AC4 governance quality gate now blocks CI on failed PHI-safe validation with actionable diagnostics.
- ✅ Resolved review finding [MEDIUM]: Added `scripts/analytics-governance-phi-rejection-test.ts` — a DB-free standalone test script (5 cases) that exercises the PHI rejection path and asserts exit=1. Added `governance:test-phi-rejection` npm script and a pre-gate CI step so the rejection path is verified on every CI run without polluting proposed.json.

### File List

- _bmad-output/implementation-artifacts/5-6-phi-safe-analytics-taxonomy-and-governance-controls.md
- .github/analytics-governance/allowlist.json
- .github/analytics-governance/proposed.json
- .github/workflows/ci.yml
- apps/api/src/modules/analytics-admin/analytics-admin.controller.ts
- apps/api/src/modules/analytics-admin/analytics-admin.module.ts
- apps/api/src/modules/analytics-admin/analytics-governance.dto.ts
- apps/api/src/modules/analytics-admin/analytics-governance.service.ts
- apps/api/src/modules/analytics-admin/analytics-governance.types.ts
- apps/api/scripts/analytics-governance-ci.ts
- apps/api/src/database/entities/analytics-taxonomy-field.entity.ts
- apps/api/src/database/entities/analytics-governance-review.entity.ts
- apps/api/src/database/migrations/1730815100000-CreateAnalyticsGovernanceTables.ts
- apps/api/src/database/migrations/index.ts
- apps/api/package.json
- apps/web/server/api/admin/phi-analytics-governance-contracts.get.ts
- apps/api/scripts/analytics-governance-phi-rejection-test.ts

### Change Log

- 2026-03-30: Implemented PHI-safe analytics taxonomy governance validation API, migration-backed taxonomy/review persistence, audit logging, and admin contract stub; story now in `review` after manual QA (automated tests skipped per policy).
- 2026-03-30: Code review fixes — added missing `ANALYTICS_GOVERNANCE_REVIEW_REQUIRED` import in `analytics-governance.service.ts` (was a compile error); replaced `@IsEnum(AnalyticsFieldClassification)` with `@IsIn(['non_phi', 'pii', 'phi'])` in governance DTO (`AnalyticsFieldClassification` is a type alias, not an enum object, causing runtime validation failure); AC4 CI/CD gate logged as open action item.
- 2026-04-02: Added PHI-safe governance CI gate (workflow + script + allow-list/proposed payload files) to block releases on validation failures; resolved AC4 review item.
- 2026-04-02: Code review fixes — enabled CI workflow push/PR triggers (gate was unreachable on workflow_dispatch-only); switched phi-governance-gate job to dedicated `doclyzer_governance_test` DB to prevent ghost superadmin user contaminating main DB; improved CI diagnostic output to print PHI violation field names, codes, and remediation hints from exception response body; removed phantom `data-source.ts` entry from File List (no actual change to that file).
- 2026-04-07: Added `scripts/analytics-governance-phi-rejection-test.ts` — DB-free PHI rejection verification test (5 cases covering phi proposal, phi reclassification, allow-listed-phi, non-phi approval, and PII review-required paths). Added `governance:test-phi-rejection` npm script and a pre-gate step in `.github/workflows/ci.yml` so the PHI rejection code path is exercised on every CI run without touching proposed.json.
- 2026-04-07: Code review fixes — wrapped `app.close()` in `.catch()` to prevent finally block masking CI exit code; removed unused `type` field from `AnalyticsGovernanceFieldDto`; wired `getReviewStateSummary()` to `GET /admin/analytics/governance/review-summary`.
