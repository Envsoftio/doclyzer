# Story 6.6: Email Pipeline — Delivery, Tracking & Template Support

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a platform,
I want a unified email pipeline with delivery tracking and template support,
so that all outbound emails are consistent, PHI-safe, and auditable across product and admin flows.

## Acceptance Criteria

1. Given the system sends any email (password reset, notifications, security/compliance notices, admin sends), when the email pipeline is invoked, then the message is queued and delivery status is tracked (pending/sent/failed/bounced where supported) and is available for analytics. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/epics.md#Story 6.6]
2. Given an email type is sent, when rendering content, then a template is used per email type with safe variable interpolation, and product/marketing emails respect communication preferences while transactional/security emails bypass suppression. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/epics.md#Story 6.6] [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/prd-email-pipeline-and-onboarding.md#Template Support]
3. Given a pipeline failure or provider error, when retries are exhausted, then terminal state is recorded deterministically and no PHI appears in logs or queue payloads. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/epics.md#Story 6.6] [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Security & Sensitive Data Rules]

## Tasks / Subtasks

- [x] Task 1: Confirm and extend the email pipeline data model, reusing existing tables and statuses (AC: #1)
- [x] Task 2: Implement a delivery worker that pulls `email_queue_items`, updates queue status, renders templates, and writes `email_delivery_events` outcomes (AC: #1, #3)
- [x] Task 3: Implement a provider interface (e.g., SMTP/SendGrid/SES) and a safe fallback stub for dev, wired by `ConfigService` (AC: #1, #3)
- [x] Task 4: Add template rendering with HTML + plain-text fallbacks and safe escaping, backed by `apps/api/src/email/templates` (AC: #2)
- [x] Task 5: Wire pipeline into existing dispatch points: notification pipeline and admin send, and replace `InMemoryNotificationService` for password reset with the pipeline (AC: #1, #2)
- [ ] Task 6: Manual validation only: enqueue sample emails, verify queue status changes, and verify delivery analytics/sending history surfaces (AC: #1-3)

## Dev Notes

### Developer Context (What this story is and isn’t)

- This story completes the **delivery side** of the existing email queue and admin analytics scaffolding; it is not creating a new queue schema.
- This story must reuse the existing `NotificationPipelineService` and `EmailAdminService` queueing logic; do not bypass with direct provider sends.
- This story does not add new notification categories or new UX flows; it wires existing flows into the unified pipeline and ensures template rendering and delivery tracking.

### Technical Requirements (Must Follow)

- Use `EmailQueueItemEntity` and `EmailDeliveryEventEntity` as the system of record for queue state and delivery outcomes. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-queue-item.entity.ts] [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-delivery-event.entity.ts]
- Queue statuses are `pending`, `processing`, `completed`; delivery outcomes are `pending`, `sent`, `failed`, `bounced`. Preserve these enums and meanings. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-queue-item.entity.ts] [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-delivery-event.entity.ts]
- Queue writes for notification events already happen in `NotificationPipelineService`; do not re-implement. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/common/notification-pipeline/notification-pipeline.service.ts]
- Admin send already enqueues and creates delivery events in `EmailAdminService`; do not bypass it. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/modules/email-admin/email-admin.service.ts]
- Admin send metadata intentionally excludes raw subject/body; worker must fetch content via template key or secure store to keep PHI out of queue payloads. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/modules/email-admin/email-admin.service.ts]
- Email templates live at `apps/api/src/email/templates/` and use Handlebars-style placeholders; use safe HTML-escaping and add plain-text fallbacks. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/email/templates/README.md]
- Respect communication preferences: product emails may be suppressed; security/compliance emails are mandatory. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/common/notification-pipeline/notification-pipeline.service.ts]
- Never log PHI or include PHI in queue metadata; only IDs, template keys, correlationId, and non-sensitive metadata allowed. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Security & Sensitive Data Rules]
- `EmailQueueItemEntity` supports `idempotencyKey` with a unique index; reuse it to avoid duplicate enqueues when retrying admin sends or notification dispatches. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-queue-item.entity.ts]
- `NotificationService` is currently bound to `InMemoryNotificationService` in `AuthModule`; replace with a pipeline-backed implementation so password reset emails flow through the queue. [Source: /Users/vishnu/Work/Server/doclyzer/apps/api/src/modules/auth/auth.module.ts]
- Use `ConfigService` in NestJS modules; no direct `process.env` reads outside `src/database/data-source.ts`. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Critical Implementation Rules]
- Controllers are thin and responses must use the standard success envelope with correlation IDs. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Architecture & Data Flow Rules]

### Architecture Compliance (Guardrails)

- Follow domain boundaries: email pipeline lives in common infrastructure and should not leak into feature modules beyond dispatch calls. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/architecture.md#Architecture & Data Flow Rules]
- Deterministic async state handling is required: queue items must move through explicit states and never silently disappear. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- PHI-safe observability is mandatory; only correlation IDs and non-sensitive metadata may be logged. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Security & Sensitive Data Rules]

### File Structure Requirements

- Existing pipeline code: `apps/api/src/common/notification-pipeline/` for dispatch and preference checks.
- Admin analytics and send endpoints: `apps/api/src/modules/email-admin/`.
- Templates: `apps/api/src/email/templates/`.
- If a worker is introduced, prefer `apps/api/src/common/email-delivery/` or `apps/api/src/workers/email/` and wire it from the app bootstrap without breaking existing module boundaries. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/architecture.md#Project Structure & Boundaries]

### Testing Requirements

- Do not add tests and do not run tests; manual validation only. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md#Dev Agent Testing Policy]

### Previous Story Intelligence (6.5)

- Recent work introduced support-request contracts and emphasized reuse of response envelopes and PHI-safe metadata. Keep email payloads and logs PHI-safe, and reuse standardized error handling patterns. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/implementation-artifacts/6-5-in-product-support-requests-linked-to-failed-critical-actions.md]
- Incident banners may already be present in client surfaces; do not rely on UI changes for pipeline correctness. [Source: /Users/vishnu/Work/Server/doclyzer/_bmad-output/implementation-artifacts/6-5-in-product-support-requests-linked-to-failed-critical-actions.md]

### Git Intelligence Summary

- Recent commits updated CI workflow and notification delivery features; do not reintroduce deprecated E2E infrastructure and align with the current notification pipeline scaffolding. [Source: git log -n 5]

### Latest Tech Information (Verify before upgrading)

- NestJS is in the v11.x line; keep new code compatible with current v11 releases and avoid framework upgrades in this story unless explicitly required. citeturn1view0
- TypeORM 1.0 requires Node.js 20+ and introduces breaking changes; this project is on TypeORM 0.3.x, so do not upgrade in this story. citeturn2view3
- Node.js 24 is LTS and supported through April 2028; ensure any email-worker tooling remains compatible with Node 24. citeturn2view0
- Nuxt 4 is the active major line for the web surface; only relevant if admin web UI changes are needed. citeturn2view5

### Project Context Reference

- /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md (stack rules, PHI-safe logging, response envelopes)
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/architecture.md (module boundaries, async state requirements)
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/prd-email-pipeline-and-onboarding.md (pipeline behavior, templates, onboarding email types)
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/epics.md#Story 6.6
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/common/notification-pipeline/notification-pipeline.service.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/modules/email-admin/email-admin.service.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/email/templates/README.md

### Completion Note

Ultimate context engine analysis completed - comprehensive developer guide created.

### References

- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/epics.md#Story 6.6
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/prd-email-pipeline-and-onboarding.md
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/planning-artifacts/architecture.md
- /Users/vishnu/Work/Server/doclyzer/_bmad-output/project-context.md
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/common/notification-pipeline/notification-pipeline.service.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/modules/email-admin/email-admin.service.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-queue-item.entity.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/database/entities/email-delivery-event.entity.ts
- /Users/vishnu/Work/Server/doclyzer/apps/api/src/email/templates/README.md
- Node.js 24.11.0 LTS release note. citeturn2view0
- TypeORM 1.0 release notes. citeturn2view3
- NestJS v11 releases. citeturn1view0
- Nuxt 4 announcement. citeturn2view5

## Dev Agent Record

### Agent Model Used

gpt-5

### Debug Log References

- 2026-04-03: Created story from sprint backlog (Epic 6, Story 6.6). Included existing email pipeline scaffolding, templates, admin analytics endpoints, and PHI-safe guardrails.
- 2026-04-03: Implemented email delivery worker, template renderer, provider stub, and pipeline-backed password reset dispatch.

### Implementation Plan

- Add email delivery module with worker, template rendering, and provider abstraction.
- Introduce template registry and per-type templates with safe HTML interpolation.
- Wire password reset dispatch to pipeline and resolve reset token via verification table.
- Add email configuration and update app module wiring.

### Completion Notes List

- Added comprehensive context for completing the email delivery worker, provider integration, template rendering, and queue lifecycle updates.
- Documented existing queue entities, admin analytics endpoints, and notification dispatch patterns to prevent duplication.
- Included latest tech constraints for NestJS/TypeORM/Node/Nuxt and explicit no-test policy.
- Implemented email delivery worker with deterministic queue outcomes and PHI-safe logging.
- Added template registry, rendering service, and new email templates with HTML + text fallbacks.
- Replaced in-memory password reset notifications with pipeline-backed dispatch that resolves reset links from verification records.
- Manual validation pending (queue enqueue + analytics verification not yet executed).

### File List

- _bmad-output/implementation-artifacts/6-6-email-pipeline-delivery-tracking-and-template-support.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/common/email-delivery/email-delivery.module.ts
- apps/api/src/common/email-delivery/email-delivery.worker.ts
- apps/api/src/common/email-delivery/email-provider.interface.ts
- apps/api/src/common/email-delivery/email-template.service.ts
- apps/api/src/common/email-delivery/template-registry.ts
- apps/api/src/common/email-delivery/providers/dev-email-provider.service.ts
- apps/api/src/common/notification/pipeline-notification.service.ts
- apps/api/src/common/notification-pipeline/notification-event.types.ts
- apps/api/src/config/email.config.ts
- apps/api/src/database/entities/verification.entity.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/email/templates/README.md
- apps/api/src/email/templates/account-email-changed.html
- apps/api/src/email/templates/account-password-changed.html
- apps/api/src/email/templates/account-closure-confirmed.html
- apps/api/src/email/templates/report-upload-complete.html
- apps/api/src/email/templates/report-parse-failed.html
- apps/api/src/email/templates/billing-payment-success.html
- apps/api/src/email/templates/billing-payment-failed.html
- apps/api/src/email/templates/billing-subscription-activated.html
- apps/api/src/email/templates/billing-subscription-cancelled.html
- apps/api/src/email/templates/admin-announcement.html
- apps/api/src/email/templates/admin-incident.html
- apps/api/src/email/templates/admin-support.html

### Change Log

- 2026-04-03: Implemented email delivery worker, template rendering, and pipeline-backed password reset dispatch.
