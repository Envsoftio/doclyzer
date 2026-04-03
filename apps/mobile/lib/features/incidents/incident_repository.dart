class PublicIncidentStatus {
  const PublicIncidentStatus({
    required this.id,
    required this.severity,
    required this.status,
    required this.headline,
    required this.message,
    required this.whatsAffected,
    required this.affectedSurfaces,
    required this.startedAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  final String id;
  final String severity;
  final String status;
  final String headline;
  final String message;
  final String whatsAffected;
  final List<String> affectedSurfaces;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  factory PublicIncidentStatus.fromJson(Map<String, dynamic> json) {
    return PublicIncidentStatus(
      id: json['id'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      headline: json['headline'] as String,
      message: json['message'] as String,
      whatsAffected: json['whatsAffected'] as String,
      affectedSurfaces: (json['affectedSurfaces'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  bool get isActive => status == 'active' || status == 'monitoring';

  bool affectsSurface(String surface) {
    return affectedSurfaces.contains(surface);
  }
}

abstract class IncidentRepository {
  Future<PublicIncidentStatus?> getActiveIncident();
}
