import 'dart:async';
import 'dart:io';

import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import 'auth_repository.dart';

/// Returns a user-friendly message for login/sign-in errors.
String _loginErrorMessage(Object error) {
  if (error is ApiException) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        return 'Unable to reach the server. Check the API address and your connection, then try again.';
      case 'AUTH_INVALID_CREDENTIALS':
        return 'Invalid email or password. Please check your details and try again.';
      case 'AUTH_RATE_LIMITED':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'AUTH_EMAIL_INVALID':
        return 'Please enter a valid email address.';
      case 'AUTH_PASSWORD_INVALID':
        return 'Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.';
      case 'AUTH_EMAIL_EXISTS':
        return 'An account with this email already exists. Try signing in or use a different email.';
      default:
        return error.message.isNotEmpty
            ? error.message
            : 'Sign-in failed. Please try again.';
    }
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is HandshakeException) {
    return 'Unable to reach the server. Check the API address and your connection, then try again.';
  }
  if (error is FormatException) {
    return 'Something went wrong on our side. Please try again later.';
  }
  return 'Unable to sign in. Please check your connection and try again.';
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<RegisterResult> register({
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      return await _registerImpl(email, password, referralCode);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<RegisterResult> _registerImpl(
    String email,
    String password,
    String? referralCode,
  ) async {
    final normalizedReferralCode = referralCode?.trim().toUpperCase();
    final data = await _client.post(
      'v1/auth/register',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
        if (normalizedReferralCode != null && normalizedReferralCode.isNotEmpty)
          'referralCode': normalizedReferralCode,
      },
      auth: false,
    );
    final d = data['data'] as Map<String, dynamic>;
    return RegisterResult(
      userId: d['userId'] as String,
      requiresVerification: d['requiresVerification'] as bool? ?? true,
      nextStep: d['nextStep'] as String? ?? 'verify_then_login',
    );
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _loginImpl(email, password);
    } on ApiException catch (e) {
      throw AuthException(_loginErrorMessage(e));
    } on Exception catch (e) {
      throw AuthException(_loginErrorMessage(e));
    }
  }

  Future<LoginResult> _loginImpl(String email, String password) async {
    final data = await _client
        .post(
          'v1/auth/login',
          body: {'email': email.trim().toLowerCase(), 'password': password},
          auth: false,
        )
        .timeout(const Duration(seconds: 15));
    final d = data['data'] as Map<String, dynamic>;
    final accessToken = d['accessToken'] as String;
    final refreshToken = d['refreshToken'] as String? ?? accessToken;
    _client.setAccessToken(accessToken);
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return LoginResult(
      accessToken: accessToken,
      tokenType: d['tokenType'] as String? ?? 'Bearer',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _client
          .post('v1/auth/logout', auth: true)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // ignore
    } finally {
      _client.clearAccessToken();
      await _tokenStorage.clear();
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.post(
        'v1/auth/forgot-password',
        body: {'email': email.trim().toLowerCase()},
        auth: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        'v1/auth/reset-password',
        body: {'token': token, 'newPassword': newPassword},
        auth: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } finally {
      _client.clearAccessToken();
      await _tokenStorage.clear();
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        'v1/auth/change-password',
        body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      final data = response['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      _client.setAccessToken(accessToken);
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  /// Restore session from stored tokens. Returns true if valid session restored.
  Future<bool> restoreSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return false;
    _client.setAccessToken(accessToken);
    // A token in secure storage is not proof that its server session still exists.
    try {
      return await refreshTokens() != null;
    } on ApiException {
      return false;
    }
  }

  /// Called by ApiClient on 401. The unauthenticated request cannot retry itself.
  Future<String?> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final data = await _client
          .post(
            'v1/auth/refresh',
            body: {'refreshToken': refreshToken},
            auth: false,
          )
          .timeout(const Duration(seconds: 15));
      final d = data['data'] as Map<String, dynamic>;
      final newAccess = d['accessToken'] as String;
      final newRefresh = d['refreshToken'] as String? ?? newAccess;
      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      _client.setAccessToken(newAccess);
      return newAccess;
    } on ApiException catch (error) {
      if (error.code == 'AUTH_UNAUTHORIZED' ||
          error.code == 'AUTH_SESSION_REVOKED') {
        await _tokenStorage.clear();
        _client.clearAccessToken();
        return null;
      }
      throw ApiException('NETWORK_ERROR', 'Session validation is unavailable.');
    } catch (_) {
      // Offline startup and transient server failures must not destroy a
      // session that may still be valid when connectivity returns.
      throw ApiException('NETWORK_ERROR', 'Session validation is unavailable.');
    }
  }
}
