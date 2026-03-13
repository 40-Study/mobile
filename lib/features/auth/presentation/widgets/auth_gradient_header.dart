import 'package:flutter/material.dart';

/// Header gradient cho các màn auth.
/// Hiển thị title + subtitle trên nền gradient primary -> secondary.
class AuthGradientHeader extends StatelessWidget {
  const AuthGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 260,
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final double height;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.secondary,
            cs.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            if (showBackButton)
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed:
                      onBack ?? () => Navigator.of(context).pop(),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white
                              .withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
