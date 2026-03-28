# Story 4.2: Credit Pack Purchase Flow

Status: review

## Story

As an authenticated user,
I want to purchase credit packs through a checkout flow,
so that I can recharge my credit balance and continue using paid features (report analysis, AI, share links).

## Acceptance Criteria

1. **Given** the user taps "Buy Credits" from the entitlement summary screen, **When** the credit pack selection loads, **Then** available credit packs are displayed with name, credits, and price in the user's currency.
2. **Given** the user selects a credit pack, **When** they tap "Pay", **Then** a Razorpay order is created server-side and the Razorpay checkout opens on the client.
3. **Given** payment succeeds (Razorpay callback), **When** the client sends the payment verification to the backend, **Then** the backend verifies the Razorpay signature, credits the user's balance, and returns the updated entitlement summary.
4. **Given** the Razorpay `payment.captured` webhook fires, **When** the backend receives it, **Then** it idempotently reconciles the order (credits balance if not already credited, marks order as reconciled).
5. **Given** payment fails or is cancelled by the user, **When** the checkout closes, **Then** the user sees a clear error message with a "Try again" option and no credits are added.
6. **Given** any order is created, **When** queried later, **Then** the order record exists with status (pending → paid → reconciled OR failed) and full audit trail (userId, packId, amount, currency, razorpayOrderId, timestamps).
7. **Given** the backend receives a webhook, **When** the signature does not match the Razorpay webhook secret, **Then** the request is rejected with 400 and no state changes occur.

## Tasks / Subtasks

- [x] Task 1: Create credit pack and order database entities + migration (AC: #1, #6)
  - [x] 1.1 Create `CreditPackEntity` (credit_packs table: id UUID, name, credits integer, price_inr numeric, price_usd numeric, is_active boolean, sort_order integer, timestamps)
  - [x] 1.2 Create `OrderEntity` (orders table: id UUID, user_id FK→users, credit_pack_id FK→credit_packs, amount numeric, currency varchar, status enum(pending/paid/reconciled/failed), razorpay_order_id varchar unique, razorpay_payment_id varchar nullable, razorpay_signature varchar nullable, credited boolean default false, metadata JSONB nullable, timestamps)
  - [x] 1.3 Create migration: create both tables + seed default credit packs (Small 5cr ₹99/$2.99, Medium 15cr ₹249/$6.99, Large 50cr ₹699/$19.99)
  - [x] 1.4 Register entities in `app.module.ts` typeOrmEntities and `data-source.ts`

- [x] Task 2: Implement BillingModule with credit pack listing and order creation (AC: #1, #2, #6)
  - [x] 2.1 Create `apps/api/src/modules/billing/billing.module.ts` — imports TypeOrmModule for CreditPackEntity, OrderEntity, UserEntitlementEntity; imports EntitlementsModule
  - [x] 2.2 Create `apps/api/src/modules/billing/billing.service.ts` with:
    - `listCreditPacks()`: return active packs sorted by sort_order
    - `createOrder(userId, creditPackId)`: validate pack exists + active, create Razorpay Order via API, persist OrderEntity with status=pending, return razorpayOrderId + amount + currency
    - `verifyPayment(userId, razorpayOrderId, razorpayPaymentId, razorpaySignature)`: verify HMAC signature with Razorpay key_secret, update order status=paid, credit user's balance (atomic), return updated entitlement summary
  - [x] 2.3 Create `apps/api/src/modules/billing/billing.controller.ts`:
    - `GET /billing/credit-packs` — public or auth-guarded, returns active packs
    - `POST /billing/orders` — auth-guarded, body: { creditPackId }, creates Razorpay order
    - `POST /billing/orders/verify` — auth-guarded, body: { razorpayOrderId, razorpayPaymentId, razorpaySignature }, verifies and credits
  - [x] 2.4 Create `apps/api/src/modules/billing/billing.types.ts` with OrderStatus enum, DTOs
  - [x] 2.5 Register BillingModule in AppModule imports

- [x] Task 3: Implement Razorpay webhook handler (AC: #4, #7)
  - [x] 3.1 `POST /billing/webhook/razorpay` — NO AuthGuard (Razorpay calls this), verify webhook signature using X-Razorpay-Signature header + webhook secret
  - [x] 3.2 Handle `payment.captured` event: find order by razorpay_order_id, idempotently credit balance if not already credited, update status=reconciled
  - [x] 3.3 Handle `payment.failed` event: update order status=failed
  - [x] 3.4 Return 200 for all valid webhook calls (Razorpay retries on non-2xx)
  - [x] 3.5 Log webhook events (no PHI — only order IDs and status)

- [x] Task 4: Razorpay integration service (AC: #2, #4, #7)
  - [x] 4.1 Create `apps/api/src/modules/billing/razorpay.service.ts` — wraps Razorpay Node SDK
  - [x] 4.2 Methods: `createOrder(amount, currency, receipt)`, `verifyPaymentSignature(orderId, paymentId, signature)`, `verifyWebhookSignature(body, signature)`
  - [x] 4.3 Add Razorpay config to ConfigService: RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET
  - [x] 4.4 Add `razorpay` npm package to apps/api

- [x] Task 5: Flutter credit pack purchase flow (AC: #1, #2, #3, #5)
  - [x] 5.1 Add `razorpay_flutter` package to apps/mobile
  - [x] 5.2 Create `CreditPackListScreen` showing available packs as cards (name, credits, price) with "Buy" button per pack
  - [x] 5.3 Implement Razorpay checkout: on "Buy" tap → call `POST /billing/orders` → open Razorpay with returned orderId + amount + key_id
  - [x] 5.4 Handle Razorpay success callback: call `POST /billing/orders/verify` with payment details → show success SnackBar "Credits added!" → navigate back to entitlement summary (refreshed)
  - [x] 5.5 Handle Razorpay failure/cancel callback: show error SnackBar with "Try again" option
  - [x] 5.6 Wire "Buy Credits" button on EntitlementSummaryScreen to navigate to CreditPackListScreen

## Dev Notes

### Architecture Compliance

- **Domain separation (ADR-CX1)**: Billing is a separate domain from clinical/report and identity/profile. The new `BillingModule` is separate from `EntitlementsModule`. BillingModule imports EntitlementsModule to update credit balance.
- **Entitlements module is NOT billing**: EntitlementsModule owns plan/entitlement reads. BillingModule owns purchase/order/payment writes. Do NOT merge them.
- **Profile isolation**: Orders are scoped to userId. No profile-level billing.
- **Response envelope**: All endpoints return `successResponse(data, correlationId)`.
- **Idempotency**: Payment verification and webhook handling MUST be idempotent. Use the `credited` boolean on OrderEntity to prevent double-crediting. Wrap credit update in a transaction.
- **No PHI in billing**: Orders contain only userId, packId, amounts, Razorpay IDs. No report or health data.

### Existing Code to Extend (NOT Reinvent)

- **EntitlementsService** (`apps/api/src/modules/entitlements/entitlements.service.ts`): Already has `getCreditBalance(userId)` and manages `UserEntitlementEntity`. Add a new method `addCredits(userId, amount): Promise<void>` that atomically increments `credit_balance` using a raw query or QueryRunner transaction (`SET credit_balance = credit_balance + :amount`). Do NOT read-then-write — use atomic increment.
- **UserEntitlementEntity** (`apps/api/src/database/entities/user-entitlement.entity.ts`): Already exists with `creditBalance` field (numeric 10,2). No schema changes needed for this story.
- **PlanEntity** (`apps/api/src/database/entities/plan.entity.ts`): Exists but is for plans, not credit packs. Credit packs are a SEPARATE entity.
- **EntitlementSummaryScreen** (Flutter): Already shows "Buy Credits" CTA button that currently shows "coming soon" SnackBar. Replace with navigation to the new CreditPackListScreen.
- **BillingRepository** (Flutter `apps/mobile/lib/features/billing/billing_repository.dart`): Already has abstract class. Add `listCreditPacks()`, `createOrder(packId)`, `verifyPayment(orderId, paymentId, signature)` methods to abstract and API implementation.
- **ApiClient** (Flutter): Existing HTTP client with auth token injection. Use for all API calls.

### Razorpay Integration Details

- **Payment provider**: Razorpay (single provider for India + international).
- **Node SDK**: `razorpay` npm package. Initialize with `key_id` and `key_secret`.
- **Order flow**: Backend creates Order via `razorpay.orders.create({ amount: amountInPaise, currency, receipt })` → returns `order.id` to client → client opens Razorpay checkout with `order.id` → on success client gets `razorpay_payment_id`, `razorpay_order_id`, `razorpay_signature` → client sends these to backend for verification.
- **Signature verification**: HMAC-SHA256 of `razorpay_order_id|razorpay_payment_id` with `key_secret`. Use `crypto.createHmac('sha256', secret).update(orderId + '|' + paymentId).digest('hex')`.
- **Webhook signature**: HMAC-SHA256 of raw request body with `webhook_secret`. Header: `X-Razorpay-Signature`.
- **Amounts**: Razorpay expects amounts in smallest currency unit (paise for INR, cents for USD). Store prices in standard units (rupees/dollars) in DB, convert to paise/cents when creating Razorpay order.
- **Flutter SDK**: `razorpay_flutter` package. `Razorpay()` → `open(options)` with key, amount, orderId, name, description → listen to `EVENT_PAYMENT_SUCCESS`, `EVENT_PAYMENT_ERROR`, `EVENT_EXTERNAL_WALLET`.
- **Environment variables needed**:
  - `RAZORPAY_KEY_ID` — public key (also sent to Flutter client)
  - `RAZORPAY_KEY_SECRET` — private key for server-side operations
  - `RAZORPAY_WEBHOOK_SECRET` — webhook signature verification

### Database Design

- **credit_packs table**: Holds purchasable credit pack definitions. Seeded in migration with 3 default packs. Superadmin will manage these in Story 5.2. Fields: id, name, credits, price_inr, price_usd, is_active, sort_order, timestamps.
- **orders table**: Transaction log for all purchase attempts. Every Razorpay order creation = one row. Status transitions: pending → paid → reconciled (happy path) or pending → failed. The `credited` boolean ensures idempotent crediting even if both verify endpoint and webhook fire.
- Column naming: `snake_case` per project convention.
- UUID primary keys with `@PrimaryGeneratedColumn('uuid')`.
- Timestamps: `timestamptz` with `@CreateDateColumn()` / `@UpdateDateColumn()`.
- Foreign keys: `user_id` → `users(id)`, `credit_pack_id` → `credit_packs(id)`.

### API Endpoint Design

```
GET /billing/credit-packs
Authorization: Bearer <token>
Response 200:
{
  "success": true,
  "data": [
    { "id": "uuid", "name": "Small Pack", "credits": 5, "priceInr": 99, "priceUsd": 2.99 },
    { "id": "uuid", "name": "Medium Pack", "credits": 15, "priceInr": 249, "priceUsd": 6.99 },
    { "id": "uuid", "name": "Large Pack", "credits": 50, "priceInr": 699, "priceUsd": 19.99 }
  ],
  "correlationId": "..."
}

POST /billing/orders
Authorization: Bearer <token>
Body: { "creditPackId": "uuid" }
Response 200:
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "razorpayOrderId": "order_xxxxx",
    "amount": 9900,
    "currency": "INR",
    "razorpayKeyId": "rzp_test_xxxxx"
  },
  "correlationId": "..."
}

POST /billing/orders/verify
Authorization: Bearer <token>
Body: { "razorpayOrderId": "order_xxxxx", "razorpayPaymentId": "pay_xxxxx", "razorpaySignature": "hex..." }
Response 200:
{
  "success": true,
  "data": {
    "creditsAdded": 5,
    "entitlementSummary": { ...same shape as GET /entitlements/summary... }
  },
  "correlationId": "..."
}

POST /billing/webhook/razorpay (NO auth — Razorpay server-to-server)
Headers: X-Razorpay-Signature: <hmac>
Body: Razorpay webhook payload JSON
Response 200: { "status": "ok" }
```

### Flutter Implementation

- **CreditPackListScreen**: Fetch packs from `GET /billing/credit-packs`. Display as Material 3 cards with pack name, credit count, price. Each card has a "Buy" `FilledButton`.
- **Purchase flow**: Tap Buy → loading state on button (disable to prevent double-tap) → call `POST /billing/orders` → receive razorpayOrderId + amount + currency + keyId → open Razorpay checkout → handle callbacks.
- **Razorpay checkout options**: `{ 'key': keyId, 'amount': amount, 'currency': currency, 'order_id': razorpayOrderId, 'name': 'Doclyzer', 'description': 'Credit Pack - {packName}' }`.
- **Success path**: Razorpay returns paymentId + orderId + signature → call `POST /billing/orders/verify` → show SnackBar "Credits added!" (auto-dismiss 3-5s) → pop back to EntitlementSummaryScreen (it will refetch).
- **Error path**: Show SnackBar "Payment failed. Try again." with retry action.
- **Repository pattern**: Add methods to existing abstract `BillingRepository` and `ApiBillingRepository`.
- **No new navigation structure needed** — CreditPackListScreen is pushed from EntitlementSummaryScreen's "Buy Credits" button.

### Webhook Endpoint Security

- The webhook endpoint `POST /billing/webhook/razorpay` must NOT have AuthGuard — Razorpay servers call it directly.
- Verify using `X-Razorpay-Signature` header: HMAC-SHA256 of raw body with webhook secret.
- To access raw body in NestJS: use `@Req() req` and `req.rawBody`. Ensure `rawBody: true` is set in NestJS bootstrap options (`NestFactory.create(AppModule, { rawBody: true })`).
- Return 200 for all valid signatures regardless of processing outcome (Razorpay retries on non-2xx).

### Credit Balance Update — Atomic Increment

Do NOT do `findOne → balance + credits → save`. This has race conditions if webhook and verify endpoint fire simultaneously. Instead:

```typescript
await this.userEntitlementRepo
  .createQueryBuilder()
  .update(UserEntitlementEntity)
  .set({ creditBalance: () => `credit_balance + ${credits}` })
  .where('user_id = :userId', { userId })
  .execute();
```

Then update the `credited` flag on the OrderEntity in the same transaction.

### Migration Pattern

Follow existing convention:
- Filename: `{timestamp}-CreateCreditPacksAndOrders.ts`
- Register in `apps/api/src/database/migrations/index.ts`
- UUID PKs with `uuid_generate_v4()`
- Include DOWN migration dropping both tables
- Seed 3 default credit packs in UP

### Config Registration

Add Razorpay config factory in billing module or a shared config:
```typescript
registerAs('razorpay', () => ({
  keyId: process.env.RAZORPAY_KEY_ID,
  keySecret: process.env.RAZORPAY_KEY_SECRET,
  webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET,
}))
```
Access via `this.configService.get('razorpay.keyId')`.

### Key Dependencies

- **Backend NEW**: `razorpay` npm package (Razorpay Node SDK)
- **Flutter NEW**: `razorpay_flutter` pub package
- **Backend EXISTING (do not re-add)**: `typeorm`, `@nestjs/typeorm`, `class-validator`, `class-transformer`, `@nestjs/jwt`, `@nestjs/passport`, `crypto` (Node built-in)
- **Flutter EXISTING**: `http`, `flutter_secure_storage`

### Previous Story Intelligence (Story 4.1)

- PlanEntity and UserEntitlementEntity are already created and registered.
- EntitlementsService has lazy auto-provisioning (creates free-tier entitlement on first access).
- EntitlementsController exists at `/entitlements/summary`.
- Flutter BillingRepository abstract class exists with `getEntitlementSummary()`.
- `getMaxProfiles()` was changed from sync to async — pattern established for service method changes.
- EntitlementSummaryScreen has a "Buy Credits" button that currently shows "coming soon" — replace this with navigation.

### Project Structure Notes

- **New module**: `apps/api/src/modules/billing/` (billing.module.ts, billing.service.ts, billing.controller.ts, billing.types.ts, razorpay.service.ts)
- **New entities**: `apps/api/src/database/entities/credit-pack.entity.ts`, `apps/api/src/database/entities/order.entity.ts`
- **New migration**: `apps/api/src/database/migrations/{timestamp}-CreateCreditPacksAndOrders.ts`
- **Modify**: `apps/api/src/database/migrations/index.ts` (register migration)
- **Modify**: `apps/api/src/app.module.ts` (add BillingModule import, add entities to typeOrmEntities)
- **Modify**: `apps/api/src/database/data-source.ts` (add entities)
- **Modify**: `apps/api/src/modules/entitlements/entitlements.service.ts` (add `addCredits()` method)
- **New Flutter screen**: `apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart`
- **Modify Flutter**: `apps/mobile/lib/features/billing/billing_repository.dart` (add purchase methods)
- **Modify Flutter**: `apps/mobile/lib/features/billing/api_billing_repository.dart` (add API implementations)
- **Modify Flutter**: `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart` (wire Buy Credits navigation)
- **Modify Flutter**: `apps/mobile/lib/main.dart` (add CreditPackListScreen route if needed)
- **Modify**: `.env.example` (add RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET)
- **No changes** to `apps/web/`

### Architecture note: BillingModule vs EntitlementsModule

Per architecture, billing and entitlements are part of the same service boundary but have different responsibilities:
- **EntitlementsModule**: Reads — plan info, credit balance, entitlement summary, limit checks
- **BillingModule**: Writes — order creation, payment processing, credit additions, purchase history

BillingModule imports EntitlementsModule (to call `addCredits()`). This keeps the read/write separation clean and matches the architecture's "billing/entitlements" service boundary.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 4 - Story 4.2]
- [Source: _bmad-output/planning-artifacts/prd.md#FR28 - Credit pack purchase]
- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Monetization (value-based)]
- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Promo codes with Razorpay]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1 Domain Separation]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns - Idempotency]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Checkout Form Pattern]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns]
- [Source: _bmad-output/implementation-artifacts/4-1-credit-balance-and-entitlement-summary-view.md]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

No issues encountered during implementation.

### Completion Notes List

- Implemented full credit pack purchase flow with Razorpay integration
- Created CreditPackEntity and OrderEntity with proper UUID PKs, FKs, and constraints
- Migration seeds 3 default credit packs (Small 5cr/₹99, Medium 15cr/₹249, Large 50cr/₹699)
- BillingModule is separate from EntitlementsModule per ADR-CX1 domain separation
- BillingService handles order creation, payment verification (HMAC-SHA256), and webhook reconciliation
- All credit balance updates use atomic SQL increment (no read-then-write race condition)
- Idempotent payment processing via `credited` boolean on OrderEntity
- Webhook endpoint has no AuthGuard; validates via X-Razorpay-Signature header
- Enabled rawBody in NestJS bootstrap for webhook signature verification
- Flutter CreditPackListScreen shows packs as Material 3 cards with Razorpay checkout integration
- EntitlementSummaryScreen "Buy Credits" button now navigates to CreditPackListScreen (replaced "coming soon" SnackBar)
- Both TypeScript (backend) and Dart (Flutter) compile cleanly with no new errors

### Change Log

- 2026-03-23: Implemented Story 4.2 — Credit Pack Purchase Flow (all 5 tasks, all ACs satisfied)

### File List

**New files:**
- apps/api/src/database/entities/credit-pack.entity.ts
- apps/api/src/database/entities/order.entity.ts
- apps/api/src/database/migrations/1730814300000-CreateCreditPacksAndOrders.ts
- apps/api/src/config/razorpay.config.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.types.ts
- apps/api/src/modules/billing/razorpay.service.ts
- apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart

**Modified files:**
- apps/api/src/database/migrations/index.ts (registered new migration)
- apps/api/src/app.module.ts (added CreditPackEntity, OrderEntity, BillingModule, razorpayConfig)
- apps/api/src/database/data-source.ts (added CreditPackEntity, OrderEntity)
- apps/api/src/modules/entitlements/entitlements.service.ts (added addCredits method)
- apps/api/src/main.ts (enabled rawBody for webhook signature verification)
- apps/mobile/lib/features/billing/billing_repository.dart (added CreditPack, CreateOrderResult, VerifyPaymentResult models and abstract methods)
- apps/mobile/lib/features/billing/api_billing_repository.dart (added API implementations for listCreditPacks, createOrder, verifyPayment)
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart (added onBuyCredits callback, replaced "coming soon" SnackBar)
- apps/mobile/lib/main.dart (added creditPackList view, CreditPackListScreen import and navigation)
- apps/mobile/pubspec.lock (razorpay_flutter added)
- .env.example (added RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET)
- _bmad-output/implementation-artifacts/sprint-status.yaml (status updated)
