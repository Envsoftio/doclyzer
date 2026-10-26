import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/auth_repository.dart';
import 'package:mobile/features/auth/screens/change_password_screen.dart';
import 'package:mobile/features/account/screens/account_information_screens.dart';

class _Auth extends Fake implements AuthRepository {
  String? currentPassword;
  String? newPassword;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    this.currentPassword = currentPassword;
    this.newPassword = newPassword;
    if (currentPassword != 'OldPass1!') {
      throw const AuthException('Current password is incorrect');
    }
  }
}

void main() {
  testWidgets('Privacy & security opens Change password', (tester) async {
    var passwordOpened = false;
    var notificationsOpened = false;
    var linksOpened = false;
    var exportOpened = false;
    var policyOpened = false;
    var deleteOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacySecurityScreen(
          onSharedLinks: () => linksOpened = true,
          onExport: () => exportOpened = true,
          onPrivacyPolicy: () => policyOpened = true,
          onChangePassword: () => passwordOpened = true,
          onNotificationSettings: () => notificationsOpened = true,
          onDeleteAccount: () => deleteOpened = true,
          appLockEnabled: false,
          onAppLockChanged: (enabled) async => enabled,
        ),
      ),
    );
    expect(find.byKey(const Key('privacy-change-password')), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    await tester.tap(find.byKey(const Key('privacy-change-password')));
    expect(passwordOpened, isTrue);
    await tester.tap(find.byKey(const Key('privacy-notification-settings')));
    expect(notificationsOpened, isTrue);
    await tester.ensureVisible(find.text('Manage shared links'));
    await tester.tap(find.text('Manage shared links'));
    await tester.scrollUntilVisible(find.text('Export your data'), 150);
    await tester.tap(find.text('Export your data'));
    await tester.scrollUntilVisible(find.text('Read the Privacy Policy'), 150);
    await tester.tap(find.text('Read the Privacy Policy'));
    await tester.tap(find.text('Delete account'));
    expect(linksOpened && exportOpened && policyOpened && deleteOpened, isTrue);
  });

  testWidgets('App lock switch follows saved result and recovers from errors', (
    tester,
  ) async {
    var shouldFail = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacySecurityScreen(
          onSharedLinks: () {},
          onExport: () {},
          onPrivacyPolicy: () {},
          onChangePassword: () {},
          onNotificationSettings: () {},
          onDeleteAccount: () {},
          appLockEnabled: false,
          onAppLockChanged: (enabled) async {
            if (shouldFail) throw StateError('unavailable');
            return enabled;
          },
        ),
      ),
    );
    final lockSwitch = find.byKey(const Key('app-lock-switch'));
    await tester.tap(lockSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(lockSwitch).value, isTrue);
    shouldFail = true;
    await tester.tap(lockSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(lockSwitch).value, isTrue);
    shouldFail = false;
    await tester.tap(lockSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(lockSwitch).value, isFalse);
  });

  testWidgets('validates passwords and sends a successful change', (
    tester,
  ) async {
    final auth = _Auth();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(authRepository: auth),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('change-password-current')),
      'wrong',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-new')),
      'NewPass1!',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'different',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pump();
    expect(find.text('New passwords do not match'), findsOneWidget);
    expect(auth.newPassword, isNull);

    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'NewPass1!',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Current password is incorrect'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('change-password-current')),
      'OldPass1!',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pumpAndSettle();
    expect(auth.currentPassword, 'OldPass1!');
    expect(auth.newPassword, 'NewPass1!');
    expect(find.text('Open'), findsOneWidget);
  });
}
