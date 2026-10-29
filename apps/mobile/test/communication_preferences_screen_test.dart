import 'dart:async';

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

class _NeverCompletes {
  final completer = Completer<void>();
}

void main() {
  testWidgets(
    'saving an already enabled choice retries consent on this device',
    (tester) async {
      final prefs = _Preferences()..marketing = true;
      var syncCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: CommunicationPreferencesScreen(
            communicationPreferencesRepository: prefs,
            supportRepository: _Support(),
            onBack: () {},
            onMarketingChanged: (enabled) async {
              expect(enabled, isTrue);
              syncCalls++;
              if (syncCalls == 1)
                throw StateError('Temporary device sync failure');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(syncCalls, 0);
      await tester.tap(find.byKey(const Key('pref-save')));
      await tester.pumpAndSettle();
      expect(prefs.marketing, isTrue);
      expect(syncCalls, 1);
      await tester.tap(find.byKey(const Key('pref-save')));
      await tester.pumpAndSettle();
      expect(syncCalls, 2);
      expect(
        find.byKey(const Key('communication-preferences-warning')),
        findsNothing,
      );
    },
  );

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
              return DeviceNotificationActionResult.enabled;
            },
            onMarketingChanged: (value) async {
              deviceConsent = value;
            },
            saveTimeout: const Duration(milliseconds: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(permissionRequests, 0);
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();
      expect(permissionRequests, 1);
      expect(find.text('Enabled'), findsOneWidget);
      expect(
        find.text('Report notifications enabled on this device'),
        findsOneWidget,
      );
      expect(prefs.marketing, false);
      expect(deviceConsent, isNull);
      await tester.scrollUntilVisible(
        find.byKey(const Key('pref-marketingPush')),
        300,
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

  testWidgets('shows progress and denial feedback for notification access', (
    tester,
  ) async {
    final action = Completer<DeviceNotificationActionResult>();
    await tester.pumpWidget(
      MaterialApp(
        home: CommunicationPreferencesScreen(
          communicationPreferencesRepository: _Preferences(),
          supportRepository: _Support(),
          onBack: () {},
          onEnablePush: () => action.future,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('enable-report-notifications')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    action.complete(DeviceNotificationActionResult.denied);
    await tester.pumpAndSettle();
    expect(find.text('Enable'), findsOneWidget);
    expect(
      find.text(
        'Notifications are still off. Allow them in device settings to receive report updates.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the current notification permission as enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CommunicationPreferencesScreen(
          communicationPreferencesRepository: _Preferences(),
          supportRepository: _Support(),
          onBack: () {},
          onEnablePush: () async => DeviceNotificationActionResult.enabled,
          getPushEnabled: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enabled'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const Key('enable-report-notifications')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'account save completes when device registration does not return',
    (tester) async {
      final prefs = _Preferences();
      final deviceRegistration = _NeverCompletes();
      await tester.pumpWidget(
        MaterialApp(
          home: CommunicationPreferencesScreen(
            communicationPreferencesRepository: prefs,
            supportRepository: _Support(),
            onBack: () {},
            onMarketingChanged: (_) => deviceRegistration.completer.future,
            saveTimeout: const Duration(milliseconds: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('pref-marketingPush')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('pref-marketingPush')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pref-save')));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();

      expect(prefs.marketing, true);
      expect(
        find.byKey(const Key('communication-preferences-success')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('communication-preferences-warning')),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
