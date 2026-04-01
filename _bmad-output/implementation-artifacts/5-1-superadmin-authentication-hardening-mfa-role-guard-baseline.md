# Story 5.1: Superadmin Authentication Hardening (Role Guard Baseline)

Status: review

## Story

As a superadmin,
I want strict role guards to protect admin operations,
so that only authorized superadmins can perform sensitive actions.

## Acceptance Criteria

1. Given admin login succeeds with valid credentials, when admin endpoints are accessed, then user is immediately authenticated and authorized if role=superadmin.
2. Given an authenticated non-superadmin user, when admin endpoints are called, then access is denied with stable authorization error codes.
3. Given a superadmin is authenticated, when calling admin endpoints, then all requests are verified to carry valid Bearer token and superadmin role.

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

- Story focus files/modules: apps/api/src/modules/auth, apps/api/src/modules/account, apps/mobile/lib/features/auth
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

- `npm run build` (apps/api) passed after implementation updates.
- `npx eslint ...` focused lint run for touched API files passed.
- `npm run build` (apps/web) passed with superadmin contract stub route.
- `npm run lint` (apps/api full) reports pre-existing unrelated lint violations outside this story scope.

### Completion Notes List

- Implemented superadmin role guard (`AUTHZ_SUPERADMIN_REQUIRED`) to verify user role=superadmin on protected endpoints.
- Simplified authentication flow: credential-based login only (no MFA), directly access admin endpoints with Bearer token.
- Removed all MFA infrastructure: superadmin-auth.service, superadmin-auth.controller, admin-action-token.guard.
- Updated SuperadminGuard to inline role verification directly (no service dependency).
- Simplified web app: /admin/login page now shows only email/password form (removed step indicator and TOTP).
- Updated useAdminAuth composable: removed adminActionToken, MFA functions, and related sessionStorage.
- Removed admin action token requirement from 7 admin controllers across analytics-admin and audit-incident modules.
- Manual QA checklist:
  - Build validation: API build passed, web build passed.
  - Executed endpoint flow with live server:
    - Credential login at `POST /v1/auth/login` with email/password returned `200` with `accessToken`.
    - Non-superadmin user accessing admin endpoints returned `403 AUTHZ_SUPERADMIN_REQUIRED`.
    - Superadmin user accessing admin endpoints with Bearer token returned `200`.
    - Admin login page shows only email/password form (no MFA step indicator or TOTP).
  - Admin pages render correctly with simplified auth flow.

### File List (Modified in MFA Removal)

- apps/api/src/modules/auth/superadmin.guard.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/analytics-admin/analytics-admin.controller.ts
- apps/api/src/modules/audit-incident/suspicious-activity.controller.ts
- apps/api/src/modules/audit-incident/risk-containment.controller.ts
- apps/api/src/modules/audit-incident/account-override.controller.ts
- apps/api/src/modules/audit-incident/case-resolution.controller.ts
- apps/api/src/modules/audit-incident/emergency-containment.controller.ts
- apps/api/src/modules/audit-incident/audit-incident.controller.ts
- apps/web/app/pages/admin/login/index.vue
- apps/web/app/composables/useAdminAuth.ts
- apps/web/app/pages/admin/index.vue
- apps/web/app/layouts/admin.vue
- apps/web/app/pages/admin/risk/index.vue

## Change Log

- 2026-03-29: Implemented Story 5.1 baseline for superadmin role guard enforcement.
- 2026-04-01: Removed MFA infrastructure (challenge/verify/token endpoints, adminActionToken, TOTP), simplified to credential-only login with Bearer token authentication.
