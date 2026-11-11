import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../../../shared/app_date_format.dart';
import '../reports_repository.dart';

class CompareReportsScreen extends StatefulWidget {
  const CompareReportsScreen({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.reportsRepository,
  });

  final String profileId;
  final String profileName;
  final ReportsRepository reportsRepository;

  @override
  State<CompareReportsScreen> createState() => _CompareReportsScreenState();
}

class _CompareReportsScreenState extends State<CompareReportsScreen> {
  List<Report>? _reports;
  LabTrendsResult? _trends;
  String? _earlierId;
  String? _laterId;
  String? _error;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _reports = null;
      _trends = null;
    });
    try {
      final results = await Future.wait<Object>([
        widget.reportsRepository.listReports(widget.profileId),
        widget.reportsRepository.getLabTrends(widget.profileId),
      ]);
      if (!mounted) return;
      final reports =
          (results[0] as List<Report>)
              .where((report) => report.status == 'parsed')
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      setState(() {
        _reports = reports;
        _trends = results[1] as LabTrendsResult;
        if (reports.length >= 2) {
          _earlierId = reports.first.id;
          _laterId = reports.last.id;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.uiUnableToLoadReportsTryAgain);
      }
    }
  }

  Report? _report(String? id) {
    for (final report in _reports ?? const <Report>[]) {
      if (report.id == id) return report;
    }
    return null;
  }

  String _reportLabel(Report report) {
    final collectionDate = DateTime.tryParse(report.collectionDate ?? '');
    final date = AppDateFormat.dateWithRelative(
      collectionDate ?? report.createdAt,
      hasTime: false,
    );
    return context.l10n.uiReportComparisonLabel(
      report.originalFileName,
      collectionDate == null ? context.l10n.uiUploadedPrefix(date) : date,
    );
  }

  bool get _selectedOrderValid {
    final earlier = _report(_earlierId);
    final later = _report(_laterId);
    if (earlier == null || later == null) return false;
    final earlierDate =
        DateTime.tryParse(earlier.collectionDate ?? '') ?? earlier.createdAt;
    final laterDate =
        DateTime.tryParse(later.collectionDate ?? '') ?? later.createdAt;
    return !earlierDate.isAfter(laterDate);
  }

  List<_Comparison> _comparisons() {
    final earlierId = _earlierId;
    final laterId = _laterId;
    if (earlierId == null || laterId == null) return [];
    final groups = <String, List<TrendParameter>>{};
    for (final parameter in _trends?.parameters ?? const <TrendParameter>[]) {
      groups
          .putIfAbsent(parameter.parameterName.trim().toLowerCase(), () => [])
          .add(parameter);
    }
    final comparisons = <_Comparison>[];
    for (final group in groups.values) {
      for (final parameter in group) {
        final before = parameter.dataPoints
            .where((point) => point.reportId == earlierId)
            .firstOrNull;
        final after = parameter.dataPoints
            .where((point) => point.reportId == laterId)
            .firstOrNull;
        if (before != null && after != null) {
          comparisons.add(
            _Comparison(
              name: parameter.parameterName,
              earlier: before.originalValue ?? before.value.toString(),
              later: after.originalValue ?? after.value.toString(),
              earlierUnit: before.originalUnit ?? parameter.unit,
              laterUnit: after.originalUnit ?? parameter.unit,
              normalizedUnit: parameter.unit,
              change: after.value - before.value,
            ),
          );
          break;
        }
      }
      if (comparisons.any(
        (row) =>
            row.name.toLowerCase() == group.first.parameterName.toLowerCase(),
      )) {
        continue;
      }
      _ObservationDisplay? before;
      _ObservationDisplay? after;
      for (final parameter in group) {
        for (final observation in parameter.observations) {
          if (observation.reportId == earlierId) {
            before ??= _ObservationDisplay(
              observation.originalValue,
              observation.originalUnit ?? parameter.unit,
            );
          }
          if (observation.reportId == laterId) {
            after ??= _ObservationDisplay(
              observation.originalValue,
              observation.originalUnit ?? parameter.unit,
            );
          }
        }
        for (final point in parameter.dataPoints) {
          if (point.reportId == earlierId) {
            before ??= _ObservationDisplay(
              point.originalValue ?? point.value.toString(),
              point.originalUnit ?? parameter.unit,
            );
          }
          if (point.reportId == laterId) {
            after ??= _ObservationDisplay(
              point.originalValue ?? point.value.toString(),
              point.originalUnit ?? parameter.unit,
            );
          }
        }
      }
      if (before != null && after != null) {
        comparisons.add(
          _Comparison(
            name: group.first.parameterName,
            earlier: before.value,
            later: after.value,
            earlierUnit: before.unit,
            laterUnit: after.unit,
          ),
        );
      }
    }
    comparisons.sort((a, b) => a.name.compareTo(b.name));
    return comparisons;
  }

  @override
  Widget build(BuildContext context) {
    final reports = _reports;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showResults
              ? context.l10n.uiCompareResults
              : context.l10n.compareReports,
        ),
      ),
      body: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        child: reports == null && _error == null
            ? const Center(
                key: Key('compare-loading'),
                child: CircularProgressIndicator(),
              )
            : _error != null
            ? DesignEmptyState(
                key: const Key('compare-error'),
                icon: Icons.wifi_off_outlined,
                title: context.l10n.uiReportsUnavailable,
                message: _error!,
                action: context.l10n.uiTryAgain042c86,
                onAction: _load,
              )
            : reports!.length < 2
            ? DesignEmptyState(
                key: Key('compare-empty'),
                icon: Icons.compare_arrows_rounded,
                title: context.l10n.uiTwoReportsAreNeeded,
                message: context.l10n.uiAddAnOlderReportForThisProfile,
              )
            : _showResults
            ? _buildResults(theme)
            : _buildSelection(theme, reports),
      ),
    );
  }

  Widget _buildSelection(
    ThemeData theme,
    List<Report> reports,
  ) => SingleChildScrollView(
    key: const Key('compare-selection'),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.profileName, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        Text(
          context.l10n.uiChooseTwoReports,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.uiUseRecordsForTheSamePersonMatching),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          key: const Key('compare-earlier'),
          isExpanded: true,
          initialValue: _earlierId,
          decoration: InputDecoration(labelText: context.l10n.uiEarlierReport),
          items: [
            for (final report in reports)
              DropdownMenuItem(
                value: report.id,
                child: Text(
                  _reportLabel(report),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _earlierId = value),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: const Key('compare-later'),
          isExpanded: true,
          initialValue: _laterId,
          decoration: InputDecoration(labelText: context.l10n.uiLaterReport),
          items: [
            for (final report in reports)
              DropdownMenuItem(
                value: report.id,
                child: Text(
                  _reportLabel(report),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _laterId = value),
        ),
        const SizedBox(height: 16),
        if (_earlierId != _laterId && !_selectedOrderValid) ...[
          Text(
            context.l10n.uiChooseTheOlderReportFirstAndThe,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.uiComparedOnlyWhenCompatibleDifferentUnitsOr,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed:
              _earlierId == null ||
                  _laterId == null ||
                  _earlierId == _laterId ||
                  !_selectedOrderValid
              ? null
              : () => setState(() => _showResults = true),
          child: Text(context.l10n.compareReports),
        ),
      ],
    ),
  );

  Widget _buildResults(ThemeData theme) {
    final before = _report(_earlierId);
    final after = _report(_laterId);
    final rows = _comparisons();
    return SingleChildScrollView(
      key: const Key('compare-results'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.profileName, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          if (before != null && after != null)
            Text(
              '${_reportLabel(before)}\n→ ${_reportLabel(after)}',
              style: theme.textTheme.titleLarge,
            ),
          const SizedBox(height: 20),
          if (rows.isEmpty)
            DesignEmptyState(
              icon: Icons.rule_outlined,
              title: context.l10n.uiCannotCompareYet,
              message:
                  context.l10n.uiTheseReportsHaveNoMatchingResultsAvailable,
            )
          else
            for (final row in rows) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _valueColumn(
                              context.l10n.uiEarlier,
                              row.earlier,
                              row.earlierUnit,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _valueColumn(
                              context.l10n.uiLater,
                              row.later,
                              row.laterUnit,
                              theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        row.change == null
                            ? context
                                  .l10n
                                  .uiNoDifferenceCalculatedCompatibilityNeedsConfirmation
                            : _changeText(row.change!, row.normalizedUnit),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.tealText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 12),
          Text(context.l10n.uiAChangeIsNotADiagnosisCompare),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() => _showResults = false),
            child: Text(context.l10n.uiChooseDifferentReports),
          ),
        ],
      ),
    );
  }

  Widget _valueColumn(
    String label,
    String value,
    String? unit,
    ThemeData theme,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: theme.textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: theme.textTheme.headlineSmall),
      Text(
        unit ?? context.l10n.uiUnitNotRecorded,
        style: theme.textTheme.bodySmall,
      ),
    ],
  );

  String _changeText(double change, String? unit) {
    if (change == 0) return context.l10n.uiNoNumericChangeBetweenTheseReports;
    final amount = change
        .abs()
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    final unitText = unit == '%'
        ? context.l10n.uiPercentagePoints
        : unit == null || unit.isEmpty
        ? ''
        : ' $unit';
    return change > 0
        ? context.l10n.uiIncreasedBy('$amount$unitText')
        : context.l10n.uiDecreasedBy('$amount$unitText');
  }
}

class _ObservationDisplay {
  const _ObservationDisplay(this.value, this.unit);
  final String value;
  final String? unit;
}

class _Comparison {
  const _Comparison({
    required this.name,
    required this.earlier,
    required this.later,
    this.earlierUnit,
    this.laterUnit,
    this.normalizedUnit,
    this.change,
  });
  final String name;
  final String earlier;
  final String later;
  final String? earlierUnit;
  final String? laterUnit;
  final String? normalizedUnit;
  final double? change;
}
