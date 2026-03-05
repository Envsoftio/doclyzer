import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/in_memory_account_repository.dart';
import 'package:mobile/features/account/screens/account_profile_screen.dart';

Widget _wrap(AccountRepository repo) {
  return MaterialApp(
    home: AccountProfileScreen(
      accountRepository: repo,
      onBack: () {},
    ),
  );
}

void main() {
  testWidgets('renders email (read-only) and displayName from repository',
      (WidgetTester tester) async {
    final repo = InMemoryAccountRepository(
      id: 'u1',
      email: 'alice@example.com',
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-profile-email')), findsOneWidget);
    expect(find.byKey(const Key('account-profile-display-name')), findsOneWidget);
    expect(find.byKey(const Key('account-profile-save')), findsOneWidget);
  });

  testWidgets('save button calls updateProfile with entered displayName',
      (WidgetTester tester) async {
    final repo = InMemoryAccountRepository(email: 'bob@example.com');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('account-profile-display-name')), 'Bob Smith');
    await tester.tap(find.byKey(const Key('account-profile-save')));
    await tester.pumpAndSettle();

    expect(repo.getLastDisplayNameForTest(), 'Bob Smith');
  });

  testWidgets('save with empty displayName clears it (optional field)',
      (WidgetTester tester) async {
    final repo = InMemoryAccountRepository(email: 'carol@example.com');
    await repo.updateProfile(displayName: 'Carol');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('account-profile-display-name')), '');
    await tester.tap(find.byKey(const Key('account-profile-save')));
    await tester.pumpAndSettle();

    expect(repo.getLastDisplayNameForTest(), isNull);
  });
}