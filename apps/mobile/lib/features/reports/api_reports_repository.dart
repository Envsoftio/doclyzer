import 'dart:io';
import 'package:crypto/crypto.dart';
import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import 'reports_repository.dart';
import 'result_range.dart';

class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository(this._client, {TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<void> requestSummary(String reportId, {bool refresh = false}) async {
    await _client.post(
      'v1/reports/processing/$reportId/summary/retry${refresh ? '?refresh=true' : ''}',
    );
  }

  static final RegExp _rangeToken = RegExp(
    r'^\s*-?\d+(?:\.\d+)?\s*[-–—]\s*-?\d+(?:\.\d+)?\s*$',
  );

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  ({String? age, String? gender}) _splitAgeGender(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return (age: null, gender: null);
    final parts = value.split('/');
    if (parts.length >= 2) {
      final age = parts.first.trim();
      final gender = parts.sublist(1).join('/').trim();
      return (
        age: age.isEmpty ? null : age,
        gender: gender.isEmpty ? null : gender,
      );
    }
    return (age: value, gender: null);
  }

  bool _looksNoisyParameter(String input) {
    final p = _normalize(input);
    if (p.isEmpty) return true;
    // A test name can be unfamiliar, long, or include several familiar words.
    // Only discard fields that are unambiguously table headers.
    return p == 'investigation results' || p == 'reference range';
  }

  String? _firstRange(String text) {
    if (preferredPrintedRange(text) != null) return text.trim();
    return _rangeToken.hasMatch(text)
        ? text.trim().replaceAll(RegExp(r'\s+'), '')
        : null;
  }

  bool? _isOutOfRange(String name, String value, String? unit, String? range) {
    final position = compareWithPrintedRange(
      ExtractedLabValue(
        parameterName: name,
        value: value,
        unit: unit,
        referenceRange: range,
      ),
    );
    return switch (position) {
      RangePosition.unknown => null,
      RangePosition.within => false,
      RangePosition.below || RangePosition.above => true,
    };
  }

  List<ExtractedLabValue> _cleanLabValues(List<ExtractedLabValue> raw) {
    final cleaned = <ExtractedLabValue>[];
    final seen = <String>{};
    final hasNoisyRows = raw.any((r) => _looksNoisyParameter(r.parameterName));

    void add(ExtractedLabValue v) {
      final name = v.parameterName.trim();
      final value = v.value.trim();
      if (name.isEmpty || value.isEmpty) return;
      final k =
          v.id ??
          '${_normalize(name)}|$value|${_normalize(v.unit ?? '')}|${_normalize(v.referenceRange ?? '')}';
      if (seen.contains(k)) return;
      seen.add(k);
      cleaned.add(v);
    }

    for (final row in raw) {
      // Keep source observations unless a field is an unambiguous table header.
      if (row.reviewVersion == 0 &&
          hasNoisyRows &&
          _looksNoisyParameter(row.parameterName)) {
        continue;
      }
      var range = row.referenceRange;
      var unit = row.unit;
      if (row.reviewVersion == 0 &&
          (range == null || range.trim().isEmpty) &&
          unit != null) {
        final inferred = _firstRange(unit);
        if (inferred != null) {
          range = inferred;
          unit = null;
        }
      }
      add(
        ExtractedLabValue(
          id: row.id,
          parameterName: row.parameterName.trim(),
          value: row.value.trim(),
          unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
          sampleDate: row.sampleDate,
          referenceRange: range?.trim().isEmpty == true ? null : range?.trim(),
          isAbnormal: row.reviewVersion > 0
              ? row.isAbnormal
              : row.isAbnormal ??
                    _isOutOfRange(row.parameterName, row.value, unit, range),
          reviewVersion: row.reviewVersion,
          sourceSnapshot: row.sourceSnapshot,
          canonicalTestId: row.canonicalTestId,
          resultKind: row.resultKind,
          reviewState: row.reviewState,
          collectionDateSource: row.collectionDateSource,
        ),
      );
    }

    return cleaned;
  }

  List<StructuredSection> _cleanStructuredSections(
    List<StructuredSection> rawSections,
  ) {
    final hasNoisyRows = rawSections.any(
      (s) => s.tests.any((t) => _looksNoisyParameter(t.parameterName)),
    );
    if (!hasNoisyRows) return rawSections;

    final cleanedSections = <StructuredSection>[];
    final seen = <String>{};

    StructuredSectionItem normalizeItem(StructuredSectionItem item) {
      var unit = item.unit;
      var range = item.referenceRange;
      if ((range == null || range.trim().isEmpty) && unit != null) {
        final inferred = _firstRange(unit);
        if (inferred != null) {
          range = inferred;
          unit = null;
        }
      }
      return StructuredSectionItem(
        parameterName: item.parameterName.trim(),
        value: item.value.trim(),
        unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
        sampleDate: item.sampleDate,
        referenceRange: range?.trim().isEmpty == true ? null : range?.trim(),
        isAbnormal:
            item.isAbnormal ??
            _isOutOfRange(item.parameterName, item.value, unit, range),
      );
    }

    for (final section in rawSections) {
      final tests = <StructuredSectionItem>[];
      for (final test in section.tests) {
        if (_looksNoisyParameter(test.parameterName)) continue;
        final normalized = normalizeItem(test);
        if (normalized.parameterName.isEmpty || normalized.value.isEmpty) {
          continue;
        }
        final key =
            '${_normalize(section.heading)}|${_normalize(normalized.parameterName)}|${normalized.value}|${_normalize(normalized.unit ?? '')}|${_normalize(normalized.referenceRange ?? '')}';
        if (seen.contains(key)) continue;
        seen.add(key);
        tests.add(normalized);
      }
      if (tests.isNotEmpty) {
        cleanedSections.add(
          StructuredSection(heading: section.heading, tests: tests),
        );
      }
    }

    return cleanedSections;
  }

  StructuredReport? _parseStructuredReport(Map<String, dynamic> d) {
    final sr = d['structuredReport'];
    if (sr is! Map<String, dynamic>) return null;

    final pd = sr['patientDetails'] as Map<String, dynamic>? ?? const {};
    final sectionsRaw = sr['sections'] as List<dynamic>? ?? const [];
    final review = sr['extractionReview'];

    var sections = sectionsRaw.whereType<Map<String, dynamic>>().map((s) {
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
    sections = _cleanStructuredSections(sections);

    // Promote "Age / Gender" from tests into patient details and remove it from sections.
    String? extractedAgeFromTests;
    String? extractedGenderFromTests;
    sections = sections
        .map((section) {
          final filtered = <StructuredSectionItem>[];
          for (final test in section.tests) {
            final key = _normalize(test.parameterName);
            if (key == 'age / gender' || key == 'age/gender') {
              final split = _splitAgeGender(test.unit ?? test.value);
              extractedAgeFromTests ??= split.age;
              extractedGenderFromTests ??= split.gender;
              continue;
            }
            filtered.add(test);
          }
          return StructuredSection(heading: section.heading, tests: filtered);
        })
        .where((s) => s.tests.isNotEmpty)
        .toList();

    final splitFromPatient = _splitAgeGender(pd['age'] as String?);
    final age = (pd['age'] as String?)?.trim().isNotEmpty == true
        ? (pd['age'] as String?)!.trim()
        : (splitFromPatient.age ?? extractedAgeFromTests);
    final gender = (pd['gender'] as String?)?.trim().isNotEmpty == true
        ? (pd['gender'] as String?)!.trim()
        : (splitFromPatient.gender ?? extractedGenderFromTests);

    return StructuredReport(
      extractionReview: review is Map<String, dynamic>
          ? ExtractionReview(
              required: review['required'] == true,
              candidateRows: (review['candidateRows'] as num?)?.toInt() ?? 0,
              parsedRows: (review['parsedRows'] as num?)?.toInt() ?? 0,
              reasons: (review['reasons'] as List<dynamic>? ?? const [])
                  .whereType<String>()
                  .toList(),
            )
          : null,
      patientDetails: StructuredPatientDetails(
        name: pd['name'] as String?,
        age: age,
        gender: gender,
        bookingId: pd['bookingId'] as String?,
        sampleCollectionDate: pd['sampleCollectionDate'] as String?,
      ),
      labDetails: (sr['labDetails'] is Map<String, dynamic>)
          ? StructuredLabDetails(
              name:
                  (sr['labDetails'] as Map<String, dynamic>)['name'] as String?,
              address:
                  (sr['labDetails'] as Map<String, dynamic>)['address']
                      as String?,
              phone:
                  (sr['labDetails'] as Map<String, dynamic>)['phone']
                      as String?,
              email:
                  (sr['labDetails'] as Map<String, dynamic>)['email']
                      as String?,
              location:
                  (sr['labDetails'] as Map<String, dynamic>)['location']
                      as String?,
            )
          : null,
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
      laboratoryName: d['laboratoryName'] as String?,
      contentType: d['contentType'] as String,
      sizeBytes: d['sizeBytes'] as int,
      status: d['status'] as String,
      summaryStatus: d['summaryStatus'] as String?,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      collectionDate: d['collectionDate'] as String?,
      collectionDateStatus: d['collectionDateStatus'] as String?,
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
    final capabilities = await _client.get(
      'v1/reports/processing/capabilities',
    );
    if (capabilities['data']?['acceptance'] == true) {
      final profiles = (await _client.get('v1/profiles'))['data'] as List;
      final profile = profiles.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['isActive'] == true,
      );
      final profileId = profile['id'] as String;
      final hash = (await sha256.bind(File(filePath).openRead()).first)
          .toString();
      final key = await _tokenStorage.getOrCreateReportUploadKey(
        profileId,
        hash,
      );
      await _tokenStorage.markReportUploadStarted();
      late Map<String, dynamic> response;
      try {
        response = await _client.uploadFile(
          'v1/reports/processing/uploads',
          'file',
          filePath,
          extraHeaders: {'Idempotency-Key': key},
          fields: {'profileId': profileId},
        );
      } on ApiException catch (error) {
        if (error.code == 'REPORT_IDEMPOTENCY_EXPIRED') {
          await _tokenStorage.clearReportUploadKey(profileId, hash);
        }
        rethrow;
      }
      final d = response['data'] as Map<String, dynamic>;
      const legacy = {
        'ready': 'parsed',
        'processing': 'parsing',
        'retry_scheduled': 'failed_transient',
        'failed': 'failed_terminal',
        'needs_attention': 'content_not_recognized',
        'cancelled': 'unparsed',
      };
      final accepted = UploadedReport(
        reportId: d['reportId'] as String,
        profileId: d['profileId'] as String,
        fileName: d['fileName'] as String,
        contentType: d['contentType'] as String,
        sizeBytes: d['sizeBytes'] as int,
        status: legacy[d['status']] ?? d['status'] as String,
        reused: d['reused'] == true,
      );
      await _tokenStorage.clearInterruptedReportUpload();
      return accepted;
    }
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
  Future<List<Report>> searchReports(String profileId, String query) async {
    final data = await _client.get(
      'v1/reports/search?profileId=${Uri.encodeQueryComponent(profileId)}&q=${Uri.encodeQueryComponent(query)}',
    );
    final list = data['data']?['reports'] as List<dynamic>? ?? [];
    return list
        .map((item) => _reportFromJson(item as Map<String, dynamic>))
        .toList();
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
        id: m['id'] as String?,
        parameterName: m['parameterName'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit: m['unit'] as String?,
        sampleDate: m['sampleDate'] as String?,
        referenceRange: m['referenceRange'] as String?,
        isAbnormal: m['isAbnormal'] as bool?,
        reviewVersion: (m['reviewVersion'] as num?)?.toInt() ?? 0,
        sourceSnapshot: m['sourceSnapshot'] as Map<String, dynamic>?,
        canonicalTestId: m['canonicalTestId'] as String?,
        resultKind: m['resultKind'] as String?,
        reviewState: m['reviewState'] as String?,
        collectionDateSource: m['collectionDateSource'] as String?,
      );
    }).toList();
    return _reportFromJson(
      d,
      extractedLabValues: _cleanLabValues(extractedLabValues),
      structuredReport: _parseStructuredReport(d),
    );
  }

  @override
  Future<Report> correctResult(
    String reportId,
    ExtractedLabValue result, {
    required String parameterName,
    required String value,
    String? unit,
    String? sampleDate,
    String? referenceRange,
  }) async {
    if (result.id == null) {
      throw StateError('This result cannot be edited yet.');
    }
    await _client.patch(
      'v1/reports/${Uri.encodeComponent(reportId)}/results/${Uri.encodeComponent(result.id!)}',
      body: {
        'expectedVersion': result.reviewVersion,
        'parameterName': parameterName,
        'value': value,
        'unit': unit,
        'sampleDate': sampleDate,
        'referenceRange': referenceRange,
      },
    );
    return getReport(reportId);
  }

  @override
  Future<ResultInsight> getResultInsight(
    String reportId,
    ExtractedLabValue result,
  ) async {
    final response = await _client.post(
      'v1/reports/${Uri.encodeComponent(reportId)}/results/insight',
      body: {
        'parameterName': result.parameterName,
        'value': result.value,
        'unit': result.unit ?? '',
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    return ResultInsight(
      testExplanation: data['testExplanation'] as String,
      resultExplanation: data['resultExplanation'] as String,
      possibleSignificance: data['possibleSignificance'] as String,
      lifestyleConsiderations:
          (data['lifestyleConsiderations'] as List<dynamic>).cast<String>(),
      suggestedFollowup: data['suggestedFollowup'] as String,
      dataUncertainties: (data['dataUncertainties'] as List<dynamic>)
          .cast<String>(),
    );
  }

  @override
  Future<Report> retryParse(String reportId, {bool force = false}) async {
    final existing =
        (await _client.get('v1/reports/$reportId'))['data']
            as Map<String, dynamic>;
    if (existing['processingState'] != null) {
      await _client.post('v1/reports/processing/$reportId/retry');
      return getReport(reportId);
    }
    final path = force
        ? 'v1/reports/$reportId/retry?force=true'
        : 'v1/reports/$reportId/retry';
    Map<String, dynamic> data;
    try {
      data = await _client.post(path);
    } on ApiException catch (error) {
      if (error.code != 'REPORT_ASYNC_RETRY_REQUIRED') rethrow;
      await _client.post('v1/reports/processing/$reportId/retry');
      return getReport(reportId);
    }
    final d = data['data'] as Map<String, dynamic>;
    final labList = d['extractedLabValues'] as List<dynamic>? ?? [];
    final extractedLabValues = labList.map((e) {
      final m = e as Map<String, dynamic>;
      return ExtractedLabValue(
        id: m['id'] as String?,
        parameterName: m['parameterName'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit: m['unit'] as String?,
        sampleDate: m['sampleDate'] as String?,
        referenceRange: m['referenceRange'] as String?,
        isAbnormal: m['isAbnormal'] as bool?,
        reviewVersion: (m['reviewVersion'] as num?)?.toInt() ?? 0,
        sourceSnapshot: m['sourceSnapshot'] as Map<String, dynamic>?,
        canonicalTestId: m['canonicalTestId'] as String?,
        resultKind: m['resultKind'] as String?,
        reviewState: m['reviewState'] as String?,
        collectionDateSource: m['collectionDateSource'] as String?,
      );
    }).toList();
    return _reportFromJson(
      d,
      extractedLabValues: _cleanLabValues(extractedLabValues),
      structuredReport: _parseStructuredReport(d),
    );
  }

  @override
  Future<List<int>> getReportFile(String reportId) async {
    return _client.getBytes('v1/reports/$reportId/file');
  }

  @override
  Future<ReportReview> getReportReview(String reportId) async {
    final response = await _client.get(
      'v1/reports/${Uri.encodeComponent(reportId)}/vl-review',
    );
    final data = response['data'] as Map<String, dynamic>;
    final candidates = (data['candidates'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => ReportReviewCandidate(
            id: row['id'] as String,
            page: (row['page'] as num?)?.toInt() ?? 0,
            testRaw: row['testRaw'] as String? ?? '',
            resultRaw: row['resultRaw'] as String?,
            unitRaw: row['unitRaw'] as String?,
            rangeRaw: row['rangeRaw'] as String?,
            reviewReasons: (row['reviewReasons'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(),
          ),
        )
        .toList();
    final applied = data['applied'] as Map<String, dynamic>? ?? const {};
    return ReportReview(
      candidates: candidates,
      applied: applied.keys.toSet(),
      reviewVersion: (data['reviewVersion'] as num?)?.toInt() ?? 0,
      partial: data['status'] == 'partial',
    );
  }

  @override
  Future<int> reviewReportCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
    required String action,
    required String testRaw,
    required String? resultRaw,
    String? unitRaw,
    String? rangeRaw,
  }) async {
    final response = await _client.patch(
      'v1/reports/${Uri.encodeComponent(reportId)}/vl-review/${Uri.encodeComponent(candidateId)}',
      body: {
        'expectedVersion': expectedVersion,
        'action': action,
        'sourceInspected': true,
        'testRaw': testRaw,
        'resultRaw': resultRaw,
        'unitRaw': unitRaw,
        'rangeRaw': rangeRaw,
      },
    );
    return ((response['data'] as Map<String, dynamic>)['reviewVersion'] as num)
        .toInt();
  }

  @override
  Future<void> applyReviewedCandidate(
    String reportId,
    String candidateId, {
    required int expectedVersion,
  }) async {
    await _client.post(
      'v1/reports/${Uri.encodeComponent(reportId)}/vl-review/${Uri.encodeComponent(candidateId)}/apply',
      body: {'expectedVersion': expectedVersion},
    );
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
          reportId: dpm['reportId'] as String?,
          originalValue: dpm['originalValue'] as String?,
          referenceRange: dpm['referenceRange'] as String?,
          originalUnit: dpm['originalUnit'] as String?,
          dateProvenance: dpm['dateProvenance'] as String?,
        );
      }).toList();
      final observations = (pm['observations'] as List<dynamic>? ?? []).map((
        item,
      ) {
        final row = item as Map<String, dynamic>;
        final date = row['date'] as String?;
        return TrendObservation(
          id: row['id'] as String?,
          reportId: row['reportId'] as String,
          originalValue: row['originalValue'] as String,
          date: date == null ? null : DateTime.tryParse(date),
          value: (row['value'] as num?)?.toDouble(),
          referenceRange: row['referenceRange'] as String?,
          notPlottedReason: row['notPlottedReason'] as String?,
          originalUnit: row['originalUnit'] as String?,
          dateProvenance: row['dateProvenance'] as String?,
          reviewState: row['reviewState'] as String?,
        );
      }).toList();
      return TrendParameter(
        parameterName: pm['parameterName'] as String,
        unit: pm['unit'] as String?,
        dataPoints: dataPoints,
        observations: observations,
        unplottedCount: (pm['unplottedCount'] as num?)?.toInt() ?? 0,
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

  @override
  Future<void> permanentlyDeleteReport(String reportId) =>
      _client.delete('v1/reports/recycle-bin/$reportId');

  @override
  Future<RecycleBinEmptyResult> emptyRecycleBin() async {
    final response = await _client.deleteAndGetJson('v1/reports/recycle-bin');
    final data = response['data'] as Map<String, dynamic>;
    return RecycleBinEmptyResult(
      deletedCount: data['deletedCount'] as int,
      failedCount: data['failedCount'] as int,
    );
  }
}
