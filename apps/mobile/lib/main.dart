import 'package:flutter/material.dart';

import 'features/account/account_repository.dart';
import 'features/account/in_memory_account_repository.dart';
import 'features/account/screens/account_profile_screen.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/forgot_password/forgot_password_screen.dart';
import 'features/auth/in_memory_auth_repository.dart';
import 'features/auth/reset_password/reset_password_screen.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/verification_screen.dart';
import 'features/consent/consent_repository.dart';
import 'features/consent/in_memory_consent_repository.dart';
import 'features/consent/screens/policy_acceptance_screen.dart';

void main() {
  runApp(const DoclyzerApp());
}

enum _AuthView {
  login,
  signup,
  verification,
  home,
  forgotPassword,
  resetPassword,
  accountProfile,
  policyAcceptance,
}

class DoclyzerApp extends StatefulWidget {
  const DoclyzerApp({
    super.key,
    AuthRepository? authRepository,
    AccountRepository? accountRepository,
    ConsentRepository? consentRepository,
  })  : _authRepository = authRepository,
        _accountRepository = accountRepository,
        _consentRepository = consentRepository;

  final AuthRepository? _authRepository;
  final AccountRepository? _accountRepository;
  final ConsentRepository? _consentRepository;

  @override
  State<DoclyzerApp> createState() => _DoclyzerAppState();
}

class _DoclyzerAppState extends State<DoclyzerApp> {
  late final AuthRepository _authRepository;
  late final AccountRepository _accountRepository;
  late final ConsentRepository _consentRepository;
  _AuthView _authView = _AuthView.login;
  String? _prefillEmail;

  @override
  void initState() {
    super.initState();
    _authRepository = widget._authRepository ?? InMemoryAuthRepository();
    _accountRepository =
        widget._accountRepository ?? InMemoryAccountRepository();
    _consentRepository =
        widget._consentRepository ?? InMemoryConsentRepository();
  }

  Future<void> _register(
    String email,
    String password,
    bool policyAccepted,
  ) async {
    final result = await _authRepository.register(
      email: email,
      password: password,
      policyAccepted: policyAccepted,
    );

    if (result.requiresVerification) {
      setState(() {
        _prefillEmail = email;
        _authView = _AuthView.verification;
      });
      return;
    }

    setState(() {
      _prefillEmail = email;
      _authView = _AuthView.login;
    });
  }

  Future<void> _login(String email, String password) async {
    await _authRepository.login(email: email, password: password);
    final consentStatus = await _consentRepository.getStatus();
    setState(() {
      _authView = consentStatus.hasPending
          ? _AuthView.policyAcceptance
          : _AuthView.home;
    });
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    setState(() {
      _authView = _AuthView.login;
    });
  }

  Future<void> _requestPasswordReset(String email) async {
    await _authRepository.requestPasswordReset(email: email);
  }

  Future<void> _confirmPasswordReset(String token, String newPassword) async {
    await _authRepository.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
    );
    setState(() {
      _authView = _AuthView.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doclyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C8C)),
        useMaterial3: true,
      ),
      home: switch (_authView) {
        _AuthView.login => LoginScreen(
            onLogin: _login,
            onGoToSignup: () {
              setState(() {
                _authView = _AuthView.signup;
              });
            },
            onGoToForgotPassword: () {
              setState(() {
                _authView = _AuthView.forgotPassword;
              });
            },
            initialEmail: _prefillEmail,
          ),
        _AuthView.signup => SignupScreen(
            onSignup: _register,
            onGoToLogin: () {
              setState(() {
                _authView = _AuthView.login;
              });
            },
          ),
        _AuthView.verification => VerificationScreen(
            onContinueToLogin: () {
              setState(() {
                _authView = _AuthView.login;
              });
            },
          ),
        _AuthView.home => HomeScreen(
            onLogout: _logout,
            onGoToAccount: () {
              setState(() {
                _authView = _AuthView.accountProfile;
              });
            },
          ),
        _AuthView.accountProfile => AccountProfileScreen(
            accountRepository: _accountRepository,
            onBack: () {
              setState(() {
                _authView = _AuthView.home;
              });
            },
          ),
        _AuthView.forgotPassword => ForgotPasswordScreen(
            onSubmit: _requestPasswordReset,
            onGoToLogin: () {
              setState(() {
                _authView = _AuthView.login;
              });
            },
            onResetSent: () {
              setState(() {
                _authView = _AuthView.resetPassword;
              });
            },
          ),
        _AuthView.resetPassword => ResetPasswordScreen(
            onReset: _confirmPasswordReset,
            onGoToLogin: () {
              setState(() {
                _authView = _AuthView.login;
              });
            },
          ),
        _AuthView.policyAcceptance => PolicyAcceptanceScreen(
            consentRepository: _consentRepository,
            onComplete: () {
              setState(() {
                _authView = _AuthView.home;
              });
            },
          ),
      },
    );
  }
}
