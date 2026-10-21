/// Result of uploading a report.
class UploadedReport {
  const UploadedReport({
    required this.reportId,
    required this.profileId,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    this.reused = false,
  });

  final String reportId;
  final String profileId;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String status;
  final bool reused;
}

/// A single extracted lab value (parameter name, value, unit, date).
class ExtractedLabValue {
  const ExtractedLabValue({
    this.id,
    required this.parameterName,
    required this.value,
    this.unit,
    this.sampleDate,
    this.referenceRange,
    this.isAbnormal,
    this.reviewVersion = 0,
    this.sourceSnapshot,
    this.canonicalTestId,
    this.resultKind,
    this.reviewState,
    this.collectionDateSource,
  });

  final String? id;
  final String parameterName;
  final String value;
  final String? unit;
  final String? sampleDate;
  final String? referenceRange;
  final bool? isAbnormal;
  final int reviewVersion;
  final Map<String, dynamic>? sourceSnapshot;
  final String? canonicalTestId;
  final String? resultKind;
  final String? reviewState;
  final String? collectionDateSource;
}

class ResultInsight {
  const ResultInsight({
    required this.testExplanation,
    required this.resultExplanation,
    required this.possibleSignificance,
    required this.lifestyleConsiderations,
    required this.suggestedFollowup,
    required this.dataUncertainties,
  });

  final String testExplanation;
  final String resultExplanation;
  final String possibleSignificance;
  final List<String> lifestyleConsiderations;
  final String suggestedFollowup;
  final List<String> dataUncertainties;
}

/// Report for display (from GET /reports/:id).
class Report {
  const Report({
    required this.id,
    required this.profileId,
    this.profileName,
    this.profileIsActive,
    required this.originalFileName,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    this.summaryStatus,
    required this.createdAt,
    this.collectionDate,
    this.collectionDateStatus,
    this.parsedAt,
    this.summary,
    this.parsedTranscript,
    this.extractedLabValues = const [],
    this.structuredReport,
    this.deletedAt,
    this.purgeAfterAt,
  });

  final String id;
  final String profileId;
  final String? profileName;
  final bool? profileIsActive;
  final String originalFileName;
  final String contentType;
  final int sizeBytes;
  final String status;
  final String? summaryStatus;
  final DateTime createdAt;

  /// Date printed in the report, when extraction found one.
  final String? collectionDate;
  final String? collectionDateStatus;
  final DateTime? parsedAt;
  final String? summary;
  final String? parsedTranscript;
  final List<ExtractedLabValue> extractedLabValues;
  final StructuredReport? structuredReport;
  final DateTime? deletedAt;
  final DateTime? purgeAfterAt;
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

class StructuredLabDetails {
  const StructuredLabDetails({
    this.name,
    this.address,
    this.phone,
    this.email,
    this.location,
  });

  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final String? location;
}

class StructuredReport {
  const StructuredReport({
    required this.patientDetails,
    this.labDetails,
    required this.sections,
    this.extractionReview,
  });

  final StructuredPatientDetails patientDetails;
  final StructuredLabDetails? labDetails;
  final List<StructuredSection> sections;
  final ExtractionReview? extractionReview;
}

class ExtractionReview {
  const ExtractionReview({
    required this.required,
    required this.candidateRows,
    required this.parsedRows,
    required this.reasons,
  });

  final bool required;
  final int candidateRows;
  final int parsedRows;
  final List<String> reasons;
}

/// A single trend data point (date + numeric value).
class TrendDataPoint {
  const TrendDataPoint({
    required this.date,
    required this.value,
    this.reportId,
    this.originalValue,
    this.referenceRange,
    this.originalUnit,
    this.dateProvenance,
  });

  final DateTime date;
  final double value;
  final String? reportId;
  final String? originalValue;
  final String? referenceRange;
  final String? originalUnit;
  final String? dateProvenance;
}

/// Every saved observation, including values that cannot be plotted.
class TrendObservation {
  const TrendObservation({
    this.id,
    required this.reportId,
    required this.originalValue,
    this.date,
    this.value,
    this.referenceRange,
    this.notPlottedReason,
    this.originalUnit,
    this.dateProvenance,
    this.reviewState,
  });

  final String? id;
  final String reportId;
  final String originalValue;
  final DateTime? date;
  final double? value;
  final String? referenceRange;
  final String? notPlottedReason;
  final String? originalUnit;
  final String? dateProvenance;
  final String? reviewState;
}

/// Trend data for a single parameter across time.
class TrendParameter {
  const TrendParameter({
    required this.parameterName,
    this.unit,
    required this.dataPoints,
    this.observations = const [],
    this.unplottedCount = 0,
  });

  final String parameterName;
  final String? unit;
  final List<TrendDataPoint> dataPoints;
  final List<TrendObservation> observations;
  final int unplottedCount;
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

class ReportReviewCandidate {
  const ReportReviewCandidate({
    required this.id,
    required this.page,
    required this.testRaw,
    required this.resultRaw,
    this.unitRaw,
    this.rangeRaw,
    this.reviewReasons = const [],
  });

  final String id;
  final int page;
  final String testRaw;
  final String? resultRaw;
  final String? unitRaw;
  final String? rangeRaw;
  final List<String> reviewReasons;
}

class ReportReview {
  const ReportReview({
    required this.candidates,
    required this.applied,
    required this.reviewVersion,
    required this.partial,
  });

  final List<ReportReviewCandidate> candidates;
  final Set<String> applied;
  final int reviewVersion;
  final bool partial;
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

  /// List reports across all profiles, newest first.
  Future<List<Report>> listAllReports();

  /// Fetch a report by id.
  Future<Report> getReport(String reportId);

  /// Save a reviewed result. The server rejects stale review versions.
  Future<Report> correctResult(
    String reportId,
    ExtractedLabValue result, {
    required String parameterName,
    required String value,
    String? unit,
    String? sampleDate,
    String? referenceRange,
  });

  /// Generate an explanation for a saved result. The API selects the value.
  Future<ResultInsight> getResultInsight(
    String reportId,
    ExtractedLabValue result,
  );

  /// Retry parsing for a report that failed. Returns updated report.
  Future<Report> retryParse(String reportId, {bool force = false});

  /// Mark report as kept (unparsed) when user chooses "Keep file anyway".
  Future<Report> keepFile(String reportId);

  /// Fetch original PDF or image bytes for viewing.
  Future<List<int>> getReportFile(String reportId);

  /// Fetch OCR suggestions. Suggestions are not report results until reviewed.
  Future<ReportReview> getReportReview(String reportId);

  /// Save a decision after inspecting the source. Returns the next review version.
  Future<int> reviewReportCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
    required String action,
    required String testRaw,
    required String? resultRaw,
    String? unitRaw,
    String? rangeRaw,
  });

  /// Publish one source-confirmed result to the report.
  Future<void> applyReviewedCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
  });

  /// Fetch lab trend data for a profile, optionally filtered by parameterName.
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  });

  /// Fetch processing attempt history for a report, oldest first.
  Future<List<ProcessingAttempt>> getProcessingAttempts(String reportId);

  /// Reassign a report to a different profile. Returns updated report.
  Future<Report> reassignReport(String reportId, String targetProfileId);

  /// Soft-delete report to recycle bin.
  Future<Report> deleteReport(String reportId);

  /// List soft-deleted reports in recycle bin (optional profile scope).
  Future<List<Report>> listRecycleBin({String? profileId});

  /// Restore report from recycle bin.
  Future<Report> restoreReport(String reportId);
}
