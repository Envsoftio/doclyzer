# Story 6.6: Email Pipeline — Delivery, Tracking & Template Support

**Status:** backlog  
**Epic:** 6 — Notifications, Incident Communication & Support

## User Story

As a platform,
I want a unified email pipeline for all outbound email types,
So that transactional and product emails are sent with consistent delivery, status tracking, and template support.

## Acceptance Criteria

- **Given** the system sends any email (password reset, welcome, verify email, OTP, notifications, security/compliance, etc.)
- **When** the email pipeline is invoked
- **Then** the message is enqueued (not sent synchronously in the request path) and processed by a worker or provider
- **And** delivery status is recorded (queued → sent / failed / bounced where available)
- **And** templates are supported per email type with injectable variables; onboarding types (welcome, verify email, OTP) have defined templates
- **And** pipeline failures use retry/backoff and terminal state handling; no PHI in logs

- **Given** a user completes registration
- **When** welcome email is configured
- **Then** a welcome email is enqueued and sent via the pipeline with the correct template

- **Given** a user requests email verification (or verification is part of signup)
- **When** the system generates a verification link/token
- **Then** a verify-email message is enqueued with the link and sent via the pipeline

- **Given** a user requests an OTP (e.g. for login or sensitive action)
- **When** the system generates a short-lived OTP
- **Then** an OTP email is enqueued with the code and expiry and sent via the pipeline

## Onboarding Email Types (in scope)

| Type | Template key | Typical variables |
|------|--------------|-------------------|
| Welcome | `welcome` | `userName`, `loginUrl`, `supportUrl` |
| Verify email | `verify-email` | `verifyLink`, `expiryMinutes`, `userName` |
| OTP / PIN | `otp` | `otpCode`, `expiryMinutes`, `purpose` (e.g. "Login") |
| Password reset | `password-reset` | `resetLink`, `expiryMinutes` (existing) |

## Technical Notes

- Single pipeline used by auth (password reset, OTP, verify), account (welcome, notices), and future notification flows; admin sending (FR79) uses the same pipeline.
- Delivery analytics (FR78) consume pipeline status data.
- Queue: Redis queue, DB job table, or provider queue (e.g. SendGrid, SES); worker or serverless consumer sends via SMTP/provider API.
- Templates: files (e.g. Handlebars/HTML) or DB; at least one template per type; variables escaped to avoid injection.

## References

- PRD: FR77, FR78, FR79
- PRD addendum: `_bmad-output/planning-artifacts/prd-email-pipeline-and-onboarding.md`
- Current: `NotificationService` (abstract) + `InMemoryNotificationService` (stub); only `sendPasswordResetToken` today.
