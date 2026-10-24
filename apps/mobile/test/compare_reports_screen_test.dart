import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/compare_reports_screen.dart';

class _Reports extends Fake implements ReportsRepository {
  @override
  Future<List<Report>> listReports(String profileId) async => [
    Report(
      id: 'older',
      profileId: profileId,
      originalFileName: 'January panel',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 1, 10),
      collectionDate: '2026-01-10',
    ),
    Report(
      id: 'newer',
      profileId: profileId,
      originalFileName: 'October panel',
      contentType: 'application/pdf',
      sizeBytes: 100,
      status: 'parsed',
      createdAt: DateTime(2026, 10, 12),
      collectionDate: '2026-10-12',
    ),
  ];

  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async => LabTrendsResult(
    parameters: [
      TrendParameter(
        parameterName: 'HbA1c',
        unit: '%',
        dataPoints: [
          TrendDataPoint(
            date: DateTime(2026, 1, 10),
            value: 6.1,
            reportId: 'older',
            originalValue: '6.1',
          ),
          TrendDataPoint(
            date: DateTime(2026, 10, 12),
            value: 5.8,
            reportId: 'newer',
            originalValue: '5.8',
          ),
        ],
      ),
      const TrendParameter(
        parameterName: 'Vitamin D',
        unit: 'ng/mL',
        dataPoints: [],
        observations: [
          TrendObservation(
            reportId: 'older',
            originalValue: '18',
            originalUnit: 'ng/mL',
          ),
        ],
      ),
      const TrendParameter(
        parameterName: 'Vitamin D',
        unit: 'nmol/L',
        dataPoints: [],
        observations: [
          TrendObservation(
            reportId: 'newer',
            originalValue: '62.4',
            originalUnit: 'nmol/L',
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('only compatible report results get a numeric difference', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CompareReportsScreen(
          profileId: 'profile-1',
          profileName: 'Priya',
          reportsRepository: _Reports(),
        ),
      ),
    );
    await tester.pump();
    final compare = find.widgetWithText(FilledButton, 'Compare reports');
    await tester.ensureVisible(compare);
    await tester.tap(compare);
    await tester.pumpAndSettle();
    expect(find.text('Decreased by 0.3 percentage points'), findsOneWidget);
    expect(
      find.text('No difference calculated. Compatibility needs confirmation.'),
      findsOneWidget,
    );
  });
}
