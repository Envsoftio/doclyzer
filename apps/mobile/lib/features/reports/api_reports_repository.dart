import '../../core/api_client.dart';
import 'reports_repository.dart';

class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository(this._client);

  final ApiClient _client;
  static final RegExp _numToken = RegExp(r'[-+]?\d+(?:\.\d+)?');
  static final RegExp _rangeToken = RegExp(r'\b\d+(?:\.\d+)?\s*-\s*\d+(?:\.\d+)?\b');

  static const List<String> _knownTests = [
    'Reticulocyte Count',
    'Haemoglobin (Hb)',
    'Total Leucocyte Count (TLC)',
    'Polymorphs',
    'Lymphocyte',
    'Monocytes',
    'Eosinophils',
    'Basophils',
    'Platelet Count (PC)',
    'RBC Count',
    'Haematocrit (HCT)',
    'Mean Corpuscular Volume (MCV)',
    'Mean Corpuscular Hemoglobin (MCH)',
    'Mean Corpuscular Hemoglobin Concentration (MCHC)',
    'Red Cell Distribution Width (RDW)',
  ];

  String _normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

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
    final wordCount = p.split(' ').length;
    if (wordCount > 12) return true;
    if (p.contains('investigation results') || p.contains('reference range')) {
      return true;
    }
    var matches = 0;
    for (final test in _knownTests) {
      if (p.contains(_normalize(test))) matches++;
      if (matches >= 2) return true;
    }
    return false;
  }

  String? _firstRange(String text) {
    final m = _rangeToken.firstMatch(text);
    return m?.group(0)?.replaceAll(' ', '');
  }

  double? _toNumber(String? s) {
    if (s == null) return null;
    final m = RegExp(r'[-+]?\d+(?:\.\d+)?').firstMatch(s);
    if (m == null) return null;
    return double.tryParse(m.group(0)!);
  }

  bool? _isOutOfRange(String? value, String? referenceRange) {
    final v = _toNumber(value);
    if (v == null) return null;
    if (referenceRange == null || referenceRange.trim().isEmpty) return null;
    final rm = RegExp(
      r'([-+]?\d+(?:\.\d+)?)\s*-\s*([-+]?\d+(?:\.\d+)?)',
    ).firstMatch(referenceRange);
    if (rm == null) return null;
    final min = double.tryParse(rm.group(1)!);
    final max = double.tryParse(rm.group(2)!);
    if (min == null || max == null) return null;
    return v < min || v > max;
  }

  String? _firstNumberAfter(String text, int startIndex) {
    final tail = text.substring(startIndex);
    final m = _numToken.firstMatch(tail);
    return m?.group(0);
  }

  List<ExtractedLabValue> _cleanLabValues(
    List<ExtractedLabValue> raw,
    String? transcript,
  ) {
    final cleaned = <ExtractedLabValue>[];
    final seen = <String>{};
    final hasNoisyRows = raw.any((r) => _looksNoisyParameter(r.parameterName));

    void add(ExtractedLabValue v) {
      final name = v.parameterName.trim();
      final value = v.value.trim();
      if (name.isEmpty || value.isEmpty) return;
      final k = '${_normalize(name)}|$value';
      if (seen.contains(k)) return;
      seen.add(k);
      cleaned.add(v);
    }

    for (final row in raw) {
      // Keep old-PDF behavior unless we actually detect OCR-style merged noise.
      if (hasNoisyRows && _looksNoisyParameter(row.parameterName)) continue;
      var range = row.referenceRange;
      var unit = row.unit;
      if ((range == null || range.trim().isEmpty) && unit != null) {
        final inferred = _firstRange(unit);
        if (inferred != null) {
          range = inferred;
          unit = null;
        }
      }
      add(
        ExtractedLabValue(
          parameterName: row.parameterName.trim(),
          value: row.value.trim(),
          unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
          sampleDate: row.sampleDate,
          referenceRange: range?.trim().isEmpty == true ? null : range?.trim(),
          isAbnormal:
              row.isAbnormal ??
              _isOutOfRange(row.value, range?.trim()),
        ),
      );
    }

    final t = transcript ?? '';
    if (hasNoisyRows && t.trim().isNotEmpty) {
      for (final test in _knownTests) {
        final idx = t.toLowerCase().indexOf(test.toLowerCase());
        if (idx < 0) continue;
        final value = _firstNumberAfter(t, idx + test.length);
        if (value == null) continue;
        final around = t.substring(idx, (idx + 120).clamp(0, t.length));
        final range = _firstRange(around);
        add(
          ExtractedLabValue(
            parameterName: test,
            value: value,
            unit: null,
            sampleDate: null,
            referenceRange: range,
            isAbnormal: _isOutOfRange(value, range),
          ),
        );
      }
    }

    return cleaned;
  }

  List<StructuredSection> _cleanStructuredSections(
    List<StructuredSection> rawSections,
    String? transcript,
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
            _isOutOfRange(item.value, range?.trim()),
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
            '${_normalize(section.heading)}|${_normalize(normalized.parameterName)}|${normalized.value}';
        if (seen.contains(key)) continue;
        seen.add(key);
        tests.add(normalized);
      }
      if (tests.isNotEmpty) {
        cleanedSections.add(StructuredSection(heading: section.heading, tests: tests));
      }
    }

    final hasCbc = cleanedSections.any(
      (s) => _normalize(s.heading).contains('complete blood count'),
    );
    if (!hasCbc) {
      cleanedSections.add(const StructuredSection(heading: 'Complete Blood Count', tests: []));
    }

    final t = transcript ?? '';
    if (t.trim().isNotEmpty) {
      final cbcIndex = cleanedSections.indexWhere(
        (s) => _normalize(s.heading).contains('complete blood count'),
      );
      if (cbcIndex >= 0) {
        final tests = <StructuredSectionItem>[...cleanedSections[cbcIndex].tests];
        for (final known in _knownTests) {
          final idx = t.toLowerCase().indexOf(known.toLowerCase());
          if (idx < 0) continue;
          final value = _firstNumberAfter(t, idx + known.length);
          if (value == null) continue;
          final around = t.substring(idx, (idx + 120).clamp(0, t.length));
          final range = _firstRange(around);
          final key =
              '${_normalize(cleanedSections[cbcIndex].heading)}|${_normalize(known)}|$value';
          if (seen.contains(key)) continue;
          seen.add(key);
          tests.add(
            StructuredSectionItem(
              parameterName: known,
              value: value,
              unit: null,
              sampleDate: null,
              referenceRange: range,
              isAbnormal: _isOutOfRange(value, range),
            ),
          );
        }
        cleanedSections[cbcIndex] = StructuredSection(
          heading: cleanedSections[cbcIndex].heading,
          tests: tests,
        );
      }
    }

    return cleanedSections.where((s) => s.tests.isNotEmpty).toList();
  }

  StructuredReport? _parseStructuredReport(Map<String, dynamic> d) {
    final sr = d['structuredReport'];
    if (sr is! Map<String, dynamic>) return null;

    final pd = sr['patientDetails'] as Map<String, dynamic>? ?? const {};
    final sectionsRaw = sr['sections'] as List<dynamic>? ?? const [];

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
    sections = _cleanStructuredSections(
      sections,
      d['parsedTranscript'] as String?,
    );

    // Promote "Age / Gender" from tests into patient details and remove it from sections.
    String? extractedAgeFromTests;
    String? extractedGenderFromTests;
    sections = sections.map((section) {
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
    }).where((s) => s.tests.isNotEmpty).toList();

    final splitFromPatient = _splitAgeGender(pd['age'] as String?);
    final age = (pd['age'] as String?)?.trim().isNotEmpty == true
        ? (pd['age'] as String?)!.trim()
        : (splitFromPatient.age ?? extractedAgeFromTests);
    final gender = (pd['gender'] as String?)?.trim().isNotEmpty == true
        ? (pd['gender'] as String?)!.trim()
        : (splitFromPatient.gender ?? extractedGenderFromTests);

    return StructuredReport(
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
    final parsedTranscript = d['parsedTranscript'] as String?;
    return _reportFromJson(
      d,
      extractedLabValues: _cleanLabValues(extractedLabValues, parsedTranscript),
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
    final parsedTranscript = d['parsedTranscript'] as String?;
    return _reportFromJson(
      d,
      extractedLabValues: _cleanLabValues(extractedLabValues, parsedTranscript),
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
