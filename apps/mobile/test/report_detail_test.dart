import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/pdf_viewer_screen.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';
import 'package:mobile/features/reports/screens/trend_chart_screen.dart';
import 'mocks.dart';

void main() {
  late MockReportsRepository reportsRepo;

  setUp(() {
    reportsRepo = MockReportsRepository();
  });

  testWidgets('Report detail shows loading then content when report loads',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'lab.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('report-detail-loading')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report-detail-content')), findsOneWidget);
    expect(find.text('lab.pdf'), findsOneWidget);
    expect(find.text('No structured data'), findsOneWidget);
    verify(() => reportsRepo.getReport('r1')).called(1);
  });

  testWidgets('Report detail shows lab values when present',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'lab.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [
            const ExtractedLabValue(
              parameterName: 'HbA1c',
              value: '5.8',
              unit: '%',
              sampleDate: '2026-01-15',
            ),
          ],
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report-detail-lab-values')), findsOneWidget);
    expect(find.text('Lab values'), findsOneWidget);
    expect(find.text('HbA1c'), findsOneWidget);
    expect(find.text('5.8'), findsOneWidget);
  });

  testWidgets('Report detail View PDF button navigates to viewer',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'lab.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-detail-view-pdf')));
    await tester.pumpAndSettle();

    expect(find.byType(PdfViewerScreen), findsOneWidget);
  });

  testWidgets('Report detail back button triggers onBack',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'lab.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));

    var backCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () => backCalled = true,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-detail-back')));
    await tester.pumpAndSettle();

    expect(backCalled, isTrue);
  });

  testWidgets('Report detail tapping lab row navigates to trend chart screen',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'lab.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [
            const ExtractedLabValue(
              parameterName: 'HbA1c',
              value: '5.8',
              unit: '%',
              sampleDate: '2026-01-15',
            ),
          ],
        ));
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => const LabTrendsResult(parameters: []));

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lab-row-HbA1c')));
    await tester.pumpAndSettle();

    expect(find.byType(TrendChartScreen), findsOneWidget);
  });

  testWidgets('Report detail with content_not_recognized shows Retry and Keep file',
      (WidgetTester tester) async {
    when(() => reportsRepo.getReport(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'brochure.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'content_not_recognized',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));
    when(() => reportsRepo.retryParse(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'brochure.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'parsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));
    when(() => reportsRepo.keepFile(any())).thenAnswer((_) async => Report(
          id: 'r1',
          profileId: 'p1',
          originalFileName: 'brochure.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'unparsed',
          createdAt: DateTime(2026, 1, 15),
          extractedLabValues: [],
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reportsRepo,
          reportId: 'r1',
          profileId: 'p1',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Not a health report'), findsOneWidget);
    expect(find.byKey(const Key('report-detail-retry')), findsOneWidget);
    expect(find.byKey(const Key('report-detail-keep-file')), findsOneWidget);
  });
}
