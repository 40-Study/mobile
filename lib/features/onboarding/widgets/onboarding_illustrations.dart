import 'dart:math' as math;
import 'package:flutter/material.dart';

// =============================================================================
// SHARED: Dot-Matrix Logo Widget (reusable for splash & onboarding)
// =============================================================================

/// Logo X từ logo.svg - animated với fly-in effect
/// Dựa trên 13 circles trong file assets/rive/logo.svg
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
/// Extracted từ assets/rive/logo.svg (updated version)
class _SvgLogoXPainter extends CustomPainter {
  _SvgLogoXPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  // 45 circles extracted from updated logo.svg
  // Positions normalized: center (108,101.5) → (0,0), scale by 107
  // Y inverted (SVG Y down → our Y up)
  static const List<_DotData> _dots = [
    // ===== LARGE DOTS (core X shape) =====
    // CENTER - largest
    _DotData(x: 0.08, y: 0.02, size: 1.00),

    // Inner diagonals (4 large dots)
    _DotData(x: 0.25, y: 0.21, size: 0.78),   // upper-right
    _DotData(x: -0.11, y: 0.20, size: 0.80),  // upper-left
    _DotData(x: 0.24, y: -0.17, size: 0.78),  // lower-right
    _DotData(x: -0.12, y: -0.14, size: 0.76),  // lower-left

    // ===== MEDIUM DOTS (arms) =====
    // Left arm
    _DotData(x: -0.27, y: 0.01, size: 0.62),  // left-center
    _DotData(x: -0.27, y: 0.40, size: 0.62),  // top-left
    _DotData(x: -0.28, y: -0.33, size: 0.60), // bottom-left

    // Right arm
    _DotData(x: 0.38, y: 0.01, size: 0.62),   // right-center
    _DotData(x: 0.42, y: 0.38, size: 0.62),   // top-right
    _DotData(x: 0.41, y: -0.34, size: 0.60),  // bottom-right

    // Top/Bottom center
    _DotData(x: 0.06, y: 0.36, size: 0.60),   // top-center
    _DotData(x: 0.04, y: -0.33, size: 0.62),  // bottom-center

    // ===== SMALL DOTS (outer arms) =====
    // Outer corners
    _DotData(x: 0.53, y: -0.17, size: 0.46),  // right-upper outer
    _DotData(x: -0.40, y: -0.16, size: 0.46), // left-upper outer
    _DotData(x: 0.52, y: 0.23, size: 0.46),   // right-lower outer
    _DotData(x: -0.44, y: -0.50, size: 0.46), // left far bottom
    _DotData(x: -0.40, y: 0.24, size: 0.46),  // left-lower outer

    // Far diagonals
    _DotData(x: 0.57, y: 0.56, size: 0.46),   // top-right far
    _DotData(x: 0.26, y: 0.53, size: 0.46),   // top-center-right
    _DotData(x: -0.13, y: 0.52, size: 0.46),  // top-center-left
    _DotData(x: -0.44, y: 0.57, size: 0.46),  // top-left far
    _DotData(x: 0.56, y: -0.51, size: 0.46),  // bottom-right far
    _DotData(x: 0.25, y: -0.47, size: 0.46),  // bottom-center-right
    _DotData(x: -0.14, y: -0.46, size: 0.46), // bottom-center-left

    // ===== TINY DOTS (scattered edges) =====
    _DotData(x: -0.54, y: -0.32, size: 0.30), // left edge
    _DotData(x: -0.53, y: 0.39, size: 0.30),  // left edge upper
    _DotData(x: 0.64, y: 0.37, size: 0.30),   // right edge upper
    _DotData(x: -0.27, y: 0.65, size: 0.30),  // top far left
    _DotData(x: -0.58, y: -0.65, size: 0.28), // far corner
    _DotData(x: -0.28, y: -0.59, size: 0.28), // bottom far left
    _DotData(x: 0.63, y: -0.33, size: 0.30),  // right edge lower
    _DotData(x: 0.71, y: 0.69, size: 0.28),   // far top-right
    _DotData(x: 0.40, y: 0.66, size: 0.30),   // top-right
    _DotData(x: -0.56, y: 0.72, size: 0.28),  // far top-left
    _DotData(x: 0.38, y: -0.61, size: 0.28),  // bottom-right
    _DotData(x: 0.69, y: -0.65, size: 0.28),  // far bottom-right

    // ===== VERY TINY DOTS (fading edges) =====
    _DotData(x: 0.74, y: 0.51, size: 0.22),   // far right
    _DotData(x: -0.39, y: 0.77, size: 0.22),  // far top
    _DotData(x: 0.73, y: -0.46, size: 0.22),  // far right lower
    _DotData(x: -0.64, y: -0.44, size: 0.22), // far left lower
    _DotData(x: -0.63, y: 0.52, size: 0.22),  // far left upper
    _DotData(x: 0.51, y: 0.76, size: 0.22),   // far top right
    _DotData(x: 0.49, y: -0.71, size: 0.18),  // very far bottom
    _DotData(x: -0.41, y: -0.70, size: 0.18), // very far bottom left
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
      final dotProgress = _getDotProgress(i);
      if (dotProgress <= 0) continue;

      final endOffset = center + Offset(dot.x * scale, -dot.y * scale);

      // Start position: fly in from outside along dot's direction
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

  double _getDotProgress(int index) {
    if (progress >= 1.0) return 1.0;
    if (progress <= 0.0) return 0.0;

    final dot = _dots[index];
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
  bool shouldRepaint(_SvgLogoXPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _DotData {
  const _DotData({required this.x, required this.y, required this.size});
  final double x;
  final double y;
  final double size;
}

// =============================================================================
// PAGE 1: AI Card Illustration - "Master Any Skill"
// =============================================================================

class AiCardIllustration extends StatelessWidget {
  const AiCardIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryBlue = colorScheme.primary;

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background concentric circles
          _ConcentricCircles(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),

          // Main blue card (tilted)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.15)
              ..rotateY(0.2)
              ..rotateZ(-0.05),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // White inner card with logo
                  Positioned(
                    left: 24,
                    top: 32,
                    right: 24,
                    bottom: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: DotMatrixLogo(size: 60)),
                    ),
                  ),
                  // Dot decoration bottom right
                  Positioned(
                    right: 20,
                    bottom: 16,
                    child: _DotGrid(
                      rows: 2,
                      cols: 3,
                      dotSize: 4,
                      spacing: 6,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // AI Engine badge
          Positioned(right: 20, top: 40, child: _AiBadge(color: primaryBlue)),
        ],
      ),
    );
  }
}

class _ConcentricCircles extends StatelessWidget {
  const _ConcentricCircles({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: _ConcentricCirclesPainter(color: color),
    );
  }
}

class _ConcentricCirclesPainter extends CustomPainter {
  _ConcentricCirclesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, 40.0 * i + 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined, size: 18, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI ENGINE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotGrid extends StatelessWidget {
  const _DotGrid({
    required this.rows,
    required this.cols,
    required this.dotSize,
    required this.spacing,
    required this.color,
  });

  final int rows;
  final int cols;
  final double dotSize;
  final double spacing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(cols, (col) {
            return Container(
              width: dotSize,
              height: dotSize,
              margin: EdgeInsets.all(spacing / 2),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );
          }),
        );
      }),
    );
  }
}

// =============================================================================
// PAGE 2: Code Editor Illustration - "Learn by Doing"
// =============================================================================

class CodeEditorIllustration extends StatelessWidget {
  const CodeEditorIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryBlue = colorScheme.primary;

    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background faded card
          Positioned(
            top: 0,
            child: Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _WindowDot(color: Colors.grey[300]!),
                    const SizedBox(width: 6),
                    _WindowDot(color: Colors.grey[300]!),
                    const SizedBox(width: 6),
                    _WindowDot(color: Colors.grey[300]!),
                  ],
                ),
              ),
            ),
          ),

          // Terminal side card
          Positioned(
            left: 0,
            top: 60,
            child: Container(
              width: 56,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 20, color: primaryBlue),
                  const SizedBox(height: 12),
                  // Colored lines
                  _ColoredLine(color: primaryBlue, width: 32),
                  const SizedBox(height: 6),
                  _ColoredLine(color: colorScheme.tertiary, width: 28),
                  const SizedBox(height: 6),
                  _ColoredLine(color: colorScheme.secondary, width: 24),
                ],
              ),
            ),
          ),

          // Main code editor card
          Positioned(
            right: 0,
            top: 40,
            child: Container(
              width: 220,
              height: 180,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Window dots + lightning
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _WindowDot(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            _WindowDot(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            _WindowDot(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.bolt,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Code lines
                    _CodeLine(width: 60, opacity: 0.6),
                    const SizedBox(height: 8),
                    _CodeLine(width: 140, opacity: 0.4),
                    const SizedBox(height: 8),
                    _CodeLine(width: 100, opacity: 0.4),
                    const SizedBox(height: 8),
                    _CodeLine(width: 120, opacity: 0.4),
                    const Spacer(),
                    // Run button
                    Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ColoredLine extends StatelessWidget {
  const _ColoredLine({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({required this.width, required this.opacity});

  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PAGE 3: Community Network Illustration - "Join the Community"
// =============================================================================

class CommunityIllustration extends StatelessWidget {
  const CommunityIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 300,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connection lines (painted first, behind nodes)
          CustomPaint(
            size: const Size(300, 280),
            painter: _ConnectionLinesPainter(
              lineColor: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),

          // Center node - people group
          Positioned(
            child: _CommunityNode(
              size: 72,
              color: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: Icon(Icons.groups, size: 32, color: colorScheme.primary),
            ),
          ),

          // Top - Expert Mentors badge
          Positioned(
            top: 20,
            child: _PillBadge(
              text: 'EXPERT MENTORS',
              color: colorScheme.primary,
            ),
          ),

          // Top-left - Graduation cap
          Positioned(
            left: 40,
            top: 70,
            child: _CommunityNode(
              size: 48,
              color: colorScheme.secondaryContainer,
              child: Icon(
                Icons.school,
                size: 22,
                color: colorScheme.secondary,
              ),
            ),
          ),

          // Top-right - Brain/gear
          Positioned(
            right: 30,
            top: 80,
            child: _CommunityNode(
              size: 48,
              color: colorScheme.primaryContainer,
              child: Icon(
                Icons.psychology,
                size: 22,
                color: colorScheme.primary,
              ),
            ),
          ),

          // Bottom-left - Avatar
          Positioned(
            left: 30,
            bottom: 70,
            child: _CommunityNode(
              size: 52,
              color: colorScheme.tertiaryContainer,
              child: Icon(
                Icons.person,
                size: 26,
                color: colorScheme.tertiary,
              ),
            ),
          ),

          // Bottom-left badge
          Positioned(
            left: 10,
            bottom: 50,
            child: _PillBadge(
              text: 'ACTIVE LEARNERS',
              color: colorScheme.primary,
            ),
          ),

          // Bottom-right - Star badge
          Positioned(
            right: 50,
            bottom: 90,
            child: _CommunityNode(
              size: 44,
              color: colorScheme.primaryContainer,
              child: Icon(
                Icons.workspace_premium,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityNode extends StatelessWidget {
  const _CommunityNode({
    required this.size,
    required this.color,
    required this.child,
    this.shadowColor,
  });

  final double size;
  final Color color;
  final Widget child;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shadowColor != null
            ? [
                BoxShadow(
                  color: shadowColor!,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ConnectionLinesPainter extends CustomPainter {
  _ConnectionLinesPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Lines from center to each node
    final nodePositions = [
      Offset(60, 94), // top-left
      Offset(size.width - 54, 104), // top-right
      Offset(56, size.height - 94), // bottom-left
      Offset(size.width - 74, size.height - 114), // bottom-right
    ];

    for (final pos in nodePositions) {
      canvas.drawLine(center, pos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
