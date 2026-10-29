# Push notifications: implementation and rollout

For console-by-console instructions, start with [Firebase and Apple setup](firebase-apple-setup.md).

Status: code is implemented, but production delivery is **not verified**. Firebase client configuration, an Apple/APNs identity decision, signed Android release validation, and the physical-device matrix below are release gates. No production database was migrated and no real push was sent by this implementation session.

## Existing architecture and changes

The inspected SDK is Flutter 3.47.2 / Dart 3.13.2; the application declares Dart ^3.11.0. It uses stateful Flutter screens, repositories, a shared authenticated API client, secure token storage, and Better Auth sessions. The backend is NestJS 11 with TypeORM and PostgreSQL. The admin is Nuxt 4/Vue 3. Existing report processing uses a durable PostgreSQL outbox, leases and a dispatcher process, not Redis for notification delivery. Existing notifications included per-token registration, an inbox, send/open audit tables, a synchronous broadcast endpoint, and custom HTTP-v1 OAuth code.

This change extends that structure:

- `apps/api/src/modules/notifications/`: installation upsert, permission/consent eligibility, Firebase Admin provider, campaign API, recipient queue, analytics and validation. The old send endpoint now queues marketing campaigns; it does not send synchronously or allow category-based consent bypass.
- `apps/api/src/modules/reports/processing/report-dispatcher.service.ts`: keeps existing idempotent report outbox delivery, adds versioned destinations, permission checks and permanent/transient failure classification; also processes campaigns.
- `apps/api/src/push-worker.ts`: optional standalone consumer of the same campaign queue. It is unnecessary when the report dispatcher is running. Multiple consumers use PostgreSQL leases.
- Account DTO/types/entity/service: separate `marketingPush` account preference, default false, and opt-out events.
- `apps/mobile/lib/features/notifications/`: versioned payload validation, local foreground rendering, FCM background entry point, permission action, token refresh/resume sync, metadata, safe navigation and analytics.
- `apps/mobile/lib/main.dart` and communication preferences: authenticated/unlocked navigation, account lifecycle cleanup and explicit permission/marketing choices.
- Android Gradle/manifest and iOS plist/entitlements: platform wiring. Package and native dependency lockfiles are updated.
- `apps/web/app/components/admin/PushCampaigns.vue` and the existing admin notifications page: draft/edit, preview count, test, immediate/scheduled send, cancellation, history and per-campaign analytics.
- Tests: `push-notifications-postgres-test.ts`, `push_payload_test.dart`, `communication_preferences_screen_test.dart`, existing inbox/widget tests.

## Migration

`1730819400000-CompletePushNotifications` adds:

- `user_device_tokens.notification_permission` and `token_updated_at`.
- A partial unique installation index. For duplicate historical installations it keeps the most recently seen row and deactivates older rows while preserving their audit identities.
- `account_preferences.marketing_push_enabled`, default false. Existing email permission is **not** migrated into marketing push consent.
- `push_campaigns`, linked to the existing persistent `push_send_audit` notification record.
- `push_recipients`, one per campaign/device, with lease, attempt, acceptance and interaction timestamps.
- Append-only application events in `push_events`, including admin audit actions and deduplicated recipient events.

Run the migration before deploying the new API/dispatcher:

```sh
cd apps/api
npm ci
npm run migration:run
npm run build
```

The migration was tested up/down in an isolated PostgreSQL schema. Production rollback drops the new campaign/recipient history; use the normal backup/deployment process before reverting. Historical devices have unknown permission and become eligible after an updated client registers them.

## Server configuration

Use `PUSH_PROVIDER=fcm`. `mock` is for development only; sending in production with the mock configuration returns failure, not acceptance.

Prefer Firebase Admin application default credentials: workload identity on Google Cloud, or `GOOGLE_APPLICATION_CREDENTIALS` pointing to a mounted service-account secret. Set `FCM_PROJECT_ID` to the intended project. Alternatively use server-only `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, and `FCM_PRIVATE_KEY`; escaped newlines in the private key are supported. Do not set only half of the email/private-key pair. The old `FCM_OAUTH_TOKEN_URL`/`FCM_SCOPE` overrides are no longer used.

Admin push routes retain AuthGuard and SuperadminGuard. There is a serialized limit of ten schedules/test sends per admin per hour. Marketing campaigns deliver only to accounts and devices with marketing push consent and OS notification permission.

The report dispatcher already runs `PushCampaignService.tick()`. Existing report push additionally requires the report completion push setting from `processing-settings.ts` (`REPORT_COMPLETION_PUSH_ENABLED`). If a deployment does not run the report dispatcher, run `npm run start:push-worker:prod`. Do not run a queue consumer against a database whose migration is pending. The standalone consumer inherits the existing application environment/configuration.

Queue behavior: pages of 500 eligible devices, at most ten sequential sends per iteration/process, eight bounded attempts, jittered exponential backoff, and a 24-hour campaign recipient lifetime. Consent and current device ownership are checked again immediately before each provider call. Invalid-token deactivation is conditional on the token hash that failed so a concurrent refresh is not disabled. FCM acceptance and database commit cannot be atomic: a crash after acceptance can cause a repeated send. Stable collapse IDs/local IDs reduce duplicate display; exactly-once external delivery is not claimed.

Retention: devices inactive for 90 days are deactivated and lose descriptive metadata; inactive provider tokens are cleared after 30 days; raw provider delivery/open logs expire after 180 days; recipient attempt/rejection events expire after 90 days. Campaign summaries, recipient outcomes and admin audit actions remain for reporting and should follow the product's eventual campaign retention policy. No platform-specific token-expiration assumption is used.

## Firebase and Android setup

1. Select/create the real Firebase project and enable the Cloud Messaging API. Grant the server service identity permission to send FCM messages in that project.
2. Register the Android app with the existing application ID **`io.envsoft.doclyzer`**.
3. Run FlutterFire configuration from `apps/mobile` against the chosen project, reviewing the generated changes. This implementation uses native default Firebase configuration (`Firebase.initializeApp()`); if adopting generated Dart options, wire `DefaultFirebaseOptions.currentPlatform` into both initialization entry points.
4. Place the project's `google-services.json` at `apps/mobile/android/app/google-services.json`. It is ignored by git. Google Services is applied when this file exists, allowing unconfigured builds to keep working without push.
5. Android 13+ permission is requested only from Account → Notification preferences → Enable. The default icon/color already exist. `transactional_high`, `transactional_normal` and `marketing` channels are created; marketing uses normal priority.
6. Set the existing release keystore variables `DOCLYZER_ANDROID_STORE_FILE`, `DOCLYZER_ANDROID_STORE_PASSWORD`, `DOCLYZER_ANDROID_KEY_ALIAS`, `DOCLYZER_ANDROID_KEY_PASSWORD`, then run `flutter build appbundle --release`. Do not bypass the signing checks.

## Apple/Firebase setup

**Register the Firebase Apple app with `io.envsoft.doclyzer`.** The iOS Runner Debug, Release and Profile configurations use this bundle ID. Confirm that the Apple App ID, provisioning profiles and any App Store Connect app use the same identifier. An app published under a different bundle ID cannot be updated under this one.

1. Register the chosen Apple bundle ID with Firebase. Add `GoogleService-Info.plist` to `ios/Runner` through Xcode and ensure Runner target membership / Copy Bundle Resources. The file is ignored by git.
2. In the Apple Developer portal enable Push Notifications for that App ID and refresh its provisioning profiles.
3. In Xcode enable Push Notifications and Background Modes → Remote notifications. No background-fetch capability is required by this implementation.
4. `Runner.entitlements` contains the development APNs entitlement. Xcode signing/export must produce the correct production entitlement for distribution. Validate the signed archive rather than editing an unsigned build's entitlements by guesswork.
5. Create/use an APNs authentication key and upload the `.p8` to Firebase Project settings → Cloud Messaging → Apple app with the correct Key ID and Team ID. Never put it in this repository.
6. Keep Firebase method swizzling enabled. The service waits for APNs availability before asking for the FCM token and retries on resume/token refresh.
7. Test on a physical iPhone with a signed development build and a distribution build. The unsigned iOS release build verifies compilation only.

Optional campaign images are sent in the FCM notification payload (Android support). Rich image presentation on iOS requires a Notification Service Extension; no extension was invented without the app's signing/provisioning configuration. iOS text/title and tap navigation work independently of rich images.

## User and admin workflow

Users enable OS notification access explicitly in Account → Notification preferences. Marketing is a separate opt-in toggle. Saving that toggle updates account intent and this installation's marketing preference. Other devices must independently opt in. Token refresh/resume does not overwrite existing consent. Account switching resets the installation's device preferences. Normal logout waits for in-flight registration, revokes its backend record, deletes the FCM token and clears local notifications; if both backend and provider revocation fail, explicit logout reports an error instead of silently promising revocation. Expired-session cleanup avoids waiting on its own failed API request and attempts provider-token revocation. No distributed implementation can retract a push already handed to APNs/FCM; message copy must remain generic.

On resume, denied or undetermined OS permission deactivates the stored device before APNs/FCM token retrieval. This is retried on a later resume if the server is unreachable. Granting permission registers the installation again and preserves its existing consent. Same-account legacy registration without an installation ID preserves the stored identity.

In Admin → Notifications:

1. Enter a generic lock-screen title/body and select all opted-in accounts or search for one account. Campaign name is optional and defaults to the title. More options contains destination, platform and HTTPS image.
2. Choose Review notification to save the draft and inspect eligible account/device counts. Subsequent edits update that draft through Save and review; unsaved edits block its send/test actions. Audience filters never execute administrator-supplied queries.
3. Test on my devices queues a separately labeled test campaign for the authenticated admin only. The admin needs a registered mobile device and explicit account/device marketing consent; tests do not bypass consent. Tests have their own IDs and metrics and never increment the source campaign's statistics.
4. Enter the approval token for a broadcast. Leave the local datetime empty for Send now, or choose a future local date/time. The browser sends UTC. Scheduling freezes the draft.
5. Cancel a draft or queued campaign before the dispatcher starts it. Once sending has begun it cannot be cancelled through this workflow.
6. Refresh history and select a campaign to see device/account counts, provider accepts, failures, app receipts, opens, destination actions, platform breakdowns, failure codes and audit actions.

The old browser registration remains available but does not infer marketing consent. The web client does not implement the new Flutter recipient-event contract; reliable campaign open metrics in this release are from mobile clients.

## Payload, navigation and analytics

Version 1 uses `notificationId`, `notificationType`, `category`, `deepLink`; campaigns also include `campaignId`, `recipientId`, `pushSendAuditId`. The rolling-upgrade parser accepts the previous `report.completed`/`reportId` payload. Unknown versions, arbitrary URLs and unrecognized paths are discarded. Allowed destinations are `/notifications`, `/reports`, `/account`, and `/reports/<UUID>`. A report is fetched through the authenticated repository before navigation, and the backend enforces access.

Navigation waits for authentication, first layout and app unlock. Account changes/session loss invalidate in-flight navigation. Foreground local notifications are shown on Android and iOS; iOS foreground remote presentation is disabled to avoid duplicates. Background notification messages are rendered by the OS; the background handler performs no navigation and creates no second notification.

FCM `sent` in the legacy provider contract means **provider accepted**, not device delivery. The admin UI uses the acceptance label. App receipts are measurable foreground callbacks, not a complete delivery metric. Recipient `opened` and `deep_link_opened` events require an owned, active installation and a previously attempted recipient, and are deduplicated in PostgreSQL. Open/action rates use unique device recipients with recorded events divided by provider-accepted device recipients. Destination navigation is an action, not a verified purchase/business conversion. No purchase conversion is claimed without a defined attribution rule. Firebase Analytics receives safe event-type dimensions, not report contents, tokens or medical data.

## Validation commands and device matrix

Verified in this workspace: API build and existing inbox contract test; Nuxt production build; real PostgreSQL migration/queue tests (including concurrent logout/account-switch mutation, isolated test sends and 501-device batching); Flutter analysis; seven focused mobile tests; Android debug APK; unsigned iOS release build. Android signed release stopped at the existing missing-keystore-variable check. No real-device delivery or production migration was performed. The temporary PostgreSQL container was removed after testing.

```sh
cd apps/api
npm run build
npm run notifications:inbox-test
PUSH_TEST_DATABASE_URL=postgres://.../disposable_database npm run notifications:push-test

cd ../web
npm run build

cd ../mobile
flutter analyze
flutter test test/push_payload_test.dart test/communication_preferences_screen_test.dart test/notifications_screen_test.dart test/app_notification_frame_test.dart
flutter build apk --debug
flutter build appbundle --release
flutter build ios --release --no-codesign
```

The PostgreSQL suite creates/drops an isolated schema in the supplied disposable database. It exercises concurrent installation upsert/token rotation, account switching, multiple devices, eligibility, future scheduling, cancellation, idempotent creation, concurrent workers, retry/permanent failures, token deactivation, recipient-event authorization/deduplication, RBAC, destination validation and migration rollback. It uses a fake provider and never sends a real push.

For **Android** and a **physical iPhone**, repeat in foreground/background/terminated states:

- Enable, deny, then change OS permission in Settings and resume; confirm registry permission updates.
- Send a report completion event twice; confirm one intent per report generation/device and generic text.
- Tap a report push while signed in, locked and signed out; verify auth/unlock gating and access checks.
- Tap a removed/unauthorized report and an unsupported payload; verify no private content appears.
- Refresh/rotate the token; verify the installation ID/row is stable and old tokens are not targeted.
- Register two devices under one user; verify separate recipient records and device-specific consent.
- Log out and switch accounts, including expired sessions/offline failures; verify old private resources cannot open and the installation is no longer eligible for the old account.
- Opt into marketing, preview/test/send/schedule/cancel, then opt out after queuing; verify send-time suppression.
- Exercise a failed token and a retryable provider outage; inspect failure code/attempts and recovery.
- Verify one foreground banner and one tap navigation, including taps launching the terminated app.
- Check dashboard counters against provider acceptance and mobile callbacks; distinguish test campaigns.
- Repeat with Android release signing and iOS distribution provisioning.

External release gates: real Firebase project files, server service identity, APNs key/team ID, Apple bundle-ID/provisioning decision, Android signing credentials, physical device tests, and production rollout/migration approval under the project's normal process.

Implementation references: [Firebase Flutter receive handling](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages), [Flutter FCM setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started), [Firebase Admin sending](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk), [FCM error classification](https://firebase.google.com/docs/cloud-messaging/error-codes), and [local notifications platform requirements](https://pub.dev/documentation/flutter_local_notifications/latest/).
