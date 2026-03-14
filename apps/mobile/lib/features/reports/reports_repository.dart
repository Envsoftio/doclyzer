/// Result of uploading a report.
class UploadedReport {
  const UploadedReport({
    required this.reportId,
    required this.profileId,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
  });

  final String reportId;
  final String profileId;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String status;
}

/// Report for display (from GET /reports/:id).
class Report {
  const Report({
    required this.id,
    required this.profileId,
    required this.originalFileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String profileId;
  final String originalFileName;
  final String contentType;
  final int sizeBytes;
  final String status;
  final DateTime createdAt;
}

abstract class ReportsRepository {
  /// Upload a report file. Returns metadata including reportId and status.
  /// When [forceUploadAnyway] is true, bypasses duplicate check (use after user chooses "Upload anyway").
  Future<UploadedReport> uploadReport(String filePath,
      {bool forceUploadAnyway = false});

  /// Fetch a report by id.
  Future<Report> getReport(String reportId);

  /// Retry parsing for a report that failed. Returns updated report.
  Future<Report> retryParse(String reportId);

  /// Mark report as kept (unparsed) when user chooses "Keep file anyway".
  Future<Report> keepFile(String reportId);

  /// Fetch original file bytes for viewing (PDF).
  Future<List<int>> getReportFile(String reportId);
}
