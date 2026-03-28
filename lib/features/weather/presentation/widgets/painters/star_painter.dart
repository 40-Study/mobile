import 'dart:math';

import 'package:flutter/material.dart';

/// Paints twinkling stars for night/dawn/dusk
class StarPainter extends CustomPainter {
  StarPainter({
    required this.starCount,
    required this.twinkleValue,
    this.starColor = Colors.white,
    this.seed = 42,
  });

  final int starCount;
  final double twinkleValue; // 0.0 - 1.0 for animation
  final Color starColor;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    for (var i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.75; // Stars in upper 75%

      // Vary star sizes - some very small, some medium
      final sizeCategory = random.nextDouble();
      final baseRadius = sizeCategory < 0.7
          ? 0.3 + random.nextDouble() * 0.5 // Small stars (70%)
          : sizeCategory < 0.9
              ? 0.8 + random.nextDouble() * 0.7 // Medium stars (20%)
              : 1.5 + random.nextDouble() * 0.5; // Bright stars (10%)

      // Twinkle effect - each star has different phase and speed
      final phase = random.nextDouble() * 2 * pi;
      final speed = 0.5 + random.nextDouble() * 1.5; // Vary twinkle speed
      final twinkle = 0.5 + 0.5 * sin(twinkleValue * 2 * pi * speed + phase);

      // Smoother opacity transition
      final opacity = 0.3 + 0.7 * twinkle * twinkle; // Quadratic for smoother fade
      final radius = baseRadius * (0.8 + 0.2 * twinkle);

      // Star body
      final paint = Paint()
        ..color = starColor.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add cross sparkle for bright stars
      if (baseRadius > 1.2 && twinkle > 0.7) {
        _drawSparkle(canvas, Offset(x, y), radius, opacity);
      }

      // Soft glow for medium/bright stars
      if (baseRadius > 0.8) {
        final glowPaint = Paint()
          ..color = starColor.withValues(alpha: opacity * 0.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2);
        canvas.drawCircle(Offset(x, y), radius * 2.5, glowPaint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, double opacity) {
    final sparklePaint = Paint()
      ..color = starColor.withValues(alpha: opacity * 0.5)
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;

    final sparkleLength = radius * 3;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - sparkleLength, center.dy),
      Offset(center.dx + sparkleLength, center.dy),
      sparklePaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - sparkleLength),
      Offset(center.dx, center.dy + sparkleLength),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.twinkleValue != twinkleValue ||
        oldDelegate.starCount != starCount;
  }
}
