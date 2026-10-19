import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/token_storage.dart';
import 'package:mobile/features/auth/api_auth_repository.dart';
import 'package:mobile/features/auth/auth_repository.dart';

class _NeverRespondingApiClient extends ApiClient {
  _NeverRespondingApiClient()
    : super(baseUrl: 'http://localhost:4002', onRefreshToken: () async => null);

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) => Completer<Map<String, dynamic>>().future;
}

void main() {
  testWidgets('login reports an unreachable API after its deadline', (
    tester,
  ) async {
    final repository = ApiAuthRepository(
      _NeverRespondingApiClient(),
      TokenStorage(),
    );

    final assertion = expectLater(
      repository.login(email: 'user@example.com', password: 'password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          contains('Check the API address'),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 16));
    await assertion;
  });
}
