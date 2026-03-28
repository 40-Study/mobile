import 'dart:math';

import 'package:flutter/material.dart';

/// Beautiful crescent moon with glow animation
class MoonPainter extends CustomPainter {
  MoonPainter({
    required this.animationValue,
    this.position = const Offset(0.7, 0.15),
    this.size = 0.1,
  });

  final double animationValue;
  final Offset position;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = canvasSize.width * position.dx;
    final centerY = canvasSize.height * position.dy;
    final center = Offset(centerX, centerY);
    final radius = canvasSize.width * size;

    // Pulsing glow
    final glowPulse = 1.0 + 0.1 * sin(animationValue * 2 * pi);

    // Outer glow layers
    final glowLayers = [
      (radius: 3.0, alpha: 0.08, blur: 30.0),
      (radius: 2.0, alpha: 0.15, blur: 20.0),
      (radius: 1.5, alpha: 0.2, blur: 10.0),
    ];

    for (final layer in glowLayers) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFFACD).withValues(alpha: layer.alpha * glowPulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      canvas.drawCircle(center, radius * layer.radius, glowPaint);
    }

    // Create crescent shape
    final moonPath = Path();
    moonPath.addOval(Rect.fromCircle(center: center, radius: radius));

    // Shadow circle to create crescent
    final shadowOffset = Offset(center.dx - radius * 0.5, center.dy - radius * 0.1);
    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCircle(center: shadowOffset, radius: radius * 0.8));

    // Combine paths
    final crescentPath = Path.combine(
      PathOperation.difference,
      moonPath,
      shadowPath,
    );

    // Moon gradient
    final moonGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFFFFFF8), // Warm white
        Color(0xFFFFFACD), // Lemon chiffon
        Color(0xFFEEE8AA), // Pale goldenrod
      ],
    );

    final moonPaint = Paint()
      ..shader = moonGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawPath(crescentPath, moonPaint);

    // Subtle inner shadow for depth
    final innerShadow = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 3);
    canvas.drawPath(crescentPath, innerShadow);

    // Bright edge highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(crescentPath, highlightPaint);
  }

  @override
  bool shouldRepaint(MoonPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.position != position;
  }
}
