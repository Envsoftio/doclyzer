# Story 6.5: In-Product Support Requests Linked to Failed Critical Actions

Status: in-progress

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a product user,
I want to request support from a failure context,
so that triage includes the relevant action metadata.

## Acceptance Criteria

1. Given a critical action fails, when a support request is created from the failure state, then the request includes linked action/correlation identifiers.

## Tasks / Subtasks

- [x] Task 1: Define support-request contract + enums for critical actions (AC: #1)
  - [x] Add shared types in `packages/contracts/support/` (or `packages/contracts/state/`) for:
    - [x] `SupportActionType` enum covering critical flows (auth, report upload/parse, share link create/revoke, billing/entitlement, notification preferences, account/profile updates).
    - [x] `SupportRequestContext` with `actionType`, `correlationId`, optional `clientActionId`, optional `errorCode`, optional `entityIds` (reportId/shareLinkId/profileId), and PHI-safe `metadata` (appVersion, platform, surface).
    - [x] `CreateSupportRequestPayload` and `SupportRequestResponse` DTO contracts used by mobile/web clients.
  - [x] Export types via `packages/contracts/index.ts` so Flutter/Nuxt can reuse enums without duplicating strings.

- [x] Task 2: Persist and accept support requests in API (AC: #1)
  - [x] Create `SupportRequestEntity` in `apps/api/src/database/entities/` with fields:
    - [x] `id`, `userId`, `actionType`, `correlationId`, `clientActionId`, `errorCode`, `errorMessage`, `entityIds` (JSON), `userMessage`, `status`, `createdAt`.
    - [x] Ensure PHI-safe fields only (no report contents, no patient names).
  - [x] Add migration in `apps/api/src/database/migrations/` and register it in `src/database/migrations/index.ts`.
  - [x] Add service/controller in an appropriate domain module (prefer `apps/api/src/modules/audit-incident/` unless a new `support` module is justified) to:
    - [x] `POST /v1/support-requests` (authenticated) to create a support request from client context.
    - [x] Include `correlationId` in response envelope; return new request ID.
  - [x] (Optional but recommended) Add admin-read endpoints for triage (guarded):
    - [x] `GET /v1/admin/support-requests` (paged list)
    - [x] `GET /v1/admin/support-requests/:id` (detail)

- [x] Task 3: Flutter integration for failure-context support CTA (AC: #1)
  - [x] Identify failure screens for critical actions (upload/parse, share link create, billing checkout, auth failures, notification preference save) and add a **PHI-safe** “Need help?” CTA in the failure callout or footer.
  - [x] When CTA is used, open a lightweight support form (single text field optional) prefilled with action type + last error metadata; submit to `POST /v1/support-requests`.
  - [x] Capture `correlationId` from the last API error envelope when available; if no response (network), generate a `clientActionId` (UUID) and include it.
  - [x] Use `StatusMessenger` for success/failure feedback; keep validation errors inline (`String? _error`).

- [x] Task 4: Web alignment (only if applicable to authenticated web surfaces) (AC: #1)
  - [x] If any authenticated web flows can fail for critical actions, add the same “Need help?” CTA and send the same support payload.
  - [x] Ensure web callouts use ARIA live regions (`role="status"` for success, `role="alert"` for error) per UX/accessibility rules.

- [ ] Task 5: Manual validation (no automated tests per project policy)
  - [ ] Trigger a failed upload and verify support request includes `actionType=report_upload`, a correlation ID, and optional user message.
  - [ ] Trigger a billing failure and verify support request is created and visible in admin list (if implemented).
  - [ ] Validate no PHI fields are captured in payload or logs.

## Dev Notes

### Developer Context (What this story is and isn’t)

- This story adds **in-product support requests** directly from failure contexts.
- It does **not** implement notification delivery (Story 6.1), preference management (Story 6.2), or messaging standardization (Story 6.3), but must reuse those patterns where applicable.
- It does **not** add a new email pipeline; only create support requests and (optionally) expose admin read endpoints for triage.

### Technical Requirements (Must Follow)

- **Response envelope required** for all API responses (`successResponse`). Errors flow through `ApiExceptionFilter`. [Source: `_bmad-output/project-context.md#Architecture & Data Flow Rules`]
- **No PHI in logs or support payloads**. Support requests must include only IDs and generic metadata. [Source: `_bmad-output/project-context.md#Security & Sensitive Data Rules`]
- **Use `ConfigService` only**, never `process.env` inside modules (except `data-source.ts`). [Source: `_bmad-output/project-context.md#Critical Implementation Rules`]
- **Controllers are thin**; one service call per endpoint. [Source: `_bmad-output/project-context.md#NestJS Framework Rules`]
- **Material 3** in Flutter; use existing theme for CTA/button. [Source: `_bmad-output/project-context.md#Flutter Framework Rules`]
- **Inline validation errors**; no SnackBars for form validation errors. [Source: `_bmad-output/project-context.md#Flutter Framework Rules`]

### Architecture & UX Compliance

- **Deterministic async state transparency** must remain visible; support CTA cannot hide or replace existing failure messaging. [Source: `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`]
- **UX feedback patterns** govern placement and tone; support CTA should appear alongside existing recovery options (Retry/Keep file anyway). [Source: `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`]
- **Critical action list** should align with the unified messaging taxonomy (auth, upload/parse, share, billing, notification preferences, account/profile updates). [Source: `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`]

### File Structure Requirements

- API entity in `apps/api/src/database/entities/` (shared entity convention). [Source: `_bmad-output/project-context.md#Technology Stack & Versions`]
- Module structure per domain: `<domain>.module.ts`, `<domain>.controller.ts`, `<domain>.service.ts`, `<domain>.dto.ts`, `<domain>.types.ts`. [Source: `_bmad-output/project-context.md#NestJS Framework Rules`]
- Shared contracts live in `packages/contracts/` and are the canonical source for enums and payload types. [Source: `_bmad-output/planning-artifacts/architecture.md#Project Structure & Boundaries`]

### Avoid Reinventing Existing Systems

- **Reuse the messaging helper** (`StatusMessenger`) for user feedback instead of new ad-hoc SnackBar code. [Source: `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`]
- **Do not create a new notification pipeline** for support requests. If a support email is required later, use the existing email pipeline (Story 6.6) in a future story. [Source: `_bmad-output/planning-artifacts/epics.md#Story 6.6`]

### Latest Tech Information (for safe upgrades)

- **NestJS 11.x** is the current major line; align new controllers/services with NestJS 11 patterns and keep dependencies compatible. [Source: https://github.com/nestjs/nest/releases]
- **TypeORM 1.0** is now released with Node.js 20+ requirement. This project is currently on TypeORM 0.3.x; do **not** upgrade within this story unless explicitly required. [Source: https://dev.typeorm.io/docs/releases/1.0/release-notes/]
- **Node.js 24 LTS** is active; ensure any tooling changes remain compatible with Node 24. [Source: https://eosl.date/eol/product/nodejs/]
- **Nuxt 4** is the active major line for the web surface; follow Nuxt 4 conventions if touching web code. [Source: https://nuxt.com/blog/v4] [Source: https://github.com/nuxt/nuxt/releases]

### Testing Requirements

- **Do not add tests** and **do not run tests**. Manual QA only. [Source: `_bmad-output/project-context.md#Dev Agent Testing Policy`]

### Previous Story Intelligence (6.4)

- Incident status banners already exist across mobile/web; place support CTAs without colliding with persistent incident banners or replacing failure messaging. [Source: `_bmad-output/implementation-artifacts/6-4-major-service-incident-status-communication-to-users.md`]
- Public incident endpoints are unauthenticated; support requests should remain **authenticated** and scoped to the requesting user.

### Git Intelligence (Recent Commit Patterns)

- Recent commits updated CI workflow and notification delivery; avoid reintroducing deprecated E2E infrastructure and reuse existing notification/message patterns. [Source: `git log -n 5`]

### Project Context Reference

- `_bmad-output/project-context.md` (Stack, strict rules, PHI-safe logging, response envelopes)
- `_bmad-output/planning-artifacts/architecture.md` (module boundaries, async state transparency)
- `_bmad-output/planning-artifacts/ux-design-specification.md` (feedback patterns)
- `_bmad-output/planning-artifacts/epics.md#Story 6.5`
- `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`
- `_bmad-output/implementation-artifacts/6-4-major-service-incident-status-communication-to-users.md`

### References

- `_bmad-output/planning-artifacts/epics.md#Story 6.5`
- `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`
- `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`
- `_bmad-output/project-context.md#Critical Implementation Rules`
- `_bmad-output/project-context.md#Security & Sensitive Data Rules`
- `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`
- `_bmad-output/implementation-artifacts/6-4-major-service-incident-status-communication-to-users.md`
- Node.js Release Schedule: https://eosl.date/eol/product/nodejs/
- NestJS Releases: https://github.com/nestjs/nest/releases
- TypeORM 1.0 Release Notes: https://dev.typeorm.io/docs/releases/1.0/release-notes/
- Nuxt 4 Announcement: https://nuxt.com/blog/v4
- Nuxt Releases: https://github.com/nuxt/nuxt/releases

## Dev Agent Record

### Agent Model Used

gpt-5

### Debug Log References

- 2026-04-03: Created story from sprint backlog (Epic 6, Story 6.5). Incorporated architecture/UX rules, messaging patterns, and PHI-safe guardrails.
- 2026-04-03: Implemented support-request contracts, API persistence/endpoints, and Flutter failure-context CTAs + support form.

### Implementation Plan

- Add shared contracts for support request payloads + action enums and export them.
- Persist support requests in API with migration, entity, and authenticated endpoints (plus admin read).
- Add Flutter support CTA + support form in critical failure contexts with PHI-safe metadata.

### Completion Notes List

- Added shared support-request contracts and exports for client reuse.
- Added support request persistence in API (entity + migration), plus `POST /v1/support-requests` and admin list/detail endpoints.
- Added Flutter support form + "Need help?" CTAs for upload/parse, share link create/revoke, billing checkout, auth failures, and notification preference save.
- No authenticated web surfaces for critical actions were found, so no web changes were applied.
- Tests were not added or run per project testing policy; manual validation in Task 5 is still pending.

### Change Log

- 2026-04-03: Added support-request contracts, API persistence/endpoints, and mobile support CTAs with support request sheet.

### File List

- apps/api/src/database/entities/support-request.entity.ts
- apps/api/src/database/migrations/1730816400000-CreateSupportRequestsTable.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts
- apps/api/src/modules/audit-incident/support-request.controller.ts
- apps/api/src/modules/audit-incident/support-request.dto.ts
- apps/api/src/modules/audit-incident/support-request.service.ts
- apps/api/src/modules/audit-incident/support-request.types.ts
- apps/mobile/lib/features/account/screens/communication_preferences_screen.dart
- apps/mobile/lib/features/auth/screens/login_screen.dart
- apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart
- apps/mobile/lib/features/billing/screens/plan_selection_screen.dart
- apps/mobile/lib/features/reports/screens/timeline_screen.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart
- apps/mobile/lib/features/support/api_support_repository.dart
- apps/mobile/lib/features/support/support_models.dart
- apps/mobile/lib/features/support/support_repository.dart
- apps/mobile/lib/features/support/support_request_sheet.dart
- apps/mobile/lib/main.dart
- packages/contracts/index.ts
- packages/contracts/support/index.ts
- packages/contracts/support/support-request.ts
- _bmad-output/implementation-artifacts/6-5-in-product-support-requests-linked-to-failed-critical-actions.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
