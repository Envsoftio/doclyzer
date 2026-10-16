# Billing, Referral, Promo, Email, and Notification Task Pack

Created: 2026-06-12
Status: Draft

## Purpose

This folder contains implementation tasks for billing, referrals, promos, email, and notifications. Each task can be picked up individually, following the dependency map below.

## Global Definition of Done

Each implementation task should meet these standards unless its file says otherwise:

- Follow existing Doclyzer NestJS, Flutter, and Nuxt patterns.
- Add migrations and entity/model changes for database work.
- Keep billing, promo, referral, reward, and notification side effects idempotent.
- Route all user credit changes through `EntitlementsService` or an equivalent ledger-safe path.
- Create audit records for admin financial, billing, promo, and reward mutations.
- Use idempotency keys for duplicate-prone email, push, webhook, and reward flows.
- Cover success, duplicate retry, failure, and authorization behavior in tests where applicable.
- Do not change files in `/Users/vishnu/Work/Server/proctorplus-language-student-platform`.

## Task Files

| Task | Name | File |
| --- | --- | --- |
| 01 | Billing Reconciliation Hardening | [01-billing-reconciliation-hardening.md](01-billing-reconciliation-hardening.md) |
| 02 | Promo Code Parity Improvements | [02-promo-code-parity-improvements.md](02-promo-code-parity-improvements.md) |
| 03 | Referral Data Model | [03-referral-data-model.md](03-referral-data-model.md) |
| 04 | Referral Apply and Invitee Bonus | [04-referral-apply-and-invitee-bonus.md](04-referral-apply-and-invitee-bonus.md) |
| 05 | Referral Milestone A | [05-referral-milestone-a.md](05-referral-milestone-a.md) |
| 06 | Referral Milestone B | [06-referral-milestone-b.md](06-referral-milestone-b.md) |
| 07 | Referral Fraud and Admin Review | [07-referral-fraud-and-admin-review.md](07-referral-fraud-and-admin-review.md) |
| 08 | Email Template Expansion | [08-email-template-expansion.md](08-email-template-expansion.md) |
| 09 | Push Notification Infrastructure | [09-push-notification-infrastructure.md](09-push-notification-infrastructure.md) |
| 10 | Mobile Referral Experience | [10-mobile-referral-experience.md](10-mobile-referral-experience.md) |
| 11 | Mobile Billing Updates | [11-mobile-billing-updates.md](11-mobile-billing-updates.md) |
| 12 | Mobile Notifications | [12-mobile-notifications.md](12-mobile-notifications.md) |
| 13 | Superadmin Billing and Promo Pages | [13-superadmin-billing-and-promo-pages.md](13-superadmin-billing-and-promo-pages.md) |
| 14 | Superadmin Referral Page | [14-superadmin-referral-page.md](14-superadmin-referral-page.md) |
| 15 | Superadmin Notification Operations | [15-superadmin-notification-operations.md](15-superadmin-notification-operations.md) |
| 16 | Optional Gift Voucher Phase | [16-optional-gift-voucher-phase.md](16-optional-gift-voucher-phase.md) |

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
- Task 16 should start only after the core billing, promo, and referral system is stable.

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

