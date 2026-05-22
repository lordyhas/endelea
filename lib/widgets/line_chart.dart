import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Minimal line chart for a short series of values, drawn without any
/// charting dependency.
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.values,
    this.labels = const [],
    this.height = 160,
    this.formatValue,
  });

  final List<double> values;

  /// Optional x axis labels, one per value. Only the first and last are drawn.
  final List<String> labels;
  final double height;
  final String Function(double value)? formatValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = formatValue ?? (v) => v.toStringAsFixed(0);
    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(format(maxValue), style: labelStyle),
            const Spacer(),
            if (values.isNotEmpty)
              Text(
                'Last ${format(values.last)}',
                style: labelStyle?.copyWith(color: theme.colorScheme.primary),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _LineChartPainter(
              values: values,
              line: theme.colorScheme.primary,
              grid: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              labels.isNotEmpty ? labels.first : format(minValue),
              style: labelStyle,
            ),
            const Spacer(),
            if (labels.length > 1) Text(labels.last, style: labelStyle),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.line,
    required this.grid,
  });

  final List<double> values;
  final Color line;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (values.isEmpty) return;

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = maxValue - minValue == 0 ? 1.0 : maxValue - minValue;
    Offset point(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height - (values[i] - minValue) / range * size.height;
      return Offset(x, values.length == 1 ? size.height / 2 : y);
    }

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = line;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 4, dot);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.line != line ||
      oldDelegate.grid != grid;
}
