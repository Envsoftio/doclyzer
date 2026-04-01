# Story 4.3: Subscription Purchase Flow

Status: done

## Story

As an authenticated user,
I want to subscribe to a paid plan through a checkout flow,
so that premium limits and features unlock (multiple profiles, higher report caps, AI chat, more share links).

## Acceptance Criteria

1. **Given** the user taps "Upgrade" from the entitlement summary screen, **When** the plan selection screen loads, **Then** available paid plans are displayed with name, features/limits comparison, and monthly price (INR + USD).
2. **Given** the user selects a paid plan, **When** they tap "Subscribe", **Then** a Razorpay subscription is created server-side and Razorpay checkout opens on the client for recurring payment authorization.
3. **Given** subscription payment succeeds (Razorpay callback), **When** the client sends subscription verification to the backend, **Then** the backend verifies the Razorpay signature, upgrades the user's entitlement to the selected plan, and returns the updated entitlement summary.
4. **Given** the Razorpay `subscription.activated` webhook fires, **When** the backend receives it, **Then** it idempotently reconciles the subscription (upgrades plan if not already upgraded, records subscription record).
5. **Given** payment fails or is cancelled by the user, **When** the checkout closes, **Then** the user sees a clear error message with a "Try again" option and no plan change occurs.
6. **Given** any subscription is created, **When** queried later, **Then** a subscription record exists with status (created → active → cancelled | halted), Razorpay subscription ID, plan reference, billing period dates, and audit trail.
7. **Given** the user is already on a paid plan, **When** they view the plan selection screen, **Then** their current plan is highlighted and no duplicate subscription can be created.

## Tasks / Subtasks

- [x]Task 1: Create SubscriptionEntity + migration (AC: #6)
  - [x]1.1 Create `SubscriptionEntity` (`subscriptions` table: id UUID PK, user_id FK→users, plan_id FK→plans, status varchar(32) default 'created', razorpay_subscription_id varchar unique, razorpay_payment_id varchar nullable, razorpay_signature varchar nullable, current_period_start timestamptz nullable, current_period_end timestamptz nullable, metadata JSONB nullable, timestamps)
  - [x]1.2 Add `razorpay_plan_id` column (varchar, nullable) to `plans` table via migration
  - [x]1.3 Create migration `{timestamp}-CreateSubscriptionsTable.ts`: creates subscriptions table, adds razorpay_plan_id to plans, seeds paid plan row with Razorpay plan ID
  - [x]1.4 Register `SubscriptionEntity` in `app.module.ts` typeOrmEntities and `data-source.ts`

- [x]Task 2: Extend BillingModule with subscription endpoints (AC: #1, #2, #3, #6, #7)
  - [x]2.1 Add `SubscriptionEntity` to BillingModule's TypeOrmModule.forFeature
  - [x]2.2 Add to BillingService:
    - `listPlans()`: return active plans with name, tier, limits, priceInfo (exclude free plan from purchase list)
    - `createSubscription(userId, planId)`: validate plan exists + active + paid tier, check user not already on this plan, create Razorpay subscription via SDK, persist SubscriptionEntity with status='created', return razorpaySubscriptionId + plan details
    - `verifySubscription(userId, razorpaySubscriptionId, razorpayPaymentId, razorpaySignature)`: verify HMAC signature, update subscription status='active', upgrade user's entitlement (change planId, set expiresAt from billing period), return updated entitlement summary
  - [x]2.3 Add to BillingController:
    - `GET /billing/plans` — auth-guarded, returns active paid plans with limits comparison
    - `POST /billing/subscriptions` — auth-guarded, body: { planId }, creates Razorpay subscription
    - `POST /billing/subscriptions/verify` — auth-guarded, body: { razorpaySubscriptionId, razorpayPaymentId, razorpaySignature }, verifies and upgrades plan
  - [x]2.4 Add DTOs to billing.types.ts: CreateSubscriptionDto, VerifySubscriptionDto, PlanResponseDto, CreateSubscriptionResponseDto, VerifySubscriptionResponseDto
  - [x]2.5 Add error codes: BILLING_PLAN_NOT_FOUND, BILLING_PLAN_INACTIVE, BILLING_ALREADY_SUBSCRIBED, BILLING_SUBSCRIPTION_NOT_FOUND, BILLING_SUBSCRIPTION_INVALID_SIGNATURE

- [x]Task 3: Handle subscription webhooks (AC: #4)
  - [x]3.1 Extend existing webhook handler in BillingController to handle `subscription.activated` event
  - [x]3.2 Add `handleWebhookSubscriptionActivated(razorpaySubscriptionId, razorpayPaymentId)` to BillingService: find subscription by razorpay_subscription_id, idempotently upgrade plan if not already active, update subscription status='active', set period dates
  - [x]3.3 Handle `subscription.halted` event: update subscription status='halted', optionally downgrade user back to free tier
  - [x]3.4 Handle `subscription.cancelled` event: update subscription status='cancelled', downgrade user to free tier, clear expiresAt
  - [x]3.5 Log webhook events (no PHI — only subscription IDs and status)

- [x]Task 4: Extend RazorpayService for subscriptions (AC: #2)
  - [x]4.1 Add `createSubscription(planRazorpayId, totalCount, customerId?)` method: calls `razorpay.subscriptions.create()` with plan_id, total_count, customer_notify
  - [x]4.2 Add `verifySubscriptionSignature(subscriptionId, paymentId, signature)` method: HMAC-SHA256 of `razorpay_payment_id|razorpay_subscription_id` with key_secret

- [x]Task 5: Extend EntitlementsService for plan upgrades (AC: #3, #4)
  - [x]5.1 Add `upgradePlan(userId, planId, expiresAt?)` method to EntitlementsService: update user's planId and expiresAt atomically; do NOT reset credit balance (credits persist across plan changes)
  - [x]5.2 Add `downgradeToPlan(userId, planId)` method: revert user to specified plan (used for cancellation/halt → free tier fallback)

- [x]Task 6: Flutter plan selection and subscribe flow (AC: #1, #2, #3, #5, #7)
  - [x]6.1 Add subscription models to billing_repository.dart: `Plan` class (id, name, tier, limits, priceInfo), `CreateSubscriptionResult` (subscriptionId, razorpaySubscriptionId, razorpayKeyId), `VerifySubscriptionResult` (entitlementSummary)
  - [x]6.2 Add abstract methods to BillingRepository: `listPlans()`, `createSubscription(planId)`, `verifySubscription(razorpaySubscriptionId, razorpayPaymentId, razorpaySignature)`
  - [x]6.3 Implement in ApiBillingRepository: `listPlans()` → GET v1/billing/plans, `createSubscription()` → POST v1/billing/subscriptions, `verifySubscription()` → POST v1/billing/subscriptions/verify
  - [x]6.4 Create `PlanSelectionScreen`: shows paid plans as cards with feature comparison vs free tier, highlights current plan if already subscribed, "Subscribe" button per plan, disabled if already on that plan
  - [x]6.5 Implement Razorpay subscription checkout: on "Subscribe" tap → call `POST /billing/subscriptions` → open Razorpay with returned subscriptionId → handle success/failure callbacks → call verify endpoint on success → navigate back to entitlement summary
  - [x]6.6 Wire "Upgrade" button on EntitlementSummaryScreen to navigate to PlanSelectionScreen

## Dev Notes

### Architecture Compliance

- **Domain separation (ADR-CX1)**: Subscriptions are handled in `BillingModule`, same as credit packs. BillingModule owns purchase/subscription writes. EntitlementsModule owns plan/entitlement reads. BillingModule imports EntitlementsModule to call `upgradePlan()`.
- **Entitlements module is NOT billing**: Do NOT add subscription creation logic to EntitlementsModule. Only add plan-switching helpers (`upgradePlan`, `downgradeToPlan`).
- **Profile isolation**: Subscriptions are scoped to userId. No profile-level subscriptions.
- **Response envelope**: All endpoints return `successResponse(data, correlationId)`.
- **Idempotency**: Subscription verification and webhook handling MUST be idempotent. Check subscription status before upgrading. Use a transaction for plan switch.
- **No PHI in billing**: Subscriptions contain only userId, planId, amounts, Razorpay IDs. No report or health data.

### Existing Code to Extend (NOT Reinvent)

- **BillingModule** (`apps/api/src/modules/billing/billing.module.ts`): Already exists with CreditPackEntity, OrderEntity, BillingController, BillingService, RazorpayService. Add SubscriptionEntity to TypeOrmModule.forFeature. Add new methods to existing services.
- **BillingService** (`apps/api/src/modules/billing/billing.service.ts`): Add `listPlans()`, `createSubscription()`, `verifySubscription()`, and webhook handlers. Do NOT create a separate SubscriptionService — keep all billing writes in one service.
- **BillingController** (`apps/api/src/modules/billing/billing.controller.ts`): Add plan listing and subscription endpoints. Extend existing webhook handler switch to include subscription events.
- **RazorpayService** (`apps/api/src/modules/billing/razorpay.service.ts`): Add `createSubscription()` and `verifySubscriptionSignature()` methods. The Razorpay SDK instance already exists.
- **EntitlementsService** (`apps/api/src/modules/entitlements/entitlements.service.ts`): Add `upgradePlan()` and `downgradeToPlan()` methods. These update `UserEntitlementEntity.planId` and `expiresAt`.
- **PlanEntity** (`apps/api/src/database/entities/plan.entity.ts`): Already has id, name, tier, limits (JSONB), priceInfo (JSONB), isActive. Add `razorpayPlanId` column. The free plan is already seeded. Seed a paid plan in the new migration.
- **UserEntitlementEntity** (`apps/api/src/database/entities/user-entitlement.entity.ts`): Already has planId (FK), expiresAt, status. No schema changes needed — plan upgrade is just updating planId + expiresAt.
- **OrderEntity** (`apps/api/src/database/entities/order.entity.ts`): This is for credit pack orders ONLY. Do NOT reuse for subscriptions. Create a separate SubscriptionEntity.
- **BillingRepository** (Flutter `billing_repository.dart`): Already has abstract class with credit pack methods. Add `listPlans()`, `createSubscription()`, `verifySubscription()`.
- **ApiBillingRepository** (Flutter `api_billing_repository.dart`): Add API implementations for plan listing and subscription endpoints.
- **EntitlementSummaryScreen** (Flutter): Already has "Upgrade" button (`_buildUpgradeCta`). Change it to navigate to PlanSelectionScreen instead of (or in addition to) CreditPackListScreen.
- **CreditPackListScreen** (Flutter): Reference for Razorpay checkout pattern — subscription flow is similar but uses subscription_id instead of order_id.

### Razorpay Subscriptions API Details

- **Subscriptions vs Orders**: Razorpay Subscriptions are DIFFERENT from Orders. Subscriptions use `razorpay.subscriptions.create()` NOT `razorpay.orders.create()`.
- **Razorpay Plans**: Before creating a subscription, a Plan must exist in Razorpay dashboard (or via API). Store `razorpay_plan_id` on our PlanEntity. Plans define period (monthly/yearly), amount, currency.
- **Create Subscription**: `razorpay.subscriptions.create({ plan_id: razorpayPlanId, total_count: 12, customer_notify: 0 })` → returns subscription object with `id`, `short_url`.
- **Checkout for Subscriptions**: Client opens Razorpay checkout with `{ 'key': keyId, 'subscription_id': razorpaySubscriptionId, 'name': 'Doclyzer', 'description': 'Monthly Plan - {planName}' }`. NOTE: use `subscription_id` NOT `order_id` — they are mutually exclusive in Razorpay checkout options.
- **Signature verification for subscriptions**: HMAC-SHA256 of `razorpay_payment_id|razorpay_subscription_id` with `key_secret`. NOTE: order is `payment_id|subscription_id` (different from credit packs which use `order_id|payment_id`).
- **Webhook events**:
  - `subscription.activated` — first payment succeeded, subscription is active
  - `subscription.charged` — recurring payment succeeded (subsequent cycles)
  - `subscription.halted` — payment failed after retries, subscription paused
  - `subscription.cancelled` — subscription cancelled by user or admin
- **Amount**: Razorpay plans define the amount. When creating a subscription, amount comes from the plan. Store plan price in `priceInfo` JSONB on PlanEntity (e.g., `{ monthlyInr: 299, monthlyUsd: 4.99 }`).
- **Flutter SDK**: Same `razorpay_flutter` package already installed. Use `_razorpay.open({ 'key': keyId, 'subscription_id': subscriptionId, ... })` — Razorpay handles recurring payment authorization.

### Database Design

- **subscriptions table**: Tracks active/past subscriptions. One active subscription per user at a time. Status transitions: created → active (on payment success) → cancelled/halted (on cancel/failure). NOT the same as orders — subscriptions are recurring.
  - `id` UUID PK
  - `user_id` FK → users (with CASCADE delete)
  - `plan_id` FK → plans (no cascade — subscriptions reference plans)
  - `status` varchar(32): 'created' | 'active' | 'cancelled' | 'halted'
  - `razorpay_subscription_id` varchar unique
  - `razorpay_payment_id` varchar nullable (first payment)
  - `razorpay_signature` varchar nullable
  - `current_period_start` timestamptz nullable
  - `current_period_end` timestamptz nullable
  - `metadata` JSONB nullable
  - `created_at`, `updated_at` timestamptz

- **plans table changes**: Add `razorpay_plan_id` varchar nullable column. The free plan has no Razorpay plan ID. Paid plans have Razorpay plan IDs (created in Razorpay dashboard).

- **Column naming**: `snake_case` per project convention.
- **UUID primary keys**: `@PrimaryGeneratedColumn('uuid')`.
- **Timestamps**: `timestamptz` with `@CreateDateColumn()` / `@UpdateDateColumn()`.

### API Endpoint Design

```
GET /billing/plans
Authorization: Bearer <token>
Response 200:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Pro Monthly",
      "tier": "paid",
      "limits": { "maxProfiles": 5, "maxReports": 100, "maxShareLinks": 10, "aiChatEnabled": true },
      "priceInfo": { "monthlyInr": 299, "monthlyUsd": 4.99 },
      "isCurrentPlan": false
    }
  ],
  "correlationId": "..."
}

POST /billing/subscriptions
Authorization: Bearer <token>
Body: { "planId": "uuid" }
Response 200:
{
  "success": true,
  "data": {
    "subscriptionId": "uuid",
    "razorpaySubscriptionId": "sub_xxxxx",
    "razorpayKeyId": "rzp_test_xxxxx",
    "planName": "Pro Monthly"
  },
  "correlationId": "..."
}

POST /billing/subscriptions/verify
Authorization: Bearer <token>
Body: { "razorpaySubscriptionId": "sub_xxxxx", "razorpayPaymentId": "pay_xxxxx", "razorpaySignature": "hex..." }
Response 200:
{
  "success": true,
  "data": {
    "planName": "Pro Monthly",
    "entitlementSummary": { ...same shape as GET /entitlements/summary... }
  },
  "correlationId": "..."
}

POST /billing/webhook/razorpay (existing endpoint — extend switch)
Handles: subscription.activated, subscription.charged, subscription.halted, subscription.cancelled
```

### Plan Upgrade Logic — EntitlementsService

```typescript
async upgradePlan(userId: string, planId: string, expiresAt?: Date): Promise<void> {
  await this.findOrProvision(userId);
  await this.entitlementRepo
    .createQueryBuilder()
    .update(UserEntitlementEntity)
    .set({ planId, expiresAt: expiresAt ?? null, status: 'active' })
    .where('user_id = :userId', { userId })
    .execute();
}
```

Do NOT reset `creditBalance` when upgrading — credits persist across plan changes. Only change `planId` and `expiresAt`.

### Subscription Status Enforcement

- Before creating a subscription, check that the user doesn't already have an active subscription to the same plan. Query: `SELECT * FROM subscriptions WHERE user_id = :userId AND status = 'active'`.
- If user has active subscription to a different plan, this is a plan change scenario. For MVP, block this and show "Cancel current subscription first". Plan change/upgrade mid-cycle is post-MVP complexity.
- If user is on free tier (no active subscription), allow subscription creation.

### Flutter Implementation

- **PlanSelectionScreen**: Fetch plans from `GET /billing/plans`. Display as Material 3 cards with plan name, price, feature list (limits comparison vs free). Each card has a "Subscribe" `FilledButton`. If user is already on that plan, show "Current Plan" badge instead of button.
- **Subscribe flow**: Tap Subscribe → loading state on button → call `POST /billing/subscriptions` → receive razorpaySubscriptionId + keyId → open Razorpay checkout with `subscription_id` (NOT order_id) → handle callbacks.
- **Razorpay checkout options for subscription**: `{ 'key': keyId, 'subscription_id': razorpaySubscriptionId, 'name': 'Doclyzer', 'description': 'Monthly Plan - {planName}' }`. Do NOT include `amount` or `order_id` — Razorpay derives these from the subscription's plan.
- **Success path**: Razorpay returns paymentId + subscriptionId + signature → call `POST /billing/subscriptions/verify` → show SnackBar "Plan upgraded!" (auto-dismiss 3-5s) → pop back to EntitlementSummaryScreen (it will refetch and show new plan).
- **Error path**: Show SnackBar "Subscription failed. Try again." with retry action.
- **Repository pattern**: Add methods to existing abstract `BillingRepository` and `ApiBillingRepository`.
- **Navigation**: EntitlementSummaryScreen's "Upgrade" button navigates to PlanSelectionScreen. PlanSelectionScreen pushes from EntitlementSummaryScreen (same pattern as CreditPackListScreen).

### Webhook Endpoint Extension

Extend the existing `handleRazorpayWebhook` method in BillingController. The webhook already validates the signature. Add cases to the event switch:

```typescript
// Existing:
if (event === 'payment.captured') { ... }
else if (event === 'payment.failed') { ... }
// Add:
else if (event === 'subscription.activated') {
  const subId = payload.payload.subscription?.entity?.id ?? '';
  const paymentId = payload.payload.payment?.entity?.id ?? '';
  await this.billingService.handleWebhookSubscriptionActivated(subId, paymentId);
}
else if (event === 'subscription.halted') { ... }
else if (event === 'subscription.cancelled') { ... }
```

### Migration Pattern

Follow existing convention:
- Filename: `{timestamp}-CreateSubscriptionsTable.ts` (use timestamp after existing billing migrations, e.g., `1730814400000`)
- Register in `apps/api/src/database/migrations/index.ts`
- UUID PKs with `uuid_generate_v4()`
- Include DOWN migration dropping subscriptions table and removing razorpay_plan_id column
- Seed one paid plan row: `{ name: 'Pro Monthly', tier: 'paid', limits: { maxProfiles: 5, maxReports: 100, maxShareLinks: 10, aiChatEnabled: true }, priceInfo: { monthlyInr: 299, monthlyUsd: 4.99 }, isActive: true, razorpayPlanId: process.env.RAZORPAY_PLAN_ID_PRO || 'plan_placeholder' }`
- The Razorpay plan must be created in Razorpay dashboard first; store its ID in env var `RAZORPAY_PLAN_ID_PRO`

### Entity Registration

New entity must be added to TWO places:
1. `apps/api/src/app.module.ts` → `typeOrmEntities` array
2. `apps/api/src/database/data-source.ts` → entities array (for CLI migration tooling)

### Config Changes

- Add `RAZORPAY_PLAN_ID_PRO` to `.env.example` (the Razorpay plan ID for the Pro Monthly plan, created in Razorpay dashboard)
- No new config factory needed — Razorpay config already exists at `apps/api/src/config/razorpay.config.ts`

### Key Dependencies

- **Backend EXISTING (do not re-add)**: `razorpay` npm, `typeorm`, `@nestjs/typeorm`, `class-validator`, `class-transformer`, `crypto` (Node built-in)
- **Flutter EXISTING (do not re-add)**: `razorpay_flutter`, `http`, `flutter_secure_storage`
- **No new packages needed** — everything is already installed from Story 4.2

### Previous Story Intelligence (Stories 4.1 & 4.2)

- PlanEntity, UserEntitlementEntity, CreditPackEntity, OrderEntity all exist and are registered.
- EntitlementsService has lazy auto-provisioning, `addCredits()`, `getCreditBalance()`, `getMaxProfiles()`.
- BillingModule exists with credit pack listing, order creation, payment verification, and webhook handling.
- RazorpayService wraps the Razorpay SDK with order creation and signature verification.
- Flutter BillingRepository abstract class exists with credit pack methods.
- `razorpay_flutter` package already added to Flutter.
- `rawBody: true` already enabled in NestJS bootstrap for webhook signature verification.
- Razorpay config factory already registered in AppModule.
- CreditPackListScreen pattern (Razorpay checkout flow) is the template for subscription checkout — follow same structure but with `subscription_id` instead of `order_id`.
- EntitlementSummaryScreen has both "Buy Credits" and "Upgrade" buttons — "Buy Credits" navigates to CreditPackListScreen, "Upgrade" should navigate to PlanSelectionScreen.

### Project Structure Notes

- **New entity**: `apps/api/src/database/entities/subscription.entity.ts`
- **New migration**: `apps/api/src/database/migrations/{timestamp}-CreateSubscriptionsTable.ts`
- **Modify**: `apps/api/src/database/migrations/index.ts` (register migration)
- **Modify**: `apps/api/src/app.module.ts` (add SubscriptionEntity to typeOrmEntities)
- **Modify**: `apps/api/src/database/data-source.ts` (add SubscriptionEntity)
- **Modify**: `apps/api/src/database/entities/plan.entity.ts` (add razorpayPlanId column)
- **Modify**: `apps/api/src/modules/billing/billing.module.ts` (add SubscriptionEntity to TypeOrmModule.forFeature)
- **Modify**: `apps/api/src/modules/billing/billing.service.ts` (add plan listing, subscription creation, verification, webhook handlers)
- **Modify**: `apps/api/src/modules/billing/billing.controller.ts` (add plan/subscription endpoints, extend webhook switch)
- **Modify**: `apps/api/src/modules/billing/billing.types.ts` (add subscription DTOs and error codes)
- **Modify**: `apps/api/src/modules/billing/razorpay.service.ts` (add createSubscription, verifySubscriptionSignature)
- **Modify**: `apps/api/src/modules/entitlements/entitlements.service.ts` (add upgradePlan, downgradeToPlan)
- **New Flutter screen**: `apps/mobile/lib/features/billing/screens/plan_selection_screen.dart`
- **Modify Flutter**: `apps/mobile/lib/features/billing/billing_repository.dart` (add Plan model, subscription methods)
- **Modify Flutter**: `apps/mobile/lib/features/billing/api_billing_repository.dart` (add API implementations)
- **Modify Flutter**: `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart` (wire Upgrade button to PlanSelectionScreen)
- **Modify Flutter**: `apps/mobile/lib/main.dart` (add PlanSelectionScreen route if needed)
- **Modify**: `.env.example` (add RAZORPAY_PLAN_ID_PRO)
- **No changes** to `apps/web/`

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 4 - Story 4.3]
- [Source: _bmad-output/planning-artifacts/prd.md#FR29 - Subscription purchase flow]
- [Source: _bmad-output/planning-artifacts/prd.md#Monetization model - credits and subscription from day one]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1 Domain Separation]
- [Source: _bmad-output/planning-artifacts/architecture.md#Billing/Entitlements Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns - Idempotency]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Upgrade Flow]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Checkout Form Pattern]
- [Source: _bmad-output/implementation-artifacts/4-1-credit-balance-and-entitlement-summary-view.md]
- [Source: _bmad-output/implementation-artifacts/4-2-credit-pack-purchase-flow.md]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

None

### Completion Notes List

- Created SubscriptionEntity with all required columns (id, userId, planId, status, razorpaySubscriptionId, razorpayPaymentId, razorpaySignature, currentPeriodStart, currentPeriodEnd, metadata, timestamps)
- Added razorpayPlanId column to PlanEntity
- Created migration 1730814400000-CreateSubscriptionsTable: creates subscriptions table, adds razorpay_plan_id to plans, seeds Pro Monthly paid plan
- Registered SubscriptionEntity in app.module.ts and data-source.ts
- Extended BillingService with listPlans(), createSubscription(), verifySubscription(), and webhook handlers for subscription.activated/halted/cancelled
- Extended BillingController with GET /billing/plans, POST /billing/subscriptions, POST /billing/subscriptions/verify endpoints
- Extended webhook handler switch for subscription events
- Added createSubscription() and verifySubscriptionSignature() to RazorpayService
- Added upgradePlan(), downgradeToPlan(), getActivePlans(), getPlanById() to EntitlementsService
- Added subscription DTOs and error codes to billing.types.ts
- Added RAZORPAY_PLAN_ID_PRO to .env.example
- Created Flutter Plan, CreateSubscriptionResult, VerifySubscriptionResult models
- Added listPlans(), createSubscription(), verifySubscription() to BillingRepository and ApiBillingRepository
- Created PlanSelectionScreen with Razorpay subscription checkout flow
- Updated EntitlementSummaryScreen with separate "Upgrade" and "Buy Credits" buttons
- Added planSelection route to main.dart

### Change Log

- 2026-03-24: Implemented subscription purchase flow — all 6 tasks completed (backend entity/migration, billing endpoints, webhooks, Razorpay subscription methods, entitlements plan upgrade/downgrade, Flutter plan selection screen)

### File List

- apps/api/src/database/entities/subscription.entity.ts (new)
- apps/api/src/database/entities/plan.entity.ts (modified — added razorpayPlanId)
- apps/api/src/database/migrations/1730814400000-CreateSubscriptionsTable.ts (new)
- apps/api/src/database/migrations/index.ts (modified — registered new migration)
- apps/api/src/app.module.ts (modified — added SubscriptionEntity)
- apps/api/src/database/data-source.ts (modified — added SubscriptionEntity)
- apps/api/src/modules/billing/billing.module.ts (modified — added SubscriptionEntity to forFeature)
- apps/api/src/modules/billing/billing.service.ts (modified — added subscription methods)
- apps/api/src/modules/billing/billing.controller.ts (modified — added plan/subscription endpoints, extended webhook)
- apps/api/src/modules/billing/billing.types.ts (modified — added subscription DTOs and error codes)
- apps/api/src/modules/billing/razorpay.service.ts (modified — added createSubscription, verifySubscriptionSignature)
- apps/api/src/modules/entitlements/entitlements.service.ts (modified — added upgradePlan, downgradeToPlan, getActivePlans, getPlanById)
- apps/mobile/lib/features/billing/billing_repository.dart (modified — added Plan, subscription models, abstract methods)
- apps/mobile/lib/features/billing/api_billing_repository.dart (modified — added API implementations)
- apps/mobile/lib/features/billing/screens/plan_selection_screen.dart (new)
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart (modified — added onUpgrade, split CTA buttons)
- apps/mobile/lib/main.dart (modified — added planSelection route)
- .env.example (modified — added RAZORPAY_PLAN_ID_PRO)
