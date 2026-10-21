import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../shared/app_date_format.dart';
import '../reports_repository.dart';
import '../result_palette.dart';
import '../result_range.dart';

class ResultInsightScreen extends StatefulWidget {
  const ResultInsightScreen({
    super.key,
    required this.result,
    required this.loadInsight,
    required this.onViewTrend,
    this.onViewOriginal,
    this.onReviewResult,
  });

  final ExtractedLabValue result;
  final Future<ResultInsight> Function() loadInsight;
  final VoidCallback onViewTrend;
  final VoidCallback? onViewOriginal;
  final VoidCallback? onReviewResult;

  @override
  State<ResultInsightScreen> createState() => _ResultInsightScreenState();
}

class _ResultInsightScreenState extends State<ResultInsightScreen> {
  late Future<ResultInsight> _insight;

  @override
  void initState() {
    super.initState();
    _insight = widget.loadInsight();
  }

  void _retry() {
    setState(() {
      _insight = widget.loadInsight();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final result = widget.result;
    final position = compareWithPrintedRange(result);
    final palette = ResultPalette.forPosition(context, position);
    final status = switch (position) {
      RangePosition.below => 'Below the listed lab range',
      RangePosition.within => 'Within the listed lab range',
      RangePosition.above => 'Above the listed lab range',
      RangePosition.unknown => 'Range comparison unavailable',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Understand this result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Container(
              key: const Key('result-insight-hero'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: palette.foreground.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR LAB RESULT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: palette.foreground,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.parameterName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.unit?.trim().isNotEmpty == true
                        ? '${result.value} ${result.unit}'
                        : result.value,
                    key: const Key('result-insight-value'),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.foreground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.foreground.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(palette.icon, size: 19, color: palette.foreground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status,
                            key: const Key('result-insight-range-status'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (position == RangePosition.unknown) ...[
                    Text(
                      unavailableRangeReason(result),
                      key: const Key('result-insight-range-reason'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (result.sourceSnapshot?['rangeSource'] ==
                      'ai_suggestion') ...[
                    Text(
                      'AI read this range as ${result.referenceRange}. Printed text: ${result.sourceSnapshot?['originalReferenceRange']}. Check the original report before relying on this comparison.',
                      key: const Key('result-range-suggestion'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _ResultFact(
                    label: 'Lab range',
                    value: result.referenceRange?.trim().isNotEmpty == true
                        ? '${result.referenceRange} ${result.unit ?? ''}'.trim()
                        : 'Not captured',
                  ),
                  if (result.sampleDate?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    _ResultFact(
                      label: 'Sample date',
                      value: AppDateFormat.fromRawWithRelative(
                        result.sampleDate!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This value was extracted from your report. Check the original if a name, value, unit or range looks wrong.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<ResultInsight>(
              future: _insight,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: CircularProgressIndicator(
                        key: Key('result-insight-loading'),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  final notSaved =
                      snapshot.error is ApiException &&
                      (snapshot.error as ApiException).code ==
                          'REPORT_RESULT_NOT_FOUND';
                  final unreviewed =
                      snapshot.error is ApiException &&
                      (snapshot.error as ApiException).code ==
                          'RESULT_INSIGHT_TEST_UNREVIEWED';
                  final unsafeInput =
                      snapshot.error is ApiException &&
                      (snapshot.error as ApiException).code ==
                          'RESULT_INSIGHT_UNSAFE_INPUT';
                  return _InsightSection(
                    icon: Icons.info_outline,
                    title: 'Explanation unavailable',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notSaved
                              ? 'This value could not be matched to a saved result. Check the original report or refresh this report.'
                              : unreviewed
                              ? 'This test has not been reviewed for AI explanations yet. Check the original report and discuss the result with your clinician.'
                              : unsafeInput
                              ? 'The extracted result is unclear, so it cannot be safely explained. Check the original report.'
                              : 'We could not load an explanation right now.',
                        ),
                        const SizedBox(height: 10),
                        if ((notSaved || unreviewed || unsafeInput) &&
                            widget.onViewOriginal != null)
                          OutlinedButton.icon(
                            onPressed: widget.onViewOriginal,
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Check original report'),
                          )
                        else if (!notSaved && !unreviewed && !unsafeInput)
                          OutlinedButton(
                            key: const Key('result-insight-retry'),
                            onPressed: _retry,
                            child: const Text('Try again'),
                          ),
                      ],
                    ),
                  );
                }
                final insight = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InsightSection(
                      icon: Icons.biotech_outlined,
                      title: 'What this test measures',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-GENERATED EXPLANATION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(insight.testExplanation),
                          const SizedBox(height: 10),
                          Text(
                            insight.possibleSignificance,
                            key: const Key('result-insight-meaning'),
                          ),
                        ],
                      ),
                    ),
                    _InsightSection(
                      icon: Icons.manage_search_outlined,
                      title: 'Your result and the lab range',
                      child: Text(insight.resultExplanation),
                    ),
                    if (insight.lifestyleConsiderations.isNotEmpty)
                      _InsightSection(
                        icon: Icons.restaurant_outlined,
                        title: 'Lifestyle considerations',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: insight.lifestyleConsiderations
                              .map((text) => _Bullet(text))
                              .toList(),
                        ),
                      ),
                    _InsightSection(
                      icon: Icons.forum_outlined,
                      title: 'Suggested next step',
                      child: Text(insight.suggestedFollowup),
                    ),
                    if (insight.dataUncertainties.isNotEmpty)
                      _InsightSection(
                        icon: Icons.rule_outlined,
                        title: 'What to check in the report',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: insight.dataUncertainties
                              .map((text) => _Bullet(text))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
            FilledButton.icon(
              key: const Key('result-insight-trend'),
              onPressed: widget.onViewTrend,
              icon: const Icon(Icons.show_chart),
              label: const Text('See result history'),
            ),
            if (widget.onViewOriginal != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('result-insight-original'),
                onPressed: widget.onViewOriginal,
                icon: const Icon(Icons.description_outlined),
                label: const Text('Check original report'),
              ),
            ],
            if (widget.onReviewResult != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                key: const Key('result-insight-review'),
                onPressed: widget.onReviewResult,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Review or correct result'),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Educational information only. It cannot diagnose a condition or tell you which treatment you need. Discuss unexpected results with a clinician.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 21, color: theme.colorScheme.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(height: 1.45),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultFact extends StatelessWidget {
  const _ResultFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, right: 10),
          child: Icon(Icons.circle, size: 6),
        ),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
