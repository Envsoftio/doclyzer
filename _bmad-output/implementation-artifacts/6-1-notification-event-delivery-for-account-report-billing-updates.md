# Story 6.1: Notification Event Delivery for Account/Report/Billing Updates

Status: in-progress

## Story

As an authenticated user,
I want to receive relevant notifications for important account, report, and billing events,
so that I stay informed without having to poll the app manually.

## Acceptance Criteria

1. Given a notifiable event occurs (account, report, or billing), when delivery rules execute, then a notification is enqueued/sent with a tracked outcome.
2. Given a notifiable event requires product-category notification, when the user's `product` communication preference is `false`, then the notification is suppressed (not sent).
3. Given a security or compliance notifiable event occurs, when delivery rules execute, then the notification is sent regardless of product preference (mandatory categories always fire).
4. Given a notification is enqueued, when it is dispatched (or fails), then delivery status is recorded in `email_delivery_events` with appropriate outcome (`pending` → `sent` / `failed` / `bounced`).
5. Given the system triggers a transactional email type (e.g. password reset, OTP), when delivery rules execute, then it bypasses product-preference gating and uses the existing pipeline unconditionally.

## Tasks / Subtasks

- [x] Task 1: Define notification event taxonomy and routing rules (AC: #1, #2, #3, #5)
  - [x] Create `src/common/notification-pipeline/notification-event.types.ts` — define `NotifiableEventType` enum (account: `ACCOUNT_EMAIL_CHANGED`, `ACCOUNT_PASSWORD_CHANGED`, `ACCOUNT_CLOSURE_CONFIRMED`; report: `REPORT_UPLOAD_COMPLETE`, `REPORT_PARSE_FAILED`; billing: `BILLING_PAYMENT_SUCCESS`, `BILLING_PAYMENT_FAILED`, `SUBSCRIPTION_ACTIVATED`, `SUBSCRIPTION_CANCELLED`; transactional: `AUTH_PASSWORD_RESET`, `AUTH_OTP_SENT`)
  - [x] Define `NotificationCategory` enum matching `COMM_PREF_CATEGORY` (`security`, `compliance`, `product`)
  - [x] Define routing map: `EVENT_CATEGORY_MAP` — maps each `NotifiableEventType` to its `NotificationCategory` and `emailType` string
  - [x] Define `MANDATORY_EVENT_CATEGORIES` = `new Set(['security', 'compliance'])` — mirrors `MANDATORY_CATEGORIES` in `account.types.ts`
- [x] Task 2: Create `NotificationPipelineService` (AC: #1, #2, #3, #4)
  - [x] Create `src/common/notification-pipeline/notification-pipeline.service.ts`
  - [x] Inject `Repository<AccountPreferenceEntity>` and `Repository<EmailQueueItemEntity>` and `Repository<EmailDeliveryEventEntity>`
  - [x] Implement `dispatch(event: { eventType: NotifiableEventType; userId: string; profileId?: string; metadata?: Record<string, string | number | boolean | null>; correlationId: string }): Promise<void>`
    - [x] Resolve category and emailType from `EVENT_CATEGORY_MAP`
    - [x] If category is NOT mandatory: load `AccountPreferenceEntity` for `userId`; if `productEmailsEnabled === false`, skip and return (no error)
    - [x] Enqueue: save `EmailQueueItemEntity` with `emailType`, `recipientScope: 'single'`, `status: 'pending'`, `scheduledAt: now`, `metadata: { userId, profileId, correlationId, ...metadata }` — no PII/PHI in content fields
    - [x] Record initial `EmailDeliveryEventEntity` with `outcome: 'pending'`, `recipientScope: 'single'`, `occurredAt: now`, `metadata: { queueItemId, source: 'notification-pipeline', eventType }`
    - [x] Log: `{ action: 'NOTIFICATION_DISPATCHED', eventType, emailType, outcome: 'queued', correlationId }` — no PHI
  - [x] Implement `suppressedByPreference(userId: string, category: NotificationCategory): Promise<boolean>`
- [x] Task 3: Create `NotificationPipelineModule` and register entities (AC: #1)
  - [x] Create `src/common/notification-pipeline/notification-pipeline.module.ts`
  - [x] Register `TypeOrmModule.forFeature([AccountPreferenceEntity, EmailQueueItemEntity, EmailDeliveryEventEntity])`
  - [x] Export `NotificationPipelineService`
  - [x] Import into `AppModule` (add alongside existing modules)
- [x] Task 4: Wire up event dispatch from billing and report modules (AC: #1)
  - [x] In `BillingService` (or wherever payment outcomes land): inject `NotificationPipelineService`; after payment-success/failure state is persisted, call `notificationPipeline.dispatch({ eventType: 'BILLING_PAYMENT_SUCCESS' / 'BILLING_PAYMENT_FAILED', userId, correlationId })`
  - [x] In reports module: after parse-complete / parse-failed state transition, call `notificationPipeline.dispatch({ eventType: 'REPORT_UPLOAD_COMPLETE' / 'REPORT_PARSE_FAILED', userId, profileId, correlationId })`
  - [x] In account module: after closure confirmation, call `notificationPipeline.dispatch({ eventType: 'ACCOUNT_CLOSURE_CONFIRMED', userId, correlationId })`
- [ ] Task 5: Validate manually (no automated tests per project policy)
  - [ ] Trigger billing payment success → confirm `email_queue_items` row created with correct `emailType` and `status=pending`, and `email_delivery_events` row with `outcome=pending`
  - [ ] Trigger report parse failure → confirm queue entry created
  - [ ] Set user product preference to `false` → trigger a product-category event → confirm no queue entry created
  - [ ] Trigger security event (e.g. password change) → confirm queue entry created regardless of product preference
  - [ ] Confirm no PII/PHI in `email_queue_items.metadata` (no email addresses, health data)

## Dev Notes

### Critical Architecture Constraints

- **Reuse existing pipeline entities** — `EmailQueueItemEntity` and `EmailDeliveryEventEntity` already exist in `apps/api/src/database/entities/`. Do NOT create new tables for notification events. The email pipeline from Story 6.6 (and the admin pipeline from 5.15/5.16) uses these same tables. This story creates the **consumer-facing dispatch layer** on top of them.
- **Reuse existing preference model** — `AccountPreferenceEntity` has `productEmailsEnabled: boolean` (one row per user, `unique: true` on `userId`). Communication preference categories (`security`, `compliance`, `product`) are already defined in `account.types.ts` as `COMM_PREF_CATEGORY` and `MANDATORY_CATEGORIES`. Mirror those constants — do not redefine them.
- **`NotificationPipelineService` lives in `src/common/`**, not `src/modules/`. It is a cross-domain infrastructure service (called by billing, reports, account) and must not belong to any single feature module.
- **No cross-module repository injection** — `NotificationPipelineService` owns its own `TypeOrmModule.forFeature(...)` registrations. It does NOT reach into `EmailAdminModule` or `AccountModule` repositories directly.
- **PHI rule** — never include email address, health data, report content, or user names in `EmailQueueItemEntity.metadata`. Only store: `userId` (UUID), `profileId` (UUID if applicable), `correlationId`, `eventType` string, and any non-PHI operational keys. This mirrors the pattern established in 5.16 where subject/body were excluded.
- **No HTTP blocking** — `dispatch()` must be fire-and-forget from the caller's perspective. Callers should `void notificationPipeline.dispatch(...)` or use a background detach if needed. The queue mechanism decouples delivery latency from the request path.

### Preference Gating Logic

Current `AccountPreferenceEntity` has a single `productEmailsEnabled` boolean. The mapping to categories is:
- `product` category → gated by `productEmailsEnabled` (can be `false`)
- `security` / `compliance` categories → mandatory, never gated (matches `MANDATORY_CATEGORIES` set in `account.types.ts`)

Load the preference row with `findOne({ where: { userId } })`. If no preference row exists (user never set preferences), treat as default `productEmailsEnabled: true` (opt-in by default).

### EmailQueueItem.recipientScope for user notifications

Admin emails use `recipientScope: 'all'` / `'segment'` / `'single'`. For user notifications, always use `recipientScope: 'single'` since these are per-user triggered events.

### Event-to-EmailType Mapping (suggested values)

| NotifiableEventType | emailType string | category |
|---|---|---|
| `REPORT_UPLOAD_COMPLETE` | `report.upload_complete` | `product` |
| `REPORT_PARSE_FAILED` | `report.parse_failed` | `product` |
| `BILLING_PAYMENT_SUCCESS` | `billing.payment_success` | `product` |
| `BILLING_PAYMENT_FAILED` | `billing.payment_failed` | `product` |
| `SUBSCRIPTION_ACTIVATED` | `billing.subscription_activated` | `product` |
| `SUBSCRIPTION_CANCELLED` | `billing.subscription_cancelled` | `product` |
| `ACCOUNT_EMAIL_CHANGED` | `account.email_changed` | `security` |
| `ACCOUNT_PASSWORD_CHANGED` | `account.password_changed` | `security` |
| `ACCOUNT_CLOSURE_CONFIRMED` | `account.closure_confirmed` | `compliance` |

Transactional types (`AUTH_PASSWORD_RESET`, `AUTH_OTP_SENT`) are already handled by the existing `NotificationService` / `InMemoryNotificationService` infrastructure in `src/common/notification/`. Do **not** reroute them through `NotificationPipelineService` in this story — they are out of scope for 6.1.

### Where to inject NotificationPipelineService (wiring guidance)

- **Billing module** (`apps/api/src/modules/billing/`): after `billingRepo.save(...)` where payment outcomes are finalized. Import `NotificationPipelineModule` in `BillingModule` and inject `NotificationPipelineService`.
- **Reports module** (`apps/api/src/modules/reports/`): after parse status transitions to `complete` or `failed`. Import `NotificationPipelineModule` in `ReportsModule`.
- **Account module** (`apps/api/src/modules/account/`): after `closureRepo.save(...)` confirms account closure. Import `NotificationPipelineModule` in `AccountModule`.

**Pattern:** add `NotificationPipelineModule` to each consuming module's `imports: []` array. Never inject the service directly across module boundaries without importing the module.

### No Migrations Needed

`EmailQueueItemEntity` and `EmailDeliveryEventEntity` tables already exist (created in Story 5.15 migration `1730815900000-CreateEmailAdminTables`). `AccountPreferenceEntity` table already exists (created in earlier stories). This story only adds application logic — no new schema.

### Module Structure

New files to create:
```
apps/api/src/common/notification-pipeline/
  notification-event.types.ts    ← enum + routing map
  notification-pipeline.service.ts
  notification-pipeline.module.ts
```

### TypeScript Rules Reminder

- `async` only on methods that `await` — `suppressedByPreference` is async (DB call); `dispatch` is async
- Use `import type` for entity types where not used as values
- Error constants in `notification-event.types.ts` as screaming snake case if needed
- No `process.env` — use `ConfigService` if any config is needed (likely not for this story)
- All module entity registrations via `TypeOrmModule.forFeature([])`

### Project Structure Notes

- New common service: `apps/api/src/common/notification-pipeline/` — consistent with `src/common/notification/`, `src/common/storage/`, `src/common/restriction/` patterns
- Entity/migration files: no new entities; reuse `email-queue-item.entity.ts` and `email-delivery-event.entity.ts` from `src/database/entities/`
- Consuming modules import `NotificationPipelineModule` from `../../common/notification-pipeline/notification-pipeline.module`
- `AppModule` import: add `NotificationPipelineModule` to `imports` array (alongside `EmailAdminModule`, `AuthModule`, etc.)

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 6: Notifications, Incident Communication & Support]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 6.1]
- [Source: _bmad-output/planning-artifacts/prd.md#FR32, FR33, FR77]
- [Source: _bmad-output/planning-artifacts/prd-email-pipeline-and-onboarding.md]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]
- [Source: apps/api/src/common/notification/notification.service.ts] — existing email stub (password reset only; not replaced by this story)
- [Source: apps/api/src/database/entities/email-queue-item.entity.ts] — reuse for enqueue
- [Source: apps/api/src/database/entities/email-delivery-event.entity.ts] — reuse for outcome tracking
- [Source: apps/api/src/database/entities/account-preference.entity.ts] — preference gating source
- [Source: apps/api/src/modules/account/account.types.ts#COMM_PREF_CATEGORY] — category constants to mirror
- [Source: apps/api/src/modules/email-admin/email-admin.service.ts] — pattern for enqueue + delivery event creation

## Dev Agent Record

### Agent Model Used

gpt-5

### Implementation Plan

- Add notification taxonomy + routing map in common notification pipeline
- Implement pipeline service with preference gating, enqueue, and delivery event tracking
- Register pipeline module and wire into billing, reports, and account domains

### Debug Log References

### Completion Notes List

- Implemented notification event taxonomy, routing, and mandatory category guardrails.
- Added notification pipeline service + module and wired dispatch calls in billing, reports, and account closures.
- Skipped automated tests per project policy; manual validation pending (Task 5).

### File List

- apps/api/src/common/notification-pipeline/notification-event.types.ts
- apps/api/src/common/notification-pipeline/notification-pipeline.module.ts
- apps/api/src/common/notification-pipeline/notification-pipeline.service.ts
- apps/api/src/app.module.ts
- apps/api/src/modules/account/account.module.ts
- apps/api/src/modules/account/account.service.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.module.ts
- apps/api/src/modules/reports/reports.service.ts

### Change Log

- 2026-04-02: Added notification pipeline taxonomy, service, module, and dispatch wiring across billing, reports, and account closure flows.
