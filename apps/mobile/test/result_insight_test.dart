import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/features/reports/reports_repository.dart';
import 'package:mobile/features/reports/result_range.dart';
import 'package:mobile/features/reports/screens/result_insight_screen.dart';
import 'package:mobile/shared/app_date_format.dart';

void main() {
  const hemoglobin = ExtractedLabValue(
    parameterName: 'Hb',
    value: '10',
    unit: 'g/dL',
    referenceRange: '12–16',
  );
  const insight = ResultInsight(
    testExplanation: 'A protein in red blood cells.',
    resultExplanation: 'Below the printed lab range.',
    possibleSignificance:
        'Hemoglobin carries oxygen through the body. A value below the printed lab range can be associated with several different situations, but this number alone cannot show which one applies. Clinicians may look at symptoms, earlier results, and other blood measurements before deciding what it means. The printed range can also depend on the laboratory and the person tested. Review the value and the rest of the report together rather than treating this one number as a diagnosis.',
    lifestyleConsiderations: ['Ask about nutrition after finding the cause.'],
    suggestedFollowup: 'Discuss this value with a clinician.',
    dataUncertainties: ['A single result cannot identify the cause.'],
  );

  test('plain values use only the printed range', () {
    expect(compareWithPrintedRange(hemoglobin), RangePosition.below);
    expect(
      compareWithPrintedRange(
        const ExtractedLabValue(
          parameterName: 'Hb',
          value: '<10',
          referenceRange: '12–16',
        ),
      ),
      RangePosition.unknown,
    );
    expect(
      compareWithPrintedRange(
        const ExtractedLabValue(
          parameterName: 'Hb',
          value: '14',
          unit: 'g/dL',
          referenceRange: '12–16',
          isAbnormal: true,
        ),
      ),
      RangePosition.unknown,
    );
  });

  test('display dates use DD-MMM-YYYY without shifting date-only values', () {
    expect(AppDateFormat.fromRaw('2026-10-17'), '17-Oct-2026');
    expect(AppDateFormat.date(DateTime(2026, 1, 2)), '02-Jan-2026');
    expect(AppDateFormat.fromRaw('unclear date'), 'unclear date');
  });

  test('relative dates keep the exact date and respect date-only samples', () {
    final now = DateTime(2026, 10, 17, 12);
    expect(
      AppDateFormat.dateWithRelative(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      ),
      '5 min ago · 17-Oct-2026',
    );
    expect(
      AppDateFormat.dateWithRelative(
        now.subtract(const Duration(days: 8)),
        now: now,
      ),
      '1 week ago · 09-Oct-2026',
    );
    expect(
      AppDateFormat.fromRawWithRelative('2026-10-17', now: now),
      'Today · 17-Oct-2026',
    );
    expect(
      AppDateFormat.fromRawWithRelative('2026-10-18', now: now),
      'In 1 day · 18-Oct-2026',
    );
    expect(
      AppDateFormat.fromRawWithRelative('unreadable', now: now),
      'unreadable',
    );
  });

  testWidgets('range status colors the displayed value', (tester) async {
    Future<Color?> valueColor(ExtractedLabValue result) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResultInsightScreen(
            result: result,
            loadInsight: () async => insight,
            onViewTrend: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
          .widget<Text>(find.byKey(const Key('result-insight-value')))
          .style
          ?.color;
    }

    final below = await valueColor(hemoglobin);
    final within = await valueColor(
      const ExtractedLabValue(
        parameterName: 'Hb',
        value: '14',
        unit: 'g/dL',
        referenceRange: '12–16',
      ),
    );
    final unknown = await valueColor(
      const ExtractedLabValue(
        parameterName: 'Hb',
        value: '14',
        referenceRange: 'see report',
      ),
    );
    expect(below, isNot(within));
    expect(unknown, isNot(within));
    expect(unknown, isNot(below));
  });

  testWidgets('generated content appears on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: ResultInsightScreen(
          result: hemoglobin,
          loadInsight: () async => insight,
          onViewTrend: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Below the listed lab range'), findsOneWidget);
    expect(find.text('What this result may mean'), findsNothing);
    expect(find.text('What this test measures'), findsOneWidget);
    final measuresCard = find.ancestor(
      of: find.text('What this test measures'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(
        of: measuresCard,
        matching: find.byKey(const Key('result-insight-meaning')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: measuresCard,
        matching: find.text('AI-GENERATED EXPLANATION'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Lifestyle considerations'), 250);
    expect(find.text('Lifestyle considerations'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed generation offers retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultInsightScreen(
          result: hemoglobin,
          loadInsight: () async {
            calls++;
            if (calls == 1) throw Exception('unavailable');
            return insight;
          },
          onViewTrend: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Explanation unavailable'), findsOneWidget);
    await tester.tap(find.byKey(const Key('result-insight-retry')));
    await tester.pumpAndSettle();
    expect(find.text('What this test measures'), findsOneWidget);
  });

  testWidgets('a missing saved result offers the original report', (
    tester,
  ) async {
    var openedOriginal = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultInsightScreen(
          result: const ExtractedLabValue(
            parameterName: 'Hb',
            value: '10',
            unit: 'g/dL',
          ),
          loadInsight: () async =>
              throw ApiException('REPORT_RESULT_NOT_FOUND', 'Result not found'),
          onViewTrend: () {},
          onViewOriginal: () => openedOriginal = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('could not be matched to a saved result'),
      findsOneWidget,
    );
    await tester.tap(find.text('Check original report').first);
    expect(openedOriginal, isTrue);
  });
}
