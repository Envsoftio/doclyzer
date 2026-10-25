# Codex Task: Audit and Complete RevenueCat Token Purchase Flow for Existing Flutter App

## Objective

You are working inside an **existing Flutter application** that already has a token/credit system and may already contain partial purchase, wallet, backend, Google Play, App Store, or RevenueCat implementation.

Your task is **not to start from scratch**.

Your task is to:

1. Inspect the current implementation in the repository.
2. Understand how authentication, tokens, wallet balance, token spending, networking, backend APIs, Android, iOS, and any billing code currently work.
3. Identify what is already complete, partially implemented, incorrect, insecure, outdated, or missing.
4. Produce a concise implementation-gap report.
5. Continue from the existing codebase and implement only the missing or incorrect parts.
6. Integrate RevenueCat for token-pack purchases on both:
   - Google Play Store / Android
   - Apple App Store / iOS
7. Keep the application's existing backend token ledger/wallet as the **source of truth**.
8. Verify the complete end-to-end flow after implementation.

Do not perform a broad rewrite. Preserve existing project architecture and conventions wherever possible.

---

# 1. Mandatory First Step: Audit the Existing Project

Before adding packages or modifying code, inspect the repository thoroughly.

Determine the following.

## Flutter / Dart

- Flutter version
- Dart version
- Current `pubspec.yaml`
- Existing dependencies related to:
  - RevenueCat
  - purchases
  - billing
  - StoreKit
  - Google Play Billing
  - payments
- Whether `purchases_flutter` is already installed
- Existing version of `purchases_flutter`, if present

## Application architecture

Identify:

- State management approach
  - Riverpod
  - Bloc/Cubit
  - Provider
  - GetX
  - MobX
  - custom
- Repository/service structure
- Dependency injection
- Routing
- Error handling
- Loading states
- Environment/configuration system
- Logging
- Analytics

Do not introduce a second architectural style unnecessarily.

## Authentication

Inspect:

- Current login flow
- Session persistence
- Auth token storage
- Current authenticated user model
- Stable backend user ID
- Logout flow
- Account switching behavior

Identify the correct stable user identifier that can be used as RevenueCat `appUserID`.

Do not use email, phone number, display name, or temporary device identifiers if a proper backend user ID exists.

## Existing token system

Find and document:

- Current token balance field/API
- Token wallet service/repository
- Token ledger/history
- Free tokens
- Referral credits
- Promotional/admin credits
- Token deductions
- Token usage during report processing or other features
- Existing balance-refresh logic
- Existing transaction tables/models if backend code exists in this repository

Determine whether the current system stores only a balance or maintains an auditable ledger.

## Existing purchase implementation

Search the entire repository for:

- RevenueCat
- `Purchases`
- `purchases_flutter`
- `purchasePackage`
- `purchaseStoreProduct`
- `getOfferings`
- `restorePurchases`
- `BillingClient`
- Google Play Billing
- StoreKit
- in-app purchase packages
- payment services
- token package IDs
- product IDs
- webhooks
- purchase sync APIs

Do not duplicate purchase logic that already exists.

## Backend

If backend source exists in the same workspace, inspect it too.

Find:

- wallet APIs
- token balance APIs
- token ledger
- purchase endpoints
- webhook endpoints
- RevenueCat integration
- transaction-id handling
- product-to-token mapping
- refund handling
- idempotency handling

If backend source is not present, clearly state that and generate a backend integration specification instead of pretending backend work was completed.

## Android

Inspect:

- application/package ID
- `android/app/build.gradle` or `build.gradle.kts`
- min SDK
- target SDK
- manifest
- current billing dependencies
- existing RevenueCat setup
- flavor/environment setup
- release signing configuration only as needed for compatibility; do not expose secrets

## iOS

Inspect:

- bundle identifier
- deployment target
- `Podfile`
- Xcode project capabilities/configuration
- StoreKit/In-App Purchase setup present in repository
- existing RevenueCat setup
- configuration for flavors/environments

---

# 2. Produce an Audit Report Before Major Changes

After inspecting the repository, output a concise report with these sections:

## Current implementation

Explain what already exists.

## Working correctly

List components that should be preserved.

## Partial / incomplete

List anything that exists but is not production-ready.

## Missing

List required pieces that do not exist.

## Security / correctness risks

Call out issues such as:

- client directly increasing token balance
- trusting token quantity sent by Flutter
- duplicate transaction risk
- missing webhook authentication
- hardcoded secret API keys
- anonymous RevenueCat users despite app login
- purchase success shown before backend credit
- missing refund handling
- duplicated Google Billing and RevenueCat implementations
- hardcoded prices
- incorrect restore behavior for consumables

## Files to modify

List existing files that need changes.

## Files to create

List new files only if required.

## Backend actions

Separate:

- code that can be implemented now
- configuration requiring credentials/dashboard access
- missing backend source/code

Then proceed with implementation without asking for confirmation unless a truly blocking secret or external credential is required.

---

# 3. Target Architecture

The final purchase architecture must be:

```text
Flutter App
    |
    v
RevenueCat Flutter SDK
    |
    +----------------------+
    |                      |
    v                      v
Google Play Billing     Apple StoreKit
    |                      |
    +----------+-----------+
               |
               v
          RevenueCat
               |
               v
         Our Backend
               |
               v
        Token Ledger
               |
               v
        Token Balance
               |
               v
      Flutter Wallet Refresh
```

RevenueCat handles the store-purchase layer and purchase validation/orchestration.

Our backend token wallet remains the authority for application tokens.

---

# 4. Non-Negotiable Wallet Rule

The Flutter client must NEVER permanently credit purchased tokens itself.

Do not do this:

```dart
balance += 300;
```

or:

```dart
currentUser.tokens += purchasedPackage.tokens;
```

A successful RevenueCat callback means the store purchase completed. It does **not** mean Flutter is authorized to mutate the server wallet.

The correct flow is:

```text
Store purchase succeeds
        |
        v
RevenueCat confirms purchase
        |
        v
Backend processes transaction
        |
        v
Backend credits token ledger exactly once
        |
        v
Flutter reloads wallet from backend
```

---

# 5. RevenueCat Flutter Integration

Use the official RevenueCat Flutter SDK:

```text
purchases_flutter
```

Before writing RevenueCat code:

1. Check whether it is already installed.
2. Check its installed/current version.
3. Read the APIs available in that version.
4. Use the current signatures rather than copying deprecated examples.

Do not downgrade a working dependency merely to match an old example.

---

# 6. RevenueCat Configuration

Support separate public SDK keys for Android and iOS.

Use the project's existing config/environment mechanism.

Conceptually:

```dart
class RevenueCatConfig {
  static const androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
  );

  static const iosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
  );
}
```

Adapt this to the existing environment system.

Never include in Flutter:

- RevenueCat secret API keys
- Google Play service-account credentials
- App Store Connect private keys
- webhook secrets

RevenueCat mobile SDK keys are public application keys, but still keep their configuration centralized.

---

# 7. RevenueCat User Identity

The application already has authenticated users.

Use the stable backend user ID as RevenueCat `appUserID`.

Example:

```text
Backend user ID: user_12345
RevenueCat appUserID: user_12345
```

Handle correctly:

- app start
- already-authenticated session
- login
- logout
- user switching
- app restart
- RevenueCat initialization before/after authentication

Avoid accidental purchase association or aliasing between different application accounts.

Inspect RevenueCat's current SDK behavior for `configure`, `logIn`, and `logOut` before implementing.

---

# 8. Token Packs

These purchases are **consumable token/credit packs**.

Example products only:

```text
tokens_100
tokens_300
tokens_700
tokens_1500
```

Do not assume these IDs are correct.

First inspect the existing repository/configuration and preserve existing IDs where applicable.

The backend must own the authoritative mapping:

```text
product_id -> token amount
```

Example:

```text
tokens_100  -> 100
tokens_300  -> 300
tokens_700  -> 700
tokens_1500 -> 1500
```

Flutter may contain display metadata, but it must not be trusted for wallet crediting.

---

# 9. RevenueCat Offerings

Prefer a RevenueCat Offering such as:

```text
token_packs
```

The actual identifier must come from existing configuration or be documented for dashboard setup.

Load products through RevenueCat Offerings/packages rather than hardcoding store prices.

Use the localized price returned by the store through RevenueCat.

Never hardcode values like:

```text
₹99
$4.99
```

in business logic.

The Flutter token store should remain platform-independent.

---

# 10. Android and iOS Product IDs

Do not assume Android and iOS product IDs must be identical.

RevenueCat packages can abstract the difference.

Conceptual example:

```text
RevenueCat package:
token_pack_300

Android product:
tokens_300_android

Apple product:
tokens_300_ios
```

If the project already uses identical IDs on both stores, preserve that structure.

---

# 11. Do Not Use RevenueCat Entitlements as the Token Wallet

Purchased tokens are consumable credits.

Do not model token balance using permanent RevenueCat entitlements.

The application backend wallet/ledger determines how many usable tokens the user owns.

Entitlements may still be used later for subscriptions or permanent unlocks, but not as the token balance.

---

# 12. Purchase Service

If the existing architecture allows it, isolate RevenueCat behind a service/repository.

Conceptual responsibilities:

```text
initializeRevenueCat()
identifyUser()
getTokenOffering()
purchaseTokenPackage()
syncPurchases()
logoutRevenueCatUser()
```

Possible model:

```dart
class TokenPackage {
  final String packageIdentifier;
  final String productIdentifier;
  final int displayTokens;
  final String localizedPrice;
}
```

Adapt names and structure to the repository.

Do not spread RevenueCat API calls across many widgets.

Do not introduce unnecessary abstraction if an equivalent service already exists.

---

# 13. Token Store Screen

Reuse the app's existing design system.

Show:

```text
Your Balance
420 Tokens
```

and available packs:

```text
100 Tokens      localized store price
300 Tokens      localized store price
700 Tokens      localized store price
1500 Tokens     localized store price
```

Use the localized store price provided through RevenueCat.

Handle states:

- loading offerings
- offerings loaded
- empty/unavailable offering
- purchase in progress
- purchase cancelled
- purchase pending if exposed
- purchase failed
- payment complete but backend wallet update pending
- wallet refreshed

Prevent repeated taps from starting parallel purchases.

---

# 14. End-to-End Purchase Flow

Implement this behavior:

```text
User opens token store
        |
        v
Load RevenueCat Offering
        |
        v
Show packages + localized prices
        |
        v
User taps Buy
        |
        v
Disable duplicate purchase taps
        |
        v
RevenueCat purchase API
        |
        v
Google Play / App Store purchase sheet
        |
        v
Purchase succeeds
        |
        v
Trigger backend purchase synchronization
        |
        v
Backend validates/processes verified transaction
        |
        v
Backend credits wallet exactly once
        |
        v
Flutter refreshes wallet from backend
        |
        v
Show updated server balance
```

Do not optimistically add purchased tokens locally.

---

# 15. Backend Purchase Synchronization

A RevenueCat webhook is strongly preferred for asynchronous reconciliation, but Flutter should not rely solely on webhook timing immediately after purchase.

After purchase success, call an authenticated backend synchronization endpoint if the existing backend architecture supports it.

Conceptual endpoint:

```http
POST /api/billing/revenuecat/sync
```

The backend should identify the user from the authenticated session/token.

Do not trust a client-provided target user ID.

Do not design this:

```json
{
  "user_id": "someone_else",
  "tokens": 10000
}
```

Instead, the backend must determine:

- authenticated user
- RevenueCat customer/app user ID
- verified transactions
- product ID
- token amount from server configuration
- whether the transaction was already processed

Example response:

```json
{
  "success": true,
  "purchaseProcessed": true,
  "balance": 720
}
```

Use existing API response conventions where available.

---

# 16. RevenueCat Webhook

If backend code is available, implement or complete an endpoint such as:

```http
POST /webhooks/revenuecat
```

Use RevenueCat's current webhook authentication/header mechanism.

Do not hardcode webhook secrets into Flutter.

Process the current RevenueCat event schema instead of assuming an old payload format.

Handle relevant one-time purchase events and refund/cancellation/reversal events.

Store sufficient metadata for audit/debugging without unnecessarily storing sensitive data.

---

# 17. Idempotency Is Mandatory

A purchase must grant tokens exactly once.

RevenueCat may retry webhook delivery.

The Flutter app may also call the synchronization endpoint multiple times.

Therefore the backend must use an external transaction identifier as an idempotency key.

Conceptual ledger schema:

```text
token_transactions

id
user_id
amount
type
source
product_id
store
external_transaction_id UNIQUE
created_at
metadata
```

Before crediting:

```text
if external_transaction_id already processed:
    return previous/current result
else:
    process credit once
```

Use a database unique constraint, not only application-level `if` logic.

---

# 18. Atomic Wallet Transaction

Purchase processing must be atomic.

Conceptually:

```text
BEGIN TRANSACTION

check transaction ID

if already exists:
    return idempotent success

resolve product ID using server product map

insert purchase ledger entry

credit wallet

COMMIT
```

Use the locking/transaction primitives appropriate to the actual database.

Avoid race conditions if webhook and sync endpoint process the same transaction simultaneously.

---

# 19. Existing Token Sources Must Continue Working

The same wallet must support:

```text
SIGNUP
REFERRAL
PROMOTIONAL
ADMIN_CREDIT
GOOGLE_PLAY_PURCHASE
APP_STORE_PURCHASE
USAGE
REFUND
ADJUSTMENT
```

Do not move free/referral/promotional credits into RevenueCat.

Example ledger:

```text
+100 SIGNUP
+50  REFERRAL
+300 APP_STORE_PURCHASE
-25  REPORT_USAGE
```

RevenueCat should only be responsible for store purchase lifecycle.

---

# 20. Refund Handling

Inspect whether refund handling already exists.

If not, design/implement it.

Do not delete the original purchase record.

Create a compensating ledger entry.

Example:

```text
+300 PURCHASE
-300 REFUND
```

Use the original transaction/purchase reference to prevent duplicate refund processing.

If the user has already spent some/all purchased tokens, preserve ledger correctness.

If the backend currently allows negative balances, use the existing rule.

If it does not, clearly document the recommended handling instead of inventing inconsistent behavior silently.

---

# 21. User Cancellation

Handle purchase cancellation separately from actual errors.

A user closing the Google Play/App Store purchase sheet should not generate a severe generic error.

Use either:

```text
Purchase cancelled
```

or silently return to the token-store screen if that matches the existing UX.

Use the correct cancellation exception/code from the installed RevenueCat SDK version.

---

# 22. Pending Purchases

Handle store purchases that can remain pending.

Do not credit tokens until the store/RevenueCat considers the transaction completed/verified.

If the SDK exposes an explicit pending result/state, represent it correctly in the UI and reconciliation flow.

Do not treat pending as failure.

---

# 23. Successful Payment but Backend Temporarily Unavailable

This is a critical recovery scenario.

Example:

```text
Payment succeeds
       |
       v
Flutter calls backend
       |
       v
Backend temporarily unavailable
```

Do not show a misleading "payment failed" message.

Use a state such as:

```text
Payment received. We are updating your token balance.
```

The transaction must be recoverable via:

- RevenueCat webhook
- later purchase sync
- wallet refresh/reconciliation after login/app restart

Do not retry forever in the client.

Use bounded retry/recheck behavior.

---

# 24. App Lifecycle Recovery

Support:

```text
Purchase starts
App closes
Purchase finishes
User reopens app
```

On appropriate app start/login/wallet entry points:

1. Ensure RevenueCat customer identity is correct.
2. Reconcile/sync purchases if required.
3. Refresh wallet balance from backend.

The user must not lose a paid purchase merely because the original Flutter callback never returned.

---

# 25. Restore Purchases

These token packs are consumables.

Do not use "Restore Purchases" as a mechanism to grant consumed token packs again.

If the app has or later adds:

- subscriptions
- non-consumables
- permanent purchases

restore logic may apply to those separately.

Never recredit token consumables just because restore was called.

---

# 26. Wallet Refresh

After backend confirmation, reload balance from the existing wallet API/repository.

Correct:

```dart
final balance = await walletRepository.getBalance();
```

Incorrect:

```dart
balance = balance + purchasedTokens;
```

The displayed balance should come from the backend after the purchase is processed.

---

# 27. Product Mapping Must Be Server-Side

The backend owns the authoritative mapping.

Conceptual configuration:

```text
token_pack_100:
  android_product_id: tokens_100_android
  ios_product_id: tokens_100_ios
  token_amount: 100
  active: true
```

Use the project's actual configuration/data model if one exists.

The client may display the token amount but must never be authoritative for what is credited.

---

# 28. Android Requirements

Inspect and complete the Android implementation.

Verify:

- correct package/application ID
- RevenueCat Android SDK key configuration
- `purchases_flutter` Android compatibility
- min SDK
- target SDK
- release build compatibility
- no conflicting independent BillingClient implementation unless there is a documented reason

RevenueCat should normally be the billing abstraction.

Do not maintain two competing purchase flows.

Document remaining Google Play Console tasks separately:

```text
1. Create one-time/consumable products.
2. Configure prices.
3. Activate products.
4. Ensure app build is uploaded to an appropriate testing track.
5. Configure testers/license testing as required.
6. Connect Google Play app/project to RevenueCat.
7. Import/create products in RevenueCat.
8. Attach products to the token-packs Offering/packages.
9. Configure Google real-time/server notifications required by RevenueCat for purchase/refund synchronization.
```

Use current console terminology when reporting final steps.

---

# 29. iOS Requirements

Inspect and complete the iOS implementation.

Verify:

- bundle identifier
- deployment target
- RevenueCat iOS SDK key configuration
- CocoaPods/SPM dependencies as used by Flutter package
- In-App Purchase capability/configuration where needed
- StoreKit compatibility
- release build compatibility

Document remaining App Store Connect tasks separately:

```text
1. Create consumable in-app purchases.
2. Configure pricing.
3. Complete required metadata.
4. Ensure agreements/tax/banking requirements are satisfied where necessary.
5. Connect App Store Connect to RevenueCat.
6. Import/create products in RevenueCat.
7. Attach them to the token-packs Offering/packages.
8. Configure sandbox users/testing.
9. Configure App Store server notifications/integrations required by RevenueCat for lifecycle/refund updates.
```

Use current App Store Connect terminology in the final report.

---

# 30. Common Flutter Purchase Interface

The Flutter UI should not care whether the store is Android or iOS.

Conceptually:

```text
Token Store UI
      |
      v
Purchase Service
      |
      v
RevenueCat
   /      \
Android   iOS
```

Platform-specific behavior should remain behind the purchase service unless the existing architecture requires otherwise.

---

# 31. Error Handling

Handle at least:

- RevenueCat initialization failure
- configuration/API key missing
- offering unavailable
- product missing
- store unavailable
- network unavailable
- user cancellation
- purchase pending
- payment failure
- RevenueCat purchase failure
- backend synchronization failure
- wallet refresh failure
- successful payment but delayed token credit

Do not expose raw stack traces or sensitive internal errors to users.

Preserve diagnostic details in safe logs.

---

# 32. Logging

Use the project's existing logging system.

Useful events include:

```text
RevenueCat initialized
RevenueCat user identified
Offering load started
Offering loaded
Purchase started
Purchase cancelled
Purchase returned success
Backend sync started
Backend sync succeeded
Backend sync delayed/failed
Wallet refreshed
Webhook received
Duplicate transaction ignored
Purchase credited
Refund processed
```

Never log:

- auth tokens
- webhook secrets
- private API keys
- payment credentials
- unnecessary PII

---

# 33. Analytics

If analytics already exists, add events following the project's conventions:

```text
token_store_viewed
token_pack_selected
token_purchase_started
token_purchase_completed
token_purchase_cancelled
token_purchase_failed
```

Do not add a new analytics provider just for this task.

---

# 34. Security Rules

These are non-negotiable.

## Never trust client token quantity

Do not accept this as authoritative:

```json
{
  "tokens": 5000
}
```

## Never expose server secrets in Flutter

Do not place:

- RevenueCat secret keys
- Google service account credentials
- App Store private keys
- webhook authorization secrets

inside the application bundle.

## Never grant based only on UI callback

A modified APK/IPA must not be able to mint tokens.

## Never process a transaction twice

Use database-level uniqueness/idempotency.

## Never let arbitrary client user IDs control wallet destination

Use authenticated server identity.

## Always use the backend ledger

```text
Verified transaction
      |
      v
Backend idempotency check
      |
      v
Ledger credit
      |
      v
Server balance
```

---

# 35. Testing Requirements

Add tests using the current test architecture where practical.

## Flutter

Test:

- offering loading
- token-package conversion/modeling
- purchase state management
- successful purchase -> backend sync
- successful purchase -> wallet refresh
- cancellation
- failure
- delayed backend sync
- prevention of double taps
- account logout/login behavior

Use mocks/fakes for RevenueCat wrapper/service rather than trying to execute real store transactions in unit tests.

## Backend

If backend is available, test:

- valid purchase transaction
- product mapping
- token credit
- duplicate webhook
- duplicate sync request
- webhook and sync arriving concurrently
- invalid product ID
- unknown user
- refund
- duplicate refund
- atomic rollback on failure

## Manual Android

Verify:

- offering loads from Google Play configuration
- localized price is correct
- purchase succeeds
- cancellation works
- pending transaction behavior
- wallet credited once
- app restart recovery
- different user on same device
- refund flow

## Manual iOS

Verify:

- offering loads from App Store Connect configuration
- localized price is correct
- sandbox purchase succeeds
- cancellation works
- wallet credited once
- app restart recovery
- different user on same device
- refund/revocation behavior

---

# 36. Concrete Duplicate-Credit Test

Example starting balance:

```text
100
```

Buy a 300-token product.

Expected:

```text
400
```

Deliver the same webhook again.

Expected:

```text
400
```

Call sync endpoint again.

Expected:

```text
400
```

Not:

```text
700
```

Then spend 25 tokens.

Expected:

```text
375
```

This test must pass conceptually and, where backend tests exist, automatically.

---

# 37. Build and Verification

After implementation:

Run the project's normal formatting/linting/test pipeline.

At minimum, where supported by the environment:

```bash
flutter pub get
flutter analyze
flutter test
```

Also verify Android build using the project's normal build flavor/configuration.

Verify iOS compilation/build where the current development environment permits it.

Do not claim iOS build verification if running on an environment that cannot perform it.

Fix warnings/errors introduced by this implementation.

Do not opportunistically fix unrelated project-wide issues unless they block this work.

---

# 38. Manual Dashboard Configuration Must Be Separated From Code

At completion, clearly distinguish four categories:

## Completed in code

What Codex actually changed and verified.

## RevenueCat Dashboard actions

What still needs to be configured manually.

## Google Play Console actions

What still needs to be configured manually.

## App Store Connect actions

What still needs to be configured manually.

## Backend / deployment actions

Webhook URL, environment variables, credentials, database migration, production deployment, etc.

Do not imply external configuration was completed when Codex did not have access to it.

---

# 39. Required Final Report From Codex

After finishing, provide a final report with the following exact structure.

## 1. Existing implementation found

Summarize what was already present before changes.

## 2. Problems found

List correctness/security/architecture issues discovered.

## 3. Changes implemented

Explain what was actually changed.

## 4. Files modified

List each file and purpose.

## 5. Files created

List each new file and purpose.

## 6. Backend status

State whether backend code was available and what was implemented.

## 7. RevenueCat status

State what is complete in code versus dashboard configuration still needed.

## 8. Google Play status

List remaining Play Console actions.

## 9. App Store status

List remaining App Store Connect actions.

## 10. Database / migration changes

List migrations/indexes/unique constraints added or still required.

## 11. Security verification

Explicitly confirm:

- Flutter cannot directly mint purchased tokens
- token amount comes from backend mapping
- transaction idempotency exists
- secrets are not bundled in Flutter
- purchases are associated with authenticated backend users

If any cannot be confirmed, say so clearly.

## 12. Testing performed

List commands/tests actually run and their results.

## 13. Remaining blockers

Only list genuine remaining blockers.

## 14. Exact next actions for developer

Give an ordered checklist of what I must do manually after Codex finishes.

---

# 40. Implementation Decision Rules

Follow these rules while working.

### If RevenueCat is already partially implemented

Do not replace it blindly.

Audit it, preserve correct pieces, and complete/fix the missing pieces.

### If another Flutter in-app purchase library already exists

Determine whether it is still actively used.

Do not leave two competing billing systems unless there is a documented requirement.

If RevenueCat is intended to replace it, migrate carefully and remove only obsolete code after verifying there are no other dependencies.

### If backend purchase credit already exists

Audit for:

- server-side product mapping
- transaction uniqueness
- authentication
- refund behavior
- webhook retries

Reuse it if sound.

### If backend is not in this repository

Do not fake backend implementation.

Implement Flutter integration only as far as safely possible and produce a concrete backend contract/specification.

### If product IDs are unknown

Do not invent production IDs.

Create centralized placeholders/configuration and clearly list exactly what must be filled in.

### If RevenueCat keys are unavailable

Do not block all code work.

Wire environment/config support and document what key values must be supplied later.

### If store products are not yet configured

Implement the application integration and provide exact dashboard/console setup steps, but do not claim live purchase testing succeeded.

---

# 41. Further Action After the Audit

Once the initial audit is complete, follow this priority order.

## Priority 1: Protect the existing wallet

Fix any ability for Flutter to directly grant purchased tokens.

## Priority 2: Correct user identity

Ensure RevenueCat purchases are tied to the authenticated backend user ID.

## Priority 3: Load real store products

Wire RevenueCat Offerings and localized prices.

## Priority 4: Implement purchase flow

Implement Android/iOS RevenueCat purchasing using the installed SDK version.

## Priority 5: Implement server synchronization

Ensure successful purchases reach the backend and become idempotent ledger entries.

## Priority 6: Implement webhook reconciliation

Ensure purchases are eventually credited even if Flutter disappears mid-flow.

## Priority 7: Refund handling

Ensure refunded/reversed transactions produce safe ledger adjustments.

## Priority 8: Lifecycle recovery

Ensure app restart/login refreshes and reconciles purchases correctly.

## Priority 9: Testing

Verify duplicate protection, cancellation, error handling, and account switching.

## Priority 10: External configuration checklist

Produce exact steps for RevenueCat, Play Console, and App Store Connect.

---

# 42. Desired Production Behavior

Android:

```text
Flutter
  -> RevenueCat
  -> Google Play Billing
  -> RevenueCat verification
  -> backend sync/webhook
  -> token ledger
  -> wallet balance
  -> Flutter refresh
```

iOS:

```text
Flutter
  -> RevenueCat
  -> Apple StoreKit/App Store
  -> RevenueCat verification
  -> backend sync/webhook
  -> token ledger
  -> wallet balance
  -> Flutter refresh
```

Both platforms must lead to identical application-level wallet behavior.

---

# 43. Definition of Done

This task is not complete merely because this works:

```dart
Purchases.purchase(...)
```

It is complete only when the project has a coherent implementation for:

```text
Product discovery
       |
       v
Localized pricing
       |
       v
Purchase
       |
       v
Verified transaction
       |
       v
Authenticated backend processing
       |
       v
Idempotent token credit
       |
       v
Wallet refresh
       |
       v
App lifecycle recovery
       |
       v
Refund/reversal handling
```

Preserve the existing project architecture.

Do not perform unnecessary refactors.

Do not guess when the repository can answer the question.

Inspect first, then modify.
