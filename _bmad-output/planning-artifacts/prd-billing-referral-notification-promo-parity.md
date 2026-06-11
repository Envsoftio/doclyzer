# PRD: Billing, Referral, Promo, Email, and Notification Parity

Created: 2026-06-12
Status: Draft
Project: Doclyzer
Reference source: `/Users/vishnu/Work/Server/proctorplus-language-student-platform` read-only analysis

## 1. Purpose

Doclyzer needs a production-ready growth and monetization layer across API, mobile, and superadmin, modeled after the billing, referral, promo code, notification, and email flows in the reference ProctorPlus Language Student Platform.

The implementation should reuse Doclyzer's existing architecture wherever possible:

- NestJS API modules under `apps/api/src/modules`
- Existing billing order, credit pack, promo, subscription, and RevenueCat/Google Pay payment flow
- Existing `user_entitlements.credit_balance` credit ledger behavior
- Existing notification pipeline and email queue
- Flutter mobile billing screens with Google Pay/platform checkout through RevenueCat
- Nuxt superadmin app

The reference project must remain read-only. No files in `/Users/vishnu/Work/Server/proctorplus-language-student-platform` should be changed.

## 2. Reference Flow Summary

The target Doclyzer flow should keep the reference system's billing and growth semantics while using Google Pay and RevenueCat:

- Students buy credit packs through Google Pay/platform checkout managed by RevenueCat.
- Promo codes can reduce pack price by percentage or flat discount.
- Zero-price promo checkouts grant credits immediately without opening Google Pay or RevenueCat purchase flow.
- Client-side RevenueCat purchase confirmation records a pending client-confirmed state.
- Server-side RevenueCat webhook reconciliation is the authoritative credit-granting step.
- Payment events are persisted for idempotency and audit.
- Referral codes are generated per student profile.
- Invitee referral bonus is held until email verification.
- Referrer rewards are released at milestone A and milestone B.
- Milestone A is triggered by the invitee's first meaningful product action.
- Milestone B is triggered by the invitee's first paid purchase.
- Referral rewards are fraud-checked, capped monthly, audited, and admin-reviewable.
- Billing, referral, gift, and ops events send email notifications.
- Push notification delivery is modeled with device tokens, preferences, delivery rows, send audit, and admin broadcast tooling.
- Superadmin can manage coupons, referral policy, referral review, gift cards, recharge packs, manual credit overrides, and notification operations.

## 3. Current Doclyzer Baseline

### 3.1 API

Doclyzer already has a substantial billing foundation:

- `BillingModule` supports credit packs, plans, orders, subscriptions, promo validation, promo management, and promo analytics. Legacy gateway-specific assumptions must be replaced with RevenueCat webhook reconciliation and Google Pay/platform checkout metadata.
- `EntitlementsModule` owns credit balances through `user_entitlements.credit_balance`.
- Credit mutations currently go through `EntitlementsService.addCredits(...)`.
- Promo codes support discount type, value, valid windows, total usage caps, per-user usage caps, analytics, reservations, redemptions, and audit events.
- Email delivery is queued through `NotificationPipelineService`, `email_queue_items`, and the email worker.
- Email admin tooling already exists for delivery history, queue status, and analytics.

Important current gaps:

- No referral model or referral endpoints.
- No referral reward milestones.
- No referral policy management.
- No referral fraud/audit workflow.
- No mobile referral screen.
- No superadmin referral screen.
- No push device token model or push delivery provider.
- Promo checkout does not yet handle zero-final-amount orders cleanly.
- Percentage promos do not appear to support an optional maximum discount cap.
- Billing reconciliation should be hardened with explicit amount/currency mismatch handling and ops alerts.
- Admin web does not yet expose billing, promo, referral, or notification operations as first-class pages.

### 3.2 Mobile

Doclyzer mobile already has:

- Credit pack listing.
- Promo code validation and application for credit packs.
- Planned paid checkout through RevenueCat SDK using Google Pay/platform billing where available.
- Recent order status refresh.
- Plan selection.
- Entitlement summary.
- `share_plus` dependency available.

Important current gaps:

- No referral signup/deep-link capture.
- No referral dashboard or progress page.
- No push token registration or push preferences.
- No zero-amount promo success path in checkout UX.
- No gift/voucher redemption surface.

### 3.3 Superadmin Web

Doclyzer admin web currently has a compact admin shell with pages such as dashboard, users, files, and risk.

Important current gaps:

- No billing operations page.
- No promo manager page.
- No referral policy/review/analytics page.
- No notification operations page.
- No push broadcast/audit page.

## 4. Goals

1. Add a referral growth system that rewards verified, non-fraudulent users and referrers.
2. Harden billing and promo flows to support free promo checkouts, better reconciliation, and admin visibility.
3. Extend email notifications for billing, promo, referral, and ops events using Doclyzer's existing email queue.
4. Add push notification infrastructure for mobile device tokens, preferences, referral/billing pushes, and superadmin broadcasts.
5. Build mobile screens for referrals, promo-aware billing, notification preferences, and related deep links.
6. Build superadmin pages for billing operations, promo management, referral management, and notification operations.
7. Preserve auditability and idempotency for all money, credit, reward, and notification flows.

## 5. Non-Goals

- Do not rewrite the existing billing module from scratch.
- Do not replace the current email queue with the reference project's immediate email orchestrator.
- Do not store gift, voucher, promo, or referral secret codes only in plaintext.
- Do not credit users from client-side purchase confirmation alone.
- Do not modify the reference ProctorPlus project.
- Do not build every feature in one implementation task; this PRD is intended to be split into smaller tasks.

## 6. Users and Actors

### Mobile User

A Doclyzer user who buys credits, applies promo codes, invites friends, receives referral rewards, and receives billing/referral notifications.

### Referred User

A new user who signs up using a referral code or referral link and can earn an invitee bonus after email verification.

### Superadmin

An internal operator who manages billing plans/packs, promo codes, referral policies, referral reviews, credit overrides, notification delivery, and operational audits.

### System

The API, workers, RevenueCat webhook handler, email queue, push provider, and scheduled jobs that perform idempotent credit, notification, and reward operations.

## 7. Functional Requirements

### 7.1 Billing and Credit Purchase

BR-1: The existing credit pack order flow must remain the primary purchase path.

BR-2: The API must treat RevenueCat webhooks as the authoritative source for paid credit allocation.

BR-3: Client-side purchase confirmation from the RevenueCat SDK must only move the order into a client-confirmed pending state until webhook reconciliation completes.

BR-4: The webhook handler must be idempotent. Repeated RevenueCat events for the same purchase/order must not grant credits more than once.

BR-5: The webhook handler must validate expected amount and currency against the stored order before granting credits.

BR-6: Amount or currency mismatch must mark the order for review, avoid credit allocation, persist an audit event, and enqueue an ops alert email.

BR-7: Invalid RevenueCat webhook authorization or signature checks must be persisted as security/audit events where possible and must enqueue an ops alert email.

BR-8: Payment failure events must mark orders failed, release or void promo reservations, and expose a useful failure reason to mobile.

BR-9: The API must expose an order status endpoint that mobile can poll after Google Pay/RevenueCat checkout.

BR-10: Credit allocation must continue to use `EntitlementsService.addCredits(...)` or a compatible ledger-safe service.

BR-11: Credit purchase completion must enqueue a billing receipt email.

BR-12: Billing receipt emails must include pack name, credits purchased, amount paid, currency, order reference, promo savings if any, and resulting status.

BR-13: Low credit notifications should be sent when a user's balance falls below configurable thresholds.

BR-14: Superadmin must be able to view orders by status, RevenueCat/Google Play payment identifiers, date range, user, promo code, and reconciliation state.

BR-15: Superadmin must be able to perform manual credit adjustments with reason, metadata, audit logging, and ops notification.

### 7.2 Promo Codes

PR-1: Doclyzer's existing promo code model should be retained and extended rather than replaced.

PR-2: Promo validation must return original amount, discount amount, final amount, currency, promo code id, human-readable label, and validation failure reason when invalid.

PR-3: Percentage promo codes should support an optional maximum discount amount.

PR-4: Promo codes must support total usage cap and per-user usage cap.

PR-5: Promo validation must not consume usage.

PR-6: Promo reservation during order creation must be idempotent per user/order.

PR-7: Promo redemption must only be finalized after successful order reconciliation or successful zero-amount promo checkout.

PR-8: Promo reservation must be released or voided when an order fails, expires, or is abandoned after a configured timeout.

PR-9: If a promo reduces the final credit pack amount to zero, the API must not start a Google Pay or RevenueCat purchase.

PR-10: Zero-amount promo checkout must create an auditable internal order, mark promo redemption as redeemed, grant credits immediately, and enqueue a billing/promo receipt email.

PR-11: Mobile must present zero-amount promo checkout as an immediate success flow with no Google Pay or RevenueCat purchase sheet.

PR-12: Superadmin must be able to create, edit, deactivate, reactivate, and inspect promo codes.

PR-13: Superadmin promo analytics must show validation count, reservation count, redemption count, failed/voided count, discount issued, revenue influenced, and per-code usage.

PR-14: Promo CSV export should remain available or be added to the admin UI if the API already supports it.

### 7.3 Referral System

RR-1: Each eligible user must have a stable referral code.

RR-2: Referral codes must be unique, case-insensitive, human-readable, and safe to share.

RR-3: The referral system should use dedicated tables instead of overloading Doclyzer's existing health/profile records.

Recommended entities:

- `user_referral_profiles`
- `referral_logs`
- `referral_reward_events`
- `referral_audit_events`
- `referral_policy_configs` or a generic `system_config`

RR-4: Referral profile must include user id, referral code, referred-by user id, created timestamp, and metadata.

RR-5: Referral log must connect referrer user id, invitee user id, referral code, status, review status, fraud flags, milestone flags, and timestamps.

RR-6: Referral reward events must record reward type, beneficiary user id, referrer user id, invitee user id, credit amount, status, block/cap reason, and metadata.

RR-7: Referral audit events must record important state changes, admin actions, fraud decisions, reward releases, and reward blocks.

RR-8: Mobile signup must accept an optional referral code.

RR-9: Referral link handling should support both manual code entry and a shared link that opens the app or signup page with the code prefilled.

RR-10: A user must not be able to refer themselves.

RR-11: A user must not be able to apply more than one referral.

RR-12: A referral must not grant invitee credits until the invitee's email is verified.

RR-13: When email verification is detected, the API must release the pending invitee bonus if the referral is still valid.

RR-14: Invitee bonus release must be idempotent.

RR-15: Referral reward credit grants must use `EntitlementsService.addCredits(...)` with referral-specific reasons.

RR-16: Add entitlement reasons for:

- `referral_invitee_bonus`
- `referral_milestone_a`
- `referral_milestone_b`
- `promo_free_credit_pack`
- `gift_voucher_redeem` if vouchers are implemented

RR-17: Milestone A should be adapted to Doclyzer as the invitee's first successful meaningful product action.

Recommended Doclyzer milestone A definition:

- First successfully processed report/document analysis that consumes or would normally consume credits.

RR-18: Milestone A must only reward the referrer if the invitee email is verified and the referral log is not blocked.

RR-19: Milestone A must be idempotent and must not reward multiple times for repeated uploads/retries.

RR-20: Milestone B should be the invitee's first reconciled paid purchase.

RR-21: Milestone B must not be awarded for zero-amount promo-only orders unless explicitly configured by referral policy.

RR-22: Milestone B reward amount may be tiered by first paid order amount and currency.

RR-23: Referral policy must be configurable by superadmin.

Recommended default policy:

- Invitee verified-email bonus: 5 credits
- Milestone A referrer reward: 5 credits
- Milestone B tier 1 referrer reward: 10 credits
- Milestone B tier 2 referrer reward: 20 credits
- Milestone B tier 3 referrer reward: 30 credits
- Monthly referrer cap: 200 credits
- Zero-amount orders count for milestone B: false

RR-24: Monthly cap calculation must count released milestone rewards within the current calendar month.

RR-25: If a reward would exceed the monthly cap, the reward must be marked capped, audited, and not granted.

RR-26: Referral fraud checks must block or flag suspicious cases before releasing rewards.

Required fraud checks:

- self-referral by same user id
- same email or same normalized email where applicable
- disposable email domain
- same device installation id after push/device registration exists
- same RevenueCat app user id, Google Play purchase token, or safe payment metadata where RevenueCat/Google Play payloads allow
- repeated invitees from a blocked domain or blocked device cluster

RR-27: Fraud decisions must be auditable and admin-reviewable.

RR-28: Superadmin must be able to release, block, or mark a referral for review.

RR-29: Admin release of a previously held reward must be idempotent and must not double-credit users.

RR-30: Mobile must show referral code, share link, total referred, credits earned, pending rewards, blocked/review state, and referred friend progress.

RR-31: Referral progress must expose a timeline per invitee:

- signed up
- email verified
- milestone A completed
- first paid purchase completed
- reward released, capped, blocked, or under review

RR-32: Referral applied and referral reward events must enqueue emails and push notifications.

### 7.4 Email Notifications

ER-1: Use Doclyzer's existing queued email architecture.

ER-2: New notification event types must be added for billing, promo, referral, and ops alerts.

Recommended event types:

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

ER-3: Email templates must be added to `apps/api/src/email/templates` and registered in the email template registry.

ER-4: Referral emails must be sent to the correct party:

- Invitee gets invitee bonus release email.
- Referrer gets milestone reward emails.
- Ops/admin gets fraud, payment mismatch, signature failure, and manual credit override alerts.

ER-5: Email queue idempotency keys must be set for referral and billing events so retries or duplicate webhooks do not enqueue duplicate user emails.

ER-6: If recipient email is missing, notification dispatch must be suppressed or failed gracefully with an audit trail.

ER-7: Superadmin notification views must display queued, sent, failed, suppressed, and retried emails.

ER-8: Email templates must avoid exposing sensitive provider payloads, raw signatures, or secret codes.

### 7.5 Push Notifications

NR-1: Add a push notification module or submodule.

NR-2: Add `user_device_tokens` table with user id, token, platform, provider, app version, installation id, preferences, last seen timestamp, active flag, and metadata.

NR-3: Add `push_send_audit` table for admin broadcasts and system sends.

NR-4: Reuse or extend the notification delivery model so push sends have delivery records.

NR-5: Mobile must register device token on login and refresh it when the provider token changes.

NR-6: Mobile must deactivate device token on logout.

NR-7: Mobile must expose notification preferences for at least billing, referrals, product updates, and admin announcements.

NR-8: Push sends must respect user preferences unless the event is operationally critical.

NR-9: Initial provider should support Firebase Cloud Messaging for Android and iOS, with local/dev mock mode available.

NR-10: Push notifications must support deep-link payloads for billing order status, referral dashboard, and referral progress.

NR-11: Superadmin must be able to send dry-run and live push broadcasts to filtered audiences.

NR-12: Superadmin must be able to inspect push send audit, delivery summary, and basic metrics.

### 7.6 Mobile App Requirements

MR-1: Add referral dashboard screen.

MR-2: Referral dashboard must show referral code, share link, copy action, share action, earned credits, pending rewards, and referred friends.

MR-3: Add referral progress screen with invitee timeline and reward outcomes.

MR-4: Add referral code entry during signup or immediately after account creation.

MR-5: Add deep-link handling for referral links.

MR-6: Update credit pack checkout to support zero-amount promo success without opening Google Pay or RevenueCat purchase flow.

MR-7: Update checkout status handling to show:

- payment pending
- client purchase confirmed
- webhook pending
- reconciled/credits added
- failed
- pending review

MR-8: Add user-facing messaging when promo validation fails due to expiry, usage cap, per-user cap, wrong pack, inactive code, or minimum amount.

MR-9: Add notification token registration, refresh, and logout deactivation.

MR-10: Add notification preferences screen or section.

MR-11: Push opens should route users to the correct billing or referral screen.

MR-12: Referral and billing screens must refresh entitlement summary after reward or purchase completion.

### 7.7 Superadmin Requirements

SR-1: Add admin navigation entries for Billing, Promos, Referrals, and Notifications.

SR-2: Billing page must show order list, filters, order details, reconciliation state, RevenueCat event ids, Google Play purchase tokens, promo usage, and credit allocation status.

SR-3: Billing page must allow manual credit adjustment with required reason and confirmation.

SR-4: Promo page must show promo list, create/edit form, activation controls, usage caps, max discount cap, analytics, and export.

SR-5: Referral page must show policy config, referral analytics, reward events, blocked/review queue, and audit timeline.

SR-6: Referral page must allow superadmin to block, release, or mark referrals for review.

SR-7: Notifications page must show email queue health, delivery events, failure reasons, push send audit, and push broadcast controls.

SR-8: All superadmin mutation endpoints must require superadmin authorization.

SR-9: All superadmin financial or reward mutations must create audit events.

SR-10: Admin UI must avoid showing raw webhook secrets, SMTP secrets, device tokens, or sensitive payment payloads.

## 8. Optional Gift Voucher Scope

The reference project includes gift cards as part of the billing/marketing system. Doclyzer can implement this as a later phase if needed.

GV-1: Add admin-generated gift vouchers for credits.

GV-2: Store voucher code hashes for lookup and only show the plaintext code once at creation.

GV-3: Add voucher events for generated, delivered, redeemed, voided, expired, and resent.

GV-4: Add mobile voucher redemption.

GV-5: Add superadmin voucher generation, expiry updates, voiding, resend, and analytics.

GV-6: Online purchased gift vouchers should be a separate later task because they require public checkout, recipient delivery, purchaser confirmation, and stricter fraud/rate-limit handling.

## 9. API Endpoint Requirements

Exact route names can follow existing Doclyzer conventions, but the following capabilities are required.

### Billing

- `GET /billing/credit-packs`
- `POST /billing/orders`
- `POST /billing/orders/client-confirmation`
- `GET /billing/orders/:orderId/status`
- `GET /billing/orders`
- `POST /billing/webhook/revenuecat`
- `POST /billing/promo/validate`

### Referral

- `GET /referrals/status`
- `GET /referrals/progress`
- `POST /referrals/apply`
- `POST /referrals/share-event` if share analytics are needed

### Mobile Notifications

- `POST /notifications/device-tokens`
- `PATCH /notifications/device-tokens/:id/preferences`
- `DELETE /notifications/device-tokens/:id`
- `POST /notifications/push-open`

### Superadmin Billing and Promo

- `GET /admin/billing/orders`
- `GET /admin/billing/orders/:id`
- `PATCH /admin/users/:userId/credits`
- `GET /admin/promos`
- `POST /admin/promos`
- `PATCH /admin/promos/:id`
- `GET /admin/promo-analytics`
- `GET /admin/promo-analytics/export`

### Superadmin Referral

- `GET /admin/referrals/policy`
- `PUT /admin/referrals/policy`
- `GET /admin/referrals`
- `GET /admin/referrals/:id`
- `PATCH /admin/referrals/:id/review`
- `GET /admin/referrals/analytics`

### Superadmin Notifications

- `GET /admin/notifications/email/queue`
- `GET /admin/notifications/email/deliveries`
- `GET /admin/notifications/push/audit`
- `POST /admin/notifications/push/dry-run`
- `POST /admin/notifications/push/send`
- `GET /admin/notifications/metrics`

## 10. Data Model Requirements

### 10.1 Existing Tables to Reuse

- `users`
- `user_entitlements`
- `credit_pack`
- `orders`
- `promo_codes`
- `promo_redemptions`
- `promo_code_audit_events`
- `email_queue_items`
- `email_delivery_events`

### 10.2 Existing Tables to Extend

`orders` should support:

- client-confirmed pending state
- pending review state
- amount/currency mismatch metadata
- final amount after promo
- RevenueCat event ids, app user ids, Google Play purchase tokens, and product identifiers
- zero-amount internal checkout marker

`promo_codes` should support:

- optional maximum discount amount for percentage discounts

`email_queue_items` should use:

- idempotency key for billing/referral/ops event families

### 10.3 New Tables

`user_referral_profiles`

- id
- user_id
- referral_code
- referred_by_user_id
- created_at
- updated_at
- metadata

`referral_logs`

- id
- referrer_user_id
- invitee_user_id
- referral_code
- status
- review_status
- invitee_bonus_released
- milestone_a_released
- milestone_b_released
- fraud_flags
- blocked_reason
- created_at
- updated_at
- metadata

`referral_reward_events`

- id
- referral_log_id
- reward_type
- beneficiary_user_id
- referrer_user_id
- invitee_user_id
- credit_amount
- status
- reason
- idempotency_key
- created_at
- released_at
- metadata

`referral_audit_events`

- id
- referral_log_id
- actor_user_id
- actor_type
- event_type
- reason
- metadata
- created_at

`referral_policy_configs` or `system_config`

- key
- value
- description
- updated_by
- updated_at

`user_device_tokens`

- id
- user_id
- token_hash
- encrypted_token or provider token storage based on security design
- platform
- provider
- app_version
- installation_id
- preferences
- is_active
- last_seen_at
- created_at
- updated_at
- metadata

`push_send_audit`

- id
- sender_user_id
- audience_filter
- title
- body
- dry_run
- target_count
- sent_count
- failed_count
- created_at
- metadata

## 11. Business Rules

1. Credits must never be granted twice for the same order, referral reward, promo checkout, or voucher redemption.
2. Paid credits must only be granted after trusted server-side reconciliation.
3. Zero-amount promo credits may be granted immediately because there is no external payment capture.
4. Referral invitee bonus must wait for email verification.
5. Referrer milestone rewards require a valid referral, verified invitee email, no blocking fraud decision, and available monthly cap.
6. Referral milestone B should require a paid reconciled order by default.
7. Admin manual credits require a reason and must notify ops.
8. Promo usage must be counted only after successful redemption, not validation.
9. Push and email delivery must be best-effort but auditable.
10. Sensitive provider secrets, raw tokens, and signatures must not be exposed in admin UI or user APIs.

## 12. Acceptance Criteria

### Billing

- A user can buy a credit pack with Google Pay/RevenueCat and receives credits exactly once after RevenueCat webhook reconciliation.
- Duplicate webhook events do not duplicate credits.
- Amount/currency mismatch prevents credit allocation and appears in admin review.
- Invalid RevenueCat webhook authorization/signature creates an ops alert.
- A failed payment releases or voids promo reservation.

### Promo

- A valid promo displays correct savings before checkout.
- Expired, inactive, capped, and per-user-capped promos return clear failure reasons.
- A zero-amount promo checkout grants credits without opening Google Pay or RevenueCat purchase flow.
- Promo redemption analytics distinguish validation, reservation, redemption, failure, and void events.

### Referral

- Every eligible user has a referral code.
- A new user can apply a referral code at signup.
- Invitee bonus is released only after email verification.
- Referrer milestone A is released once after the invitee's first successful report/document analysis.
- Referrer milestone B is released once after the invitee's first paid reconciled order.
- Blocked, capped, or under-review referrals do not grant credits automatically.
- Referral progress screen accurately shows each invitee's stage and reward state.

### Email and Push

- Billing receipt, promo free checkout, referral applied, referral reward, and ops alert emails are queued with idempotency keys.
- Email delivery history is visible to superadmin.
- Mobile registers and deactivates push tokens.
- Push preferences are respected.
- Admin dry-run push does not send real pushes.
- Admin live push creates push audit records.

### Superadmin

- Superadmin can manage promo codes and view analytics.
- Superadmin can inspect billing orders and reconciliation state.
- Superadmin can adjust credits with audit and ops notification.
- Superadmin can configure referral policy.
- Superadmin can release or block referrals with audit history.
- Superadmin can inspect notification delivery and send push broadcasts.

## 13. Suggested Implementation Tasks

Task 1: Billing reconciliation hardening

- Add verified pending and pending review states if missing.
- Add amount/currency mismatch handling.
- Add ops alert events for invalid signatures and mismatches.
- Add order status endpoint for mobile polling.

Task 2: Promo parity improvements

- Add maximum discount cap for percentage promos.
- Add zero-amount promo checkout path.
- Add tests for validation, reservation, redemption, void, and zero-amount checkout.

Task 3: Referral data model

- Add referral profile, referral log, reward event, audit event, and policy config migrations/entities.
- Add referral code generation and uniqueness handling.

Task 4: Referral apply and invitee bonus

- Accept referral code at signup/onboarding.
- Hold invitee reward until email verification.
- Release invitee bonus idempotently.
- Send referral applied email/push.

Task 5: Referral milestone A

- Define and hook into first successful Doclyzer report/document analysis.
- Release or block referrer milestone A reward.
- Add audit and notifications.

Task 6: Referral milestone B

- Hook into first paid reconciled order.
- Add amount-tier reward policy.
- Add monthly cap behavior.
- Add audit and notifications.

Task 7: Referral fraud and admin review

- Add disposable domain checks.
- Add self-referral checks.
- Add device installation overlap checks after device token model exists.
- Add admin review actions and retro-release safety.

Task 8: Email template expansion

- Add billing, promo, referral, and ops templates.
- Register templates.
- Add idempotency keys for new notification families.

Task 9: Push notification infrastructure

- Add device token endpoints.
- Add push provider abstraction.
- Add delivery/audit records.
- Add dev mock mode and FCM mode.

Task 10: Mobile referral experience

- Add referral repository and models.
- Add referral dashboard.
- Add referral progress screen.
- Add share/copy/deep-link support.

Task 11: Mobile billing updates

- Add zero-amount promo checkout success flow.
- Add order status polling.
- Improve pending/reconciled/failed/pending-review states.

Task 12: Mobile notifications

- Register push token.
- Add notification preferences.
- Handle push opens and deep links.

Task 13: Superadmin billing and promo pages

- Add admin nav items.
- Build billing orders/reconciliation page.
- Build promo manager and analytics page.

Task 14: Superadmin referral page

- Build referral policy editor.
- Build referral analytics.
- Build review queue and audit timeline.

Task 15: Superadmin notification operations

- Build email delivery/queue page.
- Build push dry-run/live broadcast page.
- Build notification metrics page.

Task 16: Optional gift voucher phase

- Add secure voucher model with hashed code lookup.
- Add mobile redemption.
- Add admin generation/voiding/analytics.
- Consider online purchased vouchers as a separate later phase.

## 14. Risks and Open Questions

1. Milestone A needs final product confirmation. This PRD recommends first successful report/document analysis.
2. Push provider credentials and platform setup need confirmation before FCM/APNS production delivery.
3. Referral link domain and deep-link strategy need confirmation.
4. Existing admin API route conventions should be confirmed before final endpoint naming.
5. Existing billing order states may need a migration strategy that does not break historical orders.
6. Promo reservation timeout behavior needs either a scheduled cleanup job or opportunistic cleanup.
7. Gift vouchers are useful but should remain optional until core referral and promo flows are complete.

## 15. Implementation Principles

- Prefer adapting Doclyzer's current modules over copying reference code directly.
- Keep money and credit changes transactional.
- Use idempotency keys for every external callback and reward release.
- Keep user-facing mobile flows simple, but keep admin audit detail rich.
- Store secrets and tokens securely.
- Build in small vertical slices that can be tested independently.
