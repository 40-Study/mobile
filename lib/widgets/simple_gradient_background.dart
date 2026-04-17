import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Together AI Pastel Cloud Background
///
/// Soft pastel gradients with gentle floating shapes and visible animations.
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
              ? const [
                  Color(0xFF010120),
                  Color(0xFF0A0A35),
                  Color(0xFF010120),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFFDF4F9),
                  Color(0xFFF5F0FF),
                  Color(0xFFEEF5FF),
                ],
          stops: isDark ? null : const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Aurora waves
          const Positioned.fill(child: _AuroraWavesLayer()),
          // Animated clouds
          const Positioned.fill(child: _PastelCloudsLayer()),
          // Floating bubbles
          const Positioned.fill(child: _FloatingBubblesLayer()),
          // Soft glowing orbs
          const Positioned.fill(child: _GlowingOrbsLayer()),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Soft aurora wave effect
class _AuroraWavesLayer extends StatefulWidget {
  const _AuroraWavesLayer();

  @override
  State<_AuroraWavesLayer> createState() => _AuroraWavesLayerState();
}

class _AuroraWavesLayerState extends State<_AuroraWavesLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
          painter: _AuroraPainter(
            progress: _controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _AuroraPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    // Wave 1 - Top
    path1.moveTo(0, size.height * 0.15);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.15 +
          math.sin((x / size.width) * math.pi * 2 + progress * math.pi * 2) * 40 +
          math.sin((x / size.width) * math.pi * 4 + progress * math.pi * 3) * 20;
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    // Wave 2 - Middle
    path2.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.5 +
          math.sin((x / size.width) * math.pi * 3 + progress * math.pi * 2 + 1) * 50 +
          math.cos((x / size.width) * math.pi * 2 + progress * math.pi * 2.5) * 25;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height * 0.3);
    path2.lineTo(0, size.height * 0.3);
    path2.close();

    // Wave 3 - Bottom
    path3.moveTo(0, size.height * 0.85);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.85 +
          math.sin((x / size.width) * math.pi * 2.5 + progress * math.pi * 2 + 2) * 35 +
          math.sin((x / size.width) * math.pi * 5 + progress * math.pi * 3) * 15;
      path3.lineTo(x, y);
    }
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    // Draw waves
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF6366F1).withValues(alpha: 0.12),
                const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              ]
            : [
                const Color(0xFFFCE7F3).withValues(alpha: 0.6),
                const Color(0xFFFCE7F3).withValues(alpha: 0.2),
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFFEC4899).withValues(alpha: 0.08),
                const Color(0xFF8B5CF6).withValues(alpha: 0.03),
              ]
            : [
                const Color(0xFFE0E7FF).withValues(alpha: 0.55),
                const Color(0xFFE0E7FF).withValues(alpha: 0.18),
              ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4));

    final paint3 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF3B82F6).withValues(alpha: 0.1),
                const Color(0xFF6366F1).withValues(alpha: 0.04),
              ]
            : [
                const Color(0xFFDBEAFE).withValues(alpha: 0.6),
                const Color(0xFFDBEAFE).withValues(alpha: 0.25),
              ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Animated pastel clouds
class _PastelCloudsLayer extends StatefulWidget {
  const _PastelCloudsLayer();

  @override
  State<_PastelCloudsLayer> createState() => _PastelCloudsLayerState();
}

class _PastelCloudsLayerState extends State<_PastelCloudsLayer>
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
          painter: _PastelCloudsPainter(
            progress: _controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelCloudsPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _PastelCloudsPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _paintDarkClouds(canvas, size);
    } else {
      _paintPastelClouds(canvas, size);
    }
  }

  void _paintPastelClouds(Canvas canvas, Size size) {
    final breathe1 = 1.0 + math.sin(progress * math.pi * 2) * 0.18;
    final breathe2 = 1.0 + math.sin(progress * math.pi * 2 + 1) * 0.15;

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.82 + math.sin(progress * math.pi * 2) * 45,
        size.height * 0.1 + math.cos(progress * math.pi * 2) * 25,
      ),
      radius: size.width * 0.35 * breathe1,
      color: const Color(0xFFFCE7F3).withValues(alpha: 0.7),
    );

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.08 + math.cos(progress * math.pi * 2) * 35,
        size.height * 0.38 + math.sin(progress * math.pi * 2 + 0.5) * 40,
      ),
      radius: size.width * 0.4 * breathe2,
      color: const Color(0xFFEDE9FE).withValues(alpha: 0.65),
    );

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.88 + math.cos(progress * math.pi * 2 + 1) * 30,
        size.height * 0.72 + math.sin(progress * math.pi * 2 + 1) * 35,
      ),
      radius: size.width * 0.32 * breathe1,
      color: const Color(0xFFDBEAFE).withValues(alpha: 0.7),
    );

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.12 + math.sin(progress * math.pi * 2 + 3) * 35,
        size.height * 0.85 + math.cos(progress * math.pi * 2 + 3) * 25,
      ),
      radius: size.width * 0.3 * breathe2,
      color: const Color(0xFFF3E8FF).withValues(alpha: 0.65),
    );
  }

  void _paintDarkClouds(Canvas canvas, Size size) {
    final breathe = 1.0 + math.sin(progress * math.pi * 2) * 0.12;

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.85 + math.sin(progress * math.pi * 2) * 25,
        size.height * 0.15 + math.cos(progress * math.pi * 2) * 18,
      ),
      radius: size.width * 0.35 * breathe,
      color: const Color(0xFFBDBBFF).withValues(alpha: 0.07),
    );

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.1 + math.cos(progress * math.pi * 2) * 22,
        size.height * 0.5 + math.sin(progress * math.pi * 2 + 1) * 25,
      ),
      radius: size.width * 0.38 * breathe,
      color: const Color(0xFFEF2CC1).withValues(alpha: 0.05),
    );

    _drawCloud(
      canvas,
      center: Offset(
        size.width * 0.7 + math.sin(progress * math.pi * 2 + 2) * 28,
        size.height * 0.85 + math.cos(progress * math.pi * 2 + 2) * 18,
      ),
      radius: size.width * 0.32 * breathe,
      color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
    );
  }

  void _drawCloud(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _PastelCloudsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// Floating bubbles
class _FloatingBubblesLayer extends StatefulWidget {
  const _FloatingBubblesLayer();

  @override
  State<_FloatingBubblesLayer> createState() => _FloatingBubblesLayerState();
}

class _FloatingBubblesLayerState extends State<_FloatingBubblesLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Bubble> _bubbles;
  final _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _bubbles = List.generate(15, (i) => _Bubble(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 6 + 3,
      speed: _random.nextDouble() * 0.35 + 0.15,
      opacity: _random.nextDouble() * 0.35 + 0.15,
      phase: _random.nextDouble() * math.pi * 2,
      wobbleAmount: _random.nextDouble() * 0.03 + 0.015,
    ));
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
          painter: _BubblesPainter(
            bubbles: _bubbles,
            progress: _controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Bubble {
  final double x, y, size, speed, opacity, phase, wobbleAmount;

  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.wobbleAmount,
  });
}

class _BubblesPainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;
  final bool isDark;

  _BubblesPainter({
    required this.bubbles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final yOffset = (progress * bubble.speed + bubble.y) % 1.0;
      final xWobble = math.sin(progress * math.pi * 4 + bubble.phase) * bubble.wobbleAmount;

      final x = (bubble.x + xWobble) * size.width;
      final y = (1.0 - yOffset) * size.height;

      final pulseOpacity = bubble.opacity *
          (0.6 + math.sin(progress * math.pi * 5 + bubble.phase) * 0.4);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            isDark
                ? const Color(0xFFBDBBFF).withValues(alpha: pulseOpacity * 0.7)
                : const Color(0xFFD4BFFF).withValues(alpha: pulseOpacity * 1.2),
            isDark
                ? const Color(0xFFBDBBFF).withValues(alpha: 0)
                : const Color(0xFFD4BFFF).withValues(alpha: 0),
          ],
          stops: const [0.2, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: bubble.size));

      canvas.drawCircle(Offset(x, y), bubble.size, paint);

      // Soft highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: pulseOpacity * 0.6);
      canvas.drawCircle(
        Offset(x - bubble.size * 0.25, y - bubble.size * 0.25),
        bubble.size * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Soft glowing orbs that pulse gently
class _GlowingOrbsLayer extends StatefulWidget {
  const _GlowingOrbsLayer();

  @override
  State<_GlowingOrbsLayer> createState() => _GlowingOrbsLayerState();
}

class _GlowingOrbsLayerState extends State<_GlowingOrbsLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Orb> _orbs;
  final _random = math.Random(88);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _orbs = List.generate(8, (i) => _Orb(
      x: _random.nextDouble() * 0.8 + 0.1,
      y: _random.nextDouble() * 0.8 + 0.1,
      size: _random.nextDouble() * 25 + 15,
      phase: _random.nextDouble() * math.pi * 2,
      pulseSpeed: _random.nextDouble() * 0.8 + 0.6,
      color: _getOrbColor(i),
    ));
  }

  Color _getOrbColor(int index) {
    const colors = [
      Color(0xFFFBCFE8), // pink
      Color(0xFFDDD6FE), // lavender
      Color(0xFFBFDBFE), // blue
      Color(0xFFA5F3FC), // cyan
      Color(0xFFFDE68A), // yellow
      Color(0xFFFBCFE8), // pink
      Color(0xFFDDD6FE), // lavender
      Color(0xFFBFDBFE), // blue
    ];
    return colors[index % colors.length];
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
          painter: _OrbsPainter(
            orbs: _orbs,
            progress: _controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Orb {
  final double x, y, size, phase, pulseSpeed;
  final Color color;

  _Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.pulseSpeed,
    required this.color,
  });
}

class _OrbsPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double progress;
  final bool isDark;

  _OrbsPainter({
    required this.orbs,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      // Smooth pulse: fade in and out
      final pulse = (math.sin(progress * math.pi * 2 * orb.pulseSpeed + orb.phase) + 1) / 2;

      // Gentle floating motion
      final floatX = math.sin(progress * math.pi * 2 + orb.phase) * 15;
      final floatY = math.cos(progress * math.pi * 2 + orb.phase * 0.7) * 12;

      final x = orb.x * size.width + floatX;
      final y = orb.y * size.height + floatY;

      final currentSize = orb.size * (0.8 + pulse * 0.4);
      final opacity = isDark ? pulse * 0.25 : pulse * 0.55;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withValues(alpha: opacity),
            orb.color.withValues(alpha: opacity * 0.6),
            orb.color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: currentSize));

      canvas.drawCircle(Offset(x, y), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
