import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/result_correction_screen.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';

class _Corrections extends Fake implements ReportsRepository {
  _Corrections({this.conflict = false});

  final bool conflict;
  String? savedValue;
  String? savedDate;
  int? savedVersion;

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
    if (conflict) {
      throw ApiException('REPORT_RESULT_VERSION_CONFLICT', 'Result changed');
    }
    savedVersion = result.reviewVersion;
    savedValue = value;
    savedDate = sampleDate;
    return Report(
      id: reportId,
      profileId: 'profile',
      originalFileName: 'source.pdf',
      contentType: 'application/pdf',
      sizeBytes: 1,
      status: 'parsed',
      createdAt: DateTime(2026),
    );
  }
}

class _ReportWithCorrection extends _Corrections {
  @override
  Future<Report> getReport(String reportId) async => Report(
    id: reportId,
    profileId: 'profile',
    originalFileName: 'source.pdf',
    contentType: 'application/pdf',
    sizeBytes: 1,
    status: 'parsed',
    createdAt: DateTime(2026),
    extractedLabValues: const [result],
  );
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

const result = ExtractedLabValue(
  id: 'row',
  parameterName: 'Hb',
  value: '10',
  unit: 'g/dL',
  reviewVersion: 1,
  sourceSnapshot: {'parameterName': 'Hb', 'value': '9', 'unit': 'g/dL'},
);

Future<void> _showEditor(WidgetTester tester, _Corrections repository) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => Navigator.of(context).push<Report>(
              MaterialPageRoute<Report>(
                builder: (_) => ResultCorrectionScreen(
                  reportId: 'report',
                  result: result,
                  reportsRepository: repository,
                  onViewOriginal: () {},
                ),
              ),
            ),
            child: const Text('Open review'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open review'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('report result opens the review screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: _ReportWithCorrection(),
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-result-row')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('review-result-row')));
    await tester.pumpAndSettle();
    expect(find.byType(ResultCorrectionScreen), findsOneWidget);
  });

  testWidgets('review saves the displayed version and corrected date', (
    tester,
  ) async {
    final repository = _Corrections();
    await _showEditor(tester, repository);
    expect(find.text('Originally extracted'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('correction-value')), '11');
    await tester.enterText(
      find.byKey(const Key('correction-date')),
      '2026-01-02',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('correction-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('correction-save')));
    await tester.pumpAndSettle();
    expect(repository.savedVersion, 1);
    expect(repository.savedValue, '11');
    expect(repository.savedDate, '2026-01-02');
    expect(find.text('Open review'), findsOneWidget);
  });

  testWidgets('stale edits ask for reload', (tester) async {
    await _showEditor(tester, _Corrections(conflict: true));
    await tester.scrollUntilVisible(
      find.byKey(const Key('correction-save')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('correction-save')));
    await tester.pumpAndSettle();
    expect(find.text('Result changed'), findsOneWidget);
    expect(find.byKey(const Key('correction-reload')), findsOneWidget);
  });
}
