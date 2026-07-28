import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/theme/theme.dart';

enum LessonStatus { completed, current, locked }

class LessonItem extends StatelessWidget {
  const LessonItem({
    super.key,
    required this.lesson,
    required this.status,
    this.onTap,
  });

  final LessonModel lesson;
  final LessonStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (icon, iconColor) = switch (status) {
      LessonStatus.completed => (Icons.check_circle, Colors.green),
      LessonStatus.current => (Icons.play_circle, cs.primary),
      LessonStatus.locked => (Icons.lock, cs.outline),
    };

    return InkWell(
      onTap: status != LessonStatus.locked ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: status == LessonStatus.locked
                          ? cs.outline
                          : cs.onSurface,
                    ),
                  ),
                  if (lesson.durationMinutes > 0)
                    Text(
                      '${lesson.durationMinutes} phut',
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                    ),
                ],
              ),
            ),
            if (status == LessonStatus.current)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dang hoc',
                  style: tt.labelSmall?.copyWith(color: cs.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
