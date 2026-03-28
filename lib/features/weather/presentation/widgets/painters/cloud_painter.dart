import 'dart:math';

import 'package:flutter/material.dart';

/// Soft, elegant clouds for daytime sky
class CloudPainter extends CustomPainter {
  CloudPainter({
    required this.animationValue,
    this.cloudCount = 3,
    this.opacity = 0.3,
    this.color = Colors.white,
  });

  final double animationValue;
  final int cloudCount;
  final double opacity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    for (var i = 0; i < cloudCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = size.height * (0.05 + random.nextDouble() * 0.2);
      final cloudScale = 0.5 + random.nextDouble() * 0.5;

      // Very slow drift
      final drift = sin(animationValue * 2 * pi + i * 1.5) * 5;
      final x = baseX + drift;

      _paintCloud(canvas, Offset(x, baseY), size.width * 0.06 * cloudScale);
    }
  }

  void _paintCloud(Canvas canvas, Offset position, double scale) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.6);

    // Soft cloud shape
    final circles = [
      (const Offset(0, 0), 1.0),
      (const Offset(-0.7, 0.05), 0.65),
      (const Offset(0.75, 0.08), 0.7),
      (const Offset(-0.25, -0.2), 0.55),
      (const Offset(0.3, -0.15), 0.5),
    ];

    for (final (offset, sizeFactor) in circles) {
      final center = position + Offset(offset.dx * scale, offset.dy * scale);
      canvas.drawCircle(center, scale * sizeFactor, paint);
    }
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.opacity != opacity;
  }
}
