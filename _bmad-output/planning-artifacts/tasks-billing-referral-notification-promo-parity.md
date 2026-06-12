# Detailed Tasks: Billing, Referral, Promo, Email, and Notification Parity

Created: 2026-06-12
Status: Draft
Source PRD: `_bmad-output/planning-artifacts/prd-billing-referral-notification-promo-parity.md`
Project: Doclyzer

Implementation split: `docs/implementation-tasks/billing-referral-notification-promo/index.md`

## How to Use This File

This task plan breaks the PRD into separate implementation-ready tasks. Each task is intentionally scoped so it can become a focused development ticket or story.

Recommended execution order:

1. Complete API foundations first.
2. Add email and push foundations next.
3. Build mobile and superadmin surfaces after API contracts stabilize.
4. Keep optional gift vouchers separate from core billing, promo, referral, email, and notification work.

## Global Definition of Done

Every implementation task should meet these standards unless the task explicitly says otherwise:

- Code follows existing Doclyzer NestJS, Flutter, and Nuxt patterns.
- Database changes include migrations and entity/model updates.
- Credit, billing, promo, and referral state changes are idempotent.
- User credit changes go through `EntitlementsService` or an equivalent ledger-safe path.
- Admin financial/reward mutations create audit records.
- Email/push side effects use idempotency keys where duplicate events are possible.
- Tests cover success, duplicate/idempotent retry, failure, and authorization behavior where applicable.
- No code or files are changed in `/Users/vishnu/Work/Server/proctorplus-language-student-platform`.

## Task Index

- Task 01: Billing Reconciliation Hardening
- Task 02: Promo Code Parity Improvements
- Task 03: Referral Data Model
- Task 04: Referral Apply and Invitee Bonus
- Task 05: Referral Milestone A
- Task 06: Referral Milestone B
- Task 07: Referral Fraud and Admin Review
- Task 08: Email Template Expansion
- Task 09: Push Notification Infrastructure
- Task 10: Mobile Referral Experience
- Task 11: Mobile Billing Updates
- Task 12: Mobile Notifications
- Task 13: Superadmin Billing and Promo Pages
- Task 14: Superadmin Referral Page
- Task 15: Superadmin Notification Operations
- Task 16: Optional Gift Voucher Phase

---

## Task 01: Billing Reconciliation Hardening

### Objective

Harden the current credit pack payment flow so that paid credits are granted only after trusted RevenueCat webhook reconciliation, duplicate provider events are safe, payment mismatch cases are reviewable, and mobile can reliably poll order status after Google Pay/RevenueCat checkout.

### PRD Coverage

- BR-1 through BR-15
- ER-2, ER-5
- Acceptance criteria: Billing

### Primary Areas

- API billing module
- RevenueCat webhook and Google Pay/platform checkout integration
- Orders entity/model
- Promo reservation cleanup behavior
- Notification pipeline for ops alerts

Likely paths:

- `apps/api/src/modules/billing`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`
- `apps/api/src/email/templates`
- `apps/api/src/database`

### Deliverables

- Add or confirm order states for:
  - created
  - payment pending
  - client purchase confirmed
  - webhook pending
  - reconciled/credits added
  - failed
  - pending review
- Ensure client purchase confirmation only records a client-confirmed pending state.
- Ensure RevenueCat webhook reconciliation is the only paid-credit allocation trigger.
- Add explicit amount and currency validation before credit allocation.
- Mark mismatched orders as pending review without adding credits.
- Persist RevenueCat event ids or equivalent idempotency keys.
- Add invalid RevenueCat webhook authorization/signature alert dispatch.
- Add payment mismatch alert dispatch.
- Add order status endpoint for mobile polling.
- Ensure failed payments release or void promo reservations.

### Acceptance Criteria

- A successful Google Pay/RevenueCat purchase adds credits exactly once after RevenueCat webhook reconciliation.
- Replaying the same RevenueCat purchase webhook does not add duplicate credits.
- Client purchase confirmation without RevenueCat webhook reconciliation does not add credits.
- Amount mismatch prevents credit allocation and marks the order pending review.
- Currency mismatch prevents credit allocation and marks the order pending review.
- Invalid RevenueCat webhook authorization/signature does not mutate credits and creates an ops alert email event.
- Failed payment changes order state and clears related promo reservation.
- Mobile can call a single order status endpoint and see current reconciliation state.

### Test Notes

- Unit test client purchase confirmation state transitions.
- Unit test duplicate webhook event id handling.
- Unit test amount mismatch and currency mismatch.
- Integration test order create, client confirmation, RevenueCat webhook reconciliation, entitlement balance changed once.
- Integration test failed webhook and promo reservation release.
- Authorization test order status endpoint cannot expose another user's order.

### Dependencies

- Existing billing/order/promo entities.
- Existing entitlement credit grant service.
- Existing notification pipeline.

### Out of Scope

- Superadmin billing UI. That is Task 13.
- Mobile checkout UX. That is Task 11.

---

## Task 02: Promo Code Parity Improvements

### Objective

Bring Doclyzer promo codes to parity with the reference flow by adding max discount caps for percentage promos, clean zero-amount checkout behavior, and robust promo lifecycle tracking.

### PRD Coverage

- PR-1 through PR-14
- BR-8, BR-11, BR-12
- Acceptance criteria: Promo

### Primary Areas

- API billing promo validation
- Promo code entity and migration
- Promo redemption/reservation lifecycle
- Credit pack order creation
- Promo analytics

Likely paths:

- `apps/api/src/modules/billing`
- `apps/api/src/database`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

### Deliverables

- Add optional `max_discount_amount` or equivalent field for percentage promo codes.
- Update promo validation to apply max discount cap.
- Return validation response with:
  - original amount
  - discount amount
  - final amount
  - currency
  - promo code id
  - promo label/description
  - invalid reason when applicable
- Keep validation non-consuming.
- Keep reservation on order creation.
- Keep final redemption only after paid reconciliation or zero-amount checkout.
- Add zero-amount promo checkout path:
  - do not start Google Pay or RevenueCat purchase flow
  - create auditable internal order
  - mark promo redemption redeemed
  - grant credits immediately
  - enqueue promo/billing receipt email
- Ensure expired, inactive, capped, wrong-pack, wrong-plan, or per-user-capped promos return clear errors.
- Ensure failed/expired/abandoned orders void or release reservations.
- Update promo analytics to distinguish validation, reservation, redeemed, failed, and voided.

### Acceptance Criteria

- Percentage promo with max discount never discounts beyond configured cap.
- Promo validation does not increase redemption usage.
- Promo reservation does not count as final redemption.
- Paid promo order redeems promo only after webhook reconciliation.
- Zero-amount promo order grants credits immediately without Google Pay or RevenueCat purchase flow.
- Zero-amount promo order is visible in order history and admin billing data.
- Duplicate zero-amount checkout submission does not grant duplicate credits.
- Promo analytics reflect the correct lifecycle counts.

### Test Notes

- Unit test flat discount, percentage discount, and capped percentage discount.
- Unit test final amount floor at zero.
- Integration test zero-amount checkout grants credits once.
- Integration test paid checkout reserves then redeems on webhook.
- Integration test payment failure voids reservation.
- Integration test per-user usage cap.

### Dependencies

- Existing billing module.
- Existing promo entities.
- Existing entitlement service.
- Task 01 for final reconciliation state names, if state changes are shared.

### Out of Scope

- Admin promo UI. That is Task 13.
- Mobile zero-amount UX. That is Task 11.

---

## Task 03: Referral Data Model

### Objective

Create the database and API model foundation for referral codes, referral logs, reward events, audit events, and referral policy configuration without coupling referral state to Doclyzer's existing health/profile records.

### PRD Coverage

- RR-1 through RR-7
- RR-15 through RR-16
- RR-23 through RR-24
- Data model requirements

### Primary Areas

- New referral module
- TypeORM entities/migrations
- Entitlement reason extensions
- Referral policy configuration

Likely paths:

- `apps/api/src/modules/referrals`
- `apps/api/src/modules/entitlements`
- `apps/api/src/database`
- `apps/api/src/users` or auth-adjacent user lifecycle code

### Deliverables

- Add `ReferralsModule`.
- Add referral entities:
  - `user_referral_profiles`
  - `referral_logs`
  - `referral_reward_events`
  - `referral_audit_events`
  - `referral_policy_configs` or generic `system_config`
- Add unique case-insensitive referral code constraint.
- Add indexes for:
  - referral code lookup
  - referrer user id
  - invitee user id
  - reward idempotency key
  - reward status
  - audit event created date
- Add referral code generator.
- Add referral profile creation for existing and new users.
- Add safe backfill behavior for users without referral profiles.
- Add referral policy defaults:
  - invitee verified-email bonus: 5 credits
  - milestone A referrer reward: 5 credits
  - milestone B tier 1 reward: 10 credits
  - milestone B tier 2 reward: 20 credits
  - milestone B tier 3 reward: 30 credits
  - monthly referrer cap: 200 credits
  - zero-amount orders count for milestone B: false
- Add entitlement change reasons:
  - `referral_invitee_bonus`
  - `referral_milestone_a`
  - `referral_milestone_b`
  - `promo_free_credit_pack`
  - `gift_voucher_redeem` if Task 16 is implemented

### Acceptance Criteria

- New users can receive referral profiles with unique referral codes.
- Existing users without referral profiles can be backfilled safely.
- Duplicate referral code generation retries safely.
- Referral policy can be loaded with defaults when no admin config exists.
- Referral reward events have idempotency keys.
- Referral audit events can be written independently from reward release.
- Entitlement reasons compile and are accepted by the credit service.

### Test Notes

- Unit test referral code format and uniqueness retry.
- Migration test constraints and indexes.
- Unit test policy default resolution.
- Unit test entitlement reason support.
- Integration test referral profile creation for a new user.

### Dependencies

- Existing user id model.
- Existing entitlement service.

### Out of Scope

- Applying referral code. That is Task 04.
- Milestone rewards. Those are Tasks 05 and 06.
- Admin review UI. That is Task 14.

---

## Task 04: Referral Apply and Invitee Bonus

### Objective

Allow a new user to apply a referral code during signup or onboarding, hold the invitee reward until email verification, and release the invitee bonus idempotently after verification.

### PRD Coverage

- RR-8 through RR-16
- RR-30 through RR-32
- ER-4, ER-5

### Primary Areas

- Auth/signup flow
- Referral apply endpoint
- Email verification hook or polling-safe release service
- Entitlement credit grant
- Referral emails/push events

Likely paths:

- `apps/api/src/modules/referrals`
- `apps/api/src/auth` or current auth module path
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

### Deliverables

- Add referral apply service method.
- Add authenticated endpoint to apply a referral code during onboarding.
- Add signup payload support for optional referral code if current auth flow permits it.
- Validate referral code:
  - exists
  - active
  - not user's own code
  - user has not already applied another referral
  - invitee/referrer accounts are eligible
- Create referral log with pending invitee bonus event.
- Mark invalid/self/already-used attempts with clear API errors.
- Hook email verification event to release pending invitee referral bonus.
- If direct verification hook is not available, add an idempotent service called after login/profile refresh when `email_verified` becomes true.
- Grant invitee credits via `EntitlementsService`.
- Write referral audit events for apply, block, and release.
- Enqueue invitee bonus released email.
- Prepare push event dispatch if Task 09 is complete; otherwise no-op safely.

### Acceptance Criteria

- User can apply a valid referral code once.
- User cannot apply their own referral code.
- User cannot apply multiple referral codes.
- Invalid referral code returns a clear error.
- Invitee does not receive credits before email verification.
- Invitee receives credits once after email verification.
- Re-running the verification release path does not duplicate credits.
- Referral log and reward event show the correct pending/released state.

### Test Notes

- Unit test valid referral apply.
- Unit test self-referral rejection.
- Unit test duplicate apply rejection.
- Unit test missing/invalid code.
- Integration test email verification releases invitee bonus once.
- Integration test repeated release call is idempotent.

### Dependencies

- Task 03 referral data model.
- Existing auth/email verification flow.
- Existing entitlement service.
- Task 08 for final email template content, though events can be stubbed first.

### Out of Scope

- Referrer milestone rewards. Those are Tasks 05 and 06.
- Fraud device checks. Those are Task 07 after device token model exists.

---

## Task 05: Referral Milestone A

### Objective

Reward the referrer once when the invitee completes their first successful meaningful Doclyzer product action.

### PRD Coverage

- RR-17 through RR-19
- RR-24 through RR-27
- RR-31 through RR-32

### Primary Areas

- Referral reward service
- Product event hook for report/document analysis completion
- Entitlement credit grant
- Audit and notification events

Likely paths:

- `apps/api/src/modules/referrals`
- Report/document analysis modules
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

### Recommended Milestone Definition

Milestone A should be triggered by the invitee's first successfully processed report/document analysis that consumes or would normally consume credits.

If the product team chooses a different definition, update this task before implementation.

### Deliverables

- Identify the API point where report/document analysis is successfully completed.
- Add a referral milestone A trigger that receives invitee user id and product event metadata.
- Check referral log exists and is eligible.
- Require invitee email verified.
- Ensure milestone A was not previously released.
- Run basic referral block checks.
- Check monthly reward cap.
- Grant referrer credits via `EntitlementsService`.
- Mark reward event released or capped/blocked.
- Mark referral log milestone A released when successful.
- Write audit event.
- Enqueue referrer milestone A email.
- Dispatch push notification if push infrastructure exists.

### Acceptance Criteria

- First eligible successful analysis releases milestone A reward to referrer.
- Repeated analyses do not release milestone A again.
- Unverified invitee does not release milestone A.
- Blocked referral does not release milestone A.
- Monthly cap prevents reward and records capped state.
- Reward event and audit event are created for success, blocked, and capped cases.

### Test Notes

- Unit test milestone A eligibility.
- Unit test duplicate trigger idempotency.
- Unit test unverified invitee behavior.
- Unit test capped reward behavior.
- Integration test first successful analysis grants referrer credits once.

### Dependencies

- Task 03 referral data model.
- Task 04 referral apply and email verification release.
- Product analysis completion event/hook.
- Task 08 email event/template for milestone A.

### Out of Scope

- Milestone B paid purchase reward. That is Task 06.
- Admin manual review tooling. That is Task 14.

---

## Task 06: Referral Milestone B

### Objective

Reward the referrer once when the invitee completes their first paid reconciled purchase, with optional amount-based reward tiers.

### PRD Coverage

- RR-20 through RR-27
- BR-2 through BR-4
- RR-31 through RR-32

### Primary Areas

- Billing reconciliation completion hook
- Referral reward service
- Referral policy tier logic
- Entitlement credit grant
- Audit and notifications

Likely paths:

- `apps/api/src/modules/billing`
- `apps/api/src/modules/referrals`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

### Deliverables

- Add referral milestone B trigger after paid order reconciliation.
- Ensure zero-amount promo-only orders do not count by default.
- Check invitee's first paid reconciled order.
- Calculate tier reward using referral policy.
- Require invitee email verified.
- Ensure milestone B was not previously released.
- Check blocked/review referral state.
- Check monthly reward cap.
- Grant referrer credits via `EntitlementsService`.
- Mark reward event released or capped/blocked.
- Mark referral log milestone B released when successful.
- Write audit event.
- Enqueue referrer milestone B email.
- Dispatch push notification if push infrastructure exists.

### Suggested Tier Inputs

Use order final paid amount and currency. The exact thresholds should live in referral policy config.

Default tier names:

- tier 1
- tier 2
- tier 3

### Acceptance Criteria

- First paid reconciled order releases milestone B reward to referrer.
- Zero-amount promo order does not release milestone B unless policy allows it.
- Duplicate webhook/order reconciliation does not release milestone B twice.
- Reconciled order by a user without referral does nothing safely.
- Monthly cap prevents reward and records capped state.
- Tier reward amount is selected from policy.

### Test Notes

- Unit test tier calculation.
- Unit test zero-amount order exclusion.
- Unit test duplicate webhook/reconciliation idempotency.
- Integration test first paid order grants referrer credits once.
- Integration test second paid order does not grant another milestone B reward.

### Dependencies

- Task 01 billing reconciliation hardening.
- Task 03 referral data model.
- Task 04 referral apply.
- Task 08 email event/template for milestone B.

### Out of Scope

- Admin policy UI. That is Task 14.
- Fraud payment-instrument overlap checks beyond basic eligibility. That is Task 07.

---

## Task 07: Referral Fraud and Admin Review

### Objective

Add referral fraud checks, review states, admin-safe release/block behavior, and audit trails so rewards can be controlled without double-crediting users.

### PRD Coverage

- RR-10 through RR-12
- RR-25 through RR-29
- Business rules

### Primary Areas

- Referral fraud service
- Disposable email domain detection
- Device overlap detection
- Payment fingerprint/signature overlap checks
- Referral review state transitions
- Admin mutation APIs

Likely paths:

- `apps/api/src/modules/referrals`
- `apps/api/src/modules/billing`
- `apps/api/src/modules/notifications` or future push module
- `apps/api/src/database`

### Deliverables

- Add referral fraud evaluation service.
- Add disposable email domain denylist/config.
- Add self-referral and same-normalized-email checks.
- Add same-device or installation-id overlap checks after Task 09 creates device token model.
- Add payment metadata overlap checks where RevenueCat/Google Play payloads expose safe comparable metadata.
- Add referral review statuses:
  - pending
  - released
  - blocked
  - under_review
- Add admin review API endpoints:
  - list review queue
  - get referral detail
  - block referral
  - release eligible held reward
  - mark under review
- Ensure admin release is idempotent.
- Ensure admin release does not bypass monthly cap unless explicitly allowed.
- Ensure every admin action writes audit event.
- Add operational summaries for blocked/capped/review referrals.

### Acceptance Criteria

- Disposable email invitee is blocked or placed under review based on configured policy.
- Same-user and same-email self-referral attempts are blocked.
- Same-device referrals are blocked or placed under review after device data exists.
- Admin can block a referral and future rewards will not release automatically.
- Admin can release an eligible held reward once.
- Admin repeated release action does not duplicate credits.
- Audit history shows fraud decision, admin actor, reason, and timestamp.

### Test Notes

- Unit test disposable domain detection.
- Unit test normalized email matching.
- Unit test admin block transition.
- Unit test admin release idempotency.
- Integration test blocked referral prevents milestone A and B.
- Authorization test non-superadmin cannot mutate review status.

### Dependencies

- Task 03 referral data model.
- Task 04 referral apply.
- Task 05 and Task 06 reward flows.
- Task 09 for device overlap checks.

### Out of Scope

- Superadmin UI. That is Task 14.

---

## Task 08: Email Template Expansion

### Objective

Add billing, promo, referral, and ops email event types/templates using Doclyzer's existing queued email pipeline.

### PRD Coverage

- ER-1 through ER-8
- BR-11 through BR-13
- RR-32

### Primary Areas

- Notification event types
- Email template registry
- Email templates
- Email queue idempotency
- Email admin compatibility

Likely paths:

- `apps/api/src/common/notification-pipeline`
- `apps/api/src/common/email-delivery`
- `apps/api/src/email/templates`
- `apps/api/src/modules/email-admin`

### Deliverables

- Add event types:
  - `billing.credit_pack.receipt`
  - `billing.order.failed`
  - `billing.order.pending_review`
  - `billing.low_credit`
  - `promo.free_checkout.receipt`
  - `referral.invitee_bonus.released`
  - `referral.milestone_a.released`
  - `referral.milestone_b.released`
  - `referral.reward.blocked`
  - `referral.reward.capped`
  - `ops.webhook_signature_failure`
  - `ops.payment_amount_mismatch`
  - `ops.credit_override`
- Add templates for each user-facing and ops-facing email.
- Register templates in the existing registry.
- Define required payload schemas for each template.
- Add idempotency key generation conventions:
  - order id for billing receipt
  - order id plus failure type for billing failed/review alerts
  - referral reward event id for referral reward emails
  - provider event id or digest for webhook ops alerts
  - credit adjustment id for manual override alerts
- Ensure missing recipient is handled gracefully.
- Ensure sensitive data is not rendered in templates.

### Acceptance Criteria

- Billing receipt email queues after successful credit purchase.
- Zero-amount promo receipt email queues after free checkout.
- Invitee bonus email queues after verified-email bonus release.
- Referrer reward emails queue after milestone A and milestone B release.
- Ops alert email queues for invalid webhook signature and payment mismatch.
- Duplicate event dispatch with the same idempotency key does not enqueue duplicate email.
- Email admin pages/API can still list new email types.

### Test Notes

- Unit test template registry entries.
- Unit test payload rendering for each template.
- Unit test idempotency key behavior.
- Integration test queue item created from billing/referral events.
- Snapshot or golden tests for template output if existing test style supports it.

### Dependencies

- Can start independently with event stubs.
- Task 01, Task 02, Task 04, Task 05, and Task 06 will use these events.

### Out of Scope

- Push notifications. That is Task 09.
- Superadmin notification UI. That is Task 15.

---

## Task 09: Push Notification Infrastructure

### Objective

Add device token registration, push preferences, push delivery abstraction, delivery audit, and admin broadcast foundations for mobile notifications.

### PRD Coverage

- NR-1 through NR-12
- MR-9 through MR-11
- SR-7

### Primary Areas

- Push notification module
- Device token persistence
- User notification preferences
- Push provider abstraction
- Push delivery/audit records

Likely paths:

- `apps/api/src/modules/notifications`
- `apps/api/src/common/notification-pipeline`
- `apps/api/src/database`
- `apps/api/src/modules/users`

### Deliverables

- Add `user_device_tokens` entity/migration.
- Store token hash for lookup/deduplication.
- Store encrypted provider token or use the existing security pattern for sensitive values.
- Track:
  - user id
  - platform
  - provider
  - app version
  - installation id
  - preferences
  - active flag
  - last seen timestamp
  - metadata
- Add `push_send_audit` entity/migration.
- Add device token endpoints:
  - register/upsert token
  - update preferences
  - deactivate token
  - track push open
- Add push provider interface.
- Add mock provider for local/dev.
- Add FCM provider implementation or adapter shell, depending on credential availability.
- Add preference checks before non-critical sends.
- Add deep-link payload support.
- Add admin dry-run and live broadcast APIs.

### Acceptance Criteria

- Mobile can register a device token.
- Registering the same token updates last seen instead of duplicating active records.
- Mobile can deactivate a token on logout.
- User preferences are persisted and respected.
- Push send creates delivery/audit rows.
- Dry-run broadcast returns target count without sending.
- Live broadcast sends or records attempted sends.
- Push open tracking records user/device/event metadata.

### Test Notes

- Unit test token hash/deduplication.
- Unit test preference filtering.
- Unit test mock provider send result handling.
- Integration test register/update/deactivate token endpoints.
- Authorization test user cannot mutate another user's token.
- Admin authorization test broadcast endpoints.

### Dependencies

- Existing user auth.
- Optional FCM/APNS credentials for production delivery.

### Out of Scope

- Flutter token registration UI/code. That is Task 12.
- Superadmin notification page. That is Task 15.

---

## Task 10: Mobile Referral Experience

### Objective

Add mobile screens and API integration for referral dashboard, sharing, referral progress, referral code entry, and referral deep-link handling.

### PRD Coverage

- MR-1 through MR-5
- MR-12
- RR-30 through RR-32

### Primary Areas

- Flutter referral feature
- Auth/signup referral code capture
- Referral API repository
- Share/copy actions
- Deep links

Likely paths:

- `apps/mobile/lib/features/referrals`
- `apps/mobile/lib/features/auth`
- `apps/mobile/lib/features/billing`
- `apps/mobile/lib/core/router` or current navigation path

### Deliverables

- Add referral API repository.
- Add referral models:
  - referral status
  - referral policy summary
  - referral progress item
  - referred friend timeline
  - reward outcome
- Add referral dashboard screen.
- Show:
  - referral code
  - share link
  - copy action
  - share action using `share_plus`
  - total referred
  - credits earned
  - pending rewards
  - review/blocked state when relevant
- Add referral progress screen.
- Show timeline stages:
  - signed up
  - email verified
  - milestone A completed
  - first paid purchase completed
  - reward released/capped/blocked/under review
- Add referral code entry during signup or post-signup onboarding.
- Add manual referral code apply screen if signup payload integration is risky.
- Add deep-link parsing for referral links.
- Refresh entitlement summary after referral reward events.

### Acceptance Criteria

- User can view their referral code and share link.
- User can copy referral code.
- User can share referral link through native share sheet.
- User can enter a referral code during signup/onboarding.
- User sees clear error for invalid/already-used/self referral code.
- Referral progress screen shows referred users and reward states.
- Referral screen updates after pull-to-refresh or app resume.
- Referral reward changes refresh entitlement summary.

### Test Notes

- Widget test referral dashboard loaded state.
- Widget test empty state.
- Widget test error state.
- Widget test progress timeline rendering.
- Repository test API parsing.
- Manual QA for share sheet and deep-link handling.

### Dependencies

- Task 03 referral data model.
- Task 04 referral apply/status endpoints.
- Task 05 and Task 06 for milestone progress.

### Out of Scope

- API referral implementation. Tasks 03 through 07.
- Push token registration. Task 12.

---

## Task 11: Mobile Billing Updates

### Objective

Update the existing Flutter billing checkout to support zero-amount promo checkout, richer order status polling, and clearer pending/reconciled/failed/review states.

### PRD Coverage

- MR-6 through MR-8
- BR-9
- PR-10 through PR-11

### Primary Areas

- Flutter billing repository
- Credit pack list screen
- RevenueCat SDK checkout handling with Google Pay/platform billing
- Order status polling
- Entitlement refresh

Likely paths:

- `apps/mobile/lib/features/billing`
- `apps/mobile/lib/features/entitlements`
- `apps/mobile/lib/core/network`

### Deliverables

- Update billing API models for:
  - zero-amount checkout result
  - payment pending
  - client purchase confirmed
  - webhook pending
  - reconciled/credits added
  - failed
  - pending review
- If API returns zero final amount, skip Google Pay/RevenueCat purchase sheet.
- Show immediate success state for zero-amount promo checkout.
- Poll order status after RevenueCat/Google Pay purchase success until reconciled, failed, or pending review.
- Show clear pending webhook state after client purchase confirmation.
- Show clear failed state and retry guidance.
- Show pending review state for mismatch/security cases.
- Refresh entitlement summary after reconciled or zero-amount success.
- Improve promo validation failure copy for:
  - expired
  - inactive
  - total cap reached
  - per-user cap reached
  - wrong pack or plan
  - minimum amount unmet

### Acceptance Criteria

- Valid zero-amount promo checkout grants credits without opening Google Pay or RevenueCat purchase flow.
- Paid checkout still opens Google Pay/RevenueCat purchase flow normally.
- After RevenueCat/Google Pay purchase success, mobile does not assume credits are added until status confirms.
- User sees pending state while webhook reconciliation is pending.
- User sees updated credits after reconciliation.
- Failed order displays clear failure message.
- Pending review order displays support-oriented message.
- Promo error reasons are user-readable.

### Test Notes

- Widget test zero-amount success path.
- Widget test paid pending/reconciled/failed states.
- Repository test order status parsing.
- Manual QA with RevenueCat sandbox and Google Pay test flow.
- Manual QA duplicate app resume/status refresh.

### Dependencies

- Task 01 order status endpoint.
- Task 02 zero-amount promo API behavior.

### Out of Scope

- Promo admin management. Task 13.
- Referral mobile screens. Task 10.

---

## Task 12: Mobile Notifications

### Objective

Register mobile push tokens, let users manage notification preferences, deactivate tokens on logout, and handle push deep links.

### PRD Coverage

- MR-9 through MR-11
- NR-2 through NR-10

### Primary Areas

- Flutter notification integration
- Push token lifecycle
- Preferences UI
- Deep-link routing

Likely paths:

- `apps/mobile/lib/features/notifications`
- `apps/mobile/lib/features/auth`
- `apps/mobile/lib/core/router`
- platform-specific Android/iOS configuration files

### Deliverables

- Add Firebase Messaging or selected push provider package if not present.
- Configure Android and iOS notification permissions.
- Register push token after login.
- Refresh token when provider token changes.
- Send app version, platform, installation id, and preferences to API.
- Deactivate token on logout.
- Add notification preferences screen or settings section:
  - billing
  - referrals
  - product updates
  - admin announcements
- Handle push open events.
- Route deep links to:
  - billing order status
  - referral dashboard
  - referral progress
- Gracefully handle missing permissions or denied notification permission.

### Acceptance Criteria

- Logged-in mobile user registers a push token.
- Token refresh updates API.
- Logout deactivates token.
- User can update push preferences.
- Denied permission does not break app login or navigation.
- Push open routes to expected screen when payload is valid.
- Push open records event with API when possible.

### Test Notes

- Repository test token register/update/deactivate calls.
- Widget test preferences screen.
- Manual QA notification permission prompt.
- Manual QA Android token registration.
- Manual QA iOS token registration if iOS setup is available.

### Dependencies

- Task 09 push notification API.
- FCM/APNS project credentials for real device testing.

### Out of Scope

- Admin broadcast UI. Task 15.

---

## Task 13: Superadmin Billing and Promo Pages

### Objective

Add superadmin pages for billing order inspection, reconciliation monitoring, manual credit adjustments, promo management, and promo analytics.

### PRD Coverage

- SR-1 through SR-4
- BR-14 through BR-15
- PR-12 through PR-14

### Primary Areas

- Nuxt admin navigation
- Admin API client
- Billing orders page
- Promo manager page
- Promo analytics/export

Likely paths:

- `apps/web/components`
- `apps/web/pages`
- `apps/web/composables`
- `apps/api/src/modules/billing`

### Deliverables

- Add admin navigation items:
  - Billing
  - Promos
- Add billing page with:
  - order list
  - filters by status, date, provider, user, promo code, reconciliation state
  - order detail drawer/page
  - provider ids
  - amount/currency
  - promo usage
  - credit allocation status
  - pending review markers
- Add manual credit adjustment action:
  - required reason
  - confirmation
  - audit event
  - ops notification
- Add promo page with:
  - promo list
  - create form
  - edit form
  - activate/deactivate controls
  - usage cap controls
  - per-user cap controls
  - max discount cap
  - applies-to fields as supported by API
- Add promo analytics view:
  - validations
  - reservations
  - redemptions
  - failed/voided
  - discount issued
  - revenue influenced
  - export link/action if API supports it

### Acceptance Criteria

- Superadmin can view billing orders and filter by common operational fields.
- Superadmin can open order details and inspect reconciliation state.
- Superadmin can perform manual credit adjustment with required reason.
- Manual credit adjustment creates audit and ops notification.
- Superadmin can create and edit promo codes.
- Superadmin can deactivate/reactivate promo codes.
- Superadmin can view promo analytics.
- Non-superadmin users cannot access admin billing/promo operations.

### Test Notes

- Component test page loading and empty states if frontend test setup exists.
- API client test for request/response mapping.
- E2E smoke test admin billing page.
- E2E smoke test promo create/edit/deactivate flow.
- API authorization tests for admin endpoints.

### Dependencies

- Task 01 billing status/review behavior.
- Task 02 promo improvements.
- Task 08 ops/manual credit email template.

### Out of Scope

- Referral admin page. Task 14.
- Notification operations page. Task 15.

---

## Task 14: Superadmin Referral Page

### Objective

Add superadmin referral management covering policy configuration, analytics, review queue, referral details, reward state, and audit timeline.

### PRD Coverage

- SR-5 through SR-6
- RR-23 through RR-29
- RR-31

### Primary Areas

- Nuxt admin referral page
- Admin referral API endpoints
- Policy editor
- Review queue
- Audit timeline

Likely paths:

- `apps/web/pages`
- `apps/web/components`
- `apps/web/composables`
- `apps/api/src/modules/referrals`

### Deliverables

- Add Referrals nav item.
- Add referral analytics cards:
  - total referral codes
  - applied referrals
  - verified invitees
  - milestone A rewards
  - milestone B rewards
  - blocked rewards
  - capped rewards
  - pending review count
  - credits issued
- Add referral policy editor:
  - invitee bonus credits
  - milestone A credits
  - milestone B tier credits
  - tier thresholds
  - monthly cap
  - zero-amount order eligibility
- Add review queue table:
  - referrer
  - invitee
  - status
  - review status
  - fraud flags
  - reward state
  - created date
- Add referral detail view:
  - referral log
  - reward events
  - invitee timeline
  - billing/order references for milestone B
  - audit timeline
- Add actions:
  - block referral
  - mark under review
  - release eligible reward
- Require reason for block/release actions.

### Acceptance Criteria

- Superadmin can view referral analytics.
- Superadmin can update referral policy.
- Superadmin can filter review queue.
- Superadmin can inspect referral detail and audit timeline.
- Superadmin can block referral with reason.
- Superadmin can release eligible held reward once.
- Repeating release action does not duplicate credits.
- Non-superadmin cannot access referral admin operations.

### Test Notes

- Component test policy editor validation.
- Component test review queue empty/loading/error states.
- API authorization tests.
- Integration test admin release endpoint idempotency.
- E2E smoke test policy update and referral review action.

### Dependencies

- Task 03 referral data model.
- Task 07 fraud/review APIs.
- Task 08 referral email templates.

### Out of Scope

- Mobile referral screens. Task 10.

---

## Task 15: Superadmin Notification Operations

### Objective

Add superadmin notification operations for email delivery inspection, queue health, push send audit, push metrics, and dry-run/live broadcast.

### PRD Coverage

- SR-7
- ER-7
- NR-11 through NR-12

### Primary Areas

- Nuxt admin notification page
- Email admin API integration
- Push admin API integration
- Broadcast form
- Delivery metrics

Likely paths:

- `apps/web/pages`
- `apps/web/components`
- `apps/web/composables`
- `apps/api/src/modules/email-admin`
- `apps/api/src/modules/notifications`

### Deliverables

- Add Notifications nav item.
- Add email queue health section:
  - queued
  - processing
  - sent
  - failed
  - suppressed
  - retrying
- Add email delivery table:
  - recipient
  - event type
  - status
  - retry count
  - failure reason
  - created/sent timestamp
- Add push audit table:
  - sender
  - audience
  - title/body summary
  - dry-run/live
  - target count
  - sent count
  - failed count
  - created timestamp
- Add push broadcast form:
  - title
  - body
  - audience filters
  - deep-link target
  - dry-run action
  - live send action
- Add metrics cards:
  - email success rate
  - email failure rate
  - push active tokens
  - push sends
  - push open count if available

### Acceptance Criteria

- Superadmin can inspect email queue and delivery status.
- Superadmin can inspect push send audit.
- Dry-run broadcast shows estimated target count and creates no live push sends.
- Live broadcast sends through push provider or mock provider and records audit.
- Broadcast form validates required title/body fields.
- Non-superadmin cannot send broadcasts.

### Test Notes

- Component test broadcast form validation.
- API client test dry-run/live request mapping.
- Admin authorization tests.
- Manual QA with mock push provider.

### Dependencies

- Existing email admin APIs.
- Task 09 push notification infrastructure.
- Task 08 expanded event types for richer email labels.

### Out of Scope

- Mobile push token registration. Task 12.

---

## Task 16: Optional Gift Voucher Phase

### Objective

Optionally add secure gift voucher functionality after core billing, promo, referral, email, and notification tasks are stable.

### PRD Coverage

- Optional gift voucher scope GV-1 through GV-6

### Primary Areas

- API voucher module
- Admin voucher generation
- Mobile voucher redemption
- Email delivery
- Optional online voucher purchase flow

Likely paths:

- `apps/api/src/modules/gift-vouchers`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`
- `apps/mobile/lib/features/gift_vouchers`
- `apps/web/pages`

### Deliverables

- Add secure voucher entities:
  - voucher
  - voucher event
  - optional voucher order if online purchase is implemented
- Store voucher code hash for lookup.
- Show plaintext voucher code only at creation time.
- Add voucher statuses:
  - active
  - redeemed
  - voided
  - expired
- Add admin voucher generation.
- Add admin voucher voiding.
- Add admin expiry update.
- Add voucher redemption endpoint.
- Add mobile voucher redemption screen.
- Grant credits through `EntitlementsService`.
- Add voucher email templates if delivery/resend is supported.
- Add voucher audit events.

### Acceptance Criteria

- Superadmin can generate a voucher and see plaintext code once.
- Voucher lookup uses hash and does not require storing plaintext code.
- User can redeem active voucher once.
- Redeeming voucher grants credits once.
- Expired, voided, or already redeemed voucher cannot be redeemed.
- Admin actions are audited.

### Test Notes

- Unit test voucher code hashing and lookup.
- Unit test redeem idempotency.
- Integration test active voucher redemption grants credits once.
- Integration test expired/voided/redeemed rejection.
- Admin authorization tests.

### Dependencies

- Existing entitlement service.
- Task 08 if voucher emails are required.
- Task 13 or a new admin page task if voucher admin UI is included.

### Out of Scope

- Online purchased gift vouchers by default.
- Scheduled delivery/resend unless explicitly added as a follow-up task.

---

## Cross-Task Dependency Map

- Task 01 enables Task 06, Task 11, and Task 13.
- Task 02 enables Task 11 and Task 13.
- Task 03 enables Task 04, Task 05, Task 06, Task 07, Task 10, and Task 14.
- Task 04 enables Task 05, Task 06, Task 10, and Task 14.
- Task 05 and Task 06 enable complete referral progress in Task 10 and Task 14.
- Task 07 enables admin review behavior in Task 14.
- Task 08 supports notification side effects across Tasks 01, 02, 04, 05, 06, 13, and 16.
- Task 09 enables Task 12 and Task 15, and strengthens fraud detection in Task 07.
- Task 10 depends on referral API readiness.
- Task 11 depends on billing and promo API readiness.
- Task 12 depends on push API readiness.
- Task 13 depends on billing and promo API readiness.
- Task 14 depends on referral API and review readiness.
- Task 15 depends on email admin and push infrastructure.
- Task 16 should start only after the core billing/promo/referral system is stable.

## Suggested Implementation Waves

### Wave 1: API Billing and Promo Foundation

- Task 01: Billing Reconciliation Hardening
- Task 02: Promo Code Parity Improvements
- Task 08: Email Template Expansion, billing/promo/ops subset

### Wave 2: API Referral Foundation

- Task 03: Referral Data Model
- Task 04: Referral Apply and Invitee Bonus
- Task 05: Referral Milestone A
- Task 06: Referral Milestone B
- Task 07: Referral Fraud and Admin Review
- Task 08: Email Template Expansion, referral subset

### Wave 3: Push Foundation

- Task 09: Push Notification Infrastructure
- Task 12: Mobile Notifications
- Task 15: Superadmin Notification Operations

### Wave 4: Mobile Product Surfaces

- Task 10: Mobile Referral Experience
- Task 11: Mobile Billing Updates

### Wave 5: Superadmin Operations

- Task 13: Superadmin Billing and Promo Pages
- Task 14: Superadmin Referral Page
- Task 15: Superadmin Notification Operations

### Wave 6: Optional Expansion

- Task 16: Optional Gift Voucher Phase
