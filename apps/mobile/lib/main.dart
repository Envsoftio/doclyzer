import 'package:flutter/material.dart';

import 'features/auth/auth_repository.dart';
import 'features/auth/in_memory_auth_repository.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/verification_screen.dart';

void main() {
  runApp(const DoclyzerApp());
}

enum _AuthView {
  login,
  signup,
  verification,
  home,
}

class DoclyzerApp extends StatefulWidget {
  const DoclyzerApp({super.key});

  @override
  State<DoclyzerApp> createState() => _DoclyzerAppState();
}

class _DoclyzerAppState extends State<DoclyzerApp> {
  final AuthRepository _authRepository = InMemoryAuthRepository();
  _AuthView _authView = _AuthView.login;
  String? _prefillEmail;

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
    setState(() {
      _authView = _AuthView.home;
    });
  }

  Future<void> _logout() async {
    await _authRepository.logout();
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
        _AuthView.home => HomeScreen(onLogout: _logout),
      },
    );
  }
}
