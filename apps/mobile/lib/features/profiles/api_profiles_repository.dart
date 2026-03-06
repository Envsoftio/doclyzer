import '../../core/api_client.dart';
import 'profiles_repository.dart';

class ApiProfilesRepository implements ProfilesRepository {
  ApiProfilesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Profile>> getProfiles() async {
    final data = await _client.get('v1/profiles');
    final list = data['data'] as List<dynamic>;
    return list.map((e) => _profileFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<int?> getMaxProfiles() async {
    // API does not expose maxProfiles; backend enforces on create.
    return null;
  }

  @override
  Future<Profile> createProfile({
    required String name,
    String? dateOfBirth,
    String? relation,
  }) async {
    try {
      final data = await _client.post(
        'v1/profiles',
        body: {
          'name': name,
          if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'dateOfBirth': dateOfBirth,
          if (relation != null && relation.isNotEmpty) 'relation': relation,
        },
      );
      final d = data['data'] as Map<String, dynamic>;
      return _profileFromJson(d);
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_LIMIT_EXCEEDED') {
        throw ProfileLimitExceededException(e.message);
      }
      rethrow;
    }
  }

  @override
  Future<Profile> updateProfile({
    required String id,
    String? name,
    String? dateOfBirth,
    String? relation,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (relation != null) body['relation'] = relation;

    final data = await _client.patch('v1/profiles/$id', body: body);
    final d = data['data'] as Map<String, dynamic>;
    return _profileFromJson(d);
  }

  @override
  Future<void> activateProfile(String id) async {
    await _client.post('v1/profiles/$id/activate');
  }

  @override
  Future<void> deleteProfile(String id) async {
    await _client.delete('v1/profiles/$id');
  }

  Profile _profileFromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] as String?;
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      relation: json['relation'] as String?,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
