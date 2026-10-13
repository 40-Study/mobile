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
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev button
          Expanded(
            child: Opacity(
              opacity: hasPrev ? 1.0 : 0.45,
              child: InkWell(
                onTap: hasPrev ? onPrevious : null,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: cs.slate600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bài trước',
                              style: tt.labelSmall?.copyWith(
                                color: cs.slate500,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              hasPrev ? 'Bài học trước' : 'Đầu khóa',
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.slate800,
                              ),
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
          ),
          AppSpacing.hGap12,

          // Progress
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentIndex + 1}/$totalLessons',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.blue600,
                ),
              ),
              Text(
                'Bài học',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          AppSpacing.hGap12,

          // Next button
          Expanded(
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: cs.blue600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      hasNext ? 'Bài tiếp theo' : 'Hoàn thành',
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    hasNext ? Icons.chevron_right_rounded : Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
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
