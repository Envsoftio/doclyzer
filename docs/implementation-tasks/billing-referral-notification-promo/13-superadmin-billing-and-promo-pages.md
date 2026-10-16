# Task 13: Superadmin Billing and Promo Pages

## Objective

Add superadmin pages for billing order inspection, reconciliation monitoring, manual credit adjustments, promo management, and promo analytics.

## PRD Coverage

- SR-1 through SR-4
- BR-14 through BR-15
- PR-12 through PR-14

## Primary Areas

- `apps/web/components`
- `apps/web/pages`
- `apps/web/composables`
- `apps/api/src/modules/billing`

## Implementation Checklist

- Add admin navigation items for Billing and Promos.
- Add billing order list page.
- Add filters by status, date, provider, user, promo code, and reconciliation state.
- Add order detail drawer or page.
- Display provider ids, amount, currency, promo usage, credit allocation status, and pending review markers.
- Add manual credit adjustment action.
- Require reason for manual credit adjustment.
- Require confirmation before adjustment.
- Ensure adjustment creates audit event.
- Ensure adjustment sends ops notification.
- Add promo list page.
- Add promo create form.
- Add promo edit form.
- Add activate/deactivate controls.
- Add usage cap, per-user cap, max discount cap, and applies-to fields.
- Add promo analytics view.
- Show validations, reservations, redemptions, failed/voided, discount issued, and revenue influenced.
- Add export action if API supports it.

## Acceptance Criteria

- Superadmin can view billing orders and filter common operational fields.
- Superadmin can open order details and inspect reconciliation state.
- Superadmin can perform manual credit adjustment with required reason.
- Manual credit adjustment creates audit and ops notification.
- Superadmin can create and edit promo codes.
- Superadmin can deactivate/reactivate promo codes.
- Superadmin can view promo analytics.
- Non-superadmin users cannot access admin billing/promo operations.

## Tests

- Component test page loading and empty states if frontend tests exist.
- API client test request/response mapping.
- E2E smoke test admin billing page.
- E2E smoke test promo create/edit/deactivate flow.
- API authorization tests for admin endpoints.

## Dependencies

- Task 01 billing status/review behavior.
- Task 02 promo improvements.
- Task 08 ops/manual credit email template.

## Out of Scope

- Referral admin page. See Task 14.
- Notification operations page. See Task 15.

