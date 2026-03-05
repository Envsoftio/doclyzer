class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.relation,
    required this.createdAt,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? dateOfBirth;
  final String? relation;
  final DateTime createdAt;
  final bool isActive;

  Profile copyWith({
    String? name,
    String? dateOfBirth,
    String? relation,
    bool? isActive,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      relation: relation ?? this.relation,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Thrown when the user has reached their plan's profile limit (e.g. free tier: 1).
class ProfileLimitExceededException implements Exception {
  ProfileLimitExceededException([this.message = 'Free plan allows 1 profile. Upgrade to add more.']);
  final String message;
}

/// Thrown when a profile with the given id does not exist.
class ProfileNotFoundException implements Exception {
  ProfileNotFoundException([this.id]);
  final String? id;

  @override
  String toString() => id != null ? 'Profile not found: $id' : 'Profile not found';
}

abstract class ProfilesRepository {
  Future<List<Profile>> getProfiles();

  /// Returns max profiles allowed for the user's plan. null = unlimited (e.g. tests).
  Future<int?> getMaxProfiles();

  Future<Profile> createProfile({
    required String name,
    String? dateOfBirth,
    String? relation,
  });

  Future<Profile> updateProfile({
    required String id,
    String? name,
    String? dateOfBirth,
    String? relation,
  });

  Future<void> activateProfile(String id);
}
