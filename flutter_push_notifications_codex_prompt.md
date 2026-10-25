# Codex Implementation Prompt: Flutter Push Notifications, Event Notifications, Marketing Campaigns, Device Registry & Analytics

## Role

Act as a senior Flutter + backend engineer. You are working inside an **existing production project**, so do not scaffold a new application and do not rewrite unrelated architecture.

First inspect the repository and determine:

- Flutter version and current app structure/state management.
- Existing authentication flow and user model.
- Existing backend language/framework.
- Existing database and ORM/query layer.
- Existing admin panel framework.
- Existing Firebase configuration, if any.
- Existing analytics/event infrastructure.
- Existing background jobs, queues, cron/scheduler, or worker processes.
- Existing API conventions, error handling, logging, environment configuration, and migrations.

Then implement push notifications by fitting into the current architecture.

Do not introduce a second framework or duplicate infrastructure if the project already has an equivalent.

---

# Objective

Implement a production-ready notification system for the Flutter app with:

1. Android push notifications.
2. Apple/iOS push notifications.
3. Firebase Cloud Messaging (FCM) as the common push delivery layer.
4. APNs configured through Firebase for iOS delivery.
5. Notifications triggered automatically by backend/system events.
6. Manual marketing/broadcast notifications from the admin panel.
7. Per-user, per-device registration.
8. Device/installation metadata and token lifecycle handling.
9. Notification preferences and marketing opt-in/opt-out.
10. Delivery/open/click analytics.
11. Deep-link/navigation handling.
12. Campaign history and audit trail.
13. Retry/failure handling.
14. Secure server-side Firebase credentials.
15. A design that allows replacing or extending the push provider later.

Do not put Firebase service-account credentials or notification-sending authority inside the Flutter application.

---

# Recommended Architecture

Use this flow:

```text
                           +----------------------+
                           |     Admin Panel      |
                           | Campaign Composer    |
                           +----------+-----------+
                                      |
                                      v
+----------------+          +---------+----------+
| System Events  |--------->| Notification       |
| order.created  |          | Service / Backend  |
| report.ready   |          +---------+----------+
| payment.done   |                    |
| etc.           |                    v
+----------------+          +---------+----------+
                            | Queue / Worker      |
                            | recommended         |
                            +---------+----------+
                                      |
                                      v
                            +---------+----------+
                            | Firebase Admin SDK  |
                            | / FCM HTTP v1       |
                            +---------+----------+
                                      |
                         +------------+------------+
                         |                         |
                         v                         v
                   Android / FCM              iOS / APNs
                         |                         |
                         +------------+------------+
                                      |
                                      v
                              Flutter Application
                                      |
                    +-----------------+------------------+
                    |                                    |
                    v                                    v
              App navigation                      Analytics API
              / deep links                   delivered/opened/action
```

Keep application/business logic independent from Firebase by defining an internal notification provider abstraction.

Example:

```text
PushProvider
  sendToDevice(...)
  sendToDevices(...)
  validateResult(...)
  classifyFailure(...)
```

Initial implementation:

```text
FirebasePushProvider implements PushProvider
```

---

# Firebase Setup

## Flutter dependencies

Inspect `pubspec.yaml` first.

Use current compatible versions of:

```yaml
firebase_core:
firebase_messaging:
firebase_analytics:
flutter_local_notifications:
```

Only add packages that are actually required.

Use FlutterFire CLI where appropriate rather than manually hardcoding Firebase options.

Expected setup:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Do not overwrite valid existing Firebase configuration without reviewing it.

---

# Android Configuration

Implement current Android FCM requirements.

Verify:

- `google-services.json` is installed correctly.
- Google Services Gradle configuration exists.
- Firebase initialization works.
- Android notification runtime permission is handled for Android 13+.
- A high-importance notification channel exists for important user-visible notifications.
- Default icon/color are configured appropriately.
- Foreground notifications are displayed using `flutter_local_notifications`.
- Background/terminated notification handling works.
- Deep-link payloads open the intended app screen.
- Release build works, not only debug.

Create channels based on notification importance rather than creating arbitrary channels.

Suggested channels:

```text
transactional_high
transactional_normal
marketing
```

Do not allow marketing notifications to use an emergency/high-priority channel.

---

# iOS / Apple Configuration

Configure:

- Firebase Apple app.
- Correct bundle ID.
- `GoogleService-Info.plist`.
- Xcode Push Notifications capability.
- Xcode Background Modes:
  - Remote notifications
  - Background fetch only if actually needed
- APNs Authentication Key uploaded to Firebase.
- Correct Apple Team ID / Key ID configuration.
- Notification permission prompt.
- Foreground presentation options.
- Background and terminated behavior.
- Deep links.
- Badge handling if the existing product uses badges.

Do not store the `.p8` APNs private key in the Flutter repository.

Prefer an APNs Authentication Key over certificate-based configuration unless the existing infrastructure explicitly requires certificates.

Test on a physical Apple device.

---

# Flutter Notification Service

Create a focused notification module/service instead of spreading FCM code throughout widgets.

Suggested structure, adapted to the existing project conventions:

```text
lib/
  notifications/
    notification_service.dart
    notification_permission_service.dart
    notification_registration_service.dart
    notification_router.dart
    notification_analytics.dart
    models/
      push_payload.dart
```

Do not force this exact folder structure if the repository uses another convention.

The notification service must handle:

1. Firebase initialization.
2. Permission request/status.
3. FCM token retrieval.
4. Token refresh.
5. Device registration with backend.
6. Foreground messages.
7. Background messages.
8. Notification taps while app is in background.
9. Notification taps that launch a terminated app.
10. Safe navigation after authentication/app initialization.
11. Logout.
12. Account switching.
13. Local foreground notification rendering.

Register the background handler as a top-level function and preserve it from release tree shaking where required.

Example concept:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Perform only safe/background-compatible work.
}
```

Do not perform arbitrary UI/navigation operations in the background handler.

---

# Permission Strategy

Do not immediately show the notification permission dialog on first frame unless the existing UX explicitly requires this.

Prefer:

1. Explain the value of notifications at a contextually useful point.
2. Request OS permission.
3. Save permission status to backend/device record.
4. Allow users to manage marketing separately from transactional notifications.

Important distinction:

```text
OS notification permission
!=
marketing consent
```

A user may permit notifications at OS level while opting out of marketing messages.

Transactional/service notifications may have different legal/product rules than marketing notifications. Implement a clear preference model instead of using one boolean for everything.

---

# Device / Installation Registry

A user can have multiple devices.

Do NOT store:

```text
users.fcm_token
```

as the primary design.

Create a device/app installation table.

Suggested schema:

## `user_devices`

```text
id                         UUID / primary key
user_id                    nullable FK if guest devices are supported
installation_id            unique installation/app-instance identifier
fcm_token                   current FCM registration token, indexed
platform                    android | ios
device_type                 phone | tablet | unknown
device_model                nullable
os_version                  nullable
app_version                 nullable
app_build_number            nullable
locale                      nullable
timezone                    nullable
notification_permission     authorized | denied | provisional | unknown
marketing_opt_in            boolean
transactional_enabled       boolean
is_active                   boolean
token_updated_at            timestamp
last_seen_at                timestamp
last_notification_at        nullable timestamp
created_at                  timestamp
updated_at                  timestamp
revoked_at                  nullable timestamp
```

If the Firebase SDK exposes/your project already captures an installation identifier, store it. Otherwise create a stable app-installation UUID locally and send it with registration.

Do not use hardware identifiers such as IMEI.

Add uniqueness rules that fit the database.

Recommended conceptual constraint:

```text
unique(installation_id)
```

Token may be indexed, but do not assume it can never change.

---

# Device Registration API

Implement an authenticated endpoint similar to:

```http
POST /api/devices/register
```

Payload:

```json
{
  "installationId": "...",
  "fcmToken": "...",
  "platform": "android",
  "deviceType": "phone",
  "deviceModel": "...",
  "osVersion": "...",
  "appVersion": "...",
  "appBuildNumber": "...",
  "locale": "en-IN",
  "timezone": "Asia/Kolkata",
  "notificationPermission": "authorized"
}
```

Backend behavior:

- Authenticate user.
- Upsert installation.
- Associate installation with the current user.
- Update current token.
- Set `is_active = true`.
- Update `last_seen_at`.
- Update `token_updated_at` when token changes.
- Never create duplicate rows for the same installation unnecessarily.
- Ensure a device that changes accounts is reassigned safely according to product requirements.

Implement:

```http
PATCH /api/devices/preferences
```

for notification preferences.

Implement logout/unregister behavior such as:

```http
POST /api/devices/unregister
```

Depending on product semantics:

- detach the user from the installation; or
- mark it inactive/revoked for that account.

Do not blindly delete data required for analytics/audit unless that matches project retention policy.

---

# Token Lifecycle

Implement token synchronization:

```dart
FirebaseMessaging.instance.getToken()
FirebaseMessaging.instance.onTokenRefresh
```

Upload a refreshed token to the backend immediately when possible.

Also refresh/update the registration:

- after login,
- when the application starts/resumes if the registration is stale,
- after app update when useful,
- after notification permission changes,
- when FCM rotates the token.

Server-side:

- record token freshness,
- mark invalid/unregistered tokens inactive when FCM rejects them,
- avoid repeatedly sending to dead tokens,
- periodically clean stale installations based on project policy.

Do not assume iOS and Android tokens have identical expiration behavior.

---

# Notification Domain Model

Create a persistent notification record separate from device records.

Suggested table:

## `notifications`

```text
id
type
category
title
body
image_url
deep_link
payload_json
source_type          system_event | admin_campaign | admin_single | other
source_reference_id  nullable
created_by_admin_id  nullable
scheduled_at         nullable
sent_at              nullable
created_at
updated_at
```

Examples of `type`:

```text
report_ready
payment_success
subscription_expiring
new_message
marketing_offer
system_announcement
```

Examples of `category`:

```text
transactional
activity
marketing
security
```

---

# Notification Recipient Records

Create per-recipient tracking.

Suggested table:

## `notification_recipients`

```text
id
notification_id
user_id
device_id
provider_message_id      nullable
status                   queued | sent | accepted | failed | opened | actioned
failure_code             nullable
failure_reason           nullable
queued_at
sent_at
provider_accepted_at     nullable
opened_at                nullable
actioned_at              nullable
created_at
updated_at
```

Important:

FCM accepting a request is NOT the same as proving that the human saw the notification.

Keep these concepts separate:

```text
queued
provider accepted
app received (when measurable)
opened
action taken
failed
```

---

# Notification Event Log

For scalable analytics, create an immutable event table if appropriate.

## `notification_events`

```text
id
notification_id
recipient_id
user_id
device_id
event_type
event_timestamp
metadata_json
```

Event types:

```text
queued
send_attempted
provider_accepted
provider_rejected
received
opened
deep_link_opened
converted
dismissed      // only when technically measurable
unsubscribed
```

Avoid claiming "delivered" unless the platform/provider signal actually means delivered.

---

# Backend Notification Service

Create a central service.

Conceptual API:

```text
NotificationService
  sendToUser(userId, notification)
  sendToUsers(userIds, notification)
  sendToDevice(deviceId, notification)
  createCampaign(...)
  scheduleCampaign(...)
  processCampaign(...)
  handleSystemEvent(...)
```

The business layer should select recipients.

The Firebase provider should only be responsible for delivery.

---

# System Event Notifications

Implement notifications from existing application/system events.

Examples only; inspect the domain and use events that actually exist:

```text
report.completed
payment.succeeded
subscription.expiring
booking.confirmed
message.received
assessment.result_ready
account.security_alert
```

Do not hardwire notification sending directly into controllers if the existing architecture supports domain events/queues.

Preferred flow:

```text
Business action
   -> domain/application event
   -> notification event handler
   -> create notification record
   -> enqueue recipient delivery
   -> worker sends FCM
```

If there is no queue infrastructure and the project is small, implement a clean synchronous adapter first but preserve an interface that can move to a worker later.

For important application actions, notification delivery failure must NOT roll back the main business transaction.

Example:

A successful payment should remain successful even if FCM is temporarily unavailable.

---

# Idempotency

System events must not create duplicate notifications when jobs retry.

Use an idempotency key such as:

```text
notification_type + domain_event_id + user_id
```

Add a unique constraint or equivalent application protection where appropriate.

---

# Admin Panel: Marketing Notification Composer

Add a notification/campaign section to the existing admin panel.

Required fields:

```text
Campaign name
Title
Body
Optional image
Deep link / destination
Audience
Schedule
Platform filter
Test-send option
```

Audience filters should use fields that legitimately exist in the application.

Examples:

```text
all marketing-opted-in users
specific users
Android only
iOS only
subscription plan
user segment
country/locale
recently active users
custom backend segment
```

Do not allow arbitrary database query execution from the admin UI.

---

# Marketing Campaign Workflow

Implement:

```text
Draft
-> Preview
-> Test Send
-> Schedule / Send Now
-> Queued
-> Sending
-> Completed / Partially Failed / Failed
```

Before a campaign is sent, show an estimated recipient count.

For large campaigns:

- process recipients in batches,
- use existing queue/worker infrastructure,
- rate-limit appropriately,
- do not send thousands of messages in a single blocking admin HTTP request.

Provide campaign cancellation for scheduled campaigns if practical with the current infrastructure.

---

# Campaign Tables

Suggested:

## `notification_campaigns`

```text
id
name
title
body
image_url
deep_link
segment_json
status
scheduled_at
started_at
completed_at
created_by_admin_id
recipient_count
sent_count
failed_count
opened_count
action_count
created_at
updated_at
```

If the existing system already has a jobs/campaign framework, reuse it.

---

# FCM Topics

Do NOT use FCM topics as the source of truth for user-specific authorization or sensitive segmentation.

Topics are useful for broad, non-sensitive public categories.

Examples:

```text
app_updates
general_announcements
```

For:

- user-specific data,
- subscriptions/plans,
- private content,
- transactional notifications,
- precise marketing segmentation,

resolve recipients on the backend and send to the devices belonging to eligible users.

Never put secrets, medical data, passwords, tokens, or highly sensitive information in push payloads.

A notification can instead contain a safe generic message and a resource ID/deep link that requires authenticated API access after opening the app.

---

# Push Payload Contract

Define one versioned payload format used across Android and iOS.

Example:

```json
{
  "notificationId": "uuid",
  "type": "report_ready",
  "category": "transactional",
  "route": "/reports/details",
  "entityId": "uuid",
  "campaignId": null,
  "analyticsId": "uuid",
  "version": 1
}
```

Do not trust push payload values for authorization.

When opening a resource:

1. Navigate using the identifier.
2. Fetch current data from backend.
3. Backend verifies current authenticated user has access.

---

# Deep Link / Navigation Handling

Implement one notification router.

Example:

```text
report_ready
   -> /reports/:id

payment_success
   -> /billing/transactions/:id

marketing_offer
   -> /offers/:id
```

Handle:

- app foreground,
- app background,
- app terminated,
- user logged out,
- expired/invalid destination,
- unsupported notification version.

If app startup/authentication has not completed, queue the intended notification navigation until it is safe.

Do not create navigation races during application boot.

---

# Foreground Notifications

FCM notifications received while the app is foregrounded may not automatically display as normal system notifications.

Use `flutter_local_notifications` where required to provide consistent visible behavior.

Avoid duplicate notifications caused by showing a local notification when the OS already displayed the remote notification.

---

# Analytics

Implement both provider analytics and application-owned analytics.

Recommended Firebase integration:

```text
firebase_analytics
```

But the application's own database should remain the source for campaign reporting required by the admin panel.

Track at minimum:

```text
notifications_created
recipients_queued
send_attempts
provider_accepts
provider_failures
notification_open
deep_link_open
campaign_conversion
marketing_opt_out
```

Suggested custom analytics events in Flutter:

```text
push_received
push_opened
push_action
notification_permission_result
```

Attach safe dimensions such as:

```text
notification_type
notification_id
campaign_id
platform
route
```

Do not send sensitive user data into analytics properties.

---

# Campaign Analytics Dashboard

Admin campaign details should show:

```text
Targeted recipients
Eligible devices
Sent / provider accepted
Failed
Unique opens
Open rate
Action/conversion count
Conversion rate
Android vs iOS
Failure reasons
```

Define formulas clearly.

Example:

```text
Open Rate = unique recipients who opened / recipients successfully sent
```

Do not call FCM acceptance "delivered" unless a real delivery metric supports it.

If Firebase/BigQuery delivery export is already used, integrate it separately rather than conflating it with app open events.

---

# User Notification Preferences

Create a preference structure that can evolve.

Suggested:

```text
marketing_enabled
product_updates_enabled
activity_enabled
transactional_enabled
```

For security-critical notifications, the product may choose not to expose an opt-out; follow existing legal/product requirements.

Store preferences at user level where they represent account intent.

Device permission remains stored separately per device.

Effective eligibility example:

```text
marketing push allowed =
  user.marketing_enabled
  AND device.marketing_opt_in
  AND device.notification_permission allows notifications
  AND device.is_active
```

Adapt to the actual product rules.

---

# Scheduling

Admin campaigns need:

```text
Send now
Schedule for date/time
```

Store scheduled times in UTC.

Show dates in the admin/user timezone.

If the application supports users across timezones, design future support for "send at local time" but do not over-engineer unless requested.

Use the existing job scheduler where available.

---

# Retry Strategy

Classify failures.

Transient examples:

```text
network timeout
provider 5xx
temporary quota/rate limit
```

Retry with bounded exponential backoff.

Permanent examples:

```text
invalid registration
unregistered device/token
invalid argument caused by bad payload
```

Do not endlessly retry permanent failures.

Mark invalid registrations inactive when Firebase indicates they are no longer usable.

---

# Security

Must implement:

- Firebase service account only on trusted backend/secret manager/environment.
- No Firebase Admin private key in Flutter.
- No APNs `.p8` private key in app repository.
- Admin campaign APIs protected by admin RBAC.
- Campaign creation/sending audit log.
- Input validation for title/body/image/deep-link.
- Rate limiting for admin sending where appropriate.
- Avoid unrestricted arbitrary URLs if deep-linking should remain internal.
- Never trust notification payload for resource authorization.
- Never expose sensitive data unnecessarily in lock-screen text.

---

# Admin Audit Log

Record:

```text
admin_id
action
campaign_id
timestamp
before/after metadata where relevant
```

Examples:

```text
campaign.created
campaign.updated
campaign.test_sent
campaign.scheduled
campaign.cancelled
campaign.sent
```

---

# Firebase Sending Implementation

Use the Firebase Admin SDK supported by the existing backend language when available.

Prefer this over manually generating OAuth tokens.

If the language/platform cannot use Firebase Admin SDK cleanly, use FCM HTTP v1 API from the backend.

Do NOT use deprecated legacy FCM server keys/APIs.

Implement:

```text
FirebasePushProvider.send(device, payload)
FirebasePushProvider.sendBatch(devices, payload)
```

Respect the provider's current batch/multicast limits. Do not hardcode assumptions without checking the SDK being used.

Capture:

```text
success/failure
provider message id
error code
error classification
```

---

# Example System Notification Flow

Example: report becomes ready.

```text
1. Report service completes report.
2. Publish `report.ready`.
3. Notification handler receives event.
4. Check idempotency.
5. Create notification:
      type = report_ready
      category = transactional
6. Find user's active installations.
7. Check eligibility/preferences.
8. Create recipient rows.
9. Enqueue sends.
10. Worker sends through FCM.
11. Store send result.
12. User taps notification.
13. Flutter reports `opened`.
14. App routes to report.
15. Flutter/backend records deep-link/action event.
```

---

# Example Marketing Flow

```text
1. Admin creates campaign.
2. Selects audience.
3. Backend computes preview/estimated count.
4. Admin sends test notification to their device/test users.
5. Admin chooses Send Now or Schedule.
6. Campaign is frozen/versioned for send.
7. Worker resolves eligible recipients.
8. Recipient rows are created.
9. Send in batches.
10. Invalid devices are deactivated.
11. Opens/actions are collected.
12. Dashboard displays campaign analytics.
```

---

# Test Notification Feature

Admin must be able to send a test push before broadcasting.

Allow:

- current admin test device, if applicable; or
- selected internal test user(s).

Clearly mark test sends so they do not contaminate production campaign conversion metrics.

---

# Logout / Account Switching

On logout:

- inform backend that this installation is no longer associated with the logged-out account, according to existing session semantics;
- clear user-specific local notification state;
- do not leave a token pointing to a previous user.

On subsequent login:

- register/upsert device for the newly authenticated account.

This is mandatory to prevent private notifications being sent to the wrong person on shared/reused devices.

---

# App Reinstallation

Assume an uninstall/reinstall can create a new installation identity and/or token.

The backend must tolerate old stale records and eventually deactivate/clean them.

Do not attempt to use device hardware fingerprinting to merge installations.

---

# Notification Inbox — Optional but Recommended

If the product benefits from an in-app notification center, add it using the same notification records.

Possible API:

```http
GET /api/notifications
POST /api/notifications/{id}/read
POST /api/notifications/read-all
```

Additional recipient columns:

```text
read_at
```

Do not make implementation of the push layer depend on the inbox unless the existing product wants this feature.

---

# Data Retention

Implement a retention strategy appropriate to the existing application.

At minimum distinguish:

- active device registrations,
- stale registrations,
- notification delivery logs,
- campaign analytics,
- audit logs.

Avoid retaining unnecessary raw device metadata forever.

---

# Observability

Add structured logs containing safe identifiers:

```text
notification_id
campaign_id
recipient_id
device_id
notification_type
provider
result
error_code
attempt
```

Never log:

```text
Firebase private credentials
APNs private keys
full access tokens
sensitive payload content
```

Add metrics where existing observability supports them:

```text
notification_send_total
notification_send_failed_total
notification_open_total
invalid_device_total
campaign_processing_duration
queue_depth
```

---

# Testing Requirements

Implement automated tests appropriate to the repository.

## Backend tests

Test:

- registration/upsert,
- token refresh,
- logout/account switching,
- duplicate installation handling,
- user with multiple devices,
- notification preferences,
- campaign audience eligibility,
- campaign scheduling,
- event idempotency,
- retryable FCM failure,
- permanent invalid-token failure,
- invalid token deactivation,
- unauthorized admin send,
- deep-link payload validation.

## Flutter tests

Test pure logic for:

- payload parsing,
- routing,
- unsupported payload versions,
- preference state where testable.

## Manual device matrix

Test at minimum:

```text
Android:
- foreground
- background
- terminated
- permission allowed
- permission denied
- token refresh
- notification tap
- app logged out

iOS physical device:
- foreground
- background
- terminated
- permission allowed
- permission denied
- notification tap
- token refresh where reproducible
- app logged out
```

Also test release builds.

---

# Required Deliverables

Before modifying code:

1. Summarize current architecture discovered in repository.
2. List files/modules you plan to change.
3. State whether Firebase already exists.
4. State backend stack and database.
5. State whether a worker/queue already exists.
6. State admin panel stack.

Then implement.

After implementation, provide:

1. Files changed.
2. Database migrations.
3. Environment variables/secrets required.
4. Firebase Console setup steps.
5. Apple Developer/Xcode setup steps.
6. Android setup steps.
7. Backend setup steps.
8. Admin usage instructions.
9. Test commands.
10. Manual verification checklist.
11. Any TODOs that require credentials/account access.
12. Any assumptions made.

---

# Environment Variables

Adapt names to project conventions.

Likely backend configuration:

```text
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
```

or use a service-account file/managed identity supported by the deployment environment.

Never commit production secrets.

Frontend should only contain Firebase client configuration that Firebase expects to be public; never include Firebase Admin credentials.

---

# Definition of Done

The feature is complete only when:

- Android receives real notifications.
- iOS physical device receives real notifications.
- Foreground/background/terminated states are handled.
- Notification tap opens the correct app destination.
- One user can have multiple registered devices.
- FCM token refresh updates backend.
- Logout does not leave private notifications associated with the old account.
- Invalid tokens are eventually deactivated.
- System events can trigger notifications.
- Admin can create and test a marketing notification.
- Admin can send immediately.
- Admin can schedule a campaign.
- Marketing preferences are respected.
- Campaign history is persisted.
- Send failures are visible.
- Notification opens/actions are tracked.
- Analytics dashboard uses clearly defined metrics.
- Firebase/APNs secrets remain server-side.
- Existing project architecture/tests continue to work.

---

# Important Engineering Rules

1. Inspect before changing.
2. Prefer the existing architecture.
3. Do not rewrite unrelated code.
4. Do not place Firebase Admin credentials in Flutter.
5. Do not use one token column on the user table as the only device model.
6. Do not treat FCM token as permanent.
7. Do not send sensitive private data in lock-screen payloads.
8. Do not trust deep-link payloads for authorization.
9. Do not allow marketing sends to bypass opt-out rules.
10. Do not let push failure break the underlying business transaction.
11. Make event notification creation idempotent.
12. Do not report provider acceptance as confirmed human delivery.
13. Use migrations rather than manually editing production database structures.
14. Reuse existing queue/worker/scheduler infrastructure.
15. Make the smallest production-safe change that fully implements the feature.

---

# Start Now

Inspect the repository first.

Return a short implementation assessment before making changes, then implement the feature end-to-end in logical phases.

If credentials are missing, complete all code/configuration that can be completed safely and clearly identify the exact external console steps required. Do not invent credentials or placeholder secrets that could accidentally be used in production.
