import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profiles/profiles_repository.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/report_detail_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  _Reports({
    this.collectionDate,
    this.collectionDateStatus,
    this.summary,
    this.summaryStatus,
    this.failedSummaryRequests = 0,
  });

  final String? collectionDate;
  final String? collectionDateStatus;
  final String? summary;
  final String? summaryStatus;
  final int failedSummaryRequests;
  int summaryRequests = 0;
  bool? lastSummaryRefresh;
  int deletes = 0;
  String? movedToProfile;

  @override
  Future<void> requestSummary(String reportId, {bool refresh = false}) async {
    summaryRequests++;
    lastSummaryRefresh = refresh;
    if (summaryRequests <= failedSummaryRequests) {
      throw Exception('Temporary summary failure');
    }
  }

  @override
  Future<Report> reassignReport(String reportId, String targetProfileId) async {
    movedToProfile = targetProfileId;
    return Report(
      id: reportId,
      profileId: targetProfileId,
      originalFileName: 'long-lab-report.pdf',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026),
    );
  }

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
    collectionDate: collectionDate,
    collectionDateStatus: collectionDateStatus,
    summaryStatus: summaryRequests > failedSummaryRequests
        ? 'ready'
        : summaryStatus,
    summary: summaryRequests > failedSummaryRequests
        ? 'Overview\nThe report includes a glucose result.'
        : summary,
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

class _FamilyProfiles extends Fake implements ProfilesRepository {
  @override
  Future<List<Profile>> getProfiles() async => [
    Profile(
      id: 'profile',
      name: 'Sam',
      createdAt: DateTime(2026),
      isActive: true,
    ),
    Profile(
      id: 'alex',
      name: 'Alex',
      createdAt: DateTime(2026),
      isActive: false,
    ),
  ];
}

void main() {
  testWidgets('missing summary is generated on request and reused on revisit', (
    tester,
  ) async {
    final reports = _Reports(summaryStatus: 'not_requested');
    Future<void> open() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailScreen(
            reportsRepository: reports,
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await open();
    expect(reports.summaryRequests, 0);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('report-detail-summary-retry')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('report-detail-summary-retry')));
    await tester.pumpAndSettle();
    expect(reports.summaryRequests, 1);
    expect(reports.lastSummaryRefresh, isFalse);
    expect(find.text('The report includes a glucose result.'), findsOneWidget);
    expect(find.byKey(const Key('report-detail-summary-retry')), findsNothing);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await open();
    expect(reports.summaryRequests, 1);
  });

  testWidgets('failed summary can be retried', (tester) async {
    final reports = _Reports(summaryStatus: 'failed', failedSummaryRequests: 1);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reports,
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(reports.summaryRequests, 0);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-summary')), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-detail-summary-retry')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('could not create the summary right now'),
      findsOneWidget,
    );
    expect(reports.summaryRequests, 1);
    await tester.tap(find.byKey(const Key('report-detail-summary-retry')));
    await tester.pumpAndSettle();
    expect(reports.summaryRequests, 2);
    expect(find.text('The report includes a glucose result.'), findsOneWidget);
  });

  testWidgets('report summary shows readable sections', (tester) async {
    final reports = _Reports(
      summary:
          'Overview\nThis report includes glucose.\n\nResults to discuss\nGlucose is 110 mg/dL.\n\nWhat to ask your clinician\nCheck the original report.',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reports,
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-lab-values')), findsOneWidget);
    expect(find.byKey(const Key('report-detail-summary')), findsNothing);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-lab-values')), findsNothing);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Results to discuss'), findsOneWidget);
    expect(find.text('Glucose is 110 mg/dL.'), findsOneWidget);
    expect(find.text('What to ask your clinician'), findsOneWidget);
    expect(
      find.byKey(const Key('report-detail-summary-refresh')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('report-detail-summary-retry')), findsNothing);
    expect(reports.summaryRequests, 0);
    await tester.tap(find.byKey(const Key('report-detail-summary-refresh')));
    await tester.pumpAndSettle();
    expect(reports.summaryRequests, 1);
    expect(reports.lastSummaryRefresh, isTrue);
    await tester.tap(find.text('Test values'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-lab-values')), findsOneWidget);
    expect(find.text('Overview'), findsNothing);
  });

  testWidgets('summary tab fits narrow screens with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2),
          ),
          child: ReportDetailScreen(
            reportsRepository: _Reports(
              summary:
                  'Overview\nThis report includes several measurements. Check the extracted results against the original.\n\nResults to discuss\nA result needs clinical context before drawing conclusions.',
            ),
            profilesRepository: _Profiles(),
            reportId: 'report',
            profileId: 'profile',
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-detail-summary')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('report overview is compact and explains a missing sample date', (
    tester,
  ) async {
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

    expect(find.textContaining('Ready to review'), findsOneWidget);
    expect(find.textContaining('Sample date not found'), findsOneWidget);
    expect(find.textContaining('Collected: Unknown'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('report-detail-overview'))).height,
      lessThan(140),
    );
    await tester.tap(find.byKey(const Key('report-detail-sample-date-help')));
    await tester.pumpAndSettle();
    expect(find.text('About sample dates'), findsOneWidget);
    expect(
      find.textContaining('different from the upload date'),
      findsOneWidget,
    );
  });

  testWidgets('report overview uses a known sample date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: _Reports(
            collectionDate: '2026-10-10',
            collectionDateStatus: 'known',
          ),
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sampled 10-Oct-2026'), findsOneWidget);
    expect(
      find.byKey(const Key('report-detail-sample-date-help')),
      findsNothing,
    );
  });

  testWidgets('parsed report offers sharing for the loaded report', (
    tester,
  ) async {
    Report? sharedReport;
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: _Reports(),
          profilesRepository: _Profiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () {},
          onShareReport: (report) => sharedReport = report,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('report-detail-share'));
    expect(tester.getTopLeft(button).dy, lessThan(100));
    await tester.tap(button);
    expect(sharedReport?.id, 'report');
    expect(sharedReport?.profileId, 'profile');
  });

  testWidgets('report move in details explains the destination and confirms', (
    tester,
  ) async {
    final reports = _Reports();
    var backs = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailScreen(
          reportsRepository: reports,
          profilesRepository: _FamilyProfiles(),
          reportId: 'report',
          profileId: 'profile',
          onBack: () => backs++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> chooseDestination() async {
      await tester.tap(find.byKey(const Key('report-detail-more-actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move report'));
      await tester.pumpAndSettle();
      expect(find.textContaining('wrong profile'), findsOneWidget);
      await tester.tap(find.byKey(const Key('reassign-profile-alex')));
      await tester.pumpAndSettle();
    }

    await chooseDestination();
    expect(find.text('Move this report?'), findsOneWidget);
    expect(reports.movedToProfile, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(reports.movedToProfile, isNull);

    await chooseDestination();
    await tester.tap(find.text('Move report'));
    await tester.pump();
    await tester.pump();
    expect(reports.movedToProfile, 'alex');
    expect(backs, 1);
  });

  testWidgets(
    'report actions use the toolbar menu and deletion needs confirmation',
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

      expect(find.byKey(const Key('report-detail-view-pdf')), findsNothing);
      expect(find.text('Results'), findsNothing);
      expect(
        find.byKey(const Key('report-detail-open-trends')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('report-detail-open-original')),
        findsOneWidget,
      );
      expect(find.text('View trends'), findsOneWidget);
      expect(find.text('Original file'), findsOneWidget);

      await tester.tap(find.byKey(const Key('report-detail-more-actions')));
      await tester.pumpAndSettle();
      expect(find.text('Attempt history'), findsOneWidget);
      expect(find.text('Compare reports'), findsOneWidget);
      expect(find.byKey(const Key('report-detail-delete')), findsOneWidget);
      expect(find.text('Reassign to profile'), findsNothing);
      await tester.tapAt(const Offset(20, 300));
      await tester.pumpAndSettle();

      Future<void> openDelete() async {
        await tester.tap(find.byKey(const Key('report-detail-more-actions')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('report-detail-delete')));
        await tester.pumpAndSettle();
      }

      await openDelete();
      expect(find.text('Move to recycle bin?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(reports.deletes, 0);

      await openDelete();
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
