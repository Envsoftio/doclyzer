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
    this.unit,
    this.onOpenReport,
    required this.onBack,
  });

  final ReportsRepository reportsRepository;
  final String profileId;
  final String parameterName;

  /// Empty string explicitly selects results whose unit is unknown.
  final String? unit;
  final ValueChanged<String>? onOpenReport;
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
      final param = widget.unit == null
          ? result.parameters.firstOrNull
          : result.parameters
                .where(
                  (p) =>
                      (p.unit ?? '').toLowerCase() ==
                          widget.unit!.trim().toLowerCase() ||
                      p.observations.any(
                        (observation) =>
                            (observation.originalUnit ?? '').toLowerCase() ==
                            widget.unit!.trim().toLowerCase(),
                      ),
                )
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
    if (param == null) {
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
              'No saved results are available for this test yet.',
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
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'No exact numeric results with a collection date can be plotted.',
            ),
            const SizedBox(height: 16),
            _buildHistory(param, points),
          ],
        ),
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
    final firstDay = _trendDay(points.first.date);
    final lastDay = _trendDay(points.last.date);
    final span = math.max(1.0, lastDay - firstDay);
    final spots = points
        .map((point) => FlSpot(_trendDay(point.date), point.value))
        .toList();
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
                const SizedBox(height: 4),
                Text(
                  'Lab reference range: ${latest.referenceRange ?? 'Unknown'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                if (latest.originalUnit != null && latest.originalUnit != unit)
                  Text('Source unit for this range: ${latest.originalUnit}'),
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
                : '${points.length} saved results · Dates are spaced by elapsed time. Tap a point for its value.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (param.unplottedCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${param.unplottedCount} result${param.unplottedCount == 1 ? '' : 's'} not plotted because the collection date or exact numeric value is unavailable.',
              key: const Key('trend-unplotted-note'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
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
                      width: chartWidth,
                      child: Column(
                        children: [
                          SizedBox(
                            key: const Key('trend-chart-content'),
                            width: chartWidth,
                            height: 260,
                            child: Semantics(
                              label:
                                  '${widget.parameterName} trend chart with ${points.length} results',
                              child: LineChart(
                                LineChartData(
                                  minX: firstDay - span * 0.025,
                                  maxX: lastDay + span * 0.025,
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
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                      ),
                                    ),
                                    bottomTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
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
                                      left: BorderSide(
                                        color: colors.outlineVariant,
                                      ),
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
                                            colors.primary.withValues(
                                              alpha: 0.18,
                                            ),
                                            colors.primary.withValues(
                                              alpha: 0.01,
                                            ),
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
                                            final point =
                                                points[spot.spotIndex];
                                            return LineTooltipItem(
                                              '${AppDateFormat.date(point.date)}\n${_formatNumber(point.value)}${unit == null ? '' : ' $unit'}\nLab range: ${point.referenceRange ?? 'Unknown'}',
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
                          SizedBox(
                            height: 34,
                            width: chartWidth,
                            child: Stack(
                              children: [
                                for (final index in _visibleDateIndexes(
                                  points,
                                  chartWidth,
                                ))
                                  Positioned(
                                    left:
                                        (((_trendDay(points[index].date) -
                                                        firstDay) /
                                                    span) *
                                                (chartWidth - 72))
                                            .clamp(0.0, chartWidth - 72),
                                    child: SizedBox(
                                      width: 72,
                                      child: Text(
                                        AppDateFormat.date(points[index].date),
                                        key: Key('trend-date-$index'),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildHistory(param, points),
        ],
      ),
    );
  }

  Widget _buildHistory(TrendParameter param, List<TrendDataPoint> points) {
    final observations = param.observations.isNotEmpty
        ? param.observations
        : points.reversed
              .map(
                (point) => TrendObservation(
                  reportId: point.reportId ?? '',
                  originalValue:
                      point.originalValue ?? _formatNumber(point.value),
                  date: point.date,
                  value: point.value,
                  referenceRange: point.referenceRange,
                  originalUnit: point.originalUnit,
                  dateProvenance: point.dateProvenance,
                ),
              )
              .toList();
    final unit = param.unit?.trim().isNotEmpty == true
        ? ' ${param.unit!.trim()}'
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'All saved results',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < observations.length; index++)
          Card(
            key: Key('trend-observation-$index'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${observations[index].originalValue}${observations[index].originalUnit == null ? unit : ' ${observations[index].originalUnit}'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    observations[index].date == null
                        ? 'Collection date unknown'
                        : 'Collected ${AppDateFormat.date(observations[index].date!)}',
                  ),
                  Text(
                    'Lab reference range: ${observations[index].referenceRange ?? 'Unknown'}',
                  ),
                  if (observations[index].date != null &&
                      observations[index].dateProvenance == 'legacy_extracted')
                    const Text(
                      'Collection date from earlier extraction; review in source report',
                    ),
                  if (observations[index].notPlottedReason != null)
                    Text(switch (observations[index].notPlottedReason) {
                      'collection_date_unknown' =>
                        'Not plotted: collection date unknown',
                      'non_numeric_value' =>
                        'Not plotted: result is not an exact number',
                      _ =>
                        'Not plotted: collection date unknown and result is not an exact number',
                    }),
                  if (widget.onOpenReport != null &&
                      observations[index].reportId.isNotEmpty)
                    TextButton(
                      key: Key('trend-source-report-$index'),
                      onPressed: () =>
                          widget.onOpenReport!(observations[index].reportId),
                      child: const Text('Open source report'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

double _trendDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch /
    Duration.millisecondsPerDay;

List<int> _visibleDateIndexes(List<TrendDataPoint> points, double width) {
  if (points.length <= 2) return List<int>.generate(points.length, (i) => i);
  final first = _trendDay(points.first.date);
  final span = math.max(1.0, _trendDay(points.last.date) - first);
  final indexes = <int>[0];
  var lastPosition = 0.0;
  for (var i = 1; i < points.length - 1; i++) {
    final position = (_trendDay(points[i].date) - first) / span * (width - 72);
    if (position - lastPosition >= 92 && width - 72 - position >= 92) {
      indexes.add(i);
      lastPosition = position;
    }
  }
  if (_trendDay(points.last.date) != first) indexes.add(points.length - 1);
  return indexes;
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
