import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/trend_chart_screen.dart';
import 'mocks.dart';

void main() {
  late MockReportsRepository reportsRepo;

  setUp(() {
    reportsRepo = MockReportsRepository();
  });

  testWidgets('TrendChartScreen shows loading state initially',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => const LabTrendsResult(parameters: []));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () {},
        ),
      ),
    );

    // Before async completes, loading state should be shown
    expect(find.byKey(const Key('trend-chart-loading')), findsOneWidget);
    expect(find.byKey(const Key('trend-chart-screen')), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('TrendChartScreen shows chart when ≥2 data points',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => LabTrendsResult(
              parameters: [
                TrendParameter(
                  parameterName: 'HbA1c',
                  unit: '%',
                  dataPoints: [
                    TrendDataPoint(
                        date: DateTime(2026, 1, 1), value: 5.8),
                    TrendDataPoint(
                        date: DateTime(2026, 2, 1), value: 6.1),
                  ],
                ),
              ],
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trend-chart-content')), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('2 data points'), findsOneWidget);
  });

  testWidgets('TrendChartScreen shows empty state when 0 data points',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => const LabTrendsResult(parameters: []));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trend-chart-empty')), findsOneWidget);
    expect(find.textContaining('Add more reports to see trend'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('TrendChartScreen shows empty state when 1 data point',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => LabTrendsResult(
              parameters: [
                TrendParameter(
                  parameterName: 'HbA1c',
                  unit: '%',
                  dataPoints: [
                    TrendDataPoint(date: DateTime(2026, 1, 1), value: 5.8),
                  ],
                ),
              ],
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trend-chart-empty')), findsOneWidget);
    expect(find.textContaining('Add more reports to see trend'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('TrendChartScreen shows error message on fetch failure',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trend-chart-error')), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('TrendChartScreen back button triggers onBack',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => const LabTrendsResult(parameters: []));

    var backCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'HbA1c',
          onBack: () => backCalled = true,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trend-chart-back')));
    await tester.pumpAndSettle();

    expect(backCalled, isTrue);
  });

  testWidgets('TrendChartScreen has Semantics widget wrapping chart region',
      (WidgetTester tester) async {
    when(() => reportsRepo.getLabTrends(any(), parameterName: any(named: 'parameterName')))
        .thenAnswer((_) async => LabTrendsResult(
              parameters: [
                TrendParameter(
                  parameterName: 'Glucose',
                  unit: 'mg/dL',
                  dataPoints: [
                    TrendDataPoint(date: DateTime(2026, 1, 1), value: 98),
                    TrendDataPoint(date: DateTime(2026, 2, 1), value: 102),
                  ],
                ),
              ],
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: reportsRepo,
          profileId: 'p1',
          parameterName: 'Glucose',
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Semantics widget wrapping the chart content must be present for a11y
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Glucose trend chart',
      ),
      findsOneWidget,
    );
  });
}
