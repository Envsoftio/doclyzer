import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/api_reports_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/result_range.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

const _lipidRange =
    'Optimal: <100\nAbove Optimal: 100-129\n'
    'Borderline: 130-159\nHigh: 160-189\nVery High: >190';

class _ReportClient extends ApiClient {
  _ReportClient(this.results)
    : super(baseUrl: 'https://example.test', onRefreshToken: () async => null);

  final List<Map<String, dynamic>> results;

  @override
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async => {
    'data': {
      'id': 'report',
      'profileId': 'profile',
      'originalFileName': 'lab-report.pdf',
      'contentType': 'application/pdf',
      'sizeBytes': 100,
      'status': 'parsed',
      'createdAt': '2026-10-23T00:00:00Z',
      'extractedLabValues': results,
    },
  };
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

void main() {
  test(
    'printed optimal range supports each LDL category and its boundaries',
    () {
      expect(preferredPrintedRange(_lipidRange), '<100');
      for (final entry in <String, RangePosition>{
        '99.9': RangePosition.within,
        '100': RangePosition.above,
        '115': RangePosition.above,
        '145': RangePosition.above,
        '170': RangePosition.above,
        '200': RangePosition.above,
      }.entries) {
        expect(
          compareWithPrintedRange(
            ExtractedLabValue(
              parameterName: 'LDL cholesterol',
              value: entry.key,
              unit: 'mg/dL',
              referenceRange: _lipidRange,
            ),
          ),
          entry.value,
          reason: entry.key,
        );
      }
    },
  );

  test('category matching distinguishes qualifiers from preferred labels', () {
    for (final label in [
      'Above Optimal',
      'Near Optimal',
      'Near or Above Optimal',
    ]) {
      expect(
        preferredPrintedRange('Optimal: <100; $label: 100-129 | High: >129'),
        '<100',
      );
      expect(preferredPrintedRange('$label: 100-129 High: >129'), isNull);
    }
    expect(
      preferredPrintedRange(
        'Very Low: <20 Low: 20-29 Borderline Low: 30-39 '
        'Normal: 40-60 Borderline High: 61-79 High: 80-99 Very High: >99',
      ),
      '40-60',
    );
  });

  test('category formatting handles escaped separators and HTML entities', () {
    for (final range in [
      _lipidRange.replaceAll('\n', r'\'),
      _lipidRange.replaceAll('\n', r'\n'),
      _lipidRange.replaceAll('\n', r'\r\n'),
      _lipidRange.replaceAll('\n', '<br/>'),
      _lipidRange
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&#x3e;')
          .replaceAll(' ', '&#x20;'),
    ]) {
      expect(preferredPrintedRange(range), '<100', reason: range);
    }
  });

  test('ambiguous or malformed category text remains uncomparable', () {
    for (final range in [
      'Optimal: <100 Normal: <120 High: >120',
      'Male Normal: <100 Female Normal: <120',
      'Optimal: <100 High: 200-150',
      'Optimal: <100 Above Optimal: 90-129 High: >129',
      'Normal: 0-100 High: 100-200',
      'Optimal: <100 High: >150-200',
      'Optimal: <100 High: 150',
      'Optimal: <100 Unknown category: >100',
      'Optimal: <100 (adults only) High: >100',
      'Optimal: <100000 High: >100000',
      'Optimal: <100High: >100',
    ]) {
      expect(preferredPrintedRange(range), isNull, reason: range);
      expect(
        compareWithPrintedRange(
          ExtractedLabValue(
            parameterName: 'Lipid',
            value: '90',
            unit: 'mg/dL',
            referenceRange: range,
          ),
        ),
        RangePosition.unknown,
        reason: range,
      );
    }
  });

  test('Albumin uses its clear printed decimal interval', () {
    for (final range in [
      '3.50-5.20',
      '3.50 − 5.20',
      '3.50\u00a0–\u202f5.20',
      '3.50&#x20;&ndash;&#32;5.20',
    ]) {
      expect(
        compareWithPrintedRange(
          ExtractedLabValue(
            parameterName: 'Albumin',
            value: '4.06&#x20;',
            unit: 'g/dL',
            referenceRange: range,
            isAbnormal: false,
            reviewState: 'needs_review',
          ),
        ),
        RangePosition.within,
        reason: range,
      );
    }
  });

  test('clear ranges retain unknown for conflicting lab flags', () {
    for (final result in [
      const ExtractedLabValue(
        parameterName: 'Albumin',
        value: '4.06',
        unit: 'g/dL',
        referenceRange: '3.50-5.20',
        isAbnormal: true,
      ),
      const ExtractedLabValue(
        parameterName: 'LDL',
        value: '90',
        unit: 'mg/dL',
        referenceRange: _lipidRange,
        isAbnormal: true,
      ),
    ]) {
      expect(compareWithPrintedRange(result), RangePosition.unknown);
    }
  });

  test(
    'missing or encoded blank units do not block printed range comparison',
    () {
      for (final unit in ['&#x20;', '&nbsp;', '&#32;', '\u00a0\u202f']) {
        final result = ExtractedLabValue(
          parameterName: 'Albumin',
          value: '4.06',
          unit: unit,
          referenceRange: '3.50-5.20',
        );
        expect(
          compareWithPrintedRange(result),
          RangePosition.within,
          reason: unit,
        );
      }
      expect(
        compareWithPrintedRange(
          const ExtractedLabValue(
            parameterName: 'Unfamiliar measured parameter',
            value: '1.7',
            referenceRange: '2.5-3.5',
          ),
        ),
        RangePosition.below,
      );
      expect(
        compareWithPrintedRange(
          const ExtractedLabValue(
            parameterName: 'Unfamiliar measured parameter',
            value: '1.7',
          ),
        ),
        RangePosition.unknown,
      );
    },
  );

  test(
    'API cleanup derives absent flags from the same printed comparison',
    () async {
      final repository = ApiReportsRepository(
        _ReportClient([
          for (final value in ['98.48', '115', '<90'])
            {
              'parameterName': 'LDL cholesterol',
              'value': value,
              'unit': 'mg/dL',
              'referenceRange': _lipidRange,
            },
          {
            'parameterName': 'Ambiguous range',
            'value': '90',
            'unit': 'mg/dL',
            'referenceRange': 'Male: 80-100 Female: 120-150',
          },
        ]),
      );
      final report = await repository.getReport('report');
      expect(report.extractedLabValues.map((row) => row.isAbnormal), [
        false,
        true,
        null,
        null,
      ]);
      expect(report.extractedLabValues.map(compareWithPrintedRange), [
        RangePosition.within,
        RangePosition.above,
        RangePosition.unknown,
        RangePosition.unknown,
      ]);
    },
  );

  test(
    'API cleanup recovers a complete category range from the unit field',
    () async {
      final repository = ApiReportsRepository(
        _ReportClient([
          {
            'parameterName': 'LDL cholesterol',
            'value': '98.48',
            'unit': _lipidRange,
          },
          {
            'parameterName': 'Albumin',
            'value': '4.06',
            'unit': 'g/dL 3.50-5.20',
          },
        ]),
      );
      final rows = (await repository.getReport('report')).extractedLabValues;
      expect(rows[0].referenceRange, _lipidRange);
      expect(rows[0].unit, isNull);
      expect(rows[0].isAbnormal, isFalse);
      expect(rows[1].referenceRange, isNull);
      expect(rows[1].unit, 'g/dL 3.50-5.20');
      expect(rows[1].isAbnormal, isNull);
    },
  );

  test(
    'API cleanup preserves equal values measured in different units',
    () async {
      final repository = ApiReportsRepository(
        _ReportClient([
          {
            'parameterName': 'Novel count',
            'value': '2',
            'unit': '%',
            'referenceRange': '1-3',
          },
          {
            'parameterName': 'Novel count',
            'value': '2',
            'unit': '/cmm',
            'referenceRange': '4-6',
          },
        ]),
      );
      final rows = (await repository.getReport('report')).extractedLabValues;
      expect(rows.length, 2);
      expect(rows.map((row) => row.unit), ['%', '/cmm']);
    },
  );

  test('API cleanup preserves unfamiliar and composite test names', () async {
    final repository = ApiReportsRepository(
      _ReportClient([
        {'parameterName': 'Investigation Results', 'value': 'Result'},
        {
          'parameterName':
              'Novel assay with a long descriptive laboratory name that exceeds twelve words in the source report',
          'value': '4.06',
          'unit': 'g/dL',
          'referenceRange': '3.50-5.20',
        },
        {
          'parameterName': 'Haemoglobin (Hb) and Platelet Count (PC) ratio',
          'value': '2.0',
          'unit': 'ratio',
          'referenceRange': '1.0-3.0',
        },
      ]),
    );
    final rows = (await repository.getReport('report')).extractedLabValues;
    expect(rows.length, 2);
    expect(rows[0].parameterName, startsWith('Novel assay'));
    expect(
      rows[1].parameterName,
      'Haemoglobin (Hb) and Platelet Count (PC) ratio',
    );
  });

  testWidgets(
    'Albumin API result renders in range even when review is needed',
    (tester) async {
      final repository = ApiReportsRepository(
        _ReportClient([
          {
            'id': 'albumin',
            'parameterName': 'Albumin',
            'value': '4.06',
            'unit': 'g/dL',
            'referenceRange': '3.50-5.20',
            'isAbnormal': false,
            'reviewState': 'needs_review',
            'reviewVersion': 0,
          },
        ]),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: repository,
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('lab-row-Albumin')));
      await tester.pumpAndSettle();
      expect(find.text('4.06 g/dL'), findsOneWidget);
      expect(find.text('Lab range 3.50-5.20'), findsOneWidget);
      expect(find.text('In listed range'), findsOneWidget);
      expect(find.text('Range unclear'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('result with a blank unit shows its printed range position', (
    tester,
  ) async {
    final repository = ApiReportsRepository(
      _ReportClient([
        {
          'parameterName': 'Unfamiliar calculation',
          'value': '1.7',
          'referenceRange': '2.5-3.5',
          'isAbnormal': true,
        },
      ]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: repository,
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('lab-row-Unfamiliar calculation')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Below range'), findsOneWidget);
    expect(find.text('Range unclear'), findsNothing);
  });
}
