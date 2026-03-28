import 'dart:math';

import 'package:flutter/material.dart';

/// Dense fog that obscures the view
class FogPainter extends CustomPainter {
  FogPainter({
    required this.animationValue,
    this.fogColor = const Color(0xFFE8E8E8),
    this.intensity = 0.8,
  });

  final double animationValue;
  final Color fogColor;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom heavy fog - thicker at bottom
    _paintBottomFog(canvas, size);

    // Drifting fog wisps
    _paintFogWisps(canvas, size);

    // Top thin layer
    _paintTopHaze(canvas, size);
  }

  void _paintBottomFog(Canvas canvas, Size size) {
    // Thick fog at bottom half
    final rect = Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.6);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        fogColor.withValues(alpha: 0.3 * intensity),
        fogColor.withValues(alpha: 0.6 * intensity),
        fogColor.withValues(alpha: 0.8 * intensity),
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintFogWisps(Canvas canvas, Size size) {
    final random = Random(42);

    for (var i = 0; i < 5; i++) {
      final yBase = size.height * (0.3 + i * 0.12);
      final drift = sin(animationValue * 2 * pi * 0.5 + i * 1.2) * size.width * 0.08;

      final wispWidth = size.width * (1.2 + random.nextDouble() * 0.3);
      final wispHeight = size.height * (0.08 + random.nextDouble() * 0.06);

      final rect = Rect.fromCenter(
        center: Offset(size.width / 2 + drift, yBase),
        width: wispWidth,
        height: wispHeight,
      );

      final alpha = (0.25 - i * 0.03) * intensity;

      final gradient = RadialGradient(
        colors: [
          fogColor.withValues(alpha: alpha),
          fogColor.withValues(alpha: alpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawOval(rect, paint);
    }
  }

  void _paintTopHaze(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fogColor.withValues(alpha: 0.2 * intensity),
        fogColor.withValues(alpha: 0.1 * intensity),
        Colors.transparent,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FogPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.intensity != intensity;
  }
}
