import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Splash màn hình loading với dot-matrix logo animation.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoAssembleController;
  late AnimationController _cardController;
  late AnimationController _footerController;

  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _footerOpacity;
  late Animation<double> _footerOffset;

  @override
  void initState() {
    super.initState();

    // Logo dots assemble animation - longer duration for visible stagger
    _logoAssembleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Card fade-in / scale animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    // Footer fade-in + slide animation
    _footerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _footerController, curve: Curves.easeOut),
    );
    _footerOffset = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _footerController, curve: Curves.easeOutCubic),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Start card animation
    _cardController.forward();

    // Start logo assemble with slight delay
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoAssembleController.forward();

    // Start footer animation after logo is mostly assembled
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _footerController.forward();
  }

  @override
  void dispose() {
    _logoAssembleController.dispose();
    _cardController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo card with dot-matrix X
              AnimatedBuilder(
                animation: _cardController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardOpacity.value,
                    child: Transform.scale(
                      scale: _cardScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 48,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _logoAssembleController,
                      builder: (context, _) {
                        return _AnimatedDotMatrixLogo(
                          size: 88,
                          progress: _logoAssembleController.value,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Loading dots indicator
              _SplashLoadingDots(color: colorScheme.primary),

              const Spacer(flex: 3),

              // Footer
              AnimatedBuilder(
                animation: _footerController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _footerOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _footerOffset.value),
                      child: child,
                    ),
                  );
                },
                child: _SplashFooter(colorScheme: colorScheme),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated dot-matrix logo with staggered dot assembly
class _AnimatedDotMatrixLogo extends StatelessWidget {
  const _AnimatedDotMatrixLogo({required this.size, required this.progress});

  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DotMatrixLogoPainter(color: Colors.black, progress: progress),
    );
  }
}

/// Logo X từ logo.svg - 45 circles với fly-in animation
/// Extracted từ assets/rive/logo.svg (updated version)
class _DotMatrixLogoPainter extends CustomPainter {
  _DotMatrixLogoPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  // 45 circles extracted from updated logo.svg
  static const List<_SplashDotData> _dots = [
    // ===== LARGE DOTS (core X shape) =====
    _SplashDotData(x: 0.08, y: 0.02, size: 1.00),     // CENTER
    _SplashDotData(x: 0.25, y: 0.21, size: 0.78),     // upper-right
    _SplashDotData(x: -0.11, y: 0.20, size: 0.80),    // upper-left
    _SplashDotData(x: 0.24, y: -0.17, size: 0.78),    // lower-right
    _SplashDotData(x: -0.12, y: -0.14, size: 0.76),   // lower-left

    // ===== MEDIUM DOTS (arms) =====
    _SplashDotData(x: -0.27, y: 0.01, size: 0.62),
    _SplashDotData(x: -0.27, y: 0.40, size: 0.62),
    _SplashDotData(x: -0.28, y: -0.33, size: 0.60),
    _SplashDotData(x: 0.38, y: 0.01, size: 0.62),
    _SplashDotData(x: 0.42, y: 0.38, size: 0.62),
    _SplashDotData(x: 0.41, y: -0.34, size: 0.60),
    _SplashDotData(x: 0.06, y: 0.36, size: 0.60),
    _SplashDotData(x: 0.04, y: -0.33, size: 0.62),

    // ===== SMALL DOTS (outer arms) =====
    _SplashDotData(x: 0.53, y: -0.17, size: 0.46),
    _SplashDotData(x: -0.40, y: -0.16, size: 0.46),
    _SplashDotData(x: 0.52, y: 0.23, size: 0.46),
    _SplashDotData(x: -0.44, y: -0.50, size: 0.46),
    _SplashDotData(x: -0.40, y: 0.24, size: 0.46),
    _SplashDotData(x: 0.57, y: 0.56, size: 0.46),
    _SplashDotData(x: 0.26, y: 0.53, size: 0.46),
    _SplashDotData(x: -0.13, y: 0.52, size: 0.46),
    _SplashDotData(x: -0.44, y: 0.57, size: 0.46),
    _SplashDotData(x: 0.56, y: -0.51, size: 0.46),
    _SplashDotData(x: 0.25, y: -0.47, size: 0.46),
    _SplashDotData(x: -0.14, y: -0.46, size: 0.46),

    // ===== TINY DOTS (scattered edges) =====
    _SplashDotData(x: -0.54, y: -0.32, size: 0.30),
    _SplashDotData(x: -0.53, y: 0.39, size: 0.30),
    _SplashDotData(x: 0.64, y: 0.37, size: 0.30),
    _SplashDotData(x: -0.27, y: 0.65, size: 0.30),
    _SplashDotData(x: -0.58, y: -0.65, size: 0.28),
    _SplashDotData(x: -0.28, y: -0.59, size: 0.28),
    _SplashDotData(x: 0.63, y: -0.33, size: 0.30),
    _SplashDotData(x: 0.71, y: 0.69, size: 0.28),
    _SplashDotData(x: 0.40, y: 0.66, size: 0.30),
    _SplashDotData(x: -0.56, y: 0.72, size: 0.28),
    _SplashDotData(x: 0.38, y: -0.61, size: 0.28),
    _SplashDotData(x: 0.69, y: -0.65, size: 0.28),

    // ===== VERY TINY DOTS (fading edges) =====
    _SplashDotData(x: 0.74, y: 0.51, size: 0.22),
    _SplashDotData(x: -0.39, y: 0.77, size: 0.22),
    _SplashDotData(x: 0.73, y: -0.46, size: 0.22),
    _SplashDotData(x: -0.64, y: -0.44, size: 0.22),
    _SplashDotData(x: -0.63, y: 0.52, size: 0.22),
    _SplashDotData(x: 0.51, y: 0.76, size: 0.22),
    _SplashDotData(x: 0.49, y: -0.71, size: 0.18),
    _SplashDotData(x: -0.41, y: -0.70, size: 0.18),
  ];

  // Pre-computed fly-in angles (golden angle distribution)
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
    // Scale to fit: positions range roughly -0.8 to 0.8
    final scale = size.width * 0.58;
    // Max radius for size=1.0 dot
    final maxRadius = size.width * 0.09;

    for (var i = 0; i < _dots.length; i++) {
      final dot = _dots[i];
      final dotProgress = _getDotProgress(i, dot);
      if (dotProgress <= 0) continue;

      final endOffset = center + Offset(dot.x * scale, -dot.y * scale);

      // Start position: fly in from outside
      final flyAngle = _flyInAngles[i % _flyInAngles.length];
      final flyDistance = size.width * 1.2;
      final startOffset = center + Offset(
        math.cos(flyAngle) * flyDistance,
        math.sin(flyAngle) * flyDistance,
      );

      // Apply easeOutBack for bouncy landing
      final curvedProgress = Curves.easeOutBack.transform(dotProgress);
      final currentOffset = Offset.lerp(startOffset, endOffset, curvedProgress)!;

      // Radius grows with easeOutCubic
      final radiusProgress = Curves.easeOutCubic.transform(dotProgress);
      final radius = maxRadius * dot.size * radiusProgress;

      // Opacity fades in quickly
      final opacity = Curves.easeOut.transform((dotProgress * 2).clamp(0.0, 1.0));
      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(currentOffset, radius, paint);
    }
  }

  double _getDotProgress(int index, _SplashDotData dot) {
    if (progress >= 1.0) return 1.0;
    if (progress <= 0.0) return 0.0;

    final distFromCenter = math.sqrt(dot.x * dot.x + dot.y * dot.y);
    // Max distance is ~0.9, normalize to 0-1
    final normalizedDist = (distFromCenter / 0.9).clamp(0.0, 1.0);

    // Center dots arrive FIRST, outer dots arrive LATER
    final staggerDelay = normalizedDist * 0.6;
    final animationWindow = 0.4;
    final dotProgress = ((progress - staggerDelay) / animationWindow).clamp(0.0, 1.0);

    return dotProgress;
  }

  @override
  bool shouldRepaint(_DotMatrixLogoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _SplashDotData {
  const _SplashDotData({required this.x, required this.y, required this.size});
  final double x;
  final double y;
  final double size;
}

/// Loading indicator: 4 dots with gradient colors
class _SplashLoadingDots extends StatefulWidget {
  const _SplashLoadingDots({required this.color});

  final Color color;

  @override
  State<_SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<_SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            // Calculate opacity based on animation progress
            final offset = index * 0.15;
            final t = (_controller.value + offset) % 1.0;
            final opacity = 0.3 + 0.7 * math.sin(t * math.pi);

            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

/// Footer with tagline and decorative elements
class _SplashFooter extends StatelessWidget {
  const _SplashFooter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main tagline
        Text(
          'ELEVATING EDUCATION',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        // Decorative line with dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            ...List.generate(3, (i) {
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              );
            }),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
          ],
        ),
      ],
    );
  }
}
