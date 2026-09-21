import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ModeToggleButton extends StatelessWidget {
  const ModeToggleButton({
    super.key,
    required this.isEditMode,
    required this.onToggle,
  });

  final bool isEditMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEditMode ? cs.primary.withValues(alpha: 0.1) : cs.surface,
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isEditMode ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditMode ? Icons.edit_outlined : Icons.visibility_outlined,
              size: 16,
              color: isEditMode ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              isEditMode ? l10n.editPortfolio : l10n.previewPortfolio,
              style: tt.labelMedium?.copyWith(
                color: isEditMode ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
