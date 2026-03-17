import 'package:flutter/material.dart';

/// Auth header matching web: icon circle + title + subtitle on surface bg.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        if (showBackButton)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        if (icon != null) ...[
          const SizedBox(height: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: cs.primary),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
