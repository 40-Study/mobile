import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class LearningTrendChart extends StatelessWidget {
  const LearningTrendChart({super.key, required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final data = stats.weeklyStudyHours ?? [30, 45, 60, 50, 80, 105, 70];
    final maxVal = data.isEmpty ? 120.0 : data.reduce(math.max);
    final yMax = ((maxVal / 30).ceil() * 30).toDouble().clamp(60.0, 150.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.learningTrend,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.last7Days,
                        style:
                            tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap4,
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap24,
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _yLabel('${yMax.toInt()} ${l10n.minutes}', tt, cs),
                    _yLabel('${(yMax * 0.5).toInt()} ${l10n.minutes}', tt, cs),
                    _yLabel('0 ${l10n.minutes}', tt, cs),
                  ],
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _LineChartPainter(
                        data: data, maxValue: yMax, color: cs.primary),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap12,
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                  .map((d) =>
                      Text(d, style: tt.labelSmall?.copyWith(color: cs.onSurface)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yLabel(String text, TextTheme tt, ColorScheme cs) {
    return Text(text, style: tt.labelSmall?.copyWith(color: cs.onSurface));
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  final List<double> data;
  final double maxValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final step = size.width / (data.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height * (1 - data[i] / maxValue);
      points.add(Offset(x, y.clamp(0, size.height)));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Points
    final pointPaint = Paint()..color = color;
    final pointBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4, pointPaint);
      canvas.drawCircle(p, 4, pointBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
