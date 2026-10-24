import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/profiles/api_profiles_repository.dart';

class _RecordingClient extends ApiClient {
  _RecordingClient()
    : super(baseUrl: 'http://localhost/', onRefreshToken: () async => null);

  String? activatedPath;

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    activatedPath = path;
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async => throw StateError('Profile activation must use PATCH');
}

void main() {
  test('profile activation uses the API PATCH route', () async {
    final client = _RecordingClient();
    await ApiProfilesRepository(client).activateProfile('profile-2');
    expect(client.activatedPath, 'v1/profiles/profile-2/activate');
  });
}
