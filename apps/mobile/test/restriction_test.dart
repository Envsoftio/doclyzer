import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/account/restriction_repository.dart';
import 'fakes.dart';
import 'package:mobile/features/auth/screens/home_screen.dart';

Widget _wrap(RestrictionRepository repo) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
      useMaterial3: true,
    ),
    home: HomeScreen(
      onLogout: () async {},
      onGoToAccount: () {},
      onGoToProfiles: () {},
      onGoToSessions: () {},
      onGoToCommunicationPreferences: () {},
      onGoToDataRights: () {},
      onGoToUploadReport: () async {},
      onGoToTimeline: () async {},
      onGoToBilling: () {},
      restrictionRepository: repo,
    ),
  );
}

void main() {
  testWidgets(
      'restriction banner is not shown when account is not restricted',
      (WidgetTester tester) async {
    final repo = FakeRestrictionRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restriction-banner')), findsNothing);
    expect(find.byKey(const Key('restriction-rationale')), findsNothing);
    expect(find.byKey(const Key('restriction-next-steps')), findsNothing);
  });

  testWidgets(
      'restriction banner is visible with rationale and next steps when account is restricted',
      (WidgetTester tester) async {
    final repo = FakeRestrictionRepository(
      initialStatus: const RestrictionStatus(
        isRestricted: true,
        rationale: 'Suspicious activity detected on your account.',
        nextSteps: 'Contact support at support@doclyzer.com to resolve.',
      ),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restriction-banner')), findsOneWidget);
    expect(find.byKey(const Key('restriction-rationale')), findsOneWidget);
    expect(find.byKey(const Key('restriction-next-steps')), findsOneWidget);
  });

  testWidgets(
      'restriction banner shows correct rationale and next steps text',
      (WidgetTester tester) async {
    final repo = FakeRestrictionRepository(
      initialStatus: const RestrictionStatus(
        isRestricted: true,
        rationale: 'Policy violation review pending.',
        nextSteps: 'Wait for admin review before proceeding.',
      ),
    );
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final rationaleWidget = tester.widget<Text>(
      find.byKey(const Key('restriction-rationale')),
    );
    expect(rationaleWidget.data, 'Policy violation review pending.');

    final nextStepsWidget = tester.widget<Text>(
      find.byKey(const Key('restriction-next-steps')),
    );
    expect(nextStepsWidget.data, 'Wait for admin review before proceeding.');
  });

  testWidgets(
      'upload action shows fallback snackbar when credits restriction lacks instructions',
      (WidgetTester tester) async {
    final repo = FakeRestrictionRepository(
      initialStatus: const RestrictionStatus(
        isRestricted: true,
        restrictedActions: ['upload_report'],
      ),
    );
    var uploadCalled = false;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
        useMaterial3: true,
      ),
      home: HomeScreen(
        onLogout: () async {},
        onGoToAccount: () {},
        onGoToProfiles: () {},
        onGoToSessions: () {},
        onGoToCommunicationPreferences: () {},
        onGoToDataRights: () {},
        onGoToUploadReport: () async {
          uploadCalled = true;
        },
        onGoToTimeline: () async {},
        onGoToBilling: () {},
        restrictionRepository: repo,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-upload-report')));
    await tester.pump(); // allow snackbar animation

    expect(uploadCalled, isFalse);
    expect(
        find.text(
            'You have used all available upload credits. Visit Plan & Credits to add more.'),
        findsOneWidget);
  });
}
