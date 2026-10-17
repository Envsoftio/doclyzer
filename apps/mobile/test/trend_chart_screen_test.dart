import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
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

class _MixedUnitTrends extends Fake implements ReportsRepository {
  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async => LabTrendsResult(
    parameters: [
      TrendParameter(
        parameterName: 'Hemoglobin',
        unit: 'g/dL',
        dataPoints: [TrendDataPoint(date: DateTime(2026, 1, 1), value: 12)],
      ),
      TrendParameter(
        parameterName: 'Hemoglobin',
        unit: 'g/L',
        dataPoints: [TrendDataPoint(date: DateTime(2026, 1, 1), value: 120)],
      ),
    ],
  );
}

void main() {
  testWidgets('unplottable result remains visible without a chart', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: _ObservationTrends(const []),
          profileId: 'profile',
          parameterName: 'Hb',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Collection date unknown'), findsOneWidget);
    expect(find.text('<5 g/dL'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets(
    'history includes all results, ranges, unknown dates, and source links',
    (tester) async {
      String? openedReport;
      final points = [
        for (var index = 0; index < 6; index++)
          TrendDataPoint(
            date: DateTime(2026, 1, index + 1),
            value: 10 + index.toDouble(),
            reportId: 'r$index',
            referenceRange: index == 0 ? '12-16' : '11-15',
          ),
      ];
      final reports = _ObservationTrends(points);
      await tester.pumpWidget(
        MaterialApp(
          home: TrendChartScreen(
            reportsRepository: reports,
            profileId: 'profile',
            parameterName: 'Hb',
            onBack: () {},
            onOpenReport: (id) => openedReport = id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('trend-observation-6'), skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Collection date unknown', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Lab reference range: 12-16', skipOffstage: false),
        findsWidgets,
      );
      expect(
        find.text('Lab reference range: Unknown', skipOffstage: false),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const Key('trend-source-report-6')),
      );
      await tester.tap(find.byKey(const Key('trend-source-report-6')));
      expect(openedReport, 'unknown-date-report');
    },
  );

  testWidgets('opening a result selects its unit series', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: _MixedUnitTrends(),
          profileId: 'profile',
          parameterName: 'Hb',
          unit: 'g/L',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('120 g/L'), findsWidgets);
    expect(find.text('12 g/dL'), findsNothing);
  });

  testWidgets('chart positions follow collection dates, not list indexes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrendChartScreen(
          reportsRepository: _TrendReports([
            TrendDataPoint(date: DateTime(2026, 1, 1), value: 10),
            TrendDataPoint(date: DateTime(2026, 1, 2), value: 11),
            TrendDataPoint(date: DateTime(2026, 2, 1), value: 12),
          ]),
          profileId: 'profile',
          parameterName: 'Hb',
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final spots = tester
        .widget<LineChart>(find.byType(LineChart))
        .data
        .lineBarsData
        .single
        .spots;
    expect(spots[1].x - spots[0].x, 1);
    expect(spots[2].x - spots[1].x, 30);
  });

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

class _ObservationTrends extends Fake implements ReportsRepository {
  _ObservationTrends(this.points);
  final List<TrendDataPoint> points;

  @override
  Future<LabTrendsResult> getLabTrends(
    String profileId, {
    String? parameterName,
  }) async => LabTrendsResult(
    parameters: [
      TrendParameter(
        parameterName: 'Hb',
        unit: 'g/dL',
        dataPoints: points,
        unplottedCount: 1,
        observations: [
          for (var index = 0; index < points.length; index++)
            TrendObservation(
              reportId: 'r$index',
              originalValue: '${10 + index}',
              date: points[index].date,
              value: points[index].value,
              referenceRange: points[index].referenceRange,
            ),
          const TrendObservation(
            reportId: 'unknown-date-report',
            originalValue: '<5',
            notPlottedReason: 'collection_date_unknown',
          ),
        ],
      ),
    ],
  );
}
