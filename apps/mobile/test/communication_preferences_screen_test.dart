import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'package:mobile/features/account/screens/communication_preferences_screen.dart';
import 'package:mobile/features/support/support_repository.dart';

class _Preferences extends Fake implements CommunicationPreferencesRepository {
  bool marketing = false;
  @override
  Future<CommunicationPreferences> getPreferences() async =>
      CommunicationPreferences(
        preferences: [
          CommunicationPreferenceItem(
            category: 'marketingPush',
            enabled: marketing,
            mandatory: false,
          ),
        ],
      );
  @override
  Future<CommunicationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    marketing = updates['marketingPush'] ?? marketing;
    return getPreferences();
  }
}

class _Support extends Fake implements SupportRepository {}

void main() {
  testWidgets(
    'OS permission requires a tap and does not imply marketing consent',
    (tester) async {
      final prefs = _Preferences();
      var permissionRequests = 0;
      bool? deviceConsent;
      await tester.pumpWidget(
        MaterialApp(
          home: CommunicationPreferencesScreen(
            communicationPreferencesRepository: prefs,
            supportRepository: _Support(),
            onBack: () {},
            onEnablePush: () async {
              permissionRequests++;
            },
            onMarketingChanged: (value) async {
              deviceConsent = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(permissionRequests, 0);
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();
      expect(permissionRequests, 1);
      expect(prefs.marketing, false);
      expect(deviceConsent, isNull);
      await tester.scrollUntilVisible(
      find.byKey(const Key('pref-marketingPush')), 300,
      scrollable: find.byType(Scrollable).first,
    );
      await tester.tap(find.byKey(const Key('pref-marketingPush')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save preferences'));
      await tester.pumpAndSettle();
      expect(prefs.marketing, true);
      expect(deviceConsent, true);
    },
  );
}
