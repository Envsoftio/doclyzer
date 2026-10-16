# Task 15: Superadmin Notification Operations

## Objective

Add superadmin notification operations for email delivery inspection, queue health, push send audit, push metrics, and dry-run/live broadcast.

## PRD Coverage

- SR-7
- ER-7
- NR-11 through NR-12

## Primary Areas

- `apps/web/pages`
- `apps/web/components`
- `apps/web/composables`
- `apps/api/src/modules/email-admin`
- `apps/api/src/modules/notifications`

## Implementation Checklist

- Add Notifications admin nav item.
- Add email queue health section.
- Show queued, processing, sent, failed, suppressed, and retrying counts.
- Add email delivery table.
- Show recipient, event type, status, retry count, failure reason, created time, and sent time.
- Add push audit table.
- Show sender, audience, title/body summary, dry-run/live state, target count, sent count, failed count, and created timestamp.
- Add push broadcast form.
- Support title, body, audience filters, deep-link target, dry-run action, and live send action.
- Add metrics cards for email success rate, email failure rate, active push tokens, push sends, and push open count.

## Acceptance Criteria

- Superadmin can inspect email queue and delivery status.
- Superadmin can inspect push send audit.
- Dry-run broadcast shows estimated target count and creates no live push sends.
- Live broadcast sends through push provider or mock provider and records audit.
- Broadcast form validates required title/body fields.
- Non-superadmin cannot send broadcasts.

## Tests

- Component test broadcast form validation.
- API client test dry-run/live request mapping.
- Admin authorization tests.
- Manual QA with mock push provider.

## Dependencies

- Existing email admin APIs.
- Task 09 push notification infrastructure.
- Task 08 expanded event types for richer email labels.

## Out of Scope

- Mobile push token registration. See Task 12.

