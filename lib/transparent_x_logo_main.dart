// Run: flutter run --flavor dev -t lib/transparent_x_logo_main.dart
//
// Abstract "X" from black circles on a fully transparent background.
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _XLogoApp());
}

class _XLogoApp extends StatelessWidget {
  const _XLogoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TransparentXLogo(size: 220),
              const SizedBox(height: 24),
              Text(
                'Logo area is transparent (no fill in painter).',
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Black circles only — background is transparent ([RepaintBoundary] friendly).
class TransparentXLogo extends StatelessWidget {
  const TransparentXLogo({super.key, this.size = 200});

  final double size;

  static const _black = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: TransparentXLogoPainter(circleColor: _black)),
    );
  }
}

/// Draws an X along two diagonals; symmetric under reflection across y = ±x.
class TransparentXLogoPainter extends CustomPainter {
  TransparentXLogoPainter({required this.circleColor});

  final Color circleColor;

  static const double _sqrt2 = 1.4142135623730951;

  /// Precomputed (nx, ny, radiusNorm) in normalized space [-1,1]².
  static final List<(double, double, double)> _circles = _buildCircles();

  /// Four diagonal unit directions from center (NE, NW, SW, SE).
  static List<Offset> get _diagonalDirs => const [
    Offset(1, 1),
    Offset(-1, 1),
    Offset(-1, -1),
    Offset(1, -1),
  ];

  static List<(double, double, double)> _buildCircles() {
    // Organic spacing along each diagonal arm (not a uniform grid).
    const distances = <double>[0.14, 0.23, 0.31, 0.38, 0.46, 0.55, 0.64];
    const sizes = <double>[0.085, 0.072, 0.062, 0.052, 0.042, 0.032, 0.022];

    return [
      (0, 0, 0.11),
      for (var i = 0; i < distances.length; i++)
        for (final dir in _diagonalDirs) ...[
          _armDot(dir, distances[i], sizes[i]),
          if (i > 0 && i < distances.length - 1)
            ..._wobblePair(dir, distances[i], sizes[i]),
        ],
    ];
  }

  static (double, double, double) _armDot(Offset dir, double d, double r) {
    final ux = dir.dx / _sqrt2;
    final uy = dir.dy / _sqrt2;
    return (ux * d, uy * d, r);
  }

  static List<(double, double, double)> _wobblePair(
    Offset dir,
    double d,
    double r,
  ) {
    final ux = dir.dx / _sqrt2;
    final uy = dir.dy / _sqrt2;
    final px = -uy;
    final py = ux;
    const wobble = 0.05;
    final s = r * 0.45;
    return [
      (ux * d + px * wobble, uy * d + py * wobble, s),
      (ux * d - px * wobble, uy * d - py * wobble, s),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally no background — transparent.

    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = size.shortestSide / 2;

    final paint = Paint()
      ..color = circleColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (final (nx, ny, nr) in _circles) {
      final ox = cx + nx * half;
      final oy = cy - ny * half;
      canvas.drawCircle(Offset(ox, oy), nr * half, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TransparentXLogoPainter oldDelegate) =>
      oldDelegate.circleColor != circleColor;
}
