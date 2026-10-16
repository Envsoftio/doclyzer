# Task 09: Push Notification Infrastructure

## Objective

Add device token registration, push preferences, push delivery abstraction, delivery audit, and admin broadcast foundations for mobile notifications.

## PRD Coverage

- NR-1 through NR-12
- MR-9 through MR-11
- SR-7

## Primary Areas

- `apps/api/src/modules/notifications`
- `apps/api/src/common/notification-pipeline`
- `apps/api/src/database`
- `apps/api/src/modules/users`

## Implementation Checklist

- Add `user_device_tokens` entity and migration.
- Store token hash for lookup/deduplication.
- Store provider token securely according to project security pattern.
- Track user id, platform, provider, app version, installation id, preferences, active flag, last seen, and metadata.
- Add `push_send_audit` entity and migration.
- Add endpoint to register/upsert token.
- Add endpoint to update token preferences.
- Add endpoint to deactivate token.
- Add endpoint to track push open.
- Add push provider interface.
- Add local/dev mock provider.
- Add FCM provider implementation or adapter shell.
- Add preference filtering for non-critical sends.
- Add deep-link payload support.
- Add admin dry-run broadcast API.
- Add admin live broadcast API.

## Acceptance Criteria

- Mobile can register a device token.
- Registering same token updates last seen instead of duplicating active rows.
- Mobile can deactivate token on logout.
- User preferences are persisted and respected.
- Push send creates delivery/audit rows.
- Dry-run broadcast returns target count without sending.
- Live broadcast sends or records attempted sends.
- Push open tracking records user/device/event metadata.

## Tests

- Unit test token hash/deduplication.
- Unit test preference filtering.
- Unit test mock provider send result handling.
- Integration test register/update/deactivate endpoints.
- Authorization test user cannot mutate another user's token.
- Admin authorization test broadcast endpoints.

## Dependencies

- Existing user auth.
- FCM/APNS credentials for production delivery.

## Out of Scope

- Flutter token lifecycle code. See Task 12.
- Superadmin notification page. See Task 15.

