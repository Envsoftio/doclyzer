import '../../core/api_client.dart';
import 'reports_repository.dart';

class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository(this._client);

  final ApiClient _client;

  StructuredReport? _parseStructuredReport(Map<String, dynamic> d) {
    final sr = d['structuredReport'];
    if (sr is! Map<String, dynamic>) return null;

    final pd = sr['patientDetails'] as Map<String, dynamic>? ?? const {};
    final sectionsRaw = sr['sections'] as List<dynamic>? ?? const [];

    final sections = sectionsRaw.whereType<Map<String, dynamic>>().map((s) {
      final testsRaw = s['tests'] as List<dynamic>? ?? const [];
      final tests = testsRaw.whereType<Map<String, dynamic>>().map((t) {
        return StructuredSectionItem(
          parameterName: t['parameterName'] as String? ?? '',
          value: t['value'] as String? ?? '',
          unit: t['unit'] as String?,
          sampleDate: t['sampleDate'] as String?,
          referenceRange: t['referenceRange'] as String?,
          isAbnormal: t['isAbnormal'] as bool?,
        );
      }).toList();

      return StructuredSection(
        heading: s['heading'] as String? ?? 'Other Tests',
        tests: tests,
      );
    }).toList();

    return StructuredReport(
      patientDetails: StructuredPatientDetails(
        name: pd['name'] as String?,
        age: pd['age'] as String?,
        gender: pd['gender'] as String?,
        bookingId: pd['bookingId'] as String?,
        sampleCollectionDate: pd['sampleCollectionDate'] as String?,
      ),
      sections: sections,
    );
  }

  Report _reportFromJson(
    Map<String, dynamic> d, {
    List<ExtractedLabValue> extractedLabValues = const [],
    StructuredReport? structuredReport,
  }) {
    final createdAt = d['createdAt'] as String?;
    final parsedAt = d['parsedAt'] as String?;
    final deletedAt = d['deletedAt'] as String?;
    final purgeAfterAt = d['purgeAfterAt'] as String?;
    return Report(
      id: d['id'] as String,
      profileId: d['profileId'] as String,
      profileName: d['profileName'] as String?,
      profileIsActive: d['profileIsActive'] as bool?,
      originalFileName: d['originalFileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      parsedAt: parsedAt != null ? DateTime.parse(parsedAt) : null,
      deletedAt: deletedAt != null ? DateTime.parse(deletedAt) : null,
      purgeAfterAt: purgeAfterAt != null ? DateTime.parse(purgeAfterAt) : null,
      summary: d['summary'] as String?,
      parsedTranscript: d['parsedTranscript'] as String?,
      extractedLabValues: extractedLabValues,
      structuredReport: structuredReport,
    );
  }

  @override
  Future<UploadedReport> uploadReport(
    String filePath, {
    bool forceUploadAnyway = false,
  }) async {
    final queryParams = forceUploadAnyway
        ? <String, String>{'duplicateAction': 'upload_anyway'}
        : null;
    final data = await _client.uploadFile(
      'v1/reports',
      'file',
      filePath,
      queryParams: queryParams,
    );
    final d = data['data'] as Map<String, dynamic>;
    return UploadedReport(
      reportId: d['reportId'] as String,
      profileId: d['profileId'] as String,
      fileName: d['fileName'] as String,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
    );
  }

  @override
  Future<List<Report>> listReports(String profileId) async {
    final data = await _client.get('v1/reports?profileId=$profileId');
    final list = data['data']?['reports'] as List<dynamic>? ?? [];
    return list.map((d) => _reportFromJson(d as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Report>> listAllReports() async {
    final data = await _client.get('v1/reports?scope=all');
    final list = data['data']?['reports'] as List<dynamic>? ?? [];
    return list.map((d) => _reportFromJson(d as Map<String, dynamic>)).toList();
  }

  @override
  Future<Report> getReport(String reportId) async {
    final data = await _client.get('v1/reports/$reportId');
    final d = data['data'] as Map<String, dynamic>;
    final labList = d['extractedLabValues'] as List<dynamic>? ?? [];
    final extractedLabValues = labList.map((e) {
      final m = e as Map<String, dynamic>;
      return ExtractedLabValue(
        parameterName: m['parameterName'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit: m['unit'] as String?,
        sampleDate: m['sampleDate'] as String?,
        referenceRange: m['referenceRange'] as String?,
        isAbnormal: m['isAbnormal'] as bool?,
      );
    }).toList();
    return _reportFromJson(
      d,
      extractedLabValues: extractedLabValues,
      structuredReport: _parseStructuredReport(d),
    );
  }

  @override
  Future<Report> retryParse(String reportId, {bool force = false}) async {
    final path = force
        ? 'v1/reports/$reportId/retry?force=true'
        : 'v1/reports/$reportId/retry';
    final data = await _client.post(path);
    final d = data['data'] as Map<String, dynamic>;
    final labList = d['extractedLabValues'] as List<dynamic>? ?? [];
    final extractedLabValues = labList.map((e) {
      final m = e as Map<String, dynamic>;
      return ExtractedLabValue(
        parameterName: m['parameterName'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit: m['unit'] as String?,
        sampleDate: m['sampleDate'] as String?,
        referenceRange: m['referenceRange'] as String?,
        isAbnormal: m['isAbnormal'] as bool?,
      );
    }).toList();
    return _reportFromJson(
      d,
      extractedLabValues: extractedLabValues,
      structuredReport: _parseStructuredReport(d),
    );
  }

  @override
  Future<List<int>> getReportFile(String reportId) async {
    return _client.getBytes('v1/reports/$reportId/file');
  }

  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async {
    final query = parameterName != null
        ? 'v1/reports/lab-trends?profileId=$profileId&parameterName=${Uri.encodeComponent(parameterName)}'
        : 'v1/reports/lab-trends?profileId=$profileId';
    final data = await _client.get(query);
    final paramList = data['data']?['parameters'] as List<dynamic>? ?? [];
    final parameters = paramList.map((p) {
      final pm = p as Map<String, dynamic>;
      final dpList = pm['dataPoints'] as List<dynamic>? ?? [];
      final dataPoints = dpList.map((dp) {
        final dpm = dp as Map<String, dynamic>;
        return TrendDataPoint(
          date: DateTime.parse(dpm['date'] as String),
          value: (dpm['value'] as num).toDouble(),
        );
      }).toList();
      return TrendParameter(
        parameterName: pm['parameterName'] as String,
        unit: pm['unit'] as String?,
        dataPoints: dataPoints,
      );
    }).toList();
    return LabTrendsResult(parameters: parameters);
  }

  @override
  Future<List<ProcessingAttempt>> getProcessingAttempts(String reportId) async {
    final data = await _client.get('v1/reports/$reportId/attempts');
    final list = data['data']?['attempts'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final attemptedAt = m['attemptedAt'] as String?;
      return ProcessingAttempt(
        id: m['id'] as String,
        trigger: m['trigger'] as String,
        outcome: m['outcome'] as String,
        attemptedAt: attemptedAt != null
            ? DateTime.parse(attemptedAt)
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<Report> reassignReport(String reportId, String targetProfileId) async {
    final data = await _client.post(
      'v1/reports/$reportId/reassign',
      body: {'targetProfileId': targetProfileId},
    );
    final d = data['data'] as Map<String, dynamic>;
    return _reportFromJson(d);
  }

  @override
  Future<Report> keepFile(String reportId) async {
    final data = await _client.post('v1/reports/$reportId/keep-file');
    final d = data['data'] as Map<String, dynamic>;
    return _reportFromJson(d);
  }

  @override
  Future<Report> deleteReport(String reportId) async {
    final data = await _client.deleteAndGetJson('v1/reports/$reportId');
    final d = data['data'] as Map<String, dynamic>;
    return _reportFromJson(d);
  }

  @override
  Future<List<Report>> listRecycleBin({String? profileId}) async {
    final path = profileId != null && profileId.isNotEmpty
        ? 'v1/reports/recycle-bin?profileId=$profileId'
        : 'v1/reports/recycle-bin';
    final data = await _client.get(path);
    final list = data['data']?['reports'] as List<dynamic>? ?? [];
    return list.map((d) => _reportFromJson(d as Map<String, dynamic>)).toList();
  }

  @override
  Future<Report> restoreReport(String reportId) async {
    final data = await _client.post('v1/reports/$reportId/restore');
    final d = data['data'] as Map<String, dynamic>;
    return _reportFromJson(d);
  }
}
