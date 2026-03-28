import 'dart:math';

import 'package:flutter/material.dart';

/// Animated rain with drops and splash ripples
class RainPainter extends CustomPainter {
  RainPainter({
    required this.animationValue,
    this.dropCount = 50,
    this.dropColor = const Color(0xFFB0C4DE),
    this.intensity = 1.0,
    this.showRipples = true,
    this.rippleY = 0.88, // Where ripples appear (sea level)
  });

  final double animationValue;
  final int dropCount;
  final Color dropColor;
  final double intensity;
  final bool showRipples;
  final double rippleY;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRainDrops(canvas, size);
    if (showRipples) {
      _paintRipples(canvas, size);
    }
  }

  void _paintRainDrops(Canvas canvas, Size size) {
    final random = Random(42);

    for (var i = 0; i < dropCount; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.8 + random.nextDouble() * 0.4;
      final length = 20 + random.nextDouble() * 25;
      final alpha = 0.4 + random.nextDouble() * 0.4;
      final thickness = 1.0 + random.nextDouble() * 1.0;

      // Calculate y position with animation
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animationValue * size.height * speed * 2.5) %
          (size.height * rippleY);

      final paint = Paint()
        ..color = dropColor.withValues(alpha: alpha * intensity)
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      // Slight angle for wind effect
      final windOffset = 5.0;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + windOffset, y + length),
        paint,
      );
    }
  }

  void _paintRipples(Canvas canvas, Size size) {
    final random = Random(99);
    final rippleBaseY = size.height * rippleY;

    for (var i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final phase = random.nextDouble();

      // Ripple expands and fades
      final rippleProgress = (animationValue + phase) % 1.0;
      final rippleRadius = rippleProgress * 15;
      final alpha = (1.0 - rippleProgress) * 0.4 * intensity;

      if (alpha > 0.05) {
        final paint = Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        // Draw ellipse for water surface perspective
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, rippleBaseY + random.nextDouble() * 20),
            width: rippleRadius * 2,
            height: rippleRadius * 0.5,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
