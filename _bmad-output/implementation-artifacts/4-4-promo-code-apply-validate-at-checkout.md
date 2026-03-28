# Story 4.4: Promo Code Apply/Validate at Checkout

Status: done

## Story

As an authenticated user,
I want promo validation,
so that eligible discounts apply correctly.

## Acceptance Criteria

1. **Given** a user enters a promo code at checkout for a credit pack, **When** the code is validated, **Then** the system returns the discounted amount (or an explicit “not applicable” reason) before any payment is created.
2. **Given** a promo code is invalid, expired, inactive, over usage cap, or not applicable to the selected product, **When** validation runs, **Then** a safe error is returned and no Razorpay order/subscription is created.
3. **Given** a valid promo code is applied for a credit pack, **When** the order is created, **Then** Razorpay receives the final discounted amount (in subunits) and the applied promo details are persisted with the order.
4. **Given** payment succeeds, **When** webhook reconciliation occurs, **Then** the promo redemption is recorded exactly once (idempotent) with code, userId, product type, discount amount, and timestamps.
5. **Given** a promo code is applied, **When** the user views checkout UI, **Then** the discount and final amount are visible with clear inline validation feedback.
6. **Given** a user enters a promo code during subscription checkout, **When** validation runs, **Then** the system returns `BILLING_PROMO_NOT_APPLICABLE` and proceeds without promo (subscription promos are out of scope until Razorpay Offers are configured).

## Tasks / Subtasks

- [x] Task 1: Add promo code data model and redemption tracking (AC: #2, #4)
  - [x] 1.1 Create `PromoCodeEntity` (e.g. `promo_codes` table: id UUID PK, code varchar unique, discount_type enum `percentage|fixed`, discount_value numeric, applies_to enum `credit_pack|subscription|both`, valid_from/valid_until timestamptz nullable, usage_cap_total integer nullable, usage_cap_per_user integer nullable, is_active boolean default true, metadata JSONB nullable, timestamps)
  - [x] 1.2 Create `PromoRedemptionEntity` (e.g. `promo_redemptions` table: id UUID PK, promo_code_id FK, user_id FK, product_type enum, product_ref_id FK/uuid nullable, order_id FK nullable, subscription_id FK nullable, discount_amount numeric, currency varchar, status enum `reserved|redeemed|void`, timestamps)
  - [x] 1.3 Add migration to create both tables and indices (code unique; `(promo_code_id, user_id)` for per-user cap checks)
  - [x] 1.4 Register entities in `app.module.ts` typeOrmEntities and `data-source.ts`

- [x] Task 2: Implement promo validation logic in BillingService (AC: #1, #2)
  - [x] 2.1 Add `validatePromoCode(userId, promoCode, productType, productId, currency)` to BillingService
  - [x] 2.2 Validation rules (server-side only; never trust client):
    - code exists + `is_active`
    - date window valid (`valid_from`/`valid_until`)
    - applicable to product type (credit pack vs subscription)
    - total usage cap (count redemptions with status `redeemed`)
    - per-user cap (count per user)
  - [x] 2.3 Compute discount amount and final price using product price from DB (credit pack price or plan price) — do NOT accept client amounts
  - [x] 2.4 Add explicit error codes: `BILLING_PROMO_NOT_FOUND`, `BILLING_PROMO_INACTIVE`, `BILLING_PROMO_EXPIRED`, `BILLING_PROMO_NOT_APPLICABLE`, `BILLING_PROMO_CAP_REACHED`, `BILLING_PROMO_USER_CAP_REACHED`

- [x] Task 3: Expose promo validation API (AC: #1, #2, #5)
  - [x] 3.1 Add `POST /billing/promo/validate` (AuthGuard) with body `{ promoCode, productType, productId }`
  - [x] 3.2 Response returns `{ discountAmount, finalAmount, currency, promoCodeId }` when valid
  - [x] 3.3 Response envelope uses `successResponse(data, correlationId)` and errors via ApiExceptionFilter

- [x] Task 4: Integrate promo application into credit pack orders (AC: #3, #4)
  - [x] 4.1 Extend `createOrder` DTO to accept optional `promoCode`
  - [x] 4.2 In `BillingService.createOrder`, recompute promo validation server-side, compute discounted amount, and create Razorpay order with discounted amount (subunits)
  - [x] 4.3 Persist applied promo details on the Order (e.g., `promoCodeId`, `discountAmount`, `finalAmount`, `currency` via explicit columns or `metadata` JSONB)
  - [x] 4.4 On webhook `payment.captured` (and verify endpoint), create or update `PromoRedemptionEntity` to `redeemed` exactly once (idempotent), linked to the order

- [x] Task 5: Handle subscription promo attempts as not applicable (AC: #6)
  - [x] 5.1 Do NOT accept promos in subscription creation for v1
  - [x] 5.2 If `promoCode` is provided on subscription checkout, return `BILLING_PROMO_NOT_APPLICABLE` without creating an offer or discount
  - [x] 5.3 Ensure UI shows “Promo codes not supported for subscriptions yet” and proceeds with full price

- [x] Task 6: Update Flutter checkout UX for promo code (AC: #5, #6)
  - [x] 6.1 Credit pack flow: add promo input + “Apply” to `CreditPackListScreen` (or a lightweight checkout sheet) — call `/billing/promo/validate` and show discount + final amount before “Pay”
  - [x] 6.2 Subscription flow: if a promo is entered, show inline message “Promo codes not supported for subscriptions yet” and block apply
  - [x] 6.3 On “Pay/Subscribe,” include `promoCode` only for credit-pack `createOrder` calls; do NOT send promo code for subscriptions

## Dev Notes

### Architecture Compliance

- **Billing domain owns promo application**: Implement promo validation and discounting inside `BillingModule`. Entitlements stays read-focused; do not push promo logic into Entitlements. (ADR-CX1 domain separation)
- **Backend is source of truth for pricing**: Promo logic must compute discounts server-side from DB prices; do not trust client amounts.
- **Promo logic owned by backend; Razorpay called with discounted amount** for credit packs only. (Product brief)
- **Subscription promos out of scope** until Razorpay Offers are configured; treat as not applicable and proceed at full price.
- **Idempotency**: Redemptions must be idempotent (webhook + verify can both fire). Use a unique constraint on `(promo_code_id, order_id)` or `(promo_code_id, subscription_id)` and update status atomically.
- **No PHI in logs**: Promo logs should contain only userId/code/order/subscription references; never include report or health data.

### Existing Code to Extend (Do Not Reinvent)

- **BillingModule** (`apps/api/src/modules/billing/`): reuse the existing order/subscription flows (Story 4.2/4.3). Add promo validation and discounting inside BillingService.
- **RazorpayService** (`apps/api/src/modules/billing/razorpay.service.ts`): already wraps order/subscription creation and signature verification.
- **OrderEntity / SubscriptionEntity**: extend with promo metadata (explicit columns or JSONB) instead of creating new parallel order tables.
- **Flutter billing screens**: `CreditPackListScreen` and `PlanSelectionScreen` already exist; add promo input + validation there.

### Data & Validation Guardrails

- **Validate required params**: Required query/body params must be explicitly validated in controller before DB queries to avoid unscoped access.
- **Usage caps concurrency**: Enforce usage caps in a transaction (or `SELECT ... FOR UPDATE`) to avoid race conditions on high-volume promo usage.
- **Promo redemption timing**: Record redemption only on successful payment (`payment.captured` or `subscription.activated`). If you create a “reserved” redemption at order creation, ensure failed/cancelled payments void it.
- **Future: subscription promos**: When Razorpay Offers are configured, revisit this story to allow subscription promo codes (discount first payment via Offer). Keep current behavior as credit-pack-only until then.

### Razorpay Details (Latest)

- **Orders API uses amount in currency subunits** (e.g., INR 295.00 → `29500` paise) when creating an order. Compute discounted amount in subunits before calling Razorpay. citeturn0search4
- **Best practice**: Use Orders API + signature verification + webhooks for payment integrity. citeturn0search9

### Testing Requirements

- **Do not add or run tests**. Follow project policy: manual QA only; no unit/integration/e2e tests.

## Previous Story Intelligence

- **Story 4.2 (Credit packs)** established the Razorpay order flow, webhook reconciliation, and idempotent crediting. Reuse the same BillingService patterns and avoid new payment pipelines. Promo discounts must be applied before `razorpay.orders.create()` and should follow the existing signature verification + webhook reconciliation flow.
- **Story 4.3 (Subscriptions)** added `SubscriptionEntity`, plan listing, and subscription checkout via Razorpay. Reuse the same create/verify/webhook pattern and store promo metadata on the subscription without changing entitlements logic.

## Git Intelligence Summary

- Recent commits show that Razorpay billing (credit packs + subscriptions) and entitlement flows were added recently. Avoid reinventing billing module structure; extend the existing BillingService and RazorpayService only.
- Share link functionality, error redaction, and report summary persistence are recent changes; do not touch these domains while adding promo logic.

## Project Context Reference

- Follow `_bmad-output/project-context.md` for strict TypeScript rules, ConfigService usage (no `process.env` in modules), error envelope patterns, and **no tests** policy.

### Project Structure Notes

- Entities: `apps/api/src/database/entities/` (snake_case table names, UUID PKs)
- Migrations: `apps/api/src/database/migrations/` (register in `index.ts`)
- Billing module: `apps/api/src/modules/billing/` (controllers thin, services own business logic)
- Flutter billing UI: `apps/mobile/lib/features/billing/screens/`

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 4 - Story 4.4]
- [Source: _bmad-output/planning-artifacts/prd.md#FR30 Promo codes at checkout]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Checkout (credits/subscription) and Validation]
- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Promo codes (superadmin) and Promo codes with Razorpay]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns and Billing/Entitlements mapping]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules, Security & Sensitive Data Rules]
- [Source: _bmad-output/implementation-artifacts/4-2-credit-pack-purchase-flow.md]
- [Source: _bmad-output/implementation-artifacts/4-3-subscription-purchase-flow.md]

## Open Questions (Save for End)

1. No open questions.

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

None.

### Completion Notes List

- Implemented promo code entities, redemptions, and order promo fields with migration/registrations.
- Added promo validation endpoint with server-side pricing rules and explicit error codes.
- Applied promos to credit-pack orders and recorded idempotent redemptions on payment success.
- Updated Flutter checkout with promo apply UI for credit packs and subscription messaging.
- Follow-up review fixes applied: promo reservation lifecycle (`reserved` -> `redeemed`/`void`) added to strengthen usage-cap concurrency handling.
- Follow-up review fixes applied: promo lookup made case-insensitive (`UPPER(code)` compare).
- Follow-up review fixes applied: checkout sheet now shows INR amounts with 2-decimal precision to match backend calculations.
- Story file list synced with current workspace change set for transparency.
- Tests not run per project policy (manual QA only).

### Change Log

- 2026-03-29: Implemented promo validation, order discounting/redemptions, and Flutter checkout updates.
- 2026-03-29: Addressed code-review findings (cap-concurrency hardening, case-insensitive promo lookup, amount-display precision, file-list sync).

### File List

- _bmad-output/implementation-artifacts/4-4-promo-code-apply-validate-at-checkout.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/database/data-source.ts
- apps/api/src/database/entities/order.entity.ts
- apps/api/src/database/entities/promo-code.entity.ts (new)
- apps/api/src/database/entities/promo-redemption.entity.ts (new)
- apps/api/src/database/migrations/1730814500000-CreatePromoCodesAndRedemptions.ts (new)
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/billing/billing.types.ts
- apps/mobile/lib/features/billing/api_billing_repository.dart
- apps/mobile/lib/features/billing/billing_repository.dart
- apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart
- apps/mobile/lib/features/billing/screens/plan_selection_screen.dart
- apps/web/package-lock.json
- _bmad-output/planning-artifacts/implementation-readiness-report-2026-03-28.md

## Story Completion Status

Status set to **done**.
Code review fixes applied; implementation complete.
