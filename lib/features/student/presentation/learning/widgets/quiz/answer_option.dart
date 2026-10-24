import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/theme/theme.dart';

/// Option đáp án với hiệu ứng xúc giác (Tactile feedback) và đổ bóng nổi
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isMultipleChoice = false,
  });

  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMultipleChoice;

  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap();
  }

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
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  shape: isMultipleChoice ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isMultipleChoice
                      ? BorderRadius.circular(10)
                      : null,
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
                    height: 1.35,
                  ),
                ),
              ),
              AppSpacing.hGap8,
              if (isSelected)
                Icon(
                  isMultipleChoice
                      ? Icons.check_box_rounded
                      : Icons.check_circle_rounded,
                  color: cs.primary,
                  size: 22,
                )
              else
                Icon(
                  isMultipleChoice
                      ? Icons.check_box_outline_blank_rounded
                      : Icons.radio_button_unchecked_rounded,
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

