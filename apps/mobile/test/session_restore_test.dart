import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/token_storage.dart';
import 'package:mobile/features/auth/api_auth_repository.dart';

class _MemoryTokens extends TokenStorage {
  _MemoryTokens(this.access, this.refresh);

  String? access;
  String? refresh;

  @override
  Future<String?> getAccessToken() async => access;

  @override
  Future<String?> getRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _RefreshClient extends ApiClient {
  _RefreshClient(this.reply)
    : super(baseUrl: 'https://example.test', onRefreshToken: () async => null);

  final Future<Map<String, dynamic>> Function() reply;
  bool? usedAuth;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    expect(path, 'v1/auth/refresh');
    expect(body?['refreshToken'], 'old-refresh');
    usedAuth = auth;
    return reply();
  }
}

void main() {
  test('restores only a server-validated session', () async {
    final tokens = _MemoryTokens('old-access', 'old-refresh');
    final client = _RefreshClient(
      () async => {
        'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
      },
    );

    expect(await ApiAuthRepository(client, tokens).restoreSession(), isTrue);
    expect(client.usedAuth, isFalse);
    expect(client.accessToken, 'new-access');
    expect(tokens.refresh, 'new-refresh');
  });

  test('revoked session clears stored credentials', () async {
    final tokens = _MemoryTokens('old-access', 'old-refresh');
    final client = _RefreshClient(
      () async => throw ApiException('AUTH_SESSION_REVOKED', 'Revoked'),
    );

    expect(await ApiAuthRepository(client, tokens).restoreSession(), isFalse);
    expect(client.accessToken, isNull);
    expect(tokens.refresh, isNull);
  });

  test('connection failure retains credentials for retry', () async {
    final tokens = _MemoryTokens('old-access', 'old-refresh');
    final client = _RefreshClient(
      () async => throw ApiException('NETWORK_ERROR', 'Offline'),
    );

    expect(await ApiAuthRepository(client, tokens).restoreSession(), isFalse);
    expect(tokens.refresh, 'old-refresh');
  });
}
