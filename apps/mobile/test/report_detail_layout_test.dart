import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  int deletes = 0;

  @override
  Future<Report> deleteReport(String reportId) async {
    deletes++;
    return getReport(reportId);
  }

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
  testWidgets(
    'report actions stay at the top and deletion needs confirmation',
    (tester) async {
      final reports = _Reports();
      var backs = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () => backs++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final delete = find.byKey(const Key('report-detail-delete'));
      final original = find.byKey(const Key('report-detail-view-pdf'));
      expect(delete, findsOneWidget);
      expect(original, findsOneWidget);
      expect(
        tester.getTopLeft(delete).dy,
        lessThan(tester.getTopLeft(original).dy),
      );

      await tester.tap(find.byKey(const Key('report-detail-more-actions')));
      await tester.pumpAndSettle();
      expect(find.text('Attempt history'), findsOneWidget);
      expect(find.text('Compare reports'), findsOneWidget);
      expect(find.text('Reassign to profile'), findsNothing);
      await tester.tapAt(const Offset(20, 300));
      await tester.pumpAndSettle();

      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.text('Move to recycle bin?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(reports.deletes, 0);

      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump();
      expect(reports.deletes, 1);
      expect(backs, 1);
    },
  );

  for (final width in [320.0, 375.0, 430.0]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'long lab data fits ${width.toInt()}px at ${textScale}x text',
        (tester) async {
          tester.view.physicalSize = Size(width, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 700),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: ReportDetailScreen(
                  reportsRepository: _Reports(),
                  profilesRepository: _Profiles(),
                  reportId: 'report',
                  profileId: 'profile',
                  onBack: () {},
                ),
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
          await tester.ensureVisible(find.text('Range unclear'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Range unclear'));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('result-insight-hero')), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
