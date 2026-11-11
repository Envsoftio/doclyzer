import 'package:mobile/core/localized_error.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/design_components.dart';
import '../../../shared/app_date_format.dart';

import '../reports_repository.dart';
import '../../profiles/profiles_repository.dart';
import '../../../shared/ai_disclaimer_note.dart';
import 'trend_chart_screen.dart';
import 'report_detail_screen.dart';

enum _HealthHistoryState { loading, loaded, error }

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({
    super.key,
    required this.profileId,
    required this.reportsRepository,
    required this.profilesRepository,
    this.profileName,
    this.onBack,
    this.onShareReport,
  });

  final String profileId;
  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String? profileName;
  final VoidCallback? onBack;
  final ValueChanged<Report>? onShareReport;

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  _HealthHistoryState _state = _HealthHistoryState.loading;
  List<TrendParameter> _params = [];
  String? _errorMessage;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _state = _HealthHistoryState.loading;
      _errorMessage = null;
    });
    try {
      final result = await widget.reportsRepository.getLabTrends(
        widget.profileId,
      );
      final allParams = result.parameters.toList()
        ..sort((a, b) {
          final count = b.dataPoints.length.compareTo(a.dataPoints.length);
          return count != 0
              ? count
              : a.parameterName.compareTo(b.parameterName);
        });
      if (mounted) {
        setState(() {
          _params = allParams;
          _state = _HealthHistoryState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _HealthHistoryState.error;
          _errorMessage = localizedError(
            context,
            e,
            fallback: context.l10n.uiUnableToLoadReportsTryAgain,
          );
        });
      }
    }
  }

  void _openTrendChart(TrendParameter param) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => TrendChartScreen(
          reportsRepository: widget.reportsRepository,
          profileId: widget.profileId,
          parameterName: param.parameterName,
          unit: param.unit ?? '',
          onBack: () => Navigator.of(ctx).pop(),
          onOpenReport: (reportId) => _openSourceReport(reportId),
        ),
      ),
    );
  }

  void _openSourceReport(String reportId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ReportDetailScreen(
          reportsRepository: widget.reportsRepository,
          profilesRepository: widget.profilesRepository,
          reportId: reportId,
          profileId: widget.profileId,
          onBack: () => Navigator.of(ctx).pop(),
          onShareReport: widget.onShareReport,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return AppDateFormat.dateWithRelative(d, hasTime: false);
  }

  @override
  Widget build(BuildContext context) {
    final showDisclaimer =
        _state == _HealthHistoryState.loaded && _params.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.trends),
        leading: widget.onBack == null
            ? null
            : BackButton(onPressed: widget.onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.profileName != null) ...[
              Text(
                context.l10n.uiResultsFor(widget.profileName!),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
            ],
            if (showDisclaimer) ...[
              TextField(
                key: const Key('trends-search'),
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: context.l10n.searchTests,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              _HistoryHeader(parameterCount: _params.length),
              const SizedBox(height: 10),
              const AiDisclaimerNote(key: Key('health-history-disclaimer')),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(_state), child: _buildBody()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _HealthHistoryState.loading) {
      return const Center(
        key: Key('health-history-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_state == _HealthHistoryState.error) {
      return Center(
        key: const Key('health-history-error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? context.l10n.somethingWrong,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: Text(context.l10n.retry)),
          ],
        ),
      );
    }
    if (_params.isEmpty) {
      return Center(
        key: Key('health-history-empty'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(context.l10n.noHealthData, textAlign: TextAlign.center),
        ),
      );
    }
    final visible = _params
        .where(
          (param) => param.parameterName.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();
    if (visible.isEmpty) {
      return DesignEmptyState(
        icon: Icons.search_off_outlined,
        title: context.l10n.noTestsFound,
        message: context.l10n.shorterTestName,
        action: context.l10n.clearSearch,
        onAction: () => setState(() {
          _searchController.clear();
          _query = '';
        }),
      );
    }
    return ListView.separated(
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final param = visible[index];
        final latest = param.dataPoints.isEmpty ? null : param.dataPoints.last;
        final first = param.dataPoints.isEmpty ? null : param.dataPoints.first;
        return Card(
          key: Key(
            'health-history-param-${param.parameterName}-${param.unit ?? 'unknown'}',
          ),
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openTrendChart(param),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          param.parameterName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (latest != null) ...[
                        _InfoBadge(
                          icon: Icons.monitor_heart_outlined,
                          label: context.l10n.uiLatestValue(
                            '${latest.value}${param.unit != null ? ' ${param.unit}' : ''}',
                          ),
                        ),
                        _InfoBadge(
                          icon: Icons.event,
                          label: context.l10n.uiCollectedOn(
                            _formatDate(latest.date),
                          ),
                        ),
                      ] else
                        _InfoBadge(
                          icon: Icons.info_outline,
                          label: context.l10n.uiNoChartableResultYet,
                        ),
                      if (param.unit == null)
                        _InfoBadge(
                          icon: Icons.straighten,
                          label: context.l10n.unitUnavailable,
                        ),
                      if (param.unplottedCount > 0)
                        _InfoBadge(
                          icon: Icons.info_outline,
                          label: '${param.unplottedCount} not plotted',
                        ),
                      if (param.dataPoints.length > 1)
                        _InfoBadge(
                          icon: Icons.timeline,
                          label:
                              '${param.dataPoints.length} points since ${_formatDate(first!.date)}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.parameterCount});

  final int parameterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insights_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.uiLabParametersTracked(parameterCount.toString()),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
