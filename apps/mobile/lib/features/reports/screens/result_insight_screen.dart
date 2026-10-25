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
      RangePosition.below => "Below this lab's reference range",
      RangePosition.within => "Within this lab's reference range",
      RangePosition.above => "Above this lab's reference range",
      RangePosition.unknown => 'Cannot compare with the lab range',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Understand this result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              key: const Key('result-insight-hero'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 17,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'YOUR RESULT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.parameterName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Text(
                        result.value,
                        key: const Key('result-insight-value'),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: palette.foreground,
                          fontSize: 36,
                        ),
                      ),
                      if (result.unit?.trim().isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            result.unit!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.background,
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
                  const SizedBox(height: 16),
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
                  if (position != RangePosition.unknown &&
                      preferredPrintedRange(result.referenceRange ?? '') !=
                          null) ...[
                    Text(
                      'This comparison uses the preferred category printed by the lab. Check that the category applies to you.',
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
                  Divider(color: colors.outlineVariant),
                  const SizedBox(height: 4),
                  _ResultFact(
                    label: 'Lab reference range',
                    value: result.referenceRange?.trim().isNotEmpty == true
                        ? '${result.referenceRange} ${result.unit ?? ''}'.trim()
                        : 'Not available in this result',
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
            Wrap(
              key: const Key('result-insight-actions'),
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('result-insight-trend'),
                  onPressed: widget.onViewTrend,
                  icon: const Icon(Icons.show_chart_outlined),
                  label: const Text('Result history'),
                ),
                if (widget.onViewOriginal != null)
                  OutlinedButton.icon(
                    key: const Key('result-insight-original'),
                    onPressed: widget.onViewOriginal,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Original report'),
                  ),
                if (widget.onReviewResult != null)
                  TextButton.icon(
                    key: const Key('result-insight-review'),
                    onPressed: widget.onReviewResult,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Review value'),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Understand your result', style: theme.textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(
              'Educational context to help you discuss this result.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'AI-GENERATED GUIDANCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    _InsightSection(
                      icon: Icons.manage_search_outlined,
                      title: 'Understanding this result',
                      highlighted: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight.resultExplanation),
                          const SizedBox(height: 16),
                          Text(
                            'What it could mean',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            insight.possibleSignificance,
                            key: const Key('result-insight-meaning'),
                          ),
                        ],
                      ),
                    ),
                    _InsightSection(
                      icon: Icons.biotech_outlined,
                      title: 'What this test measures',
                      child: Text(insight.testExplanation),
                    ),
                    _InsightSection(
                      icon: Icons.forum_outlined,
                      title: 'Suggested next step',
                      child: Text(insight.suggestedFollowup),
                    ),
                    _InsightSection(
                      icon: Icons.rule_outlined,
                      title: 'What this result cannot tell you',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'One result alone cannot diagnose a condition '
                            'or explain symptoms.',
                          ),
                          if (insight.dataUncertainties.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              'Details to check',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 7),
                            ...insight.dataUncertainties.map(_Bullet.new),
                          ],
                        ],
                      ),
                    ),
                    if (insight.lifestyleConsiderations.isNotEmpty)
                      _InsightSection(
                        icon: Icons.restaurant_outlined,
                        title: 'Lifestyle factors to discuss',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: insight.lifestyleConsiderations
                              .map((text) => _Bullet(text))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
            _ContextNote(
              icon: Icons.verified_user_outlined,
              text:
                  'This value was extracted from your report. Check the '
                  'original if the name, value, unit or range looks wrong. '
                  'AI explanations are educational and cannot tell you '
                  'which treatment you need.',
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
    this.highlighted = false,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: highlighted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : null,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 14),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(height: 1.5),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ContextNote extends StatelessWidget {
  const _ContextNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
