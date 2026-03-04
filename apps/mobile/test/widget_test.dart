import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.pumpWidget(const DoclyzerApp());

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
}
