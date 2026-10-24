import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/account/screens/account_profile_screen.dart';
import 'package:mobile/features/billing/billing_repository.dart';

class _Account extends Fake implements AccountRepository {
  String name = 'Test';
  @override
  Future<AccountProfile> updateProfile({String? displayName}) async {
    name = displayName ?? name;
    return getProfile();
  }

  @override
  Future<AccountProfile> getProfile() async => AccountProfile(
    id: '1',
    email: 'test@example.com',
    displayName: name,
    createdAt: DateTime(2026),
  );
}

class _Restrictions extends Fake implements RestrictionRepository {
  @override
  Future<RestrictionStatus> getStatus() async =>
      const RestrictionStatus(isRestricted: false);
}

class _Billing extends Fake implements BillingRepository {
  @override
  Future<EntitlementSummary> getEntitlementSummary() async =>
      EntitlementSummary(
        planName: 'Free',
        tier: 'free',
        creditBalance: 12,
        status: 'active',
        activatedAt: DateTime(2026),
        limits: const EntitlementLimits(
          maxProfiles: 2,
          maxReports: 10,
          maxShareLinks: 1,
          aiChatEnabled: false,
        ),
      );
}

void main() {
  testWidgets('Account groups credits and referrals and switches appearance', (
    tester,
  ) async {
    var mode = ThemeMode.system;
    var billingOpened = false;
    var referralsOpened = false;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: AccountProfileScreen(
            accountRepository: _Account(),
            restrictionRepository: _Restrictions(),
            billingRepository: _Billing(),
            onBack: () {},
            themeMode: mode,
            onThemeChanged: (value) => setState(() => mode = value),
            onGoToBilling: () => billingOpened = true,
            onGoToReferrals: () => referralsOpened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.text('Delete account'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('additional-account-information')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Additional account information'), findsOneWidget);
    expect(find.text('Free · 12 credits'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('account-credits')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-credits')));
    await tester.ensureVisible(find.byKey(const Key('account-referrals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-referrals')));
    expect(billingOpened && referralsOpened, isTrue);
    await tester.ensureVisible(find.byKey(const Key('appearance-dark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('appearance-dark')));
    await tester.pumpAndSettle();
    expect(mode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Appearance'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byKey(const Key('appearance-light')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Appearance'))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byKey(const Key('appearance-system')));
    await tester.pumpAndSettle();
    expect(mode, ThemeMode.system);
    expect(find.byKey(const Key('account-profile-save')), findsNothing);
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('account-edit-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-edit-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.byKey(const Key('account-profile-save')), findsOneWidget);
    expect(find.text('Change photo'), findsOneWidget);
    expect(find.text('Appearance'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('account-profile-display-name')),
      'Updated name',
    );
    await tester.tap(find.byKey(const Key('account-profile-save')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Updated name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
