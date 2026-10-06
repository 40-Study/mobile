import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class PortfolioSectionHeader extends StatelessWidget {
  const PortfolioSectionHeader({
    super.key,
    required this.title,
    required this.visible,
    required this.isEditMode,
    required this.onToggleVisibility,
  });

  final String title;
  final bool visible;
  final bool isEditMode;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          if (isEditMode) ...[
            Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
            AppSpacing.hGap8,
          ],
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: visible ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (isEditMode) ...[
            Switch.adaptive(
              value: visible,
              onChanged: (_) => onToggleVisibility(),
              activeColor: cs.primary,
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            AppSpacing.hGap4,
            Icon(Icons.more_horiz, size: 20, color: cs.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}
