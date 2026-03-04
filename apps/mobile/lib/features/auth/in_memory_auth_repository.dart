import 'dart:math';

import 'auth_repository.dart';

class _AuthAccount {
  const _AuthAccount({
    required this.userId,
    required this.email,
    required this.password,
  });

  final String userId;
  final String email;
  final String password;
}

class InMemoryAuthRepository implements AuthRepository {
  final Map<String, _AuthAccount> _accountsByEmail = {};
  String? _activeAccessToken;

  @override
  Future<RegisterResult> register({
    required String email,
    required String password,
    required bool policyAccepted,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!policyAccepted) {
      throw const AuthException('Please accept terms and privacy policy');
    }
    if (!_isEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email');
    }
    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters');
    }
    if (_accountsByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('Account already exists');
    }

    final userId = 'user-${_accountsByEmail.length + 1}';
    _accountsByEmail[normalizedEmail] = _AuthAccount(
      userId: userId,
      email: normalizedEmail,
      password: password,
    );

    return RegisterResult(
      userId: userId,
      requiresVerification: true,
      nextStep: 'verify_then_login',
    );
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accountsByEmail[normalizedEmail];
    if (account == null || account.password != password) {
      throw const AuthException('Invalid credentials');
    }

    _activeAccessToken = _token();
    return LoginResult(
      accessToken: _activeAccessToken!,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<void> logout() async {
    _activeAccessToken = null;
  }

  bool _isEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String _token() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
