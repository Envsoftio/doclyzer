# Flutter iOS and Android release validation

Status: **release blocked**. Updated 2026-10-20. Automated tests and simulator
launches cover code and basic startup; an authenticated upload journey on physical
devices has not been observed.

## Verified locally

- `flutter analyze --no-pub`: clean.
- `flutter test --no-pub`: passes, including secure session restoration,
  same-file idempotent retry after a lost upload response, and upload-screen
  retry with back navigation disabled until acceptance.
- `flutter build apk --debug --no-pub`: builds and launches on Android 16
  (API 36) emulator; sign-in screen inspected.
- `flutter build ios --simulator --debug --no-pub`: builds and launches on
  iPhone 17 Pro, iOS 26.3 simulator; sign-in screen inspected.
- `flutter build ios --release --no-codesign --no-pub`: compiles an unsigned
  iOS device build. Signing, install, and hardware behavior are unverified.
- `flutter build appbundle --release --no-pub` with a placeholder HTTPS API
  URL: compiled an Android bundle before the release-signing gate was added.
  That artifact was debug-key signed and must not be distributed.

The app records only an interruption flag in secure storage while awaiting
upload acceptance. It does not persist the selected file path or report bytes.
After relaunch, the user is directed to check Reports before choosing the file
again. A retry in the same session reuses the same idempotency key for the
same profile and file bytes. Server-side processing continues after acceptance.

## Required physical-device exercises

Run against a staging HTTPS API and live processing worker using a disposable
verified account and a test report. Record device model, OS version, API and
worker revision, report ID, screenshot or screen recording, and result for
each run. Avoid real health data in artifacts.

1. On iPhone and Android, sign in; force-close and relaunch; verify the session
   restores. Revoke the session and verify a fresh sign-in is required. Test
   offline relaunch, then reconnect and retry session validation.
2. Select a PDF from Files, a photo from the gallery, and a camera photo.
   Verify permissions, filename/profile confirmation, acceptance, report
   status, and finished results. Deny permission once, then grant it in system
   settings. Check Android picker recovery after activity recreation.
3. Start a large upload; interrupt the network before receiving acceptance.
   Reconnect and retry the same file. Verify one server report is created.
   Force-close during upload, relaunch, check Reports, and reselect only if
   missing. Repeat with the app backgrounded after acceptance; verify the
   worker finishes and status reconciles on return.
4. Check system back, app-bar back, tab changes, notification deep links,
   narrow screens, large text, rotation, and keyboard insets. Back must not
   abandon an upload before acceptance; after acceptance navigation must work.
5. Verify report-ready push display and authorized open on both platforms,
   including after logout/relogin. Check foreground, background, and closed
   app delivery separately.

## Release configuration gates

- Android release now refuses to build without `DOCLYZER_ANDROID_STORE_FILE`,
  `DOCLYZER_ANDROID_STORE_PASSWORD`, `DOCLYZER_ANDROID_KEY_ALIAS`, and
  `DOCLYZER_ANDROID_KEY_PASSWORD`. Supply the production keystore through
  secure CI/device-local configuration, never the repository. The missing
  credentials failure was verified with `flutter build appbundle --release`;
  the debug APK still builds.
- Provide a production HTTPS `API_BASE_URL` at build time. The local defaults
  target a developer API. Verify release builds reject cleartext transport.
- Produce signed Android App Bundle and iOS archive using production
  entitlements, APNs/FCM configuration, and store credentials. Install and run
  those artifacts on physical devices before distribution.
- Replace the default Flutter launcher icons with approved Doclyzer artwork;
  the iOS simulator home screen still shows the Flutter placeholder.
- The current Flutter tool migrated the iOS deployment target from 13.0 to
  15.0 during the build. Confirm iOS 15 is the intended minimum before release.
