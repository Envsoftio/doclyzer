import 'package:flutter/material.dart';

import '../reports_repository.dart';
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
      final result = await widget.reportsRepository.getLabTrends(widget.profileId);
      final allParams = result.parameters
          .where((p) => p.dataPoints.isNotEmpty)
          .toList()
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
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              key: const Key('health-history-disclaimer'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Informational only — not medical advice. Discuss with your doctor.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            FilledButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_params.isEmpty) {
      return const Center(
        key: Key('health-history-empty'),
        child: Text(
          'No health data yet. Upload a report to see your health history.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: _params.length,
      itemBuilder: (context, index) {
        final param = _params[index];
        final latest = param.dataPoints.last;
        return ListTile(
          key: Key('health-history-param-${param.parameterName}'),
          title: Text(param.parameterName),
          subtitle: Text('${latest.value}${param.unit != null ? ' ${param.unit}' : ''}  ·  ${_formatDate(latest.date)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openTrendChart(param),
        );
      },
    );
  }
}
