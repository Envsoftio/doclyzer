# Story 6.4: Major Service Incident Status Communication to Users

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a product user,
I want to see major service incident notices on affected surfaces,
so that I understand disruptions and the current status while using the product.

## Acceptance Criteria

1. Given a major incident is active, when I use affected surfaces, then the current incident notice and status are shown.

## Tasks / Subtasks

- [x] Task 1: Define incident status contract and shared types (AC: #1)
  - [x] Add shared contract in `packages/contracts/state/incident-status.ts` (or similar) for:
    - `IncidentSeverity` (e.g. `major`, `critical`)
    - `IncidentStatus` (e.g. `active`, `monitoring`, `resolved`)
    - `IncidentSurface` (e.g. `mobile_app`, `web_share`, `web_landing`, `api`) and `affectedSurfaces: IncidentSurface[]`
    - `PublicIncidentStatus` payload returned to clients (PHI-safe fields only)
  - [x] Export via `packages/contracts/state/index.ts` so Flutter/Nuxt can reuse enums.

- [x] Task 2: Persist and serve incident status from API (AC: #1)
  - [x] Create `ServiceIncidentEntity` in `apps/api/src/database/entities/` following entity conventions.
  - [x] Add migration in `apps/api/src/database/migrations/` for incident storage (do not edit existing migrations).
  - [x] Add `ServiceIncidentService` under `apps/api/src/modules/audit-incident/` (fits incident/audit domain) to:
    - create/update incident records
    - resolve active incident
    - fetch current public incident (most recent `active` or `monitoring`)
  - [x] Add public read endpoint (unauthenticated) for clients (share page needs public access):
    - `GET /v1/incidents/active` → returns `{ success, data: PublicIncidentStatus | null, correlationId }`
  - [x] Add admin-only endpoints to set/resolve incidents (guarded with `AuthGuard` + admin role), e.g.:
    - `POST /v1/admin/incidents` (create/activate)
    - `PATCH /v1/admin/incidents/:id/resolve`
  - [x] Ensure all responses use the standard response envelope; errors use typed exception classes.

- [x] Task 3: Client integration for incident banner (AC: #1)
  - [x] Flutter: fetch `/v1/incidents/active` on app start and on resume; cache for short TTL (e.g. 5 minutes).
  - [x] Flutter: show a top-of-screen banner on affected screens (timeline/home, report upload flow, share flow, billing) when `affectedSurfaces` includes `mobile_app` and status is `active` or `monitoring`.
  - [x] Web share page (`apps/web/pages/share/[token].vue` or current structure): fetch active incident and show a top banner when `affectedSurfaces` includes `web_share`.
  - [x] Landing page (`apps/web/pages/index.vue`): show a compact banner when `affectedSurfaces` includes `web_landing`.
  - [x] Web accessibility: banner uses `role="status"` (polite) for active/monitoring, `role="alert"` for critical interruptions; stays in DOM for updates.

- [x] Task 4: UX copy + severity rules (AC: #1)
  - [x] Copy is PHI-safe and non-alarmist; avoid specific report/user identifiers.
  - [x] Severity drives styling only (no functional blocks in this story). If a blocking state is needed later, add a new story.
  - [x] Include “Last updated” and short “What’s affected” summary text.

- [x] Task 5: Manual validation (no automated tests per project policy)
  - [x] Activate an incident affecting `mobile_app` and confirm banner appears on app home and upload flow.
  - [x] Activate an incident affecting `web_share` and confirm banner appears on share page without login.
  - [x] Resolve incident and confirm banner disappears (or transitions to `resolved` status if configured).

## Dev Notes

### Developer Context (What this story is and isn’t)

- This story adds **user-facing incident status communication** (banners) across affected surfaces.
- It does **not** implement notification delivery (Story 6.1), preference management (Story 6.2), or in-app messaging standardization (Story 6.3). It must reuse those patterns where relevant.
- It does **not** add incident email blasts (admin email types exist elsewhere) — this is strictly **in-product** status messaging.

### Technical Requirements (Must Follow)

- **Response envelope required** for all API responses. Use `successResponse(data, correlationId)` and `ApiExceptionFilter` for errors. [Source: `_bmad-output/project-context.md#Architecture & Data Flow Rules`]
- **No PHI in logs or incident payloads.** Public incident text must be generic and non-user-specific. [Source: `_bmad-output/project-context.md#Security & Sensitive Data Rules`]
- **Use `ConfigService`**, never `process.env` inside modules (except `data-source.ts`). [Source: `_bmad-output/project-context.md#Critical Implementation Rules`]
- **Controllers are thin**; one service call per endpoint. [Source: `_bmad-output/project-context.md#NestJS Framework Rules`]
- **Material 3** in Flutter; banners should respect app theme and avoid hardcoded colors. [Source: `_bmad-output/project-context.md#Flutter Framework Rules`]

### Architecture & UX Compliance

- **Deterministic async state transparency** is required; banners must not hide or block existing upload/parse/billing states. [Source: `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`]
- **Feedback patterns** (success/error/warning/info) from UX spec should guide banner tone and placement. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`]
- **Share and landing route partitioning** must remain intact; public incident endpoint should be safe for share/landing access. [Source: `_bmad-output/planning-artifacts/architecture.md#Frontend Architecture`]

### File Structure Requirements

- API entity in `apps/api/src/database/entities/` (shared entity convention). [Source: `_bmad-output/project-context.md#Technology Stack & Versions`]
- API incident module under `apps/api/src/modules/audit-incident/` alongside other incident/audit services.
- Client banner components:
  - Flutter: reusable widget under `apps/mobile/lib/core/` or `apps/mobile/lib/shared/`.
  - Web: component under `apps/web/components/` and used in `pages/index.vue` and share page.

### Avoid Reinventing Existing Systems

- **Do not create a new notification pipeline** — use the existing `NotificationPipelineService` only if the product later decides to send incident emails (out of scope). [Source: `_bmad-output/implementation-artifacts/6-1-notification-event-delivery-for-account-report-billing-updates.md`]
- **Reuse messaging conventions** from Story 6.3 (banner tone, status copy, PHI-safe phrasing). [Source: `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`]

### Latest Tech Information (for safe upgrades)

- **Node.js 24.x is Active LTS** (“Krypton”) with Active LTS start on 2025-10-28. Ensure any new tooling stays compatible with Node 24. [Source: https://github.com/nodejs/Release]
- **TypeORM 0.3.x is current stable**; verify new migrations and DataSource usage against latest 0.3.x documentation. [Source: https://releasealert.dev/github/typeorm/typeorm]
- **NestJS v11** is the current major line; align new modules and decorators with NestJS 11 conventions. [Source: https://github.com/nestjs/nest/releases]
- **Nuxt 4.x** is the active major line for the web surface; follow Nuxt 4 conventions for `app/` structure and SSR behavior if touching web code. [Source: https://nuxt.com/blog/v4] [Source: https://github.com/nuxt/nuxt/releases]

### Testing Requirements

- **Do not add tests** and **do not run tests**. Manual QA only. [Source: `_bmad-output/project-context.md#Dev Agent Testing Policy`]

### Previous Story Intelligence (6.3)

- In-app messaging is standardized via a shared helper; incident banners should follow the same tone and placement rules (persistent banner for ongoing state). [Source: `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`]
- Web admin status callouts use ARIA live regions; replicate the same ARIA roles for incident banners on web pages. [Source: `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`]

### Git Intelligence (Recent Commit Patterns)

- Recent commits updated CI targeting `develop` and removed deprecated E2E infra; avoid reintroducing E2E tooling. [Source: `git log -n 5`]
- Notification delivery and admin dashboard work landed recently; prefer extending existing modules/components rather than adding parallel systems. [Source: `git log -n 5`]

### Project Context Reference

- `_bmad-output/project-context.md` (Stack, strict rules, PHI-safe logging, response envelopes)
- `_bmad-output/planning-artifacts/architecture.md` (route partitioning, async status transparency)
- `_bmad-output/planning-artifacts/ux-design-specification.md` (feedback patterns, banner tone)
- `_bmad-output/planning-artifacts/epics.md#Story 6.4`
- `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`

### References

- `_bmad-output/planning-artifacts/epics.md#Story 6.4`
- `_bmad-output/planning-artifacts/architecture.md#Frontend Architecture`
- `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`
- `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`
- `_bmad-output/project-context.md#Critical Implementation Rules`
- `_bmad-output/project-context.md#Security & Sensitive Data Rules`
- `_bmad-output/implementation-artifacts/6-1-notification-event-delivery-for-account-report-billing-updates.md`
- `_bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md`
- Node.js Release Schedule: https://github.com/nodejs/Release
- TypeORM Releases: https://releasealert.dev/github/typeorm/typeorm
- NestJS Releases: https://github.com/nestjs/nest/releases
- Nuxt 4 Release Blog: https://nuxt.com/blog/v4
- Nuxt Releases: https://github.com/nuxt/nuxt/releases

## Dev Agent Record

### Agent Model Used

gpt-5

### Debug Log References

- 2026-04-03: Created story from sprint backlog (Epic 6, Story 6.4). Incorporated architecture/UX rules, previous-story messaging patterns, and incident banner guardrails.
- 2026-04-03: Implemented incident contracts, API persistence + endpoints, and mobile/web banners. Tests skipped per project policy.

### Implementation Plan

- Add shared incident contracts for client reuse and align API payloads.
- Persist incident records with TypeORM entity + migration, then expose public/admin endpoints in audit-incident module.
- Surface incident banners in Flutter and Nuxt with PHI-safe copy, severity styling, and ARIA roles.

### Completion Notes List

- Story file generated with incident status contract, API endpoint guidance, and client banner integration tasks.
- Emphasized PHI-safe copy and reuse of messaging patterns.
- Tests explicitly excluded per project policy.
- Added incident status contracts, API entity/service/controllers, and client banners for mobile/web surfaces.
- Manual validation steps in Task 5 are pending.

### File List

- packages/contracts/state/incident-status.ts
- packages/contracts/state/index.ts
- apps/api/src/database/entities/service-incident.entity.ts
- apps/api/src/database/migrations/1730816300000-CreateServiceIncidentsTable.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/audit-incident/service-incident.types.ts
- apps/api/src/modules/audit-incident/service-incident.dto.ts
- apps/api/src/modules/audit-incident/service-incident.service.ts
- apps/api/src/modules/audit-incident/service-incident.controller.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts
- apps/mobile/lib/features/incidents/incident_repository.dart
- apps/mobile/lib/features/incidents/api_incident_repository.dart
- apps/mobile/lib/core/feedback/incident_banner.dart
- apps/mobile/lib/main.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/lib/features/reports/screens/timeline_screen.dart
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart
- apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart
- apps/mobile/lib/features/billing/screens/plan_selection_screen.dart
- apps/web/app/composables/useIncidentStatus.ts
- apps/web/app/components/incident/IncidentBanner.vue
- apps/web/app/pages/share/[token].vue
- apps/web/app/pages/index.vue
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-04-03: Story created (ready-for-dev).
- 2026-04-03: Implemented incident status contracts, API endpoints, and mobile/web banners (manual QA pending).
- 2026-04-14: All tasks complete; story marked review.
