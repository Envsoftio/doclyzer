import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<ResultInsight> getResultInsight(
    String reportId,
    ExtractedLabValue result,
  ) async => const ResultInsight(
    testExplanation: 'A measured lab value.',
    resultExplanation: 'Compare with the listed lab range.',
    possibleSignificance: 'This requires clinical context.',
    lifestyleConsiderations: [],
    suggestedFollowup: 'Review this with a clinician.',
    dataUncertainties: ['The result needs context.'],
  );

  @override
  Future<Report> getReport(String reportId) async => Report(
    id: reportId,
    profileId: 'profile',
    originalFileName: 'long-lab-report.pdf',
    contentType: 'application/pdf',
    sizeBytes: 100,
    status: 'parsed',
    createdAt: DateTime(2026),
    structuredReport: const StructuredReport(
      patientDetails: StructuredPatientDetails(),
      sections: [
        StructuredSection(
          heading: 'Blood chemistry',
          tests: [
            StructuredSectionItem(
              parameterName: 'Very long laboratory parameter name',
              value: '123456789012345678901234567890',
              unit: 'milligrams per deciliter',
              referenceRange: '123456789012345678901234567890',
            ),
          ],
        ),
      ],
    ),
    extractedLabValues: const [
      ExtractedLabValue(
        parameterName: 'Very long laboratory parameter name',
        value: '123456789012345678901234567890',
        unit: 'milligrams per deciliter',
        sampleDate: '2026-10-17T12:34:56+05:30',
        referenceRange: '123456789012345678901234567890',
      ),
    ],
  );
}

class _Profiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [];
}

void main() {
  testWidgets('long lab data fits a narrow report detail screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: _Reports(),
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('report-detail-lab-values')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Range unclear'), findsOneWidget);
    await tester.tap(find.text('Range unclear'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('result-insight-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
