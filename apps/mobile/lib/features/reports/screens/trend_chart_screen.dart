import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../reports_repository.dart';

enum _TrendState { loading, loaded, error }

class TrendChartScreen extends StatefulWidget {
  const TrendChartScreen({
    super.key,
    required this.reportsRepository,
    required this.profileId,
    required this.parameterName,
    required this.onBack,
  });

  final ReportsRepository reportsRepository;
  final String profileId;
  final String parameterName;
  final VoidCallback onBack;

  @override
  State<TrendChartScreen> createState() => _TrendChartScreenState();
}

class _TrendChartScreenState extends State<TrendChartScreen> {
  _TrendState _state = _TrendState.loading;
  TrendParameter? _parameter;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  Future<void> _loadTrend() async {
    setState(() {
      _state = _TrendState.loading;
      _errorMessage = null;
    });
    try {
      final result = await widget.reportsRepository.getLabTrends(
        widget.profileId,
        parameterName: widget.parameterName,
      );
      final param = result.parameters
          .where((p) => p.parameterName == widget.parameterName)
          .firstOrNull;
      if (mounted) {
        setState(() {
          _parameter = param;
          _state = _TrendState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _TrendState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('trend-chart-screen'),
      appBar: AppBar(
        title: Text(widget.parameterName),
        leading: IconButton(
          key: const Key('trend-chart-back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _TrendState.loading) {
      return const Center(
        key: Key('trend-chart-loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_state == _TrendState.error) {
      return Center(
        key: const Key('trend-chart-error'),
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
              onPressed: _loadTrend,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final param = _parameter;
    if (param == null || param.dataPoints.length < 2) {
      return Center(
        key: const Key('trend-chart-empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'No trend data available',
              child: const Icon(Icons.show_chart, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              param != null && param.dataPoints.length == 1
                  ? '${param.dataPoints[0].value}${param.unit != null ? ' ${param.unit}' : ''}\n\nAdd more reports to see trend'
                  : 'Add more reports to see trend',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return _buildChart(param);
  }

  Widget _buildChart(TrendParameter param) {
    final spots = param.dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = param.dataPoints.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final maxY = param.dataPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final rawPadding = (maxY - minY) * 0.1;
    final padding = rawPadding == 0 ? (minY.abs() * 0.1).clamp(0.5, double.maxFinite) : rawPadding;
    final chartMinY = minY - padding;
    final chartMaxY = maxY + padding;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: '${widget.parameterName} trend chart',
            child: SizedBox(
              key: const Key('trend-chart-content'),
              height: 280,
              child: LineChart(
                LineChartData(
                  minY: chartMinY.isFinite ? chartMinY : minY - 1,
                  maxY: chartMaxY.isFinite ? chartMaxY : maxY + 1,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        param.unit ?? 'Value',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      sideTitles: const SideTitles(showTitles: true, reservedSize: 44),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Date'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          if (idx < 0 || idx >= param.dataPoints.length) {
                            return const SizedBox.shrink();
                          }
                          final date = param.dataPoints[idx].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.round();
                          if (idx < 0 || idx >= param.dataPoints.length) return null;
                          final dp = param.dataPoints[idx];
                          final dateStr =
                              '${dp.date.year}-${dp.date.month.toString().padLeft(2, '0')}-${dp.date.day.toString().padLeft(2, '0')}';
                          final valStr = param.unit != null
                              ? '${dp.value} ${param.unit}'
                              : '${dp.value}';
                          return LineTooltipItem(
                            '$dateStr\n$valStr',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${param.dataPoints.length} data points',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
