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
  _Account({this.photo, this.displayName = 'Priya Mehta Narayanan'});

  final String? photo;
  final String displayName;

  @override
  Future<AccountProfile> getProfile() async => AccountProfile(
    id: 'user-1',
    email: 'priya@example.com',
    displayName: displayName,
    avatarUrl: photo,
    createdAt: DateTime(2026),
  );
}

class _Restriction extends Fake implements RestrictionRepository {
  @override
  Future<RestrictionStatus> getStatus() async =>
      const RestrictionStatus(isRestricted: false);
}

class _Billing extends Fake implements BillingRepository {}

Widget _home({
  String? photo,
  String accountName = 'Priya Mehta Narayanan',
  Future<bool> Function()? shouldOfferPushPermission,
  Future<bool> Function()? shouldOpenPushPermissionSettings,
  Future<bool> Function()? onEnablePushPermission,
  Future<bool> Function()? onOpenPushSettings,
  VoidCallback? onPushPermissionPromptHandled,
}) => MaterialApp(
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
    accountRepository: _Account(photo: photo, displayName: accountName),
    shouldOfferPushPermission: shouldOfferPushPermission,
    shouldOpenPushPermissionSettings: shouldOpenPushPermissionSettings,
    onEnablePushPermission: onEnablePushPermission,
    onOpenPushSettings: onOpenPushSettings,
    onPushPermissionPromptHandled: onPushPermissionPromptHandled,
  ),
);

void main() {
  testWidgets('home header and upload card fit the Pen phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_home(accountName: 'Anita Rao'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('A little clarity.\nAll in one place.'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('home header displays the uploaded account photo', (
    tester,
  ) async {
    await tester.pumpWidget(_home(photo: 'https://example.com/photo'));
    await tester.pump();
    final avatar = find.byKey(const Key('dashboard-account-avatar'));
    final image = tester.widget<Image>(
      find.descendant(of: avatar, matching: find.byType(Image)),
    );
    expect((image.image as NetworkImage).url, 'https://example.com/photo');
  });

  testWidgets('dashboard asks before requesting notification permission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var permissionRequests = 0;
    var promptHandled = false;
    await tester.pumpWidget(
      _home(
        shouldOfferPushPermission: () async => true,
        onEnablePushPermission: () async {
          permissionRequests++;
          return true;
        },
        onPushPermissionPromptHandled: () => promptHandled = true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('dashboard-push-permission')), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(permissionRequests, 0);
    expect(
      find.textContaining('Marketing stays off unless you choose it.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('dashboard-enable-push')));
    await tester.pumpAndSettle();
    expect(permissionRequests, 1);
    expect(find.byKey(const Key('dashboard-push-permission')), findsNothing);
    expect(promptHandled, true);
  });

  testWidgets('dashboard notification prompt can be dismissed', (tester) async {
    var promptHandled = false;
    await tester.pumpWidget(
      _home(
        shouldOfferPushPermission: () async => true,
        onEnablePushPermission: () async => true,
        onPushPermissionPromptHandled: () => promptHandled = true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('dashboard-dismiss-push')));
    await tester.pumpAndSettle();

    expect(promptHandled, true);
    expect(find.byKey(const Key('dashboard-push-permission')), findsNothing);
  });

  testWidgets('denied notification permission offers device settings', (
    tester,
  ) async {
    var permissionRequests = 0;
    var settingsOpens = 0;
    await tester.pumpWidget(
      _home(
        shouldOfferPushPermission: () async => true,
        shouldOpenPushPermissionSettings: () async => true,
        onEnablePushPermission: () async {
          permissionRequests++;
          return false;
        },
        onOpenPushSettings: () async {
          settingsOpens++;
          return true;
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Open settings'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-enable-push')));
    await tester.pumpAndSettle();
    expect(settingsOpens, 1);
    expect(permissionRequests, 0);
  });
}
