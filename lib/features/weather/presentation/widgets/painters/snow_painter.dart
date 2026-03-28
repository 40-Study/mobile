import 'dart:math';

import 'package:flutter/material.dart';

/// Gentle falling snowflakes
class SnowPainter extends CustomPainter {
  SnowPainter({
    required this.animationValue,
    this.flakeCount = 25,
    this.flakeColor = Colors.white,
  });

  final double animationValue;
  final int flakeCount;
  final Color flakeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    for (var i = 0; i < flakeCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.3 + random.nextDouble() * 0.4;
      final flakeSize = 2 + random.nextDouble() * 4;
      final alpha = 0.5 + random.nextDouble() * 0.5;

      // Slow falling with gentle sway
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animationValue * size.height * speed) %
          (size.height + flakeSize * 2);

      // Horizontal sway
      final swayPhase = random.nextDouble() * 2 * pi;
      final swayAmount = 20 + random.nextDouble() * 30;
      final x = baseX + sin(animationValue * 2 * pi + swayPhase) * swayAmount;

      final paint = Paint()
        ..color = flakeColor.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, flakeSize * 0.3);

      canvas.drawCircle(Offset(x, y), flakeSize, paint);

      // Add subtle glow for larger flakes
      if (flakeSize > 4) {
        final glowPaint = Paint()
          ..color = flakeColor.withValues(alpha: alpha * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, flakeSize);
        canvas.drawCircle(Offset(x, y), flakeSize * 1.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
