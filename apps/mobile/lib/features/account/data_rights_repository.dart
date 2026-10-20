class DataExportRequest {
  const DataExportRequest({
    required this.requestId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.downloadUrl,
    this.failureReason,
  });

  final String requestId;
  final String userId;
  final String status;
  final String createdAt;
  final String? completedAt;
  final String? downloadUrl;
  final String? failureReason;
}

class ClosureRequest {
  const ClosureRequest({
    required this.requestId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.message,
    this.purgeAfterAt,
  });

  final String requestId;
  final String userId;
  final String status;
  final String createdAt;
  final String message;
  final String? purgeAfterAt;
}

class DataRightsException implements Exception {
  const DataRightsException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class DataRightsRepository {
  Future<DataExportRequest> createExportRequest();

  Future<DataExportRequest> getExportRequest(String requestId);

  Future<ClosureRequest> createClosureRequest({
    required bool confirmClosure,
    required String password,
  });

  Future<ClosureRequest?> getClosureRequest();

  Future<ClosureRequest> restoreClosure() =>
      throw const DataRightsException('Restoration is unavailable.');
}
