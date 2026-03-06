import '../../core/api_client.dart';
import 'account_repository.dart';

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._client);

  final ApiClient _client;

  @override
  Future<AccountProfile> getProfile() async {
    final data = await _client.get('v1/account/profile');
    final d = data['data'] as Map<String, dynamic>;
    return _profileFromJson(d);
  }

  @override
  Future<AccountProfile> updateProfile({String? displayName}) async {
    final data = await _client.patch(
      'v1/account/profile',
      body: {'displayName': displayName},
    );
    final d = data['data'] as Map<String, dynamic>;
    return _profileFromJson(d);
  }

  AccountProfile _profileFromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] as String?;
    return AccountProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
    );
  }
}
