import 'package:flutter/material.dart';

/// Layered mountain silhouettes for depth effect
class MountainPainter extends CustomPainter {
  MountainPainter({
    required this.colors,
    this.heightFactor = 0.25,
    this.layerCount = 3,
  });

  final List<Color> colors; // Colors from back to front
  final double heightFactor;
  final int layerCount;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height;
    final maxHeight = size.height * heightFactor;

    // Draw layers from back to front
    for (var layer = 0; layer < layerCount && layer < colors.length; layer++) {
      final layerHeight = maxHeight * (0.5 + (layer / layerCount) * 0.5);
      final yOffset = (layerCount - 1 - layer) * maxHeight * 0.08;

      _paintLayer(
        canvas,
        size,
        baseY - yOffset,
        layerHeight,
        colors[layer],
        layer,
      );
    }
  }

  void _paintLayer(
    Canvas canvas,
    Size size,
    double baseY,
    double maxHeight,
    Color color,
    int layerIndex,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Different peak patterns for each layer
    final peaks = _getPeaksForLayer(layerIndex);

    for (final peak in peaks) {
      final x = size.width * peak.x;
      final y = baseY - maxHeight * peak.heightRatio;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  List<_Peak> _getPeaksForLayer(int layer) {
    return switch (layer) {
      0 => const [
          // Back layer - distant mountains (smoother, lower)
          _Peak(0.0, 0.2),
          _Peak(0.1, 0.45),
          _Peak(0.2, 0.35),
          _Peak(0.35, 0.6),
          _Peak(0.5, 0.4),
          _Peak(0.65, 0.55),
          _Peak(0.8, 0.38),
          _Peak(0.9, 0.5),
          _Peak(1.0, 0.25),
        ],
      1 => const [
          // Middle layer
          _Peak(0.0, 0.15),
          _Peak(0.12, 0.5),
          _Peak(0.25, 0.3),
          _Peak(0.4, 0.7),
          _Peak(0.55, 0.4),
          _Peak(0.7, 0.65),
          _Peak(0.85, 0.35),
          _Peak(1.0, 0.2),
        ],
      _ => const [
          // Front layer - closer mountains (sharper, higher)
          _Peak(0.0, 0.1),
          _Peak(0.08, 0.4),
          _Peak(0.18, 0.25),
          _Peak(0.28, 0.75),
          _Peak(0.42, 0.35),
          _Peak(0.52, 0.85),
          _Peak(0.65, 0.45),
          _Peak(0.78, 0.7),
          _Peak(0.88, 0.3),
          _Peak(1.0, 0.15),
        ],
    };
  }

  @override
  bool shouldRepaint(MountainPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.heightFactor != heightFactor;
  }
}

class _Peak {
  const _Peak(this.x, this.heightRatio);
  final double x;
  final double heightRatio;
}
