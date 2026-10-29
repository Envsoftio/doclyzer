# Firebase and Apple setup for Doclyzer push notifications

**[Certain] Register the Apple app in Firebase with `io.envsoft.doclyzer`.** The Android application ID and all iOS Runner build configurations use this identifier.

This guide covers the console settings, downloaded files, backend environment values and device checks required by the notification implementation already in this repository. It does not contain actual credentials. Console instructions were checked against official documentation on 29 October 2026; labels may vary slightly by account.

## Setup order

1. Confirm the Apple App ID and signing configuration use `io.envsoft.doclyzer`.
2. Select the Firebase project and register its Android and Apple apps.
3. Enable push for the Apple App ID and configure APNs authentication keys.
4. Upload those APNs keys to Firebase.
5. Finish Xcode signing and add the Firebase configuration files.
6. Configure the backend Firebase credentials and restart the relevant processes.
7. Test through Doclyzer on physical devices.

## 1. Confirm the iOS bundle ID and signing

These values come from the current repository:

| Configuration | Current application identifier |
| --- | --- |
| Android | `io.envsoft.doclyzer` |
| iOS Debug | `io.envsoft.doclyzer` |
| iOS Release | `io.envsoft.doclyzer` |
| iOS Profile | `io.envsoft.doclyzer` |

All Runner configurations now use `io.envsoft.doclyzer`. If an Apple App ID, provisioning profile, or App Store Connect app was previously created under another identifier, create or update the Apple-side app identity and signing setup for this ID. Apple treats a different bundle ID as a different app identity; an existing published app cannot be updated under a new bundle ID.

From the repository root:

```sh
open apps/mobile/ios/Runner.xcworkspace
```

In Xcode:

1. Select the blue **Runner** project, then the **Runner application target**.
2. Open **Build Settings** and search for **Product Bundle Identifier**.
3. Verify Debug, Release and Profile all show `io.envsoft.doclyzer`.
4. The `RunnerTests` target uses the distinct test identifier `io.envsoft.doclyzer.RunnerTests`; it does not need its own Firebase app registration.
5. Check that the Apple Team and provisioning profiles are for `io.envsoft.doclyzer`.

## 2. Firebase: choose the project and enable messaging

Open the [Firebase Console](https://console.firebase.google.com/) and select the project that will serve this deployment, or create one.

Go to **Project settings → General** and record the **Project ID**. This is the value for `FCM_PROJECT_ID`; it is not the display name, project number, mobile Firebase App ID or API key.

Go to **Project settings → Cloud Messaging**. Verify **Firebase Cloud Messaging API (V1)** is enabled. If the console links to Google Cloud to enable it, use that link with the same project selected. The backend uses the Admin SDK; no legacy FCM server key is needed. [Firebase server setup](https://firebase.google.com/docs/cloud-messaging/server-environment)

Use the same Firebase project for the two mobile app registrations and the backend sending credentials for this deployment. This implementation does not require Firebase Authentication, Firestore or Realtime Database: login and notification records remain in the existing backend.

## 3. Firebase: register Android and download its file

1. In **Project settings → General → Your apps**, choose **Add app → Android**.
2. Enter Android package name **`io.envsoft.doclyzer`**.
3. Choose a recognizable nickname, such as `Doclyzer Android`.
4. Register the app and download **`google-services.json`**.
5. Place it at the exact path below, retaining the filename without a download suffix such as `(1)`.

```text
apps/mobile/android/app/google-services.json
```

The repository already declares the Google Services Gradle plugin and applies it when this file exists. Firebase Flutter dependencies are already installed; review the wizard's SDK suggestions without duplicating existing dependencies. [Firebase Android registration](https://firebase.google.com/docs/android/setup)

**Checkpoint:** the JSON's Android package name is `io.envsoft.doclyzer`, and its project ID is the project selected in Step 2.

## 4. Firebase: register Apple and download its file

1. In the same project's **Your apps**, choose **Add app → Apple/iOS**.
2. Enter bundle ID **`io.envsoft.doclyzer`**.
3. Use a nickname such as `Doclyzer iOS`. The App Store ID can be supplied if the app already has one.
4. Register the app and download **`GoogleService-Info.plist`**.
5. Save it here:

```text
apps/mobile/ios/Runner/GoogleService-Info.plist
```

In Xcode, use **File → Add Files to “Runner”…** to add that file to the Runner group. Select the **Runner target**. If the source is outside the project, enable the copy option; if it is already at the path above, avoid making another copy. Confirm Runner target membership and **Build Phases → Copy Bundle Resources** contains the plist once.

Its `BUNDLE_ID` must match the chosen Apple identifier. A plist simply sitting on disk is insufficient if the build does not include it. [Firebase Apple registration and configuration file](https://firebase.google.com/docs/ios/setup)

This app currently calls `Firebase.initializeApp()` using native configuration. Supplying the two native files above fits the existing code; manually inventing `firebase_options.dart` is unnecessary. FlutterFire CLI is an alternative, but review generated changes before adopting explicit Dart options.

## 5. Apple Developer: enable Push Notifications for the App ID

Use the correct team in your [Apple Developer account](https://developer.apple.com/account/). These portal changes require an Account Holder or Admin.

1. Open **Certificates, Identifiers & Profiles → Identifiers**.
2. Select the App ID matching Step 1. For a new app, register an explicit App ID using that bundle ID first.
3. Enable **Push Notifications**, then save/confirm.
4. Refresh or regenerate provisioning profiles affected by the capability change. With automatic signing, let Xcode resolve the profiles for the correct team; with manual signing, regenerate and download them yourself.

App ID capability changes can invalidate existing provisioning profiles. [Apple capability setup](https://developer.apple.com/help/account/identifiers/enable-app-capabilities/)

## 6. Apple Developer: create or reuse an APNs authentication key

An **APNs authentication key** is different from an **App Store Connect API key**, a Sign in with Apple key and a Firebase service-account key.

1. In **Certificates, Identifiers & Profiles → Keys**, check whether your team already has an appropriate APNs key available securely.
2. If a new key is required, click **+**, give it a descriptive name and select **Apple Push Notification service (APNs)**.
3. Click **Configure**. Select the environment and key scope. A **Topic Specific** key must include the chosen bundle ID; a **Team Scoped** key can cover the team's permitted topics.
4. For environment-specific keys, arrange Sandbox coverage for development and Production coverage for distribution. Use the appropriate separate keys/related key where required by the portal. An existing key may already provide the necessary coverage; inspect its configuration.
5. Confirm/register and download the `.p8` file. Record its **Key ID** and environment.
6. Record the **Team ID** from your Apple membership details.

Keep the downloaded file securely: Apple does not allow downloading that private key again. Do not revoke a shared key without checking which other apps use it. [Apple APNs key creation](https://developer.apple.com/help/account/keys/create-a-private-key/)

You are using token-based APNs authentication through Firebase. You do not need to create APNs TLS certificates for this route; app signing certificates and provisioning profiles still serve their separate purpose. [Apple token-based APNs authentication](https://developer.apple.com/help/account/capabilities/communicate-with-apns-using-authentication-tokens/)

## 7. Firebase: upload the APNs keys

Return to **Firebase → Project settings → Cloud Messaging → Apple app configuration**. Select the Apple app registered in Step 4.

Under **APNs authentication key**, upload the applicable development and production keys. For each upload, supply:

| Field | Value |
| --- | --- |
| Authentication key file | The Apple APNs `.p8` file |
| Key ID | The identifier of that specific Apple key |
| Team ID | The Apple Developer team that owns the app/key |
| Environment, if requested | The environment covered by that key |

Save and verify the displayed key information. Configure production coverage for TestFlight/App Store testing as well as development coverage for local signed builds. [Firebase APNs upload instructions](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)

**The `.p8` goes to Firebase. It does not go in the Flutter app or the backend's `FCM_PRIVATE_KEY`.**

## 8. Xcode: verify capabilities and signing

In **Runner target → Signing & Capabilities**:

- Select the Apple **Team** that owns the App ID.
- Verify the bundle ID from Step 1.
- Use automatic signing if that is your team's workflow, or select matching manual profiles.
- Verify **Push Notifications** is present.
- Verify **Background Modes → Remote notifications** is enabled.

The repository already includes these capabilities, the notification-center delegate and `Runner/Runner.entitlements`. Its source entitlement is `aps-environment = development`; validate the environment in the signed distribution archive through the signing/export workflow. An unsigned release build does not prove APNs provisioning is correct.

For this implementation, Remote notifications is the background mode being used; no periodic background-fetch feature was implemented. Keep Firebase method swizzling enabled—do not add `FirebaseAppDelegateProxyEnabled = NO`. [Firebase Flutter Apple requirements](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)

## 9. Firebase: obtain backend credentials

For a server without managed application default credentials:

1. Open **Firebase → Project settings → Service accounts → Firebase Admin SDK**.
2. Choose **Generate new private key**, confirm and download the JSON securely.
3. Keep it on the trusted server/secret store, outside the mobile application and source control.

Prefer a managed service identity where available. A downloaded JSON can be used through `GOOGLE_APPLICATION_CREDENTIALS`. [Firebase Admin credentials setup](https://firebase.google.com/docs/admin/setup)

The service identity must be allowed to send in the intended Google Cloud project. Check IAM if it lacks access; the Firebase Cloud Messaging API Admin role (`roles/firebasecloudmessaging.admin`) includes the message-creation permission. You do not need to grant general project Owner access just to send messages. [Firebase Cloud Messaging roles](https://cloud.google.com/iam/docs/roles-permissions/firebasecloudmessaging)

### Option A: use the downloaded JSON as a server secret

Set these values in the backend environment. Replace every angle-bracket value before using this example:

```dotenv
PUSH_PROVIDER=fcm
FCM_PROJECT_ID=<your-firebase-project-id>
GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/firebase-service-account.json
FCM_CLIENT_EMAIL=
FCM_PRIVATE_KEY=
REPORT_COMPLETION_PUSH_ENABLED=true
PUSH_ADMIN_APPROVAL_SECRET=<a-new-random-secret>
```

The file must actually exist at `GOOGLE_APPLICATION_CREDENTIALS` **inside each sending process/container**. A host path is not automatically accessible inside Docker. Mount the secret read-only into the API and report-dispatcher containers (and a standalone push worker, if used).

### Option B: map the JSON fields into the existing `.env`

The current backend also supports this route:

| Existing `.env` setting | Source |
| --- | --- |
| `PUSH_PROVIDER` | Set to `fcm` |
| `FCM_PROJECT_ID` | JSON `project_id` |
| `FCM_CLIENT_EMAIL` | JSON `client_email` |
| `FCM_PRIVATE_KEY` | JSON `private_key`, including its PEM header/footer |
| `REPORT_COMPLETION_PUSH_ENABLED` | Set to `true` for automatic report pushes |
| `PUSH_ADMIN_APPROVAL_SECRET` | Generate your own random secret; Firebase does not provide it |

Use a quoted single-line private-key value with escaped `\n` line breaks. The backend converts those escapes into real line breaks. Do not paste the Apple `.p8` key into this setting. Choose one credential route; the code selects explicit email/private-key credentials when both are present, otherwise application default credentials.

To generate the separate broadcast approval secret locally:

```sh
openssl rand -hex 32
```

Keep the output private. The existing admin broadcast workflow uses it when scheduling/sending to multiple users.

After changing `.env`, recreate the relevant Docker Compose containers through your deployment workflow; `docker compose restart` alone does not reload changed container environment values. Ensure the notification migration has been applied and a dispatcher is running. See [the backend rollout guide](push-notifications.md#server-configuration).

## 10. Rebuild and test through Doclyzer

From `apps/mobile`:

```sh
flutter pub get
flutter devices
flutter run -d <your-device-id>
```

Use a signed build on a physical iPhone. An unsigned iOS build cannot be installed as the device verification step. Test Android separately using the same Firebase project.

For the current implementation:

1. Sign in to Doclyzer on the device.
2. Open **Account → Notification preferences** and tap **Enable**. Accept the OS notification request.
3. For a marketing test, enable **Marketing push notifications** and save. OS permission alone does not opt the account/device into marketing.
4. Sign into the web admin with the **same account**. It must have the existing superadmin role.
5. Open **Admin → Notifications → Marketing campaigns**.
6. Create a draft with a safe generic title/body and destination `/notifications`.
7. Review the preview. Your device should be eligible.
8. Click **Test on my devices**. The implementation sends only to the current admin's eligible devices; it creates a separate test campaign.
9. Check both foreground and background behavior, then tap the notification. Refresh campaign analytics.
10. Complete a report to test the separate automatic report event flow.

Use the app's composer for the complete test. It includes Doclyzer's versioned payload and recipient IDs. A plain Firebase Console test can check basic background delivery, but cannot by itself prove this app's custom routing and database analytics work.

Repeat the iPhone check with a properly signed distribution/TestFlight build. Confirm production APNs credentials and signing, not just development delivery.

## 11. Troubleshooting

| Symptom | Check first |
| --- | --- |
| Push initialization unavailable | Correct native config file is present and included in the build; rebuild the app. |
| iOS APNs token unavailable | Correct Apple team, push capability, signed profile and physical device. Then resume the app to retry registration. |
| Android works but iOS does not | Apple bundle ID, plist target membership, APNs key/Team ID and environment. |
| Development works but TestFlight fails | Production APNs key coverage and distribution provisioning. |
| Authentication/project error from FCM | Backend project ID, service identity permissions and matching mobile Firebase project. |
| Eligible device count is zero | Signed-in account, OS permission, account marketing opt-in, this device's marketing opt-in and recent registration. |
| Campaign remains queued | The dispatcher is running with the new migration and Firebase credentials. |
| Provider accepted but no banner | Device permission, foreground/background state, iOS Focus/notification settings; acceptance is not confirmed delivery. |
| Firebase Console test displays, but tap does not route | Use the Doclyzer campaign composer to supply the required payload. |

## Completion checklist

- [ ] Apple app identity selected; iOS Debug/Release/Profile identifiers checked.
- [ ] Android and Apple apps registered in the intended Firebase project.
- [ ] FCM API V1 enabled.
- [ ] `google-services.json` installed at the Android app path.
- [ ] `GoogleService-Info.plist` added to the Runner target once.
- [ ] Push enabled for the Apple App ID; signing profiles refreshed.
- [ ] APNs keys uploaded to Firebase with correct Key ID, Team ID and environment coverage.
- [ ] Xcode team, capabilities and signing verified.
- [ ] Backend Firebase credentials configured; Apple key and Firebase key kept separate.
- [ ] API/dispatcher environment refreshed and notification migration applied.
- [ ] Real Android and physical iPhone receive test pushes.
- [ ] Foreground, background, terminated launch, tap navigation and marketing opt-out checked.
- [ ] Signed Android release and iOS distribution/TestFlight behavior checked.

Keep `.p8` files and service-account private keys out of Git, Flutter assets, screenshots and shared logs. The mobile Firebase configuration files identify the client apps; they are not replacements for the backend's sending credentials.
