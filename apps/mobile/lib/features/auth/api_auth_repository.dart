import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../../core/token_storage.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<RegisterResult> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _registerImpl(email, password);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<RegisterResult> _registerImpl(String email, String password) async {
    final data = await _client.post(
      'v1/auth/register',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
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
      throw AuthException(e.message);
    }
  }

  Future<LoginResult> _loginImpl(String email, String password) async {
    final data = await _client.post(
      'v1/auth/login',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      auth: false,
    );
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
      await _client.post('v1/auth/logout', auth: true);
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

  /// Restore session from stored tokens. Returns true if valid session restored.
  Future<bool> restoreSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return false;
    _client.setAccessToken(accessToken);
    return true;
  }

  /// Called by ApiClient on 401 to refresh tokens. Uses direct HTTP to avoid retry loop.
  Future<String?> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final base = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
      final res = await http.post(
        Uri.parse('${base}v1/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Refresh failed');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final d = data['data'] as Map<String, dynamic>;
      final newAccess = d['accessToken'] as String;
      final newRefresh = d['refreshToken'] as String? ?? newAccess;
      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return newAccess;
    } catch (_) {
      await _tokenStorage.clear();
      _client.clearAccessToken();
      return null;
    }
  }
}
