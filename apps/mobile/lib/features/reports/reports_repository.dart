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

/// A single extracted lab value (parameter name, value, unit, date).
class ExtractedLabValue {
  const ExtractedLabValue({
    required this.parameterName,
    required this.value,
    this.unit,
    this.sampleDate,
    this.referenceRange,
    this.isAbnormal,
  });

  final String parameterName;
  final String value;
  final String? unit;
  final String? sampleDate;
  final String? referenceRange;
  final bool? isAbnormal;
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
    this.parsedAt,
    this.summary,
    this.parsedTranscript,
    this.extractedLabValues = const [],
    this.structuredReport,
  });

  final String id;
  final String profileId;
  final String originalFileName;
  final String contentType;
  final int sizeBytes;
  final String status;
  final DateTime createdAt;
  final DateTime? parsedAt;
  final String? summary;
  final String? parsedTranscript;
  final List<ExtractedLabValue> extractedLabValues;
  final StructuredReport? structuredReport;
}

class StructuredPatientDetails {
  const StructuredPatientDetails({
    this.name,
    this.age,
    this.gender,
    this.bookingId,
    this.sampleCollectionDate,
  });

  final String? name;
  final String? age;
  final String? gender;
  final String? bookingId;
  final String? sampleCollectionDate;
}

class StructuredSectionItem {
  const StructuredSectionItem({
    required this.parameterName,
    required this.value,
    this.unit,
    this.sampleDate,
    this.referenceRange,
    this.isAbnormal,
  });

  final String parameterName;
  final String value;
  final String? unit;
  final String? sampleDate;
  final String? referenceRange;
  final bool? isAbnormal;
}

class StructuredSection {
  const StructuredSection({required this.heading, required this.tests});

  final String heading;
  final List<StructuredSectionItem> tests;
}

class StructuredReport {
  const StructuredReport({
    required this.patientDetails,
    required this.sections,
  });

  final StructuredPatientDetails patientDetails;
  final List<StructuredSection> sections;
}

/// A single trend data point (date + numeric value).
class TrendDataPoint {
  const TrendDataPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// Trend data for a single parameter across time.
class TrendParameter {
  const TrendParameter({
    required this.parameterName,
    this.unit,
    required this.dataPoints,
  });

  final String parameterName;
  final String? unit;
  final List<TrendDataPoint> dataPoints;
}

/// Result from GET /reports/lab-trends.
class LabTrendsResult {
  const LabTrendsResult({required this.parameters});

  final List<TrendParameter> parameters;
}

/// A single processing attempt record (immutable).
class ProcessingAttempt {
  const ProcessingAttempt({
    required this.id,
    required this.trigger,
    required this.outcome,
    required this.attemptedAt,
  });

  final String id;
  final String trigger;
  final String outcome;
  final DateTime attemptedAt;
}

abstract class ReportsRepository {
  /// Upload a report file. Returns metadata including reportId and status.
  /// When [forceUploadAnyway] is true, bypasses duplicate check (use after user chooses "Upload anyway").
  Future<UploadedReport> uploadReport(
    String filePath, {
    bool forceUploadAnyway = false,
  });

  /// List reports for the given profile, newest first.
  Future<List<Report>> listReports(String profileId);

  /// Fetch a report by id.
  Future<Report> getReport(String reportId);

  /// Retry parsing for a report that failed. Returns updated report.
  Future<Report> retryParse(String reportId, {bool force = false});

  /// Mark report as kept (unparsed) when user chooses "Keep file anyway".
  Future<Report> keepFile(String reportId);

  /// Fetch original file bytes for viewing (PDF).
  Future<List<int>> getReportFile(String reportId);

  /// Fetch lab trend data for a profile, optionally filtered by parameterName.
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  });

  /// Fetch processing attempt history for a report, oldest first.
  Future<List<ProcessingAttempt>> getProcessingAttempts(String reportId);

  /// Reassign a report to a different profile. Returns updated report.
  Future<Report> reassignReport(String reportId, String targetProfileId);
}
