# PRD Addendum: Email Pipeline & Onboarding Emails

**Extends:** PRD (FR77, FR78, FR79) and Epic 6 / Story 6.6  
**Date:** 2026-03-06

## Summary

All outbound email is sent through a **single queue-based pipeline**. Messages are enqueued by the API and sent asynchronously by a worker (or provider) so that sending is independent of the HTTP request. Onboarding and auth-related emails are first-class types in this pipeline.

## Email Pipeline Behaviour

- **Queue-first:** When the system needs to send an email, it enqueues a job (e.g. to Redis, DB, or provider queue). The HTTP response is not blocked on delivery.
- **Independent sending:** A worker or provider consumes the queue and sends emails; retries, backoff, and failure handling are applied in the pipeline.
- **Delivery status:** Each send is tracked (queued → sent / failed / bounced where the provider supports it). Data is used for analytics (FR78) and support.
- **Single pipeline:** Password reset, welcome, verification, OTP, product notifications, and admin-sent emails all use the same pipeline and template mechanism.

## Onboarding & Auth Email Types

| Type | When sent | Purpose |
|------|-----------|--------|
| **Welcome** | After successful registration | Confirm signup, set expectations, next steps (e.g. verify email, add profile). |
| **Verify email** | When user requests email verification or as part of signup | Link or token to verify ownership of the email address. |
| **PIN / OTP** | When user requests OTP (e.g. login, sensitive action) | Short-lived code in email for verification; no PHI. |
| **Password reset** | Already in scope | Token/link for password reset (existing flow). |

All of the above use the same pipeline: enqueue → template render → send → record outcome.

## Template Support

- One template per email type (and optionally per locale).
- Variables are injectable (e.g. `{{userName}}`, `{{verifyLink}}`, `{{otpCode}}`, `{{expiryMinutes}}`).
- No PHI in templates beyond what is necessary (e.g. recipient email); no report content or health data.
- Templates are versioned and editable without code deploy (e.g. stored in DB or files; admin UI later).

## Non-functional

- **PHI:** No PHI in logs or queue payloads beyond recipient identifier and template key.
- **Retry:** Configurable retries with backoff; terminal failure state and optional dead-letter.
- **Preferences:** Product/marketing emails respect communication preferences (Epic 6); transactional (welcome, verify, OTP, password reset) are sent regardless of marketing preference.

## Out of scope (for this addendum)

- In-app push notifications (separate channel).
- SMS OTP (future; same queue pattern can be extended).

## References

- PRD: FR77 (email pipeline), FR78 (delivery analytics), FR79 (admin sending).
- Epics: Story 6.6 (Email Pipeline — Delivery, Tracking & Template Support); Epic 6 (Notifications).
