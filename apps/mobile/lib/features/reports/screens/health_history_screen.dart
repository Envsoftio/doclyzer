import 'package:flutter/material.dart';

import '../reports_repository.dart';
import '../../../shared/ai_disclaimer_note.dart';
import 'trend_chart_screen.dart';

enum _HealthHistoryState { loading, loaded, error }

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({
    super.key,
    required this.profileId,
    required this.reportsRepository,
  });

  final String profileId;
  final ReportsRepository reportsRepository;

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  _HealthHistoryState _state = _HealthHistoryState.loading;
  List<TrendParameter> _params = [];
  String? _errorMessage;

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
      final allParams =
          result.parameters.where((p) => p.dataPoints.isNotEmpty).toList()
            ..sort((a, b) => a.parameterName.compareTo(b.parameterName));
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
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final showDisclaimer =
        _state == _HealthHistoryState.loaded && _params.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Health History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDisclaimer) ...[
              _HistoryHeader(parameterCount: _params.length),
              const SizedBox(height: 10),
              const AiDisclaimerNote(key: Key('health-history-disclaimer')),
              const SizedBox(height: 10),
            ],
            Expanded(child: _buildBody()),
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
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: const Text('Retry')),
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
          child: const Text(
            'No health data yet. Upload a report to see your health history.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: _params.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final param = _params[index];
        final latest = param.dataPoints.last;
        final first = param.dataPoints.first;
        return Card(
          key: Key('health-history-param-${param.parameterName}'),
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
                      _InfoBadge(
                        icon: Icons.monitor_heart_outlined,
                        label:
                            'Latest: ${latest.value}${param.unit != null ? ' ${param.unit}' : ''}',
                      ),
                      _InfoBadge(
                        icon: Icons.event,
                        label: 'Updated: ${_formatDate(latest.date)}',
                      ),
                      if (param.dataPoints.length > 1)
                        _InfoBadge(
                          icon: Icons.timeline,
                          label:
                              '${param.dataPoints.length} points since ${_formatDate(first.date)}',
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
              '$parameterCount lab parameters tracked',
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
