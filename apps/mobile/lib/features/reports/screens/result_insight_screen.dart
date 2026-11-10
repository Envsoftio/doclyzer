import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/api_client.dart';
import '../../../shared/ai_disclaimer_note.dart';
import '../../../shared/language_selector.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/app_date_format.dart';
import '../reports_repository.dart';
import '../result_palette.dart';
import '../result_range.dart';

class ResultInsightScreen extends StatefulWidget {
  const ResultInsightScreen({
    super.key,
    required this.result,
    required this.loadInsight,
    this.loadLocalizedInsight,
    this.cancellation,
    required this.onViewTrend,
    this.onViewOriginal,
    this.onReviewResult,
  });

  final ExtractedLabValue result;
  final Future<ResultInsight> Function() loadInsight;
  final Future<ResultInsight> Function(String locale)? loadLocalizedInsight;
  final InsightRequestCancellation? cancellation;
  final VoidCallback onViewTrend;
  final VoidCallback? onViewOriginal;
  final VoidCallback? onReviewResult;

  @override
  State<ResultInsightScreen> createState() => _ResultInsightScreenState();
}

class _ResultInsightScreenState extends State<ResultInsightScreen> {
  late Future<ResultInsight> _insight;
  String _language = 'en';
  String? _preferred;

  @override
  void dispose() {
    widget.cancellation?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final preferred = supportedLanguage(
      Localizations.localeOf(context).languageCode,
    );
    if (_preferred != preferred) {
      _preferred = preferred;
      _language = widget.loadLocalizedInsight == null ? 'en' : preferred;
      _insight = _load();
    }
  }

  Future<ResultInsight> _load() =>
      widget.loadLocalizedInsight?.call(_language) ?? widget.loadInsight();

  void _retry() {
    setState(() {
      _insight = _load();
    });
  }

  ButtonStyle _compactActionStyle() => OutlinedButton.styleFrom(
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: 12),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final result = widget.result;
    final position = compareWithPrintedRange(result);
    final palette = ResultPalette.forPosition(context, position);
    final status = switch (position) {
      RangePosition.below => context.l10n.belowLabRange,
      RangePosition.within => context.l10n.withinLabRange,
      RangePosition.above => context.l10n.aboveLabRange,
      RangePosition.unknown => context.l10n.cannotCompare,
    };
    final value = Wrap(
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
            fontSize: 34,
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
    );
    final rangeStatus = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(11),
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
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.understandResult)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              key: const Key('result-insight-hero'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.yourResult,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.parameterName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 280) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            value,
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: rangeStatus,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: value),
                          const SizedBox(width: 10),
                          Expanded(child: rangeStatus),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  if (position == RangePosition.unknown) ...[
                    Text(
                      unavailableRangeReason(result),
                      key: const Key('result-insight-range-reason'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (position != RangePosition.unknown &&
                      preferredPrintedRange(result.referenceRange ?? '') !=
                          null) ...[
                    Text(
                      context.l10n.categoryComparisonHelp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
                  ],
                  Divider(color: colors.outlineVariant),
                  _ResultFact(
                    label: context.l10n.labReferenceRange,
                    value: result.referenceRange?.trim().isNotEmpty == true
                        ? '${result.referenceRange} ${result.unit ?? ''}'.trim()
                        : context.l10n.resultUnavailable,
                  ),
                  if (result.sampleDate?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    _ResultFact(
                      label: context.l10n.sampleDate,
                      value: AppDateFormat.fromRawWithRelative(
                        result.sampleDate!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              key: const Key('result-insight-actions'),
              spacing: 8,
              runSpacing: 2,
              children: [
                OutlinedButton.icon(
                  key: const Key('result-insight-trend'),
                  onPressed: widget.onViewTrend,
                  style: _compactActionStyle(),
                  icon: const Icon(Icons.show_chart_outlined),
                  label: Text(context.l10n.resultHistory),
                ),
                if (widget.onViewOriginal != null)
                  OutlinedButton.icon(
                    key: const Key('result-insight-original'),
                    onPressed: widget.onViewOriginal,
                    style: _compactActionStyle(),
                    icon: const Icon(Icons.description_outlined),
                    label: Text(context.l10n.originalReport),
                  ),
                if (widget.onReviewResult != null)
                  TextButton.icon(
                    key: const Key('result-insight-review'),
                    onPressed: widget.onReviewResult,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(context.l10n.reviewValue),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.understandYourResult,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              context.l10n.educationalContext,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            const AiDisclaimerNote(key: Key('result-insight-disclaimer')),
            if (widget.loadLocalizedInsight != null) ...[
              const SizedBox(height: 12),
              LanguageSelector(
                value: _language,
                description: true,
                onChanged: (value) {
                  setState(() {
                    _language = value;
                    _insight = _load();
                  });
                },
              ),
              if (_language != 'en')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.translationNote,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            const SizedBox(height: 14),
            FutureBuilder<ResultInsight>(
              key: ValueKey(_language),
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
                    title: context.l10n.explanationUnavailable,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notSaved
                              ? context.l10n.missingSavedResult
                              : unreviewed
                              ? context.l10n.unreviewedTest
                              : unsafeInput
                              ? context.l10n.unsafeResult
                              : _language != 'en'
                              ? context.l10n.translationFailed
                              : context.l10n.explanationFailed,
                        ),
                        const SizedBox(height: 10),
                        if ((notSaved || unreviewed || unsafeInput) &&
                            widget.onViewOriginal != null)
                          OutlinedButton.icon(
                            onPressed: widget.onViewOriginal,
                            icon: const Icon(Icons.description_outlined),
                            label: Text(context.l10n.checkOriginal),
                          )
                        else if (!notSaved && !unreviewed && !unsafeInput)
                          OutlinedButton(
                            key: const Key('result-insight-retry'),
                            onPressed: _retry,
                            child: Text(context.l10n.tryAgain),
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
                        context.l10n.aiGuidance,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    _InsightSection(
                      icon: Icons.manage_search_outlined,
                      title: context.l10n.understandingResult,
                      highlighted: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight.resultExplanation),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.possibleMeaning,
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
                      title: context.l10n.whatTestMeasures,
                      child: Text(insight.testExplanation),
                    ),
                    _InsightSection(
                      icon: Icons.forum_outlined,
                      title: context.l10n.suggestedNextStep,
                      child: Text(insight.suggestedFollowup),
                    ),
                    _InsightSection(
                      icon: Icons.rule_outlined,
                      title: context.l10n.resultLimitations,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.oneResultLimit),
                          if (insight.dataUncertainties.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.detailsToCheck,
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
                        title: context.l10n.lifestyleFactors,
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
              text: context.l10n.insightContext,
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
    final readingStyle = TextStyle(
      inherit: false,
      fontSize: 16,
      fontFamilyFallback: AppTheme.scriptFonts,
      textBaseline: TextBaseline.alphabetic,
      height: 1.5,
      color: theme.colorScheme.onSurface,
    );
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
              DefaultTextStyle(style: readingStyle, child: child),
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
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
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
