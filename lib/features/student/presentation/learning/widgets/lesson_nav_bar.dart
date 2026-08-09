import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class LessonNavBar extends StatelessWidget {
  const LessonNavBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    required this.isCompleted,
    this.onPrev,
    this.onNext,
    this.onComplete,
  });

  final int currentIndex;
  final int totalLessons;
  final bool isCompleted;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < totalLessons - 1;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev button
          IconButton.outlined(
            onPressed: hasPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left),
          ),
          AppSpacing.hGap12,

          // Progress indicator
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bai ${currentIndex + 1}/$totalLessons',
                  style: tt.labelMedium?.copyWith(color: cs.outline),
                ),
                AppSpacing.vGap4,
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / totalLessons,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cs.primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGap12,

          // Next or Complete button
          if (hasNext)
            IconButton.outlined(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            )
          else
            FilledButton.icon(
              onPressed: isCompleted ? null : onComplete,
              icon: Icon(isCompleted ? Icons.check : Icons.done_all, size: 18),
              label: Text(isCompleted ? 'Da xong' : 'Hoan thanh'),
            ),
        ],
      ),
    );
  }
}
