import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/account/screens/account_profile_screen.dart';
import 'fakes.dart';

Widget _wrap(
  AccountRepository repo, {
  RestrictionRepository? restrictionRepository,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
      useMaterial3: true,
    ),
    home: AccountProfileScreen(
      accountRepository: repo,
      restrictionRepository:
          restrictionRepository ?? FakeRestrictionRepository(),
      onBack: () {},
    ),
  );
}

void main() {
  testWidgets('renders email (read-only) and displayName from repository',
      (WidgetTester tester) async {
    final repo = FakeAccountRepository(id: 'u1', email: 'alice@example.com');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-profile-email')), findsOneWidget);
    expect(find.byKey(const Key('account-profile-display-name')), findsOneWidget);
    expect(find.byKey(const Key('account-profile-save')), findsOneWidget);
  });

  testWidgets('save button calls updateProfile with entered displayName',
      (WidgetTester tester) async {
    final repo = FakeAccountRepository(email: 'bob@example.com');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('account-profile-display-name')), 'Bob Smith');
    await tester.tap(find.byKey(const Key('account-profile-save')));
    await tester.pumpAndSettle();

    final profile = await repo.getProfile();
    expect(profile.displayName, 'Bob Smith');
  });

  testWidgets('save with empty displayName clears it (optional field)',
      (WidgetTester tester) async {
    final repo = FakeAccountRepository(email: 'carol@example.com');
    await repo.updateProfile(displayName: 'Carol');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('account-profile-display-name')), '');
    await tester.tap(find.byKey(const Key('account-profile-save')));
    await tester.pumpAndSettle();

    final profile = await repo.getProfile();
    expect(profile.displayName, isNull);
  });

  testWidgets('restriction banner not shown when account is not restricted',
      (WidgetTester tester) async {
    final repo = FakeAccountRepository(email: 'dave@example.com');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-restriction-banner')), findsNothing);
    expect(find.byKey(const Key('account-restriction-rationale')), findsNothing);
    expect(find.byKey(const Key('account-restriction-next-steps')), findsNothing);
  });

  testWidgets('restriction banner shown with rationale and next steps when restricted',
      (WidgetTester tester) async {
    final repo = FakeAccountRepository(email: 'eve@example.com');
    final restrictionRepo = FakeRestrictionRepository(
      initialStatus: const RestrictionStatus(
        isRestricted: true,
        rationale: 'Account under review.',
        nextSteps: 'Contact support to resolve.',
      ),
    );
    await tester.pumpWidget(_wrap(repo, restrictionRepository: restrictionRepo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-restriction-banner')), findsOneWidget);
    expect(find.byKey(const Key('account-restriction-rationale')), findsOneWidget);
    expect(find.byKey(const Key('account-restriction-next-steps')), findsOneWidget);
  });
}
