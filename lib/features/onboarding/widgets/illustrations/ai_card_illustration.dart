import 'package:flutter/material.dart';

import 'dot_matrix_logo.dart';

/// Page 1: AI Card - "Master Any Skill"
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
          _ConcentricCircles(color: colorScheme.outline.withValues(alpha: 0.15)),

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
                  // Dot decoration
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
