import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/theme.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.enrollment,
    this.onTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: course?.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(course!.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: course?.thumbnailUrl == null
                    ? Icon(Icons.school, color: cs.primary, size: 32)
                    : null,
              ),
              AppSpacing.hGap16,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.title ?? 'Khoa hoc',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${enrollment.completedLessons}/${enrollment.totalLessons} bai • ${enrollment.progressPercentage.toStringAsFixed(0)}%',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    AppSpacing.vGap8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: cs.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
