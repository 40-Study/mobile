import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/theme/theme.dart';

/// Widget hiển thị biểu đồ xu hướng độ tập trung theo tuần
/// và phân tích định tính.
class FocusTrendChartWidget extends StatelessWidget {
  const FocusTrendChartWidget({
    super.key,
    required this.insights,
  });

  final ParentLearningInsightsModel insights;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn phụ UPPERCASE
        Text(
          'THEO DÕI NĂNG LỰC',
          style: tt.labelSmall?.copyWith(
            color: cs.slate500,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),

        // Tiêu đề + Badge trung bình
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Mức độ tập trung theo thời gian',
                style: tt.titleMedium?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                insights.focusTrendAverageDelta,
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Khung Biểu đồ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 20, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _FocusAreaChartPainter(
                    points: insights.focusTrendPoints,
                    lineColor: const Color(0xFF2563EB),
                    fillGradientStart:
                        const Color(0xFF2563EB).withValues(alpha: 0.25),
                    fillGradientEnd:
                        const Color(0xFF2563EB).withValues(alpha: 0.01),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Nhãn trục X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final pt in _filterDisplayPoints(
                      insights.focusTrendPoints))
                    Text(
                      pt.label,
                      style: TextStyle(
                        color: cs.slate400,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Ghi chú định tính dưới biểu đồ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: cs.slate600,
                fontSize: 13,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: 'Ghi chú: ',
                  style: TextStyle(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: insights.focusTrendNote),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FocusTrendDataPoint> _filterDisplayPoints(
      List<FocusTrendDataPoint> all) {
    if (all.length <= 6) return all;
    // Lọc lấy 5-6 mốc tiêu biểu: T1, T3, T6, T9, T12
    return [
      all.first,
      all[(all.length * 0.25).floor()],
      all[(all.length * 0.5).floor()],
      all[(all.length * 0.75).floor()],
      all.last,
    ];
  }
}

class _FocusAreaChartPainter extends CustomPainter {
  _FocusAreaChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillGradientStart,
    required this.fillGradientEnd,
  });

  final List<FocusTrendDataPoint> points;
  final Color lineColor;
  final Color fillGradientStart;
  final Color fillGradientEnd;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vẽ 3 đường lưới ngang mờ
    final yStep = size.height / 3;
    for (var i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(0, yStep * i),
        Offset(size.width, yStep * i),
        gridPaint,
      );
    }

    const minScore = 60.0;
    const maxScore = 100.0;
    const scoreRange = maxScore - minScore;

    final offsets = <Offset>[];
    final dx = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final normalized =
          ((points[i].score - minScore) / scoreRange).clamp(0.0, 1.0);
      final y = size.height - (normalized * (size.height - 16)) - 8;
      final x = i * dx;
      offsets.add(Offset(x, y));
    }

    // Tạo đường cong Cubic Bezier
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (var i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Vẽ phần Fill Gradient bên dưới đường cong
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillGradientStart, fillGradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Vẽ đường cong chính
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Vẽ điểm tròn cho điểm cuối cùng (tuần mới nhất)
    final lastPoint = offsets.last;
    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 7, glowPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 3.5, dotPaint);

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 1.8, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _FocusAreaChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
