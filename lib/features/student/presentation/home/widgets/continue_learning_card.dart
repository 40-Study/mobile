import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/theme.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.enrollment,
    this.onContinueTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback? onContinueTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final progressLabel = enrollment.progressPercentage.toStringAsFixed(0);
    final course = enrollment.course;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onContinueTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'Tiếp tục học',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.vGap12,
                LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = constraints.maxWidth < 340 ? 88.0 : 108.0;

                    return Row(
                      children: [
                        _CourseCover(size: imageSize),
                        AppSpacing.hGap16,
                        Expanded(
                          child: SizedBox(
                            height: imageSize,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        course?.title ?? 'Khóa học của bạn',
                                        style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    AppSpacing.hGap8,
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 19,
                                        color: cs.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.vGap4,
                                Text(
                                  'Bài ${enrollment.completedLessons + 1} • '
                                  '${course?.instructorName ?? "40Study"}',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor:
                                              cs.surfaceContainerHighest,
                                        ),
                                      ),
                                    ),
                                    AppSpacing.hGap12,
                                    Text(
                                      '$progressLabel%',
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCover extends StatelessWidget {
  const _CourseCover({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/python-course-cover.png',
              fit: BoxFit.cover,
            ),
            Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.sm,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 19,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
