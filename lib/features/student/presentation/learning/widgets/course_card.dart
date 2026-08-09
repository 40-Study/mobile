import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/theme.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.enrollment, this.onTap});

  final EnrollmentModel enrollment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final progressLabel = enrollment.progressPercentage.toStringAsFixed(0);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  image: course?.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(course!.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: course?.thumbnailUrl == null
                    ? Icon(
                        Icons.auto_stories_outlined,
                        color: cs.onPrimaryContainer,
                        size: 30,
                      )
                    : null,
              ),
              AppSpacing.hGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.title ?? 'Khóa học',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course?.instructorName != null) ...[
                      AppSpacing.vGap4,
                      Text(
                        course!.instructorName!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppSpacing.vGap8,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${enrollment.completedLessons}/'
                            '${enrollment.totalLessons} bài',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          '$progressLabel%',
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
