# Story 3.4: Copy/Distribute Share Link UX

Status: done

## Story

As an authenticated user,
I want copy and native share actions on my share links,
so that distributing links to doctors or others is low-friction.

## Acceptance Criteria

1. **Given** a share link exists in the active links list
   **When** the user taps the copy icon
   **Then** the URL is copied to clipboard and a SnackBar confirms "Link copied to clipboard"

2. **Given** a share link exists in the active links list
   **When** the user taps the share icon (share/send)
   **Then** the native OS share sheet opens with the link URL as the share payload

3. **Given** a new share link was just created (created state)
   **When** the "Copy Link" button is tapped
   **Then** the URL is copied to clipboard and a SnackBar confirms "Link copied to clipboard"

4. **Given** a new share link was just created (created state)
   **When** a "Share Link" button is tapped
   **Then** the native OS share sheet opens with the link URL

5. **Given** the native share sheet is opened
   **When** the user selects an app (e.g., Messages, WhatsApp, email)
   **Then** the link is passed as the message body to that app's share flow

6. **Given** the share sheet is dismissed (user cancels)
   **When** dismissed without sharing
   **Then** no error is shown; the UI stays in its current state unchanged

## Tasks / Subtasks

- [x] Add `share_plus` package to Flutter dependencies (AC: 2, 4, 5)
  - [x] In `apps/mobile/pubspec.yaml`, add `share_plus: ^10.1.4` under `dependencies`
  - [x] Run `flutter pub get` (dev will do this; just note it in file list)

- [x] Add share action to existing links list in `CreateShareLinkScreen` (AC: 1, 2)
  - [x] In `_CreateShareLinkScreenState`, add `_shareLink(String url)` method that calls `Share.share(url)` from `package:share_plus/share_plus.dart`
  - [x] In the existing links `Card > ListTile` trailing `Row`, add `IconButton` with `Icons.share_outlined` BEFORE the copy icon: `IconButton(key: Key('share-existing-link-${link.id}'), icon: const Icon(Icons.share_outlined), tooltip: 'Share link', onPressed: () => _shareLink(link.shareUrl))`
  - [x] The existing copy `IconButton` key remains `Icons.copy_outlined` (no key currently — add `key: Key('copy-existing-link-${link.id}')` to the copy button for consistency)

- [x] Add "Share Link" button to newly-created link section (AC: 4, 5, 6)
  - [x] In the `_CreateState.created && _newLink != null` block, after the existing "Copy Link" `ElevatedButton`, add an `OutlinedButton` for sharing:
    ```dart
    OutlinedButton(
      key: const Key('share-link-button'),
      onPressed: () => _shareLink(_newLink!.shareUrl),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.share_outlined, size: 16), SizedBox(width: 8), Text('Share Link')],
      ),
    ),
    ```
  - [x] Place it BETWEEN the "Copy Link" button and the "Revoke Link" button

- [x] Add `share_plus` import to `create_share_link_screen.dart` (AC: 2, 4)
  - [x] Add `import 'package:share_plus/share_plus.dart';` to the top of `create_share_link_screen.dart`

## Dev Notes

### Scope
- **Pure Flutter UI change** — no backend changes required
- Adds native OS share sheet alongside existing clipboard copy
- `share_plus` is the standard Flutter package for OS-level share sheets (pub.dev: https://pub.dev/packages/share_plus)
- No new screens needed — changes only to `create_share_link_screen.dart`

### Package: `share_plus`
- **Add to `pubspec.yaml`:** `share_plus: ^10.1.4`
- **Import:** `import 'package:share_plus/share_plus.dart';`
- **Usage:** `Share.share(url)` opens the native share sheet. No subject needed for a bare URL.
- `Share.share()` is async but can be called with `unawaited` — failures are handled internally by the package (no exception on cancel)
- Works on both iOS (UIActivityViewController) and Android (ACTION_SEND Intent) out of the box
- No platform-specific config required for basic URL sharing

### Method to add to `_CreateShareLinkScreenState`
```dart
Future<void> _shareLink(String url) async {
  await Share.share(url);
}
```

### Existing copy mechanism (DO NOT change)
The `_copyLink()` method already works correctly:
```dart
Future<void> _copyLink(String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }
}
```
This is already wired to both the copy icon in existing links AND the "Copy Link" button in the created state. Do NOT change it.

### Widget key convention
- Copy icon on existing link tile: `Key('copy-existing-link-${link.id}')` — add key (currently missing)
- Share icon on existing link tile: `Key('share-existing-link-${link.id}')`
- Share button on created link: `Key('share-link-button')`
- These follow the kebab-case widget key pattern used in 3.1–3.3

### Exact position for "Share Link" button in created state
Current order in `_CreateState.created` block:
1. `SelectableText(_newLink!.shareUrl, key: Key('share-url-text'))`
2. Expiry text (conditional)
3. `SizedBox(height: 16)`
4. **`ElevatedButton` "Copy Link"** ← `Key('copy-link-button')`
5. `SizedBox(height: 8)`
6. **`OutlinedButton` "Revoke Link"** ← `Key('new-link-revoke-button')`

New order should be:
1. `SelectableText` (unchanged)
2. Expiry text (unchanged)
3. `SizedBox(height: 16)`
4. `ElevatedButton` "Copy Link" (unchanged)
5. `SizedBox(height: 8)`
6. **NEW** `OutlinedButton` "Share Link" ← `Key('share-link-button')`
7. `SizedBox(height: 8)`
8. `OutlinedButton` "Revoke Link" (unchanged)

### Project Structure Notes
- Only file to modify: `apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart`
- Only file to add package to: `apps/mobile/pubspec.yaml`
- No new files needed

### References
- [Source: apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart] — full existing implementation
- [Source: apps/mobile/pubspec.yaml] — current dependencies (share_plus not present)
- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.4]
- [Source: _bmad-output/implementation-artifacts/3-3-default-share-policy-settings-for-new-links.md] — previous story patterns

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Added `share_plus: ^10.1.4` dependency to pubspec.yaml
- Added `_shareLink(String url)` method using `Share.share(url)` from share_plus
- Added share icon (`Icons.share_outlined`) before copy icon in existing links list with keyed buttons
- Added `share-link-button` OutlinedButton in created state between "Copy Link" and "Revoke Link"
- Added `share_plus` import to create_share_link_screen.dart
- All 6 ACs satisfied: clipboard copy with SnackBar (existing, unchanged), native share sheet for both existing links and newly created link, cancel/dismiss handled by share_plus internally

### File List

- apps/mobile/pubspec.yaml
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart

### Change Log

- 2026-03-22: Implemented story 3.4 — added share_plus package and native OS share sheet actions to CreateShareLinkScreen
