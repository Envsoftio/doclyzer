import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'fakes.dart';
import 'package:mobile/features/account/screens/communication_preferences_screen.dart';

Widget _wrap(
  CommunicationPreferencesRepository repo, {
  VoidCallback? onBack,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
      useMaterial3: true,
    ),
    home: CommunicationPreferencesScreen(
      communicationPreferencesRepository: repo,
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  testWidgets('renders all 3 preference categories', (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pref-security')), findsOneWidget);
    expect(find.byKey(const Key('pref-compliance')), findsOneWidget);
    expect(find.byKey(const Key('pref-product')), findsOneWidget);
    expect(find.byKey(const Key('pref-save')), findsOneWidget);
  });

  testWidgets('mandatory categories show "Required for your account" label',
      (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pref-security-mandatory-hint')), findsOneWidget);
    expect(find.byKey(const Key('pref-compliance-mandatory-hint')), findsOneWidget);
  });

  testWidgets('mandatory categories have non-interactive switches',
      (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final securitySwitch = tester.widget<Switch>(
      find.byKey(const Key('pref-security')),
    );
    final complianceSwitch = tester.widget<Switch>(
      find.byKey(const Key('pref-compliance')),
    );

    expect(securitySwitch.onChanged, isNull);
    expect(complianceSwitch.onChanged, isNull);
  });

  testWidgets('optional (product) category has interactive switch',
      (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final productSwitch = tester.widget<Switch>(
      find.byKey(const Key('pref-product')),
    );
    expect(productSwitch.onChanged, isNotNull);
  });

  testWidgets(
      'toggling optional category and tapping Save calls updatePreferences with correct payload',
      (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pref-product')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('pref-save')));
    await tester.pumpAndSettle();

    final updated = await repo.getPreferences();
    final product = updated.preferences
        .firstWhere((p) => p.category == commPrefCategoryProduct);
    expect(product.enabled, isFalse);
  });

  testWidgets('successful save shows inline success message',
      (WidgetTester tester) async {
    final repo = FakeCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pref-product')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('pref-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('communication-preferences-success')), findsOneWidget);
  });

  testWidgets('error from repository shows inline error widget',
      (WidgetTester tester) async {
    final repo = _FailingOnUpdateCommunicationPreferencesRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pref-product')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('pref-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('communication-preferences-error')), findsOneWidget);
  });
}

class _FailingOnUpdateCommunicationPreferencesRepository
    implements CommunicationPreferencesRepository {
  @override
  Future<CommunicationPreferences> getPreferences() async {
    return const CommunicationPreferences(
      preferences: [
        CommunicationPreferenceItem(
          category: commPrefCategorySecurity,
          enabled: true,
          mandatory: true,
        ),
        CommunicationPreferenceItem(
          category: commPrefCategoryCompliance,
          enabled: true,
          mandatory: true,
        ),
        CommunicationPreferenceItem(
          category: commPrefCategoryProduct,
          enabled: true,
          mandatory: false,
        ),
      ],
    );
  }

  @override
  Future<CommunicationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    throw const CommunicationPreferencesException('Server error');
  }
}
