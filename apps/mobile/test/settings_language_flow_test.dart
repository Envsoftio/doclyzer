import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/account/screens/account_profile_screen.dart';
import 'package:mobile/features/auth/auth_repository.dart';
import 'package:mobile/features/auth/screens/home_screen.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/auth/sessions_repository.dart';
import 'package:mobile/features/billing/billing_repository.dart';
import 'package:mobile/features/incidents/incident_repository.dart';
import 'package:mobile/features/notifications/push_notification_service.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/sharing/sharing_repository.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:mobile/main.dart';
import 'package:mobile/core/theme/app_theme.dart';

import 'language_support_test.dart' show chooseLanguage;

class _Account extends Fake implements AccountRepository {
  String language = 'en';
  String? requested;
  int saves = 0;
  Completer<AccountProfile>? pending;

  AccountProfile profile([String? locale]) => AccountProfile(
    id: 'user',
    email: 'test@example.com',
    displayName: 'Test',
    createdAt: DateTime(2026),
    preferredLanguage: locale ?? language,
  );

  @override
  Future<AccountProfile> getProfile() async => profile();

  @override
  Future<AccountProfile> updateProfile({
    String? displayName,
    String? preferredLanguage,
  }) {
    requested = preferredLanguage;
    saves++;
    pending = Completer<AccountProfile>();
    return pending!.future;
  }

  void save() {
    language = requested!;
    pending!.complete(profile());
  }
}

class _Dependencies extends Fake
    implements
        AuthRepository,
        ProfilesRepository,
        RestrictionRepository,
        BillingRepository,
        DataRightsRepository,
        IncidentRepository {
  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async => const LoginResult(accessToken: 'test', tokenType: 'Bearer');
  @override
  Future<List<Profile>> getProfiles() async => [];
  @override
  Future<RestrictionStatus> getStatus() async =>
      const RestrictionStatus(isRestricted: false);
  @override
  Future<ClosureRequest?> getClosureRequest() async => null;
  @override
  Future<PublicIncidentStatus?> getActiveIncident() async => null;
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

class _Unused extends Fake
    implements
        SessionsRepository,
        CommunicationPreferencesRepository,
        ReportsRepository,
        SharingRepository {}

class _Push extends Fake implements PushNotificationService {
  @override
  bool Function()? canNavigate;
  @override
  Future<void> Function(String)? onDestinationOpen;
  @override
  Future<bool> Function(String)? onReportOpen;
  @override
  VoidCallback? onForegroundReport;
  @override
  Future<void> start() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> flushPendingNavigation() async {}
  @override
  Future<bool> shouldOfferPermissionPrompt() async => false;
  @override
  Future<bool> shouldOpenPermissionSettings() async => false;
}

Future<void> _openSettings(WidgetTester tester, _Account account) async {
  FlutterSecureStorage.setMockInitialValues({'doclyzer_language': 'en'});
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final dependencies = _Dependencies();
  final unused = _Unused();
  await tester.pumpWidget(
    DoclyzerApp(
      authRepository: dependencies,
      accountRepository: account,
      profilesRepository: dependencies,
      sessionsRepository: unused,
      communicationPreferencesRepository: unused,
      dataRightsRepository: dependencies,
      restrictionRepository: dependencies,
      reportsRepository: unused,
      sharingRepository: unused,
      billingRepository: dependencies,
      incidentRepository: dependencies,
      pushNotificationService: _Push(),
    ),
  );
  await tester.pumpAndSettle();
  await tester
      .widget<LoginScreen>(find.byType(LoginScreen))
      .onLogin('test@example.com', 'test');
  await tester.pumpAndSettle();
  tester.widget<HomeScreen>(find.byType(HomeScreen)).onGoToAccount();
  await tester.pumpAndSettle();
}

String locale(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).locale!.languageCode;
ListTile languageTile(WidgetTester tester) =>
    tester.widget<ListTile>(find.byKey(const Key('language-selector')));
Future<String?> storedLanguage() =>
    const FlutterSecureStorage().read(key: 'doclyzer_language');

void main() {
  setUpAll(() async {
    for (final family in ['Plus Jakarta Sans', ...AppTheme.scriptFonts]) {
      await (FontLoader(family)..addFont(
            rootBundle.load('assets/fonts/${family.replaceAll(' ', '')}.ttf'),
          ))
          .load();
    }
  });
  testWidgets(
    'Settings changes every language immediately and persists acknowledged saves',
    (tester) async {
      final account = _Account();
      await _openSettings(tester, account);
      // English last exercises returning from an Indian language to English too.
      for (final language in [
        ...supportedLanguageNames.keys.where((code) => code != 'en'),
        'en',
      ]) {
        await chooseLanguage(tester, language);
        expect(locale(tester), language);
        expect(account.requested, language);
        expect(languageTile(tester).enabled, false);
        expect(
          find.descendant(
            of: find.byKey(const Key('language-selector')),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        final saves = account.saves;
        await tester.tap(find.byKey(const Key('language-selector')));
        await tester.pump();
        expect(find.byKey(const Key('language-options')), findsNothing);
        expect(account.saves, saves);
        account.save();
        await tester.pumpAndSettle();
        expect(await storedLanguage(), language);
        expect(languageTile(tester).enabled, true);
        expect(
          tester.element(find.byType(AccountProfileScreen)).l10n.localeName,
          language,
        );
        final navigation = find.byType(NavigationBar);
        final bounds = tester.getRect(navigation);
        for (final label
            in find
                .descendant(of: navigation, matching: find.byType(Text))
                .evaluate()) {
          final labelBounds = tester.getRect(find.byWidget(label.widget));
          expect(labelBounds.top, greaterThanOrEqualTo(bounds.top));
          expect(labelBounds.bottom, lessThanOrEqualTo(bounds.bottom));
        }
      }
      // Reopening settings must not reset the confirmed preference.
      await chooseLanguage(tester, 'ta');
      account.save();
      await tester.pumpAndSettle();
      tester
          .widget<AccountProfileScreen>(find.byType(AccountProfileScreen))
          .onBack();
      await tester.pumpAndSettle();
      tester.widget<HomeScreen>(find.byType(HomeScreen)).onGoToAccount();
      await tester.pumpAndSettle();
      expect(locale(tester), 'ta');
      expect(find.text(supportedLanguageNames['ta']!), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final failure in ['network', 'mismatch', 'timeout']) {
    testWidgets('Settings rolls back and allows retry after $failure', (
      tester,
    ) async {
      final account = _Account();
      await _openSettings(tester, account);
      await chooseLanguage(tester, 'kn');
      expect(locale(tester), 'kn');
      if (failure == 'network') {
        account.pending!.completeError(const AccountException('offline'));
      } else if (failure == 'mismatch') {
        account.pending!.complete(account.profile('en'));
      } else {
        await tester.pump(const Duration(seconds: 16));
      }
      await tester.pumpAndSettle();
      expect(locale(tester), 'en');
      expect(await storedLanguage(), 'en');
      expect(languageTile(tester).enabled, true);
      expect(find.byType(SnackBar), findsOneWidget);
      if (failure == 'timeout') {
        // A late response must not change the UI after a reported failure.
        account.pending!.complete(account.profile('kn'));
        await tester.pumpAndSettle();
        expect(locale(tester), 'en');
      }
      await chooseLanguage(tester, 'te');
      account.save();
      await tester.pumpAndSettle();
      expect(locale(tester), 'te');
      expect(await storedLanguage(), 'te');
      expect(tester.takeException(), isNull);
    });
  }
}
