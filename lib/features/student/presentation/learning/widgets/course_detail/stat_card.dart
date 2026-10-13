import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            AppSpacing.vGap4,
            Text(
              value,
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.slate900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: cs.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
