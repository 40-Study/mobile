import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class VisibilityOption extends StatelessWidget {
  const VisibilityOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(
          icon,
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: tt.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? cs.primary : cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(Icons.circle_outlined, color: cs.outlineVariant),
    );
  }
}
