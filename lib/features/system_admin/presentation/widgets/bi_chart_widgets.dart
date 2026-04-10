import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Bar chart for comparing values across categories
class BIBarChart extends StatelessWidget {
  const BIBarChart({
    super.key,
    required this.data,
    this.barColor,
    this.showValues = true,
    this.height = 200,
  });

  final List<ChartDataPoint> data;
  final Color? barColor;
  final bool showValues;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = barColor ?? cs.primary;

    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((point) {
          final heightFraction = maxValue > 0 ? point.value / maxValue : 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showValues)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatValue(point.value),
                        style: tt.labelSmall?.copyWith(
                          color: cs.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  Flexible(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: (height - 40) * heightFraction,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            color,
                            color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point.label,
                    style: tt.labelSmall?.copyWith(
                      color: cs.textTertiary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatValue(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(1)}K';
    return val.toStringAsFixed(0);
  }
}

/// Horizontal bar chart for rankings
class BIHorizontalBarChart extends StatelessWidget {
  const BIHorizontalBarChart({
    super.key,
    required this.data,
    this.height = 300,
    this.showLabels = true,
  });

  final List<RankingDataPoint> data;
  final double height;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        final widthFraction = maxValue > 0 ? point.value / maxValue : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '#${index + 1}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text(
                  point.label,
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      height: 28,
                      width: MediaQuery.of(context).size.width *
                          0.4 *
                          widthFraction,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            point.color ?? cs.primary,
                            (point.color ?? cs.primary).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: showLabels
                          ? Text(
                              _formatValue(point.value),
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatValue(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(0)}K';
    return NumberFormat('#,###').format(val);
  }
}

/// Donut chart for distribution
class BIDonutChart extends StatelessWidget {
  const BIDonutChart({
    super.key,
    required this.data,
    this.size = 160,
    this.strokeWidth = 24,
    this.centerWidget,
  });

  final List<DonutDataPoint> data;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + d.value);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              data: data,
              total: total,
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.strokeWidth,
  });

  final List<DonutDataPoint> data;
  final double total;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    var startAngle = -90 * (3.14159 / 180);

    for (final point in data) {
      final sweepAngle = (point.value / total) * 360 * (3.14159 / 180);

      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Line chart for trends
class BILineChart extends StatelessWidget {
  const BILineChart({
    super.key,
    required this.data,
    this.height = 180,
    this.lineColor,
    this.showDots = false,
    this.showGrid = true,
  });

  final List<TimeSeriesDataPoint> data;
  final double height;
  final Color? lineColor;
  final bool showDots;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = lineColor ?? cs.primary;

    if (data.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _LineChartPainter(
          data: data,
          lineColor: color,
          gridColor: cs.outline.withValues(alpha: 0.3),
          showDots: showDots,
          showGrid: showGrid,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
    required this.showDots,
    required this.showGrid,
  });

  final List<TimeSeriesDataPoint> data;
  final Color lineColor;
  final Color gridColor;
  final bool showDots;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minVal = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final padding = 8.0;
    final chartHeight = size.height - padding * 2;
    final chartWidth = size.width - padding * 2;

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5;

      for (var i = 0; i <= 4; i++) {
        final y = padding + (chartHeight / 4) * i;
        canvas.drawLine(
          Offset(padding, y),
          Offset(size.width - padding, y),
          gridPaint,
        );
      }
    }

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = chartWidth / (data.length - 1);

    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y =
          padding + chartHeight - ((data[i].value - minVal) / range) * chartHeight * 0.9;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width - padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots
    if (showDots) {
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      final dotBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 5, dotBorderPaint);
        canvas.drawCircle(point, 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Comparison chart with two data series
class BIComparisonChart extends StatelessWidget {
  const BIComparisonChart({
    super.key,
    required this.label1,
    required this.label2,
    required this.data,
    this.color1,
    this.color2,
    this.height = 200,
  });

  final String label1;
  final String label2;
  final List<ComparisonDataPoint> data;
  final Color? color1;
  final Color? color2;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final c1 = color1 ?? cs.primary;
    final c2 = color2 ?? cs.secondary;

    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data
        .expand((d) => [d.value1, d.value2])
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: c1, label: label1),
            const SizedBox(width: 24),
            _LegendItem(color: c2, label: label2),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((point) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: maxValue > 0
                                  ? (height - 30) * (point.value1 / maxValue)
                                  : 0,
                              decoration: BoxDecoration(
                                color: c1,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: maxValue > 0
                                  ? (height - 30) * (point.value2 / maxValue)
                                  : 0,
                              decoration: BoxDecoration(
                                color: c2,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: tt.labelSmall?.copyWith(
                          color: cs.textTertiary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.textSecondary),
        ),
      ],
    );
  }
}

// Data point classes
class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

class RankingDataPoint {
  const RankingDataPoint({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

class DonutDataPoint {
  const DonutDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class TimeSeriesDataPoint {
  const TimeSeriesDataPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;
}

class ComparisonDataPoint {
  const ComparisonDataPoint({
    required this.label,
    required this.value1,
    required this.value2,
  });

  final String label;
  final double value1;
  final double value2;
}
