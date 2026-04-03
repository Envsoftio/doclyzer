# Story 6.2: Notification Preference Controls by Category

Status: in-progress

## Story

As an authenticated user,
I want to view and update my notification preferences by category (security, compliance, product),
so that future notification deliveries respect my choices while mandatory notices (security/compliance) are always sent.

## Acceptance Criteria

1. Given I am authenticated, when I call `GET /account/communication-preferences`, then the response includes all three categories (`security`, `compliance`, `product`) with their `enabled` and `mandatory` flags, and `security`/`compliance` are always `enabled: true, mandatory: true`.
2. Given I am authenticated, when I call `PUT /account/communication-preferences` with `{ "productEmails": false }`, then my `product` category preference is saved and the response reflects `enabled: false` for `product`.
3. Given I update preferences and the product category is `false`, when `NotificationPipelineService.dispatch()` is called for a `product`-category event, then the notification is suppressed (no queue entry created).
4. Given I update preferences and the product category is `false`, when `NotificationPipelineService.dispatch()` is called for a `security` or `compliance`-category event, then the notification is sent regardless (mandatory categories always fire).
5. Given no preference row exists for me (first-time user), when preferences are read or dispatch is evaluated, then `product` defaults to `enabled: true` (opt-in by default).
6. Given I attempt to disable `security` or `compliance` categories via `PUT /account/communication-preferences`, when the request is processed, then those categories remain `enabled: true` (mandatory, not updatable by user).

## Tasks / Subtasks

- [x] Task 1: Verify and harden existing preference API (AC: #1, #2, #5, #6)
  - [x] Confirm `GET /account/communication-preferences` returns correct shape: `{ preferences: [{ category, enabled, mandatory }] }` — this is already implemented in `AccountService.getCommunicationPreferences()`. No changes needed if it matches AC#1.
  - [x] Confirm `PUT /account/communication-preferences` with `UpdateCommunicationPreferencesDto` only accepts `productEmails?: boolean`. Security/compliance are not in the DTO, so they cannot be changed — already correct.
  - [x] Confirm `UpdateCommunicationPreferencesDto` uses `@IsOptional() @IsBoolean()` on `productEmails` — already in place. No changes needed.
  - [x] Confirm `AccountService.updateCommunicationPreferences()` creates a preference row if none exists, sets `productEmailsEnabled`, and returns the full 3-category preference response.
  - [x] Confirm default behaviour: if no `AccountPreferenceEntity` row exists for user, `productEmailsEnabled` defaults to `true` (opt-in).

- [x] Task 2: Create `NotificationPipelineService` and supporting types in `src/common/notification-pipeline/` (AC: #3, #4, #5)
  - [x] Create `apps/api/src/common/notification-pipeline/notification-event.types.ts`:
    - Define `NotifiableEventType` enum:
      ```
      REPORT_UPLOAD_COMPLETE = 'REPORT_UPLOAD_COMPLETE'
      REPORT_PARSE_FAILED = 'REPORT_PARSE_FAILED'
      BILLING_PAYMENT_SUCCESS = 'BILLING_PAYMENT_SUCCESS'
      BILLING_PAYMENT_FAILED = 'BILLING_PAYMENT_FAILED'
      SUBSCRIPTION_ACTIVATED = 'SUBSCRIPTION_ACTIVATED'
      SUBSCRIPTION_CANCELLED = 'SUBSCRIPTION_CANCELLED'
      ACCOUNT_EMAIL_CHANGED = 'ACCOUNT_EMAIL_CHANGED'
      ACCOUNT_PASSWORD_CHANGED = 'ACCOUNT_PASSWORD_CHANGED'
      ACCOUNT_CLOSURE_CONFIRMED = 'ACCOUNT_CLOSURE_CONFIRMED'
      ```
    - Define `NotificationCategory` type: `'security' | 'compliance' | 'product'`
    - Define `MANDATORY_NOTIFICATION_CATEGORIES: ReadonlySet<NotificationCategory>` = `new Set(['security', 'compliance'])` — mirrors `MANDATORY_CATEGORIES` in `account.types.ts`, do NOT import from there (cross-module leakage)
    - Define `EVENT_CATEGORY_MAP: Record<NotifiableEventType, { category: NotificationCategory; emailType: string }>`:

      | Event | emailType | category |
      |---|---|---|
      | REPORT_UPLOAD_COMPLETE | `report.upload_complete` | product |
      | REPORT_PARSE_FAILED | `report.parse_failed` | product |
      | BILLING_PAYMENT_SUCCESS | `billing.payment_success` | product |
      | BILLING_PAYMENT_FAILED | `billing.payment_failed` | product |
      | SUBSCRIPTION_ACTIVATED | `billing.subscription_activated` | product |
      | SUBSCRIPTION_CANCELLED | `billing.subscription_cancelled` | product |
      | ACCOUNT_EMAIL_CHANGED | `account.email_changed` | security |
      | ACCOUNT_PASSWORD_CHANGED | `account.password_changed` | security |
      | ACCOUNT_CLOSURE_CONFIRMED | `account.closure_confirmed` | compliance |

  - [x] Create `apps/api/src/common/notification-pipeline/notification-pipeline.service.ts`:
    - Inject: `@InjectRepository(AccountPreferenceEntity)`, `@InjectRepository(EmailQueueItemEntity)`, `@InjectRepository(EmailDeliveryEventEntity)`
    - Implement `async dispatch(event: { eventType: NotifiableEventType; userId: string; profileId?: string; metadata?: Record<string, string | number | boolean | null>; correlationId: string }): Promise<void>`:
      1. Resolve `{ category, emailType }` from `EVENT_CATEGORY_MAP[event.eventType]`
      2. If `category` is NOT in `MANDATORY_NOTIFICATION_CATEGORIES`: load `AccountPreferenceEntity` where `userId = event.userId`; if `pref?.productEmailsEnabled === false`, log suppression and return early (no error thrown)
      3. Save `EmailQueueItemEntity`: `{ emailType, recipientScope: 'single', status: 'pending', scheduledAt: new Date(), metadata: { userId: event.userId, profileId: event.profileId ?? null, correlationId: event.correlationId, eventType: event.eventType, ...event.metadata } }` — no PII/PHI in metadata (no email address, no health data, no names)
      4. Save `EmailDeliveryEventEntity`: `{ outcome: 'pending', recipientScope: 'single', occurredAt: new Date(), metadata: { queueItemId: savedQueueItem.id, source: 'notification-pipeline', eventType: event.eventType } }`
      5. Log: `{ action: 'NOTIFICATION_DISPATCHED', eventType: event.eventType, emailType, outcome: 'queued', correlationId: event.correlationId }` — no PHI
    - Implement `async suppressedByPreference(userId: string, category: NotificationCategory): Promise<boolean>`:
      - If `category` in `MANDATORY_NOTIFICATION_CATEGORIES` → return `false`
      - Load pref row → return `pref?.productEmailsEnabled === false ? true : false`

  - [x] Create `apps/api/src/common/notification-pipeline/notification-pipeline.module.ts`:
    - Import `TypeOrmModule.forFeature([AccountPreferenceEntity, EmailQueueItemEntity, EmailDeliveryEventEntity])`
    - Provider: `NotificationPipelineService`
    - Export: `NotificationPipelineService`
    - Do NOT set `global: true` — consuming modules import explicitly

- [x] Task 3: Register `NotificationPipelineModule` in `AppModule` (AC: #3, #4)
  - [x] In `apps/api/src/app.module.ts`: add `NotificationPipelineModule` to the `imports` array (alongside `EmailAdminModule`, `AuthModule`, etc.)

- [x] Task 4: Wire notification dispatch into billing, reports, and account modules (AC: #3, #4)
  - [x] **Billing module** (`apps/api/src/modules/billing/billing.service.ts`):
    - Add `NotificationPipelineModule` to `BillingModule` imports
    - Inject `NotificationPipelineService` in `BillingService` constructor
    - After payment success is persisted: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS, userId, correlationId })`
    - After payment failure: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.BILLING_PAYMENT_FAILED, userId, correlationId })`
    - After subscription activated: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.SUBSCRIPTION_ACTIVATED, userId, correlationId })`
    - After subscription cancelled: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.SUBSCRIPTION_CANCELLED, userId, correlationId })`
  - [x] **Reports module** (`apps/api/src/modules/reports/` or `parsing/`):
    - Locate where parse status transitions to `complete` or `failed` — likely in a parsing service/worker
    - Add `NotificationPipelineModule` to that module's imports
    - Inject `NotificationPipelineService`
    - After parse completes: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.REPORT_UPLOAD_COMPLETE, userId, profileId, correlationId })`
    - After parse fails: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.REPORT_PARSE_FAILED, userId, profileId, correlationId })`
  - [x] **Account module** (`apps/api/src/modules/account/account.service.ts`):
    - Add `NotificationPipelineModule` to `AccountModule` imports
    - Inject `NotificationPipelineService` in `AccountService`
    - In `createClosureRequest()` after `closureRepo.save(entity)`: `void notificationPipeline.dispatch({ eventType: NotifiableEventType.ACCOUNT_CLOSURE_CONFIRMED, userId, correlationId })`

- [ ] Task 5: Manual validation (no automated tests per project policy)
  - [ ] `GET /account/communication-preferences` — confirm 3 categories returned, security/compliance `mandatory: true`
  - [ ] `PUT /account/communication-preferences` `{ "productEmails": false }` — confirm `product.enabled` becomes `false`
  - [ ] Trigger `BILLING_PAYMENT_SUCCESS` with product preference `false` → confirm no `email_queue_items` row created
  - [ ] Trigger `BILLING_PAYMENT_SUCCESS` with product preference `true` (default) → confirm `email_queue_items` row created with `emailType: 'billing.payment_success'`, `status: 'pending'`, and `email_delivery_events` row with `outcome: 'pending'`
  - [ ] Trigger `ACCOUNT_EMAIL_CHANGED` (security category) with product preference `false` → confirm queue entry IS created (mandatory bypass)
  - [ ] Verify `email_queue_items.metadata` contains only `userId`, `profileId`, `correlationId`, `eventType` — no email addresses, no health content

## Dev Notes

### Critical Architecture Constraints

- **Story 6.1 dependency**: `NotificationPipelineService` and `NotificationPipelineModule` were specified in Story 6.1. If Story 6.1 has NOT been implemented yet, this story creates them. If 6.1 was implemented, extend the existing service. Check `apps/api/src/common/notification-pipeline/` for existence.
- **Reuse existing entities** — `EmailQueueItemEntity` and `EmailDeliveryEventEntity` already exist in `apps/api/src/database/entities/`. Do NOT create new tables. `AccountPreferenceEntity` table also exists.
- **Preference API is already implemented** in `AccountService` and `AccountController` — `getCommunicationPreferences()` and `updateCommunicationPreferences()` with `UpdateCommunicationPreferencesDto`. Task 1 is a verification task, not a build task. Only change if something deviates from ACs.
- **Do NOT cross-import `MANDATORY_CATEGORIES` from `account.types.ts`** — that would couple `common/notification-pipeline` to `modules/account`. Define an independent `MANDATORY_NOTIFICATION_CATEGORIES` constant in `notification-event.types.ts` with the same values.
- **`dispatch()` is fire-and-forget** — callers use `void notificationPipeline.dispatch(...)`. Do NOT `await` it in the calling service's request path. This keeps delivery latency off the request path.
- **No new migrations needed** — all required tables already exist.

### Existing Preference API Shape (verified from source)

```
GET /account/communication-preferences
→ { preferences: [
    { category: 'security',   enabled: true,  mandatory: true  },
    { category: 'compliance', enabled: true,  mandatory: true  },
    { category: 'product',    enabled: <bool>, mandatory: false }
  ]}

PUT /account/communication-preferences
Body: { productEmails?: boolean }
→ Same response shape as GET
```

`AccountPreferenceEntity` has a single `productEmailsEnabled: boolean` column (default `true`, unique on `userId`). The 3-category view is constructed in `AccountService.getCommunicationPreferences()` — security and compliance are always hardcoded as `enabled: true, mandatory: true`.

### PHI Safety Rule

- `EmailQueueItemEntity.metadata`: only `userId` (UUID), `profileId` (UUID, nullable), `correlationId`, `eventType` string, and any non-PHI operational keys from `event.metadata`.
- NEVER include: email address, display name, report content, health values, or any user-readable string that could identify a person outside of their UUID.

### Module Wiring Pattern

Each consuming module must add `NotificationPipelineModule` to its own `imports: []` array — never inject `NotificationPipelineService` directly without importing its module. Pattern example from existing code: `AccountModule` imports `AuthModule` to use `AuthService`.

### TypeScript Rules Reminders

- `async` only on methods that `await` — both `dispatch` and `suppressedByPreference` are async (they hit the DB)
- `import type` for entity type references not used as values
- No `process.env` inside modules — `ConfigService` only (this module likely needs none)
- Error constants as SCREAMING_SNAKE_CASE in `notification-event.types.ts` if any
- Module exports are minimal — only export `NotificationPipelineService`

### Files to Create

```
apps/api/src/common/notification-pipeline/
  notification-event.types.ts    ← enum, category type, routing map, mandatory set
  notification-pipeline.service.ts
  notification-pipeline.module.ts
```

### Files to Modify

```
apps/api/src/app.module.ts                           ← add NotificationPipelineModule import
apps/api/src/modules/billing/billing.module.ts       ← add NotificationPipelineModule
apps/api/src/modules/billing/billing.service.ts      ← inject + call dispatch
apps/api/src/modules/reports/*.module.ts             ← add NotificationPipelineModule (locate correct module)
apps/api/src/modules/reports/*.service.ts            ← inject + call dispatch after parse transitions
apps/api/src/modules/account/account.module.ts       ← add NotificationPipelineModule
apps/api/src/modules/account/account.service.ts      ← inject + call dispatch after closure
```

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 6.2]
- [Source: _bmad-output/implementation-artifacts/6-1-notification-event-delivery-for-account-report-billing-updates.md] — Story 6.1 spec (same notification-pipeline infrastructure, read fully before implementing)
- [Source: apps/api/src/modules/account/account.service.ts#getCommunicationPreferences] — existing preference read logic
- [Source: apps/api/src/modules/account/account.service.ts#updateCommunicationPreferences] — existing preference write logic
- [Source: apps/api/src/modules/account/account.dto.ts#UpdateCommunicationPreferencesDto] — existing DTO
- [Source: apps/api/src/modules/account/account.types.ts#COMM_PREF_CATEGORY] — category constants to mirror (not import)
- [Source: apps/api/src/database/entities/account-preference.entity.ts] — preference entity
- [Source: apps/api/src/database/entities/email-queue-item.entity.ts] — reuse for enqueue
- [Source: apps/api/src/database/entities/email-delivery-event.entity.ts] — reuse for outcome tracking
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline] — cross-domain service in common/
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

gpt-5

### Debug Log References

None.
### Completion Notes List

- Verified communication preference API behavior aligns with mandatory categories and product opt-in defaults.
- Removed cross-module coupling in notification taxonomy and aligned mandatory category guardrails.
- Wired subscription activation/cancellation notifications and tightened queue metadata to UUID-only fields.
- Manual validation steps remain pending (Task 5).
### File List

- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/common/notification-pipeline/notification-event.types.ts
- apps/api/src/common/notification-pipeline/notification-pipeline.module.ts
- apps/api/src/common/notification-pipeline/notification-pipeline.service.ts
- apps/api/src/modules/account/account.module.ts
- apps/api/src/modules/account/account.service.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/reports/reports.module.ts
- apps/api/src/modules/reports/reports.service.ts

### Change Log

- 2026-04-02: Updated notification taxonomy to avoid cross-module imports, added subscription activation/cancellation dispatches, and removed extra metadata from notification queue events.
- 2026-04-03: Code review fix — corrected File List to include all files modified during implementation (app.module.ts, notification-pipeline.module.ts, account.module.ts, billing.module.ts, reports.module.ts).
