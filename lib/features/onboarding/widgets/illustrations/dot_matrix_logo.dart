import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Logo X từ logo.svg - animated với fly-in effect
class DotMatrixLogo extends StatelessWidget {
  const DotMatrixLogo({
    super.key,
    this.size = 80,
    this.dotColor,
    this.animated = false,
    this.animationProgress = 1.0,
  });

  final double size;
  final Color? dotColor;
  final bool animated;
  final double animationProgress;

  @override
  Widget build(BuildContext context) {
    final color = dotColor ?? Theme.of(context).colorScheme.onSurface;

    return CustomPaint(
      size: Size(size, size),
      painter: _SvgLogoXPainter(
        color: color,
        progress: animated ? animationProgress : 1.0,
      ),
    );
  }
}

/// Logo X từ logo.svg - 45 circles với fly-in animation
class _SvgLogoXPainter extends CustomPainter {
  _SvgLogoXPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  // 45 circles extracted from logo.svg
  // Positions normalized: center (108,101.5) → (0,0), scale by 107
  static const List<_DotData> _dots = [
    // CENTER - largest
    _DotData(x: 0.08, y: 0.02, size: 1.00),
    // Inner diagonals
    _DotData(x: 0.25, y: 0.21, size: 0.78),
    _DotData(x: -0.11, y: 0.20, size: 0.80),
    _DotData(x: 0.24, y: -0.17, size: 0.78),
    _DotData(x: -0.12, y: -0.14, size: 0.76),
    // Left arm
    _DotData(x: -0.27, y: 0.01, size: 0.62),
    _DotData(x: -0.27, y: 0.40, size: 0.62),
    _DotData(x: -0.28, y: -0.33, size: 0.60),
    // Right arm
    _DotData(x: 0.38, y: 0.01, size: 0.62),
    _DotData(x: 0.42, y: 0.38, size: 0.62),
    _DotData(x: 0.41, y: -0.34, size: 0.60),
    // Top/Bottom center
    _DotData(x: 0.06, y: 0.36, size: 0.60),
    _DotData(x: 0.04, y: -0.33, size: 0.62),
    // Outer corners
    _DotData(x: 0.53, y: -0.17, size: 0.46),
    _DotData(x: -0.40, y: -0.16, size: 0.46),
    _DotData(x: 0.52, y: 0.23, size: 0.46),
    _DotData(x: -0.44, y: -0.50, size: 0.46),
    _DotData(x: -0.40, y: 0.24, size: 0.46),
    // Far diagonals
    _DotData(x: 0.57, y: 0.56, size: 0.46),
    _DotData(x: 0.26, y: 0.53, size: 0.46),
    _DotData(x: -0.13, y: 0.52, size: 0.46),
    _DotData(x: -0.44, y: 0.57, size: 0.46),
    _DotData(x: 0.56, y: -0.51, size: 0.46),
    _DotData(x: 0.25, y: -0.47, size: 0.46),
    _DotData(x: -0.14, y: -0.46, size: 0.46),
    // Tiny dots
    _DotData(x: -0.54, y: -0.32, size: 0.30),
    _DotData(x: -0.53, y: 0.39, size: 0.30),
    _DotData(x: 0.64, y: 0.37, size: 0.30),
    _DotData(x: -0.27, y: 0.65, size: 0.30),
    _DotData(x: -0.58, y: -0.65, size: 0.28),
    _DotData(x: -0.28, y: -0.59, size: 0.28),
    _DotData(x: 0.63, y: -0.33, size: 0.30),
    _DotData(x: 0.71, y: 0.69, size: 0.28),
    _DotData(x: 0.40, y: 0.66, size: 0.30),
    _DotData(x: -0.56, y: 0.72, size: 0.28),
    _DotData(x: 0.38, y: -0.61, size: 0.28),
    _DotData(x: 0.69, y: -0.65, size: 0.28),
    // Very tiny dots
    _DotData(x: 0.74, y: 0.51, size: 0.22),
    _DotData(x: -0.39, y: 0.77, size: 0.22),
    _DotData(x: 0.73, y: -0.46, size: 0.22),
    _DotData(x: -0.64, y: -0.44, size: 0.22),
    _DotData(x: -0.63, y: 0.52, size: 0.22),
    _DotData(x: 0.51, y: 0.76, size: 0.22),
    _DotData(x: 0.49, y: -0.71, size: 0.18),
    _DotData(x: -0.41, y: -0.70, size: 0.18),
  ];

  // Golden angle distribution for fly-in
  static final List<double> _flyInAngles = List.generate(
    50,
    (i) => (i * 137.5 % 360) * 3.14159 / 180,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width * 0.58;
    final maxRadius = size.width * 0.09;

    for (var i = 0; i < _dots.length; i++) {
      final dot = _dots[i];
      final dotProgress = _getDotProgress(i);
      if (dotProgress <= 0) continue;

      final endOffset = center + Offset(dot.x * scale, -dot.y * scale);
      final flyAngle = _flyInAngles[i % _flyInAngles.length];
      final flyDistance = size.width * 1.2;
      final startOffset = center +
          Offset(
            math.cos(flyAngle) * flyDistance,
            math.sin(flyAngle) * flyDistance,
          );

      final curvedProgress = Curves.easeOutBack.transform(dotProgress);
      final currentOffset = Offset.lerp(startOffset, endOffset, curvedProgress)!;
      final radiusProgress = Curves.easeOutCubic.transform(dotProgress);
      final radius = maxRadius * dot.size * radiusProgress;
      final opacity = Curves.easeOut.transform((dotProgress * 2).clamp(0.0, 1.0));
      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(currentOffset, radius, paint);
    }
  }

  double _getDotProgress(int index) {
    if (progress >= 1.0) return 1.0;
    if (progress <= 0.0) return 0.0;

    final dot = _dots[index];
    final distFromCenter = math.sqrt(dot.x * dot.x + dot.y * dot.y);
    final normalizedDist = (distFromCenter / 0.9).clamp(0.0, 1.0);
    final staggerDelay = normalizedDist * 0.6;
    const animationWindow = 0.4;
    return ((progress - staggerDelay) / animationWindow).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(_SvgLogoXPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _DotData {
  const _DotData({required this.x, required this.y, required this.size});
  final double x;
  final double y;
  final double size;
}
