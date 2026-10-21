import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/theme/theme.dart';

class CourseStatusBadge extends StatelessWidget {
  const CourseStatusBadge({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (status) {
      'published' => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        Icons.check_circle_outline,
      ),
      'rejected' => (
        cs.errorContainer,
        cs.onErrorContainer,
        Icons.error_outline,
      ),
      'pending_review' => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        Icons.schedule_outlined,
      ),
      'archived' => (
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
        Icons.archive_outlined,
      ),
      _ => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        Icons.edit_note_outlined,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderFull,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            AppSpacing.hGap4,
            Flexible(
              child: Text(
                teacherCourseStatus(status),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
