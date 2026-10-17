import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

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
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
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
            FilledButton(onPressed: _loadTrend, child: const Text('Retry')),
          ],
        ),
      );
    }

    final param = _parameter;
    if (param == null || param.dataPoints.isEmpty) {
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
              'No numeric saved results are available for this test yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final points =
        param.dataPoints.where((point) => point.value.isFinite).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (points.isEmpty) {
      return const Center(
        child: Text('No numeric results are available to plot.'),
      );
    }
    return _buildChart(param, points);
  }

  Widget _buildChart(TrendParameter param, List<TrendDataPoint> points) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final latest = points.last;
    final unit = param.unit?.trim().isNotEmpty == true
        ? param.unit!.trim()
        : null;
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();
    final scale = _ChartScale.fromPoints(points);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('trend-latest-summary'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest result',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatNumber(latest.value)}${unit == null ? '' : ' $unit'}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateFormat.dateWithRelative(latest.date, hasTime: false),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                if (points.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Previous: ${_formatNumber(points[points.length - 2].value)}${unit == null ? '' : ' $unit'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Result history', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            points.length == 1
                ? 'One saved result. Add another report to see a trend.'
                : '${points.length} saved results · Swipe the graph to see more dates. Tap a point for its value.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (points.length > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = math.max(
                    constraints.maxWidth,
                    points.length * 100.0,
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      key: const Key('trend-chart-content'),
                      width: chartWidth,
                      height: 300,
                      child: Semantics(
                        label:
                            '${widget.parameterName} trend chart with ${points.length} results',
                        child: LineChart(
                          LineChartData(
                            minX: -0.18,
                            maxX: points.length - 0.82,
                            minY: scale.min,
                            maxY: scale.max,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: scale.interval,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.7,
                                ),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: scale.interval,
                                  reservedSize: scale.labelWidth,
                                  getTitlesWidget: (value, meta) =>
                                      SideTitleWidget(
                                        meta: meta,
                                        space: 5,
                                        child: Text(
                                          scale.label(value),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.round();
                                    if ((value - index).abs() > 0.001 ||
                                        index < 0 ||
                                        index >= points.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 7,
                                      fitInside:
                                          SideTitleFitInsideData.fromTitleMeta(
                                            meta,
                                            distanceFromEdge: 2,
                                          ),
                                      child: Text(
                                        AppDateFormat.date(points[index].date),
                                        key: Key('trend-date-$index'),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
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
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(color: colors.outlineVariant),
                                bottom: BorderSide(
                                  color: colors.outlineVariant,
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: false,
                                color: colors.primary,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      colors.primary.withValues(alpha: 0.18),
                                      colors.primary.withValues(alpha: 0.01),
                                    ],
                                  ),
                                ),
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, _, _, _) =>
                                      FlDotCirclePainter(
                                        radius: 4,
                                        color: colors.primary,
                                        strokeWidth: 2,
                                        strokeColor: colors.surface,
                                      ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                getTooltipItems: (touchedSpots) =>
                                    touchedSpots.map((spot) {
                                      final point = points[spot.x.round()];
                                      return LineTooltipItem(
                                        '${AppDateFormat.date(point.date)}\n${_formatNumber(point.value)}${unit == null ? '' : ' $unit'}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Recent readings', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final point in points.reversed.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppDateFormat.dateWithRelative(
                          point.date,
                          hasTime: false,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${_formatNumber(point.value)}${unit == null ? '' : ' $unit'}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value
      .toStringAsFixed(8)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

class _ChartScale {
  const _ChartScale(this.min, this.max, this.interval);

  final double min;
  final double max;
  final double interval;

  factory _ChartScale.fromPoints(List<TrendDataPoint> points) {
    final minValue = points.map((point) => point.value).reduce(math.min);
    final maxValue = points.map((point) => point.value).reduce(math.max);
    final spread = maxValue - minValue;
    final padding = spread == 0
        ? math.max(minValue.abs() * 0.15, 0.01)
        : spread * 0.15;
    final interval = _niceInterval((spread + padding * 2) / 4);
    var min = ((minValue - padding) / interval).floorToDouble() * interval;
    final max = ((maxValue + padding) / interval).ceilToDouble() * interval;
    if (minValue >= 0 && min < 0) min = 0;
    return _ChartScale(min, max > min ? max : min + interval, interval);
  }

  static double _niceInterval(double raw) {
    final exponent = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    final fraction = raw / exponent;
    final nice = fraction <= 1
        ? 1
        : fraction <= 2
        ? 2
        : fraction <= 5
        ? 5
        : 10;
    return nice * exponent;
  }

  String label(double value) =>
      _formatNumber(double.parse(value.toStringAsFixed(8)));

  double get labelWidth => math.max(
    48,
    math.min(82, math.max(label(min).length, label(max).length) * 8.0 + 10),
  );
}
