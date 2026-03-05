import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'auth_repository.dart';

class _AuthAccount {
  const _AuthAccount({
    required this.userId,
    required this.email,
    required this.passwordHash,
  });

  final String userId;
  final String email;
  // SHA-256 hex digest — no salt intentionally; this is a test/local stub only.
  // A real HttpAuthRepository will delegate hashing to the API over TLS.
  final String passwordHash;
}

class InMemoryAuthRepository implements AuthRepository {
  final Map<String, _AuthAccount> _accountsByEmail = {};
  String? _activeAccessToken;
  // Per-email pending reset tokens — supports concurrent test users.
  final Map<String, String> _pendingResetTokensByEmail = {};

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
      passwordHash: _hashPassword(password),
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
    if (account == null || account.passwordHash != _hashPassword(password)) {
      throw const AuthException('Invalid credentials');
    }

    _activeAccessToken = _secureToken();
    return LoginResult(
      accessToken: _activeAccessToken!,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<void> logout() async {
    _activeAccessToken = null;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    // Enumeration-safe: always succeed regardless of account existence.
    // Store token per-email so concurrent test users don't stomp each other.
    _pendingResetTokensByEmail[normalizedEmail] = _secureToken();
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final matchedEmail = _pendingResetTokensByEmail.entries
        .where((e) => e.value == token)
        .map((e) => e.key)
        .firstOrNull;

    if (matchedEmail == null) {
      throw const AuthException('Invalid or expired reset token');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters');
    }
    final account = _accountsByEmail[matchedEmail];
    if (account == null) {
      throw const AuthException('Invalid or expired reset token');
    }

    _accountsByEmail[matchedEmail] = _AuthAccount(
      userId: account.userId,
      email: matchedEmail,
      passwordHash: _hashPassword(newPassword),
    );

    // Revoke active session and consume the token on password reset.
    _activeAccessToken = null;
    _pendingResetTokensByEmail.remove(matchedEmail);
  }

  /// Test/dev utility — retrieve the last reset token issued for [email].
  String? getLastResetTokenForTest([String? email]) {
    if (email != null) {
      return _pendingResetTokensByEmail[email.trim().toLowerCase()];
    }
    return _pendingResetTokensByEmail.values.lastOrNull;
  }

  bool _isEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  static String _secureToken() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
