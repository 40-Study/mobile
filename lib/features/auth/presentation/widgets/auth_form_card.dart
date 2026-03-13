import 'package:flutter/material.dart';

/// Card trắng bo tròn góc trên, chồng lên gradient header.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.child,
    this.overlap = 40,
  });

  final Widget child;

  /// Khoảng card chồng lên header.
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Transform.translate(
      offset: Offset(0, -overlap),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
