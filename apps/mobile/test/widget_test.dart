import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/in_memory_auth_repository.dart';
import 'package:mobile/features/consent/in_memory_consent_repository.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('signup requires policy acknowledgement before submit', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyzerApp());

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('signup-email')), 'new@example.com');
    await tester.enterText(find.byKey(const Key('signup-password')), 'StrongPass123!');

    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Please accept terms and privacy policy'), findsOneWidget);

    await tester.tap(find.byKey(const Key('signup-policy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verification-continue-login')), findsOneWidget);
  });

  testWidgets('login and logout transition app state', (WidgetTester tester) async {
    await tester.pumpWidget(DoclyzerApp(
      consentRepository: InMemoryConsentRepository(hasPending: false),
    ));

    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('signup-email')), 'flow@example.com');
    await tester.enterText(find.byKey(const Key('signup-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('signup-policy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login-email')), 'flow@example.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doclyzer'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  testWidgets('login screen has forgot password entry point', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyzerApp());

    expect(find.byKey(const Key('go-to-forgot-password')), findsOneWidget);
  });

  testWidgets('forgot password screen navigates from login and back', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyzerApp());

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('forgot-password-email')), findsOneWidget);
    expect(find.byKey(const Key('forgot-password-submit')), findsOneWidget);

    await tester.tap(find.byKey(const Key('forgot-password-back-to-login')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  testWidgets('forgot password shows error when email is empty', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyzerApp());

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address'), findsOneWidget);
  });

  testWidgets('full password reset flow: request, enter code, set new password, login',
      (WidgetTester tester) async {
    final repo = InMemoryAuthRepository();
    await tester.pumpWidget(DoclyzerApp(
      authRepository: repo,
      consentRepository: InMemoryConsentRepository(hasPending: false),
    ));

    // Register an account
    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('signup-email')), 'resetme@example.com');
    await tester.enterText(find.byKey(const Key('signup-password')), 'OldPass123!');
    await tester.tap(find.byKey(const Key('signup-policy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();

    // Go to forgot password and submit
    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('forgot-password-email')), 'resetme@example.com');
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    // Should be on reset password screen
    expect(find.byKey(const Key('reset-password-token')), findsOneWidget);

    final token = repo.getLastResetTokenForTest();
    expect(token, isNotNull);

    await tester.enterText(find.byKey(const Key('reset-password-token')), token!);
    await tester.enterText(
        find.byKey(const Key('reset-password-new-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pumpAndSettle();

    // Should be back on login screen
    expect(find.byKey(const Key('login-submit')), findsOneWidget);

    // Login with new password should succeed
    await tester.enterText(find.byKey(const Key('login-email')), 'resetme@example.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doclyzer'), findsOneWidget);
  });

  testWidgets('reset password screen shows error for invalid token', (WidgetTester tester) async {
    await tester.pumpWidget(const DoclyzerApp());

    // Navigate to forgot password and submit an unknown email (no valid token)
    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('forgot-password-email')), 'ghost@example.com');
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    // Enter a wrong token
    await tester.enterText(find.byKey(const Key('reset-password-token')), 'totally-wrong-token');
    await tester.enterText(
        find.byKey(const Key('reset-password-new-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-password-error')), findsOneWidget);
  });
}
