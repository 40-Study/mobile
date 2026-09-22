import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/presentation/learning/widgets/section/section_widgets.dart';
import 'package:study/theme/theme.dart';

class LessonPreviewItem extends StatelessWidget {
  const LessonPreviewItem({
    super.key,
    required this.index,
    required this.lesson,
    required this.onTap,
    this.isLocked = false,
  });

  final int index;
  final LessonModel lesson;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = lesson.progress?.status == 'completed';
    final isInProgress = lesson.progress?.status == 'in_progress';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isInProgress
                ? cs.primary.withValues(alpha: 0.05)
                : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isInProgress
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              LessonStatusIcon(isCompleted: isCompleted, isInProgress: isInProgress, isLocked: isLocked),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${lesson.title}',
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${lesson.durationMinutes}:00',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _buildStatusLabel(tt, cs, isCompleted, isInProgress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(TextTheme tt, ColorScheme cs, bool isCompleted, bool isInProgress) {
    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hoàn thành', style: tt.labelSmall?.copyWith(color: cs.primary)),
          Icon(Icons.chevron_right_rounded, size: 16, color: cs.primary),
        ],
      );
    }
    if (isInProgress) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Đang học', style: tt.labelSmall?.copyWith(color: cs.primary)),
          Icon(Icons.chevron_right_rounded, size: 16, color: cs.primary),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Chưa mở khóa', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
      ],
    );
  }
}
