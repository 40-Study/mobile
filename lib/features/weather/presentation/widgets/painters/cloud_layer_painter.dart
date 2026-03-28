import 'dart:math';

import 'package:flutter/material.dart';

/// Fluffy cloud layers for cloudy weather
class CloudLayerPainter extends CustomPainter {
  CloudLayerPainter({
    required this.animationValue,
    this.cloudColor = const Color(0xFFCBD5E0),
    this.layerCount = 3,
  });

  final double animationValue;
  final Color cloudColor;
  final int layerCount;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(123);

    // Draw layers from back to front
    for (var layer = 0; layer < layerCount; layer++) {
      final yBase = size.height * (0.02 + layer * 0.1);
      final alpha = 0.85 - layer * 0.15;
      final scale = 1.2 - layer * 0.15;
      final speed = 0.5 + layer * 0.3;
      final drift = sin(animationValue * 2 * pi * speed) * (20 + layer * 10);

      // Multiple clouds per layer
      for (var i = 0; i < 5; i++) {
        final xBase = size.width * (i * 0.28 - 0.15);
        final xOffset = drift * (layer % 2 == 0 ? 1 : -1);
        final yOffset = random.nextDouble() * 30;

        _paintFluffyCloud(
          canvas,
          Offset(xBase + xOffset, yBase + yOffset),
          size.width * 0.18 * scale,
          cloudColor.withValues(alpha: alpha),
        );
      }
    }
  }

  void _paintFluffyCloud(
    Canvas canvas,
    Offset center,
    double scale,
    Color color,
  ) {
    // Main cloud body - multiple overlapping soft circles
    final puffs = <({Offset offset, double size})>[
      // Center mass
      (offset: Offset(0, 0), size: 1.0),
      (offset: Offset(-scale * 0.4, scale * 0.05), size: 0.85),
      (offset: Offset(scale * 0.45, scale * 0.08), size: 0.8),
      // Top puffs
      (offset: Offset(-scale * 0.15, -scale * 0.25), size: 0.7),
      (offset: Offset(scale * 0.2, -scale * 0.2), size: 0.65),
      (offset: Offset(scale * 0.0, -scale * 0.3), size: 0.55),
      // Side extensions
      (offset: Offset(-scale * 0.7, scale * 0.1), size: 0.6),
      (offset: Offset(scale * 0.75, scale * 0.12), size: 0.55),
      // Bottom fill
      (offset: Offset(-scale * 0.25, scale * 0.15), size: 0.5),
      (offset: Offset(scale * 0.3, scale * 0.18), size: 0.45),
    ];

    // Soft glow behind cloud
    final glowPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.8);
    canvas.drawCircle(center, scale * 0.9, glowPaint);

    // Draw each puff
    for (final puff in puffs) {
      final puffCenter = center + puff.offset;
      final puffRadius = scale * 0.45 * puff.size;

      // Soft edge
      final softPaint = Paint()
        ..color = color.withValues(alpha: color.a * 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, puffRadius * 0.5);
      canvas.drawCircle(puffCenter, puffRadius * 1.2, softPaint);

      // Main puff
      final mainPaint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, puffRadius * 0.3);
      canvas.drawCircle(puffCenter, puffRadius, mainPaint);
    }

    // Highlight on top
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.3);
    canvas.drawCircle(
      center + Offset(-scale * 0.1, -scale * 0.2),
      scale * 0.35,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(CloudLayerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.cloudColor != cloudColor;
  }
}
