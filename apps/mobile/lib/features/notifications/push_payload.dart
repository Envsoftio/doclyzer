class PushPayload {
  PushPayload._(this.data, this.path, this.reportId);
  final Map<String, dynamic> data;
  final String path;
  final String? reportId;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static PushPayload? parse(Map<String, dynamic> data) {
    // Accept the existing report dispatcher contract during rolling deployment.
    final version = data['version']?.toString();
    if (version != '1' &&
        !(version == null && data['notificationType'] == 'report.completed')) {
      return null;
    }
    final legacyId = data['reportId'];
    final path =
        data['deepLink'] ??
        (legacyId is String && _uuid.hasMatch(legacyId)
            ? '/reports/$legacyId'
            : '/notifications');
    if (path is! String) return null;
    String? reportId;
    if (path.startsWith('/reports/')) {
      reportId = path.substring('/reports/'.length);
      if (!_uuid.hasMatch(reportId)) return null;
    } else if (!['/reports', '/notifications', '/account'].contains(path)) {
      return null;
    }
    if (data['recipientId'] != null &&
        (data['recipientId'] is! String ||
            !_uuid.hasMatch(data['recipientId']))) {
      return null;
    }
    return PushPayload._(Map.unmodifiable(data), path, reportId);
  }
}
