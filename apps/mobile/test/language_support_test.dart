import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/token_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/account/api_account_repository.dart';
import 'package:mobile/features/auth/api_auth_repository.dart';
import 'package:mobile/features/auth/screens/onboarding_screen.dart';
import 'package:mobile/features/auth/screens/signup_screen.dart';
import 'package:mobile/features/reports/api_reports_repository.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:mobile/l10n/app_localizations_hi.dart';
import 'package:mobile/l10n/app_localizations_en.dart';
import 'package:mobile/shared/app_date_format.dart';
import 'package:mobile/shared/localized_description.dart';
import 'package:mobile/shared/language_selector.dart';

class _Client extends ApiClient {
  _Client()
    : super(baseUrl: 'http://localhost/', onRefreshToken: () async => null);
  String language = 'en';
  Map<String, dynamic>? lastBody;
  String? lastPath;
  Map<String, dynamic> get profile => {
    'id': 'user',
    'email': 'test@example.com',
    'displayName': 'Test',
    'createdAt': '2026-01-01T00:00:00Z',
    'preferredLanguage': language,
  };
  @override
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async => {
    'data': profile,
  };
  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    lastPath = path;
    lastBody = body;
    language = body?['preferredLanguage'] as String? ?? language;
    return {'data': profile};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    lastPath = path;
    lastBody = body;
    return {
      'data': path.endsWith('/auth/register')
          ? {'userId': 'user', 'requiresVerification': true}
          : {
              'summary': 'हिन्दी में सेव किया गया सारांश।',
              'locale': body?['locale'],
            },
    };
  }
}

Widget app(String language, Widget child, {double scale = 1}) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

Future<void> chooseLanguage(WidgetTester tester, String language) async {
  final selector = find.byKey(const Key('language-selector'));
  await tester.ensureVisible(selector);
  await tester.tap(selector);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  final menu = find.descendant(
    of: find.byKey(const Key('language-options')),
    matching: find.byType(Scrollable),
  );
  final option = find.byKey(Key('language-$language'));
  await tester.scrollUntilVisible(option, 150, scrollable: menu);
  await tester.pump();
  expect(option.hitTestable(), findsOneWidget);
  await tester.tap(option);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() async {
    for (final family in ['Plus Jakarta Sans', ...AppTheme.scriptFonts]) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load('assets/fonts/${family.replaceAll(' ', '')}.ttf'),
        );
      await loader.load();
    }
  });
  testWidgets('Hindi onboarding pages and relative dates use the catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => AppDateFormat.configure(null));
    final hindi = AppLocalizationsHi();
    expect(
      hindi.onboardingStoreTitle,
      isNot(AppLocalizationsEn().onboardingStoreTitle),
    );
    await tester.pumpWidget(
      app('hi', OnboardingScreen(onComplete: () {}), scale: 1.3),
    );
    await tester.pumpAndSettle();
    expect(find.text(hindi.onboardingStoreTitle), findsOneWidget);
    await tester.tap(find.text(hindi.onboardingNext));
    await tester.pumpAndSettle();
    expect(find.text(hindi.onboardingUnderstandTitle), findsOneWidget);
    await tester.tap(find.text(hindi.onboardingNext));
    await tester.pumpAndSettle();
    expect(find.text(hindi.onboardingTrackTitle), findsOneWidget);
    expect(tester.takeException(), isNull);

    AppDateFormat.configure(hindi);
    expect(
      AppDateFormat.fromRawWithRelative(
        '2026-11-11',
        now: DateTime(2026, 11, 11, 12),
      ),
      startsWith(hindi.uiToday),
    );
    expect(AppDateFormat.date(DateTime(2026, 11, 11)), contains('नव'));
  });
  testWidgets('the app builder configures date labels from its locale', (
    tester,
  ) async {
    addTearDown(() => AppDateFormat.configure(null));
    final hindi = AppLocalizationsHi();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('hi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) {
          AppDateFormat.configure(context.l10n);
          return child!;
        },
        home: Scaffold(
          body: Builder(
            builder: (_) => Text(
              AppDateFormat.relativeDate(
                DateTime(2026, 11, 11),
                now: DateTime(2026, 11, 11, 12),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(hindi.uiToday), findsOneWidget);
  });
  testWidgets(
    'Settings sheet remains usable on a small phone with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var language = 'en';
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => app(
            language,
            Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  LanguageSelector(
                    settings: true,
                    value: language,
                    onChanged: (value) => setState(() => language = value),
                  ),
                ],
              ),
            ),
            scale: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final code in [
        ...supportedLanguageNames.keys.where((code) => code != 'en'),
        'en',
      ]) {
        await chooseLanguage(tester, code);
        await tester.pumpAndSettle();
        expect(language, code);
        expect(tester.takeException(), isNull);
      }
    },
  );
  test(
    'signup sends preference; settings persist it without clearing the name',
    () async {
      final client = _Client();
      await ApiAuthRepository(client, TokenStorage()).register(
        email: 'test@example.com',
        password: 'Synthetic!42',
        preferredLanguage: 'hi',
      );
      expect(client.lastBody?['preferredLanguage'], 'hi');
      expect(client.lastPath, 'v1/auth/register');
      final account = ApiAccountRepository(client);
      expect(
        (await account.updateProfile(
          preferredLanguage: 'hi',
        )).preferredLanguage,
        'hi',
      );
      expect(client.lastBody!.containsKey('displayName'), false);
      expect(
        (await ApiAccountRepository(client).getProfile()).preferredLanguage,
        'hi',
      );
      await ApiReportsRepository(client).getLocalizedSummary('report', 'hi');
      expect(client.lastBody, {'locale': 'hi'});
      expect(client.lastPath, 'v1/reports/report/summary/language');
    },
  );

  for (final language in supportedLanguageNames.keys) {
    test('signup and account round trip preserve $language', () async {
      final client = _Client();
      await ApiAuthRepository(client, TokenStorage()).register(
        email: 'test@example.com',
        password: 'Synthetic!42',
        preferredLanguage: language,
      );
      expect(client.lastBody?['preferredLanguage'], language);
      final repository = ApiAccountRepository(client);
      expect(
        (await repository.updateProfile(
          preferredLanguage: language,
        )).preferredLanguage,
        language,
      );
      expect((await repository.getProfile()).preferredLanguage, language);
      final report = ApiReportsRepository(client);
      await report.getLocalizedSummary('report', language);
      expect(client.lastBody?['locale'], language);
    });
    for (final width in [320.0, 430.0]) {
      testWidgets(
        '$language signup and language menu at $width with enlarged text',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var selected = 'en';
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) => app(
                selected,
                SignupScreen(
                  language: selected,
                  onLanguageChanged: (value) =>
                      setState(() => selected = value),
                  onSignup: (_, _, _) async {},
                  onGoToLogin: () {},
                ),
                scale: 2,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await chooseLanguage(tester, language);
          await tester.pumpAndSettle();
          expect(selected, language);
          final context = tester.element(find.byType(SignupScreen));
          expect(context.l10n.localeName, language);
          if (language != 'en') {
            expect(context.l10n.preferredLanguage, isNot('Preferred language'));
          }
          await tester.ensureVisible(find.byKey(const Key('signup-submit')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final width in [320.0, 430.0]) {
    testWidgets('Hindi signup wraps at ${width}px with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var language = 'en';
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => app(
            language,
            SignupScreen(
              language: language,
              onLanguageChanged: (value) => setState(() => language = value),
              onSignup: (_, _, _) async {},
              onGoToLogin: () {},
            ),
            scale: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await chooseLanguage(tester, 'hi');
      await tester.pumpAndSettle();
      expect(language, 'hi');
      expect(find.text('पसंदीदा भाषा'), findsOneWidget);
      expect(find.text('ईमेल पता'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('signup-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'saved preference selects Hindi; a late Hindi response cannot replace English',
    (tester) async {
      final pending = Completer<String>();
      final calls = <String>[];
      await tester.pumpWidget(
        app(
          'hi',
          Scaffold(
            body: LocalizedDescription(
              english: 'Saved English summary: Hb 10 g/dL.',
              load: (locale) {
                calls.add(locale);
                return pending.future;
              },
              builder: (text) => Text(text),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(calls, ['hi']);
      await chooseLanguage(tester, 'en');
      await tester.pumpAndSettle();
      expect(find.textContaining('Saved English summary'), findsOneWidget);
      pending.complete('सेव किया गया विवरण: Hb 10 g/dL.');
      await tester.pumpAndSettle();
      expect(find.textContaining('सेव किया गया विवरण'), findsNothing);
      expect(find.textContaining('Saved English summary'), findsOneWidget);
      await chooseLanguage(tester, 'hi');
      await tester.pumpAndSettle();
      expect(find.textContaining('सेव किया गया विवरण'), findsOneWidget);
      expect(find.textContaining('Saved English summary'), findsNothing);
    },
  );

  testWidgets('failed translation keeps English selectable and retry visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        'hi',
        Scaffold(
          body: LocalizedDescription(
            english: 'Saved English summary',
            load: (_) async => throw Exception('unavailable'),
            builder: (text) => Text(text),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('अनुवाद उपलब्ध नहीं है'), findsOneWidget);
    await chooseLanguage(tester, 'en');
    await tester.pumpAndSettle();
    expect(find.text('Saved English summary'), findsOneWidget);
  });

  testWidgets('changed summary requests a fresh translation', (tester) async {
    var source = 'first';
    var calls = 0;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return app(
            'hi',
            Scaffold(
              body: LocalizedDescription(
                english: source,
                load: (_) async {
                  calls++;
                  return source == 'first' ? 'पहला विवरण' : 'नया विवरण';
                },
                builder: (text) => Text(text),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    update(() => source = 'second');
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('नया विवरण'), findsOneWidget);
    expect(find.text('पहला विवरण'), findsNothing);
  });
}
