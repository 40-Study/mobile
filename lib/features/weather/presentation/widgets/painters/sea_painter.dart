import 'dart:math';

import 'package:flutter/material.dart';

/// Calm sea with gentle waves
class SeaPainter extends CustomPainter {
  SeaPainter({
    required this.animationValue,
    required this.seaColor,
    this.waveColor,
    this.heightFactor = 0.25,
    this.showReflection = false,
    this.reflectionColor,
  });

  final double animationValue;
  final Color seaColor;
  final Color? waveColor;
  final double heightFactor;
  final bool showReflection;
  final Color? reflectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    final seaTop = size.height * (1 - heightFactor);

    // Sea gradient
    final seaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        seaColor,
        seaColor.withValues(alpha: 0.9),
        seaColor.withValues(alpha: 0.95),
      ],
    );

    final seaPaint = Paint()
      ..shader = seaGradient.createShader(
        Rect.fromLTWH(0, seaTop, size.width, size.height - seaTop),
      );

    // Draw sea base
    canvas.drawRect(
      Rect.fromLTWH(0, seaTop, size.width, size.height - seaTop),
      seaPaint,
    );

    // Gentle waves
    _paintWaves(canvas, size, seaTop);

    // Sun/moon reflection on water
    if (showReflection && reflectionColor != null) {
      _paintReflection(canvas, size, seaTop);
    }
  }

  void _paintWaves(Canvas canvas, Size size, double seaTop) {
    final waveHeight = size.height * 0.008;
    final effectiveWaveColor = waveColor ?? Colors.white.withValues(alpha: 0.15);

    for (var i = 0; i < 4; i++) {
      final waveY = seaTop + (i * size.height * 0.03) + 5;
      final phase = animationValue * 2 * pi + i * 0.8;
      final waveAmplitude = waveHeight * (1 - i * 0.2);

      final path = Path();
      path.moveTo(0, waveY);

      for (var x = 0.0; x <= size.width; x += 4) {
        final y = waveY + sin((x / size.width * 4 * pi) + phase) * waveAmplitude;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final wavePaint = Paint()
        ..color = effectiveWaveColor.withValues(
          alpha: (effectiveWaveColor.a * (0.15 - i * 0.03)).clamp(0.0, 1.0),
        );

      canvas.drawPath(path, wavePaint);
    }
  }

  void _paintReflection(Canvas canvas, Size size, double seaTop) {
    final reflectionWidth = size.width * 0.15;
    final centerX = size.width * 0.5;

    final reflectionGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        reflectionColor!.withValues(alpha: 0.4),
        reflectionColor!.withValues(alpha: 0.2),
        reflectionColor!.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final reflectionPaint = Paint()
      ..shader = reflectionGradient.createShader(
        Rect.fromLTWH(
          centerX - reflectionWidth / 2,
          seaTop,
          reflectionWidth,
          size.height * 0.15,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Wavy reflection path
    final path = Path();
    final reflectionHeight = size.height * 0.12;

    path.moveTo(centerX - reflectionWidth / 2, seaTop);

    for (var y = seaTop; y <= seaTop + reflectionHeight; y += 2) {
      final progress = (y - seaTop) / reflectionHeight;
      final wave = sin(animationValue * 4 * pi + progress * 6) * 3;
      final width = reflectionWidth * (1 - progress * 0.5);
      path.lineTo(centerX - width / 2 + wave, y);
    }

    for (var y = seaTop + reflectionHeight; y >= seaTop; y -= 2) {
      final progress = (y - seaTop) / reflectionHeight;
      final wave = sin(animationValue * 4 * pi + progress * 6) * 3;
      final width = reflectionWidth * (1 - progress * 0.5);
      path.lineTo(centerX + width / 2 + wave, y);
    }

    path.close();
    canvas.drawPath(path, reflectionPaint);
  }

  @override
  bool shouldRepaint(SeaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.seaColor != seaColor;
  }
}
