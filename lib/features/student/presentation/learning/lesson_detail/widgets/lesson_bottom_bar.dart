import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Bottom navigation bar cho lesson detail
class LessonBottomBar extends StatelessWidget {
  const LessonBottomBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentIndex;
  final int totalLessons;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  bool get hasPrev => currentIndex > 0;
  bool get hasNext => currentIndex < totalLessons - 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          // Prev button
          Expanded(
            child: InkWell(
              onTap: hasPrev ? onPrevious : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left_rounded, size: 20, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bai truoc', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text(
                            hasPrev ? 'Gioi thieu khoa hoc' : '--',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.hGap12,

          // Progress
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentIndex + 1}/$totalLessons',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
              ),
              Text('Bai hoc', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          AppSpacing.hGap12,

          // Next button
          Expanded(
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasNext ? 'Bai tiep theo' : 'Hoan thanh',
                          style: tt.labelMedium?.copyWith(color: cs.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    hasNext ? Icons.chevron_right_rounded : Icons.check_rounded,
                    size: 20,
                    color: cs.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
