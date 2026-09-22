import 'package:flutter/material.dart';

/// Page 3: Community Network - "Join the Community"
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
          // Connection lines (behind nodes)
          CustomPaint(
            size: const Size(300, 280),
            painter: _ConnectionLinesPainter(
              lineColor: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),

          // Center node - people group
          _CommunityNode(
            size: 72,
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            child: Icon(Icons.groups, size: 32, color: colorScheme.primary),
          ),

          // Top - Expert Mentors badge
          Positioned(
            top: 20,
            child: _PillBadge(text: 'EXPERT MENTORS', color: colorScheme.primary),
          ),

          // Top-left - Graduation cap
          Positioned(
            left: 40,
            top: 70,
            child: _CommunityNode(
              size: 48,
              color: colorScheme.secondaryContainer,
              child: Icon(Icons.school, size: 22, color: colorScheme.secondary),
            ),
          ),

          // Top-right - Brain/gear
          Positioned(
            right: 30,
            top: 80,
            child: _CommunityNode(
              size: 48,
              color: colorScheme.primaryContainer,
              child: Icon(Icons.psychology, size: 22, color: colorScheme.primary),
            ),
          ),

          // Bottom-left - Avatar
          Positioned(
            left: 30,
            bottom: 70,
            child: _CommunityNode(
              size: 52,
              color: colorScheme.tertiaryContainer,
              child: Icon(Icons.person, size: 26, color: colorScheme.tertiary),
            ),
          ),

          // Bottom-left badge
          Positioned(
            left: 10,
            bottom: 50,
            child: _PillBadge(text: 'ACTIVE LEARNERS', color: colorScheme.primary),
          ),

          // Bottom-right - Star badge
          Positioned(
            right: 50,
            bottom: 90,
            child: _CommunityNode(
              size: 44,
              color: colorScheme.primaryContainer,
              child: Icon(Icons.workspace_premium, size: 20, color: colorScheme.primary),
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
    final nodePositions = [
      const Offset(60, 94),
      Offset(size.width - 54, 104),
      Offset(56, size.height - 94),
      Offset(size.width - 74, size.height - 114),
    ];

    for (final pos in nodePositions) {
      canvas.drawLine(center, pos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
