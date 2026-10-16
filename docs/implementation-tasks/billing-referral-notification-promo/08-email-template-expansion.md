# Task 08: Email Template Expansion

## Objective

Add billing, promo, referral, and ops email event types/templates using Doclyzer's existing queued email pipeline.

## PRD Coverage

- ER-1 through ER-8
- BR-11 through BR-13
- RR-32

## Primary Areas

- `apps/api/src/common/notification-pipeline`
- `apps/api/src/common/email-delivery`
- `apps/api/src/email/templates`
- `apps/api/src/modules/email-admin`

## Implementation Checklist

- Add event type `billing.credit_pack.receipt`.
- Add event type `billing.order.failed`.
- Add event type `billing.order.pending_review`.
- Add event type `billing.low_credit`.
- Add event type `promo.free_checkout.receipt`.
- Add event type `referral.invitee_bonus.released`.
- Add event type `referral.milestone_a.released`.
- Add event type `referral.milestone_b.released`.
- Add event type `referral.reward.blocked`.
- Add event type `referral.reward.capped`.
- Add event type `ops.webhook_signature_failure`.
- Add event type `ops.payment_amount_mismatch`.
- Add event type `ops.credit_override`.
- Add user-facing and ops-facing templates.
- Register templates in the existing registry.
- Define required payload schemas for each template.
- Add idempotency key conventions for billing, referral, webhook ops, and credit override events.
- Handle missing recipient gracefully.
- Avoid rendering provider secrets, raw signatures, raw device tokens, or sensitive payment payloads.

## Acceptance Criteria

- Billing receipt email queues after successful credit purchase.
- Zero-amount promo receipt email queues after free checkout.
- Invitee bonus email queues after verified-email bonus release.
- Referrer reward emails queue after milestone A and B release.
- Ops alert email queues for invalid webhook signature and payment mismatch.
- Duplicate dispatch with same idempotency key does not enqueue duplicate email.
- Email admin APIs/pages can still list new email types.

## Tests

- Unit test template registry entries.
- Unit test payload rendering for each template.
- Unit test idempotency key behavior.
- Integration test queue item created from billing/referral events.
- Snapshot or golden tests for templates if existing test style supports it.

## Dependencies

- Can start independently with event stubs.
- Task 01, Task 02, Task 04, Task 05, and Task 06 will dispatch these events.

## Out of Scope

- Push notifications. See Task 09.
- Superadmin notification UI. See Task 15.

