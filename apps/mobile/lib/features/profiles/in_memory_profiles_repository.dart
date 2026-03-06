import 'profiles_repository.dart';

class InMemoryProfilesRepository implements ProfilesRepository {
  InMemoryProfilesRepository({this.maxProfiles});

  final int? maxProfiles;

  final List<_InternalProfile> _profiles = [];
  String? _activeProfileId;

  @override
  Future<List<Profile>> getProfiles() async {
    return _profiles.map(_toProfile).toList();
  }

  @override
  Future<int?> getMaxProfiles() async => maxProfiles;

  @override
  Future<Profile> createProfile({
    required String name,
    String? dateOfBirth,
    String? relation,
  }) async {
    if (maxProfiles != null && _profiles.length >= maxProfiles!) {
      throw ProfileLimitExceededException();
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final internal = _InternalProfile(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth,
      relation: relation,
      createdAt: DateTime.now(),
    );
    _profiles.add(internal);
    _activeProfileId ??= id;
    return _toProfile(internal);
  }

  @override
  Future<Profile> updateProfile({
    required String id,
    String? name,
    String? dateOfBirth,
    String? relation,
  }) async {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ProfileNotFoundException(id);
    }
    final existing = _profiles[index];
    _profiles[index] = _InternalProfile(
      id: existing.id,
      name: name ?? existing.name,
      dateOfBirth: dateOfBirth ?? existing.dateOfBirth,
      relation: relation ?? existing.relation,
      createdAt: existing.createdAt,
    );
    return _toProfile(_profiles[index]);
  }

  @override
  Future<void> activateProfile(String id) async {
    final found = _profiles.any((p) => p.id == id);
    if (!found) {
      throw ProfileNotFoundException(id);
    }
    _activeProfileId = id;
  }

  @override
  Future<void> deleteProfile(String id) async {
    final index = _profiles.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ProfileNotFoundException(id);
    }
    _profiles.removeAt(index);
    if (_activeProfileId == id) {
      _activeProfileId = _profiles.isNotEmpty ? _profiles.first.id : null;
    }
  }

  Profile _toProfile(_InternalProfile p) {
    return Profile(
      id: p.id,
      name: p.name,
      dateOfBirth: p.dateOfBirth,
      relation: p.relation,
      createdAt: p.createdAt,
      isActive: p.id == _activeProfileId,
    );
  }
}

class _InternalProfile {
  _InternalProfile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.relation,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? dateOfBirth;
  final String? relation;
  final DateTime createdAt;
}
