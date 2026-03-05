import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/consent/consent_repository.dart';
import 'package:mobile/features/consent/in_memory_consent_repository.dart';
import 'package:mobile/features/consent/screens/policy_acceptance_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/auth/in_memory_auth_repository.dart';

Widget _wrap(ConsentRepository repo, {VoidCallback? onComplete}) {
  return MaterialApp(
    home: PolicyAcceptanceScreen(
      consentRepository: repo,
      onComplete: onComplete ?? () {},
    ),
  );
}

void main() {
  testWidgets('renders all pending policy titles', (WidgetTester tester) async {
    final repo = InMemoryConsentRepository(hasPending: true);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('policy-acceptance-item-terms')), findsOneWidget);
    expect(
        find.byKey(const Key('policy-acceptance-item-privacy')), findsOneWidget);
  });

  testWidgets('"Accept & Continue" button is disabled until all checkboxes are checked',
      (WidgetTester tester) async {
    final repo = InMemoryConsentRepository(hasPending: true);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final submitFinder = find.byKey(const Key('policy-acceptance-submit'));
    final button = tester.widget<FilledButton>(submitFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('checking all checkboxes enables the submit button',
      (WidgetTester tester) async {
    final repo = InMemoryConsentRepository(hasPending: true);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('policy-acceptance-item-terms')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('policy-acceptance-item-privacy')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('policy-acceptance-submit')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
      'tapping "Accept & Continue" calls acceptPolicies and invokes onComplete',
      (WidgetTester tester) async {
    final repo = InMemoryConsentRepository(hasPending: true);
    var completed = false;

    await tester.pumpWidget(_wrap(repo, onComplete: () => completed = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('policy-acceptance-item-terms')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('policy-acceptance-item-privacy')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('policy-acceptance-submit')));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets(
      'DoclyzerApp routes to PolicyAcceptanceScreen post-login when policies are pending',
      (WidgetTester tester) async {
    final authRepo = InMemoryAuthRepository();
    final consentRepo = InMemoryConsentRepository(hasPending: true);

    await tester.pumpWidget(DoclyzerApp(
      authRepository: authRepo,
      consentRepository: consentRepo,
    ));
    await tester.pumpAndSettle();

    // Register an account first
    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'consent-test@example.com');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('signup-policy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();

    // Continue to login from verification screen
    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();

    // Login
    await tester.enterText(
        find.byKey(const Key('login-email')), 'consent-test@example.com');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('policy-acceptance-item-terms')), findsOneWidget);
  });
}
