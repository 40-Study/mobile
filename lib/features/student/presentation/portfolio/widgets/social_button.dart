import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.type});

  final String type;

  IconData get _icon {
    switch (type) {
      case 'dribbble':
        return Icons.sports_basketball;
      case 'behance':
        return Icons.brush;
      case 'linkedin':
        return Icons.business_center;
      case 'github':
        return Icons.code;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Icon(_icon, size: 18, color: cs.onSurface),
    );
  }
}
