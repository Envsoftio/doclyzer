import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/screens/trend_chart_screen.dart';

class _TrendReports extends Fake implements ReportsRepository {
  _TrendReports(this.points);

  final List<TrendDataPoint> points;

  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async {
    return LabTrendsResult(
      parameters: [
        TrendParameter(parameterName: 'Hb', unit: 'g/dL', dataPoints: points),
      ],
    );
  }
}

void main() {
  testWidgets('dates and small Y values remain readable on a narrow graph', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final points = [
      for (var index = 0; index < 8; index++)
        TrendDataPoint(
          date: DateTime(2026, 1, index + 1),
          value: 0.11 + index * 0.01,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: _TrendReports(points),
          profileId: 'profile',
          parameterName: 'Hb',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('trend-latest-summary')), findsOneWidget);
    expect(find.byKey(const Key('trend-chart-content')), findsOneWidget);
    expect(find.text('08-Jan-2026'), findsWidgets);
    expect(find.byKey(const Key('trend-date-0')), findsOneWidget);
    expect(find.byKey(const Key('trend-date-7')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one point shows a useful summary instead of an empty graph', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: _TrendReports([
            TrendDataPoint(date: DateTime(2026, 10, 17), value: 10),
          ]),
          profileId: 'profile',
          parameterName: 'Hb',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('One saved result. Add another report to see a trend.'),
      findsOneWidget,
    );
    expect(find.text('10 g/dL'), findsWidgets);
    expect(find.byKey(const Key('trend-chart-content')), findsNothing);
  });
}
