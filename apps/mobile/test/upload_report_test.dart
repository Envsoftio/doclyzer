import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/features/account/account_repository.dart';
import 'package:mobile/features/account/communication_preferences_repository.dart';
import 'package:mobile/features/account/data_rights_repository.dart';
import 'package:mobile/features/account/restriction_repository.dart';
import 'package:mobile/features/auth/auth_repository.dart';
import 'package:mobile/features/auth/sessions_repository.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/upload_report_screen.dart';
import 'package:mobile/main.dart';
import 'mocks.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockProfilesRepository profilesRepo;
  late MockReportsRepository reportsRepo;
  late MockRestrictionRepository restrictionRepo;

  setUpAll(() {
    registerFallbackValue(RegisterResult(
      userId: '',
      requiresVerification: false,
      nextStep: '',
    ));
    registerFallbackValue(LoginResult(accessToken: '', tokenType: ''));
  });

  setUp(() {
    authRepo = MockAuthRepository();
    profilesRepo = MockProfilesRepository();
    reportsRepo = MockReportsRepository();
    restrictionRepo = MockRestrictionRepository();
  });

  testWidgets('Upload report button navigates to upload screen when user has active profile',
      (WidgetTester tester) async {
    when(() => authRepo.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const RegisterResult(
          userId: 'u1',
          requiresVerification: true,
          nextStep: 'verify_then_login',
        ));
    when(() => authRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const LoginResult(
          accessToken: 'tok',
          tokenType: 'Bearer',
        ));
    when(() => authRepo.logout()).thenAnswer((_) async {});
    when(() => restrictionRepo.getStatus()).thenAnswer((_) async =>
        const RestrictionStatus(isRestricted: false));
    when(() => profilesRepo.getProfiles()).thenAnswer((_) async => [
          Profile(
            id: 'p1',
            name: 'Me',
            dateOfBirth: null,
            relation: null,
            createdAt: DateTime(2026, 1, 1),
            isActive: true,
          ),
        ]);

    await tester.pumpWidget(DoclyzerApp(
      authRepository: authRepo,
      accountRepository: MockAccountRepository(),
      profilesRepository: profilesRepo,
      sessionsRepository: MockSessionsRepository(),
      communicationPreferencesRepository:
          MockCommunicationPreferencesRepository(),
      dataRightsRepository: MockDataRightsRepository(),
      restrictionRepository: restrictionRepo,
      reportsRepository: reportsRepo,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'upload@example.com');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('login-email')), 'upload@example.com');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('go-to-upload-report')), findsOneWidget);
    await tester.tap(find.byKey(const Key('go-to-upload-report')));
    await tester.pumpAndSettle();

    expect(find.text('Upload Report'), findsOneWidget);
    expect(find.byKey(const Key('upload-report-pick')), findsOneWidget);
  });

  testWidgets('Upload result with status unparsed shows parse-failure UI with Retry and Keep file anyway',
      (WidgetTester tester) async {
    when(() => reportsRepo.retryParse(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 1),
        ));
    when(() => reportsRepo.keepFile(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'unparsed',
          createdAt: DateTime(2026, 1, 1),
        ));

    var onCompleteCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: UploadReportScreen(
        reportsRepository: reportsRepo,
        activeProfileName: 'Me',
        onBack: () {},
        onComplete: () => onCompleteCalled = true,
        initialReport: const UploadedReport(
          reportId: 'r1',
          profileId: 'p1',
          fileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'unparsed',
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('parse-failure-message')), findsOneWidget);
    expect(find.text('We couldn\'t read this format. Your file is saved.'),
        findsOneWidget);
    expect(find.byKey(const Key('parse-failure-retry')), findsOneWidget);
    expect(find.byKey(const Key('parse-failure-keep-file')), findsOneWidget);

    await tester.tap(find.byKey(const Key('parse-failure-keep-file')));
    await tester.pumpAndSettle();
    expect(onCompleteCalled, isTrue);
  });

  testWidgets('Tapping Retry calls retryParse on repository',
      (WidgetTester tester) async {
    when(() => reportsRepo.retryParse(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 1),
        ));

    await tester.pumpWidget(MaterialApp(
      home: UploadReportScreen(
        reportsRepository: reportsRepo,
        activeProfileName: 'Me',
        onBack: () {},
        onComplete: () {},
        initialReport: const UploadedReport(
          reportId: 'r1',
          profileId: 'p1',
          fileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'unparsed',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('parse-failure-retry')));
    await tester.pumpAndSettle();

    verify(() => reportsRepo.retryParse('r1')).called(1);
  });

  testWidgets('View PDF button calls getReportFile and navigates to viewer',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReportFile(any()))
        .thenAnswer((_) async => [0x25, 0x50, 0x44, 0x46]); // %PDF

    await tester.pumpWidget(MaterialApp(
      home: UploadReportScreen(
        reportsRepository: reportsRepo,
        activeProfileName: 'Me',
        onBack: () {},
        onComplete: () {},
        initialReport: const UploadedReport(
          reportId: 'r1',
          profileId: 'p1',
          fileName: 'x.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('view-pdf-button')));
    await tester.pumpAndSettle();

    verify(() => reportsRepo.getReportFile('r1')).called(1);
    // PdfViewerScreen shows (viewer or error state after load)
    expect(find.text('x.pdf'), findsOneWidget);
  });
}
