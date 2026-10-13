import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Option đáp án với animation
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? cs.primary.withValues(alpha: 0.15)
        : const Color(0xFFEFF6FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[index % _labels.length],
                  style: tt.labelLarge?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Text(
                  text,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 22)
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
