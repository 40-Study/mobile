import 'dart:math';

import 'package:flutter/material.dart';

/// Elegant sun with soft glow - similar style to moon
class SunPainter extends CustomPainter {
  SunPainter({
    required this.animationValue,
    this.position = const Offset(0.5, 0.25),
    this.size = 0.12,
    this.rayCount = 12,
    this.isRising = false,
    this.glowIntensity = 1.0,
  });

  final double animationValue;
  final Offset position;
  final double size;
  final int rayCount;
  final bool isRising;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = canvasSize.width * position.dx;
    final centerY = canvasSize.height * position.dy;
    final center = Offset(centerX, centerY);
    final radius = canvasSize.width * size;

    // Gentle pulsing
    final pulse = 1.0 + 0.03 * sin(animationValue * 2 * pi);

    if (isRising) {
      _paintRisingSun(canvas, canvasSize, center, radius, pulse);
    } else {
      _paintFullSun(canvas, center, radius, pulse);
    }
  }

  void _paintFullSun(Canvas canvas, Offset center, double radius, double pulse) {
    // Soft outer glow layers (like moon style)
    final glowLayers = [
      (radius: 6.0, alpha: 0.06, blur: 60.0, color: const Color(0xFFFFF8E1)),
      (radius: 4.0, alpha: 0.10, blur: 40.0, color: const Color(0xFFFFECB3)),
      (radius: 2.5, alpha: 0.15, blur: 25.0, color: const Color(0xFFFFE082)),
      (radius: 1.6, alpha: 0.25, blur: 15.0, color: const Color(0xFFFFD54F)),
    ];

    for (final layer in glowLayers) {
      final glowPaint = Paint()
        ..color = layer.color.withValues(alpha: layer.alpha * glowIntensity * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      canvas.drawCircle(center, radius * layer.radius, glowPaint);
    }

    // Soft light rays (god rays effect)
    _paintSoftRays(canvas, center, radius, pulse);

    // Sun body with gradient
    final sunGradient = RadialGradient(
      colors: const [
        Color(0xFFFFFFFF), // Pure white center
        Color(0xFFFFFFF0), // Ivory
        Color(0xFFFFE082), // Light gold
        Color(0xFFFFD54F), // Gold edge
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final sunPaint = Paint()
      ..shader = sunGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * pulse),
      );
    canvas.drawCircle(center, radius * pulse, sunPaint);

    // Bright edge highlight (like moon)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center, radius * pulse, highlightPaint);
  }

  void _paintSoftRays(Canvas canvas, Offset center, double radius, double pulse) {
    final rayCount = 8;
    final rotation = animationValue * 2 * pi / 60; // Very slow rotation

    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi + rotation;

      // Breathing effect per ray
      final breathe = sin(animationValue * 2 * pi + i * 0.8);
      final rayLength = radius * (4.0 + breathe * 0.5) * pulse;
      final rayWidth = radius * 0.8;

      final path = Path();

      // Create soft triangular ray
      final tipX = center.dx + cos(angle) * rayLength;
      final tipY = center.dy + sin(angle) * rayLength;

      final baseAngle1 = angle - 0.08;
      final baseAngle2 = angle + 0.08;
      final baseRadius = radius * 1.2;

      path.moveTo(
        center.dx + cos(baseAngle1) * baseRadius,
        center.dy + sin(baseAngle1) * baseRadius,
      );
      path.lineTo(tipX, tipY);
      path.lineTo(
        center.dx + cos(baseAngle2) * baseRadius,
        center.dy + sin(baseAngle2) * baseRadius,
      );
      path.close();

      final rayGradient = RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.25 * glowIntensity),
          const Color(0xFFFFD54F).withValues(alpha: 0.1 * glowIntensity),
          Colors.transparent,
        ],
      );

      final rayPaint = Paint()
        ..shader = rayGradient.createShader(
          Rect.fromCircle(center: center, radius: rayLength),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rayWidth * 0.5);

      canvas.drawPath(path, rayPaint);
    }
  }

  void _paintRisingSun(
    Canvas canvas,
    Size canvasSize,
    Offset center,
    double radius,
    double pulse,
  ) {
    final horizonY = canvasSize.height * position.dy;
    final sunCenter = Offset(center.dx, horizonY);

    // Clip to show only top portion
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, canvasSize.width, horizonY));

    // Horizon glow (soft layers like moon)
    final glowLayers = [
      (radius: 5.0, alpha: 0.08, blur: 50.0, color: const Color(0xFFFFCC80)),
      (radius: 3.0, alpha: 0.15, blur: 30.0, color: const Color(0xFFFFAB40)),
      (radius: 2.0, alpha: 0.25, blur: 15.0, color: const Color(0xFFFF8A65)),
    ];

    for (final layer in glowLayers) {
      final glowPaint = Paint()
        ..color = layer.color.withValues(alpha: layer.alpha * glowIntensity * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      canvas.drawCircle(sunCenter, radius * layer.radius, glowPaint);
    }

    // Sun body
    final sunGradient = RadialGradient(
      colors: const [
        Color(0xFFFFFFF0),
        Color(0xFFFFE082),
        Color(0xFFFFB74D),
        Color(0xFFFF8A65),
      ],
    );
    final sunPaint = Paint()
      ..shader = sunGradient.createShader(
        Rect.fromCircle(center: sunCenter, radius: radius * pulse),
      );
    canvas.drawCircle(sunCenter, radius * pulse, sunPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.position != position ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
