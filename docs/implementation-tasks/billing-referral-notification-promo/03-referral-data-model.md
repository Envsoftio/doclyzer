# Task 03: Referral Data Model

## Objective

Create the database and API model foundation for referral codes, referral logs, reward events, audit events, and referral policy configuration without coupling referral state to Doclyzer health/profile records.

## PRD Coverage

- RR-1 through RR-7
- RR-15 through RR-16
- RR-23 through RR-24
- Data model requirements

## Primary Areas

- `apps/api/src/modules/referrals`
- `apps/api/src/modules/entitlements`
- `apps/api/src/database`
- User lifecycle code for profile creation/backfill

## Implementation Checklist

- Add `ReferralsModule`.
- Add `user_referral_profiles` entity and migration.
- Add `referral_logs` entity and migration.
- Add `referral_reward_events` entity and migration.
- Add `referral_audit_events` entity and migration.
- Add `referral_policy_configs` or generic `system_config` entity and migration.
- Add unique case-insensitive referral code constraint.
- Add indexes for referral code lookup, referrer id, invitee id, reward idempotency key, reward status, and audit created date.
- Add referral code generator.
- Create referral profiles for new users.
- Add safe backfill for existing users without referral profiles.
- Add referral policy defaults: invitee bonus 5, milestone A 5, milestone B tiers 10/20/30, monthly cap 200, zero-amount order eligibility false.
- Add entitlement reasons: `referral_invitee_bonus`, `referral_milestone_a`, `referral_milestone_b`, `promo_free_credit_pack`.
- Reserve `gift_voucher_redeem` reason if Task 16 is implemented.

## Acceptance Criteria

- New users can receive referral profiles with unique referral codes.
- Existing users can be backfilled safely.
- Duplicate referral code generation retries safely.
- Referral policy loads defaults when no admin config exists.
- Referral reward events support idempotency keys.
- Referral audit events can be written independently from reward release.
- Entitlement reasons compile and are accepted by the credit service.

## Tests

- Unit test referral code format.
- Unit test uniqueness retry.
- Migration test constraints and indexes.
- Unit test policy default resolution.
- Unit test entitlement reason support.
- Integration test referral profile creation for a new user.

## Dependencies

- Existing user id model.
- Existing entitlement service.

## Out of Scope

- Applying referral code. See Task 04.
- Milestone rewards. See Tasks 05 and 06.
- Admin review UI. See Task 14.

