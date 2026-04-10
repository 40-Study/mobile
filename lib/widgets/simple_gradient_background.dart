import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Beautiful milk-colored background with gentle wave ripples
class SimpleGradientBackground extends StatelessWidget {
  const SimpleGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1a1c2e),
                  const Color(0xFF2d2a4a),
                  const Color(0xFF1e2235),
                ]
              : [
                  const Color(0xFFF5F0E8), // warm milk top
                  const Color(0xFFFAF6F0), // creamy milk middle
                  const Color(0xFFF0EBE3), // milk bottom
                ],
        ),
      ),
      child: Stack(
        children: [
          // Wave ripples layer
          const Positioned.fill(
            child: _WavesLayer(),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Animated gentle wave ripples
class _WavesLayer extends StatefulWidget {
  const _WavesLayer();

  @override
  State<_WavesLayer> createState() => _WavesLayerState();
}

class _WavesLayerState extends State<_WavesLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WavesPainter(
            progress: _controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _WavesPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _paintDarkWaves(canvas, size);
    } else {
      _paintLightWaves(canvas, size);
    }
  }

  void _paintLightWaves(Canvas canvas, Size size) {
    // Wave 1 - bottom, slowest, most visible
    _drawWave(
      canvas,
      size,
      waveHeight: 25,
      yOffset: size.height * 0.75,
      phaseShift: progress * math.pi * 2,
      color: const Color(0xFFE8E0D5).withValues(alpha: 0.5),
      wavelength: 1.2,
    );

    // Wave 2 - middle
    _drawWave(
      canvas,
      size,
      waveHeight: 20,
      yOffset: size.height * 0.5,
      phaseShift: progress * math.pi * 2 + math.pi / 3,
      color: const Color(0xFFE5DDD0).withValues(alpha: 0.35),
      wavelength: 1.5,
    );

    // Wave 3 - upper middle
    _drawWave(
      canvas,
      size,
      waveHeight: 15,
      yOffset: size.height * 0.3,
      phaseShift: progress * math.pi * 2 + math.pi / 2,
      color: const Color(0xFFDDD5C8).withValues(alpha: 0.25),
      wavelength: 1.8,
    );

    // Wave 4 - top, fastest, subtle
    _drawWave(
      canvas,
      size,
      waveHeight: 12,
      yOffset: size.height * 0.15,
      phaseShift: progress * math.pi * 2 + math.pi,
      color: const Color(0xFFD8D0C5).withValues(alpha: 0.2),
      wavelength: 2.0,
    );
  }

  void _paintDarkWaves(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      waveHeight: 25,
      yOffset: size.height * 0.75,
      phaseShift: progress * math.pi * 2,
      color: Colors.white.withValues(alpha: 0.04),
      wavelength: 1.2,
    );

    _drawWave(
      canvas,
      size,
      waveHeight: 20,
      yOffset: size.height * 0.5,
      phaseShift: progress * math.pi * 2 + math.pi / 3,
      color: Colors.white.withValues(alpha: 0.03),
      wavelength: 1.5,
    );

    _drawWave(
      canvas,
      size,
      waveHeight: 15,
      yOffset: size.height * 0.3,
      phaseShift: progress * math.pi * 2 + math.pi / 2,
      color: Colors.white.withValues(alpha: 0.02),
      wavelength: 1.8,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double waveHeight,
    required double yOffset,
    required double phaseShift,
    required Color color,
    required double wavelength,
  }) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 2) {
      final relativeX = x / size.width;
      final y = yOffset +
          math.sin((relativeX * math.pi * 2 * wavelength) + phaseShift) *
              waveHeight +
          math.sin((relativeX * math.pi * 4 * wavelength) + phaseShift * 1.5) *
              (waveHeight * 0.3);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
