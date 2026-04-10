import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// A compact metric card for displaying key financial figures
class BIMetricCard extends StatelessWidget {
  const BIMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.trend,
    this.trendUp,
    this.icon,
    this.isPrimary = false,
    this.onTap,
  });

  final String label;
  final double value;
  final String? suffix;
  final double? trend;
  final bool? trendUp;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  String _formatValue(double val) {
    if (val >= 1e9) {
      return '${(val / 1e9).toStringAsFixed(1)}B';
    } else if (val >= 1e6) {
      return '${(val / 1e6).toStringAsFixed(1)}M';
    } else if (val >= 1e3) {
      return '${(val / 1e3).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###').format(val);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.85)],
                )
              : null,
          color: isPrimary ? null : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: cs.outline.withValues(alpha: 0.5)),
          boxShadow: isPrimary ? cs.shadowPrimary : cs.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isPrimary
                        ? cs.onPrimary.withValues(alpha: 0.8)
                        : cs.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: isPrimary
                          ? cs.onPrimary.withValues(alpha: 0.8)
                          : cs.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    _formatValue(value),
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? cs.onPrimary : cs.onSurface,
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: tt.labelMedium?.copyWith(
                      color: isPrimary
                          ? cs.onPrimary.withValues(alpha: 0.7)
                          : cs.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            if (trend != null) ...[
              const SizedBox(height: 8),
              _TrendIndicator(
                value: trend!,
                isPositive: trendUp ?? trend! >= 0,
                isPrimary: isPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({
    required this.value,
    required this.isPositive,
    required this.isPrimary,
  });

  final double value;
  final bool isPositive;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final color = isPrimary
        ? cs.onPrimary.withValues(alpha: 0.9)
        : (isPositive ? cs.secondary : cs.error);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
          style: tt.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// A larger hero metric card for primary dashboard values
class BIHeroMetricCard extends StatelessWidget {
  const BIHeroMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.suffix = 'VND',
    this.subtitle,
    this.trend,
    this.chartData,
  });

  final String label;
  final double value;
  final String suffix;
  final String? subtitle;
  final double? trend;
  final List<double>? chartData;

  String _formatValue(double val) {
    if (val >= 1e9) {
      return NumberFormat('#,##0.0').format(val / 1e9);
    } else if (val >= 1e6) {
      return NumberFormat('#,##0.0').format(val / 1e6);
    }
    return NumberFormat('#,###').format(val);
  }

  String _getSuffix(double val) {
    if (val >= 1e9) return 'B $suffix';
    if (val >= 1e6) return 'M $suffix';
    return suffix;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: cs.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cs.shadowPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend! >= 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 12,
                        color: cs.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trend! >= 0 ? '+' : ''}${trend!.toStringAsFixed(1)}%',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _formatValue(value),
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
                TextSpan(
                  text: ' ${_getSuffix(value)}',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: tt.bodySmall?.copyWith(
                color: cs.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (chartData != null && chartData!.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              child: _MiniLineChart(data: chartData!, color: cs.onPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 60),
      painter: _LineChartPainter(data: data, color: color),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range) * size.height * 0.9;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
