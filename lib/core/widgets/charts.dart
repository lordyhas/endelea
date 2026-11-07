import 'dart:math' as math;

import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

/// A point of a [ProgressLineChart].
class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

/// Line chart over time (exercise curves, body weight).
class ProgressLineChart extends StatelessWidget {
  const ProgressLineChart({
    required this.points,
    required this.formatValue,
    required this.formatDate,
    required this.semanticLabel,
    this.height = 200,
    super.key,
  });

  final List<ChartPoint> points;
  final String Function(double value) formatValue;
  final String Function(DateTime date) formatDate;

  /// Read by screen readers instead of the chart.
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final labelStyle = theme.textTheme.labelSmall.tabular;
    if (points.isEmpty) return SizedBox(height: height);

    final values = points.map((p) => p.value);
    var minY = values.reduce(math.min);
    var maxY = values.reduce(math.max);
    final padding = math.max((maxY - minY) * 0.15, maxY.abs() * 0.05 + 1);
    minY = math.max(0, minY - padding);
    maxY = maxY + padding;

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: 0,
              maxX: math.max(1, points.length - 1).toDouble(),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: _interval(minY, maxY),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: colors.surfaceHighest, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: _interval(minY, maxY),
                    getTitlesWidget: (value, meta) => value == meta.max
                        ? const SizedBox.shrink()
                        : Text(formatValue(value), style: labelStyle),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: math
                        .max(1, (points.length / 4).ceil())
                        .toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formatDate(points[index].date),
                          style: labelStyle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colors.surfaceHighest,
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      LineTooltipItem(
                        '${formatValue(spot.y)}\n'
                        '${formatDate(points[spot.x.round()].date)}',
                        theme.textTheme.labelMedium.tabular ??
                            const TextStyle(),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (final (i, point) in points.indexed)
                      FlSpot(i.toDouble(), point.value),
                  ],
                  color: scheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: points.length <= 20),
                  belowBarData: BarAreaData(
                    show: true,
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar chart of one value per week.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.values,
    required this.labels,
    required this.formatValue,
    required this.semanticLabel,
    this.height = 180,
    super.key,
  });

  final List<double> values;

  /// One label per bar; empty strings are skipped.
  final List<String> labels;
  final String Function(double value) formatValue;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final labelStyle = theme.textTheme.labelSmall.tabular;
    final maxY = values.isEmpty ? 1.0 : math.max(1, values.reduce(math.max));
    final barWidth = values.length > 26
        ? 4.0
        : (values.length > 12 ? 8.0 : 16.0);

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.15,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: _interval(0, maxY * 1.15),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: colors.surfaceHighest, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: _interval(0, maxY * 1.15),
                    getTitlesWidget: (value, meta) => value == meta.max
                        ? const SizedBox.shrink()
                        : Text(formatValue(value), style: labelStyle),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      final step = math.max(1, (values.length / 6).ceil());
                      if (index >= labels.length || index % step != 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labels[index], style: labelStyle),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.surfaceHighest,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        formatValue(rod.toY),
                        theme.textTheme.labelMedium.tabular ??
                            const TextStyle(),
                      ),
                ),
              ),
              barGroups: [
                for (final (i, value) in values.indexed)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: scheme.primary,
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// About four grid lines with round steps.
double _interval(double min, double max) {
  final range = (max - min).abs();
  if (range <= 0) return 1;
  final raw = range / 4;
  final magnitude = math
      .pow(10, (math.log(raw) / math.ln10).floor())
      .toDouble();
  final normalized = raw / magnitude;
  final step = normalized < 1.5
      ? 1
      : normalized < 3
      ? 2
      : normalized < 7
      ? 5
      : 10;
  return step * magnitude;
}
