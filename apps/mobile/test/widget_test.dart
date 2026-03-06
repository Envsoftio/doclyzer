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
import 'package:mobile/main.dart';
import 'mocks.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockAccountRepository accountRepo;
  late MockProfilesRepository profilesRepo;
  late MockSessionsRepository sessionsRepo;
  late MockCommunicationPreferencesRepository commPrefsRepo;
  late MockDataRightsRepository dataRightsRepo;
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
    accountRepo = MockAccountRepository();
    profilesRepo = MockProfilesRepository();
    sessionsRepo = MockSessionsRepository();
    commPrefsRepo = MockCommunicationPreferencesRepository();
    dataRightsRepo = MockDataRightsRepository();
    restrictionRepo = MockRestrictionRepository();
  });

  Widget app() => DoclyzerApp(
        authRepository: authRepo,
        accountRepository: accountRepo,
        profilesRepository: profilesRepo,
        sessionsRepository: sessionsRepo,
        communicationPreferencesRepository: commPrefsRepo,
        dataRightsRepository: dataRightsRepo,
        restrictionRepository: restrictionRepo,
      );

  testWidgets('signup with valid data calls register and shows verification',
      (WidgetTester tester) async {
    when(() => authRepo.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const RegisterResult(
          userId: 'u1',
          requiresVerification: true,
          nextStep: 'verify_then_login',
        ));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('signup-email')), 'new@example.com');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();

    verify(() => authRepo.register(
          email: 'new@example.com',
          password: 'StrongPass123!',
        )).called(1);
    expect(find.byKey(const Key('verification-continue-login')), findsOneWidget);
  });

  testWidgets('login and logout transition app state',
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

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'flow@example.com');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login-email')), 'flow@example.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'StrongPass123!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doclyzer'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  testWidgets('login screen has forgot password entry point',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('go-to-forgot-password')), findsOneWidget);
  });

  testWidgets('forgot password screen navigates from login and back',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('forgot-password-email')), findsOneWidget);
    expect(find.byKey(const Key('forgot-password-submit')), findsOneWidget);

    await tester.tap(find.byKey(const Key('forgot-password-back-to-login')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  testWidgets('forgot password shows error when email is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address'), findsOneWidget);
  });

  testWidgets('full password reset flow: request, enter code, set new password, login',
      (WidgetTester tester) async {
    const testToken = 'test-reset-token-123';
    when(() => authRepo.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const RegisterResult(
          userId: 'u1',
          requiresVerification: true,
          nextStep: 'verify_then_login',
        ));
    when(() => authRepo.requestPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async {});
    when(() => authRepo.confirmPasswordReset(
          token: testToken,
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async {});
    when(() => authRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const LoginResult(
          accessToken: 'tok',
          tokenType: 'Bearer',
        ));
    when(() => restrictionRepo.getStatus()).thenAnswer((_) async =>
        const RestrictionStatus(isRestricted: false));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-signup')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'resetme@example.com');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'OldPass123!');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-continue-login')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('forgot-password-email')), 'resetme@example.com');
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-password-token')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('reset-password-token')), testToken);
    await tester.enterText(
        find.byKey(const Key('reset-password-new-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('login-email')), 'resetme@example.com');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doclyzer'), findsOneWidget);
  });

  testWidgets('reset password screen shows error for invalid token',
      (WidgetTester tester) async {
    when(() => authRepo.requestPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async {});
    when(() => authRepo.confirmPasswordReset(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        )).thenThrow(const AuthException('Invalid or expired reset token'));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('go-to-forgot-password')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('forgot-password-email')), 'ghost@example.com');
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('reset-password-token')), 'totally-wrong-token');
    await tester.enterText(
        find.byKey(const Key('reset-password-new-password')), 'NewPass456!');
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-password-error')), findsOneWidget);
  });
}
