import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_item.dart';
import 'package:study/theme/theme.dart';

class SectionItem extends StatelessWidget {
  const SectionItem({
    super.key,
    required this.section,
    required this.isExpanded,
    required this.completedCount,
    this.onToggle,
    this.onLessonTap,
  });

  final SectionModel section;
  final bool isExpanded;
  final int completedCount;
  final VoidCallback? onToggle;
  final void Function(LessonModel lesson)? onLessonTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lessons = section.lessons ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Section header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          '$completedCount/${lessons.length} bai',
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ],
                    ),
                  ),
                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: completedCount == lessons.length
                          ? Colors.green.withValues(alpha: 0.1)
                          : cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      completedCount == lessons.length ? 'Xong' : 'Dang hoc',
                      style: tt.labelSmall?.copyWith(
                        color: completedCount == lessons.length
                            ? Colors.green
                            : cs.primary,
                      ),
                    ),
                  ),
                  AppSpacing.hGap8,
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.outline,
                  ),
                ],
              ),
            ),
          ),
          // Lessons list
          if (isExpanded && lessons.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: lessons.map((lesson) {
                  final status = _getLessonStatus(lesson, lessons);
                  return LessonItem(
                    lesson: lesson,
                    status: status,
                    onTap: () => onLessonTap?.call(lesson),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  LessonStatus _getLessonStatus(LessonModel lesson, List<LessonModel> lessons) {
    final progress = lesson.progress;
    if (progress?.status == 'completed') return LessonStatus.completed;

    // Check if any progress exists
    if (progress?.progressPercentage != null && progress!.progressPercentage > 0) {
      return LessonStatus.current;
    }

    // Check if previous lessons completed
    final index = lessons.indexOf(lesson);
    if (index == 0) return LessonStatus.current;

    final prevLesson = lessons[index - 1];
    if (prevLesson.progress?.status == 'completed') {
      return LessonStatus.current;
    }

    return LessonStatus.locked;
  }
}
