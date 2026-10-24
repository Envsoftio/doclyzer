import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/auth/screens/home_screen.dart';
import 'package:mobile/features/billing/billing_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [
    Profile(
      id: 'profile-1',
      name: 'Priya Mehta Narayanan',
      createdAt: DateTime(2026),
      isActive: true,
    ),
  ];
}

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<List<Report>> listReports(String profileId) async => [
    Report(
      id: 'report-1',
      profileId: profileId,
      originalFileName: 'Complete blood count',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 10, 12),
    ),
  ];

  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async => LabTrendsResult(
    parameters: [
      TrendParameter(
        parameterName: 'Hemoglobin',
        unit: 'g/dL',
        dataPoints: [TrendDataPoint(date: DateTime(2026, 10, 12), value: 13.2)],
      ),
    ],
  );
}

class _Account extends Fake implements AccountRepository {
  @override
  Future<AccountProfile> getProfile() async => AccountProfile(
    id: 'user-1',
    email: 'priya@example.com',
    displayName: 'Priya Mehta Narayanan',
    createdAt: DateTime(2026),
  );
}

class _Restriction extends Fake implements RestrictionRepository {
  @override
  Future<RestrictionStatus> getStatus() async =>
      const RestrictionStatus(isRestricted: false);
}

class _Billing extends Fake implements BillingRepository {}

void main() {
  testWidgets('home header and upload card fit the Pen phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
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
          onGoToReferrals: () {},
          restrictionRepository: _Restriction(),
          reportsRepository: _Reports(),
          profilesRepository: _Profiles(),
          billingRepository: _Billing(),
          accountRepository: _Account(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('A little clarity.\nAll in one place.'), findsOneWidget);
  });
}
