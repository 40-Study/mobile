import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/presentation/learning/widgets/thumbnail_placeholder.dart';
import 'package:study/theme/theme.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.enrollment,
    required this.onContinue,
  });

  final EnrollmentModel enrollment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Tiếp tục học',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đang học',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Card
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.soft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: 120,
                    height: 140,
                    child: course?.thumbnailUrl != null
                        ? Image.network(
                            course!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                ThumbnailPlaceholder(cs: cs),
                          )
                        : ThumbnailPlaceholder(cs: cs),
                  ),
                ),
                AppSpacing.hGap16,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        course?.categoryName ?? 'Khóa học',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        course?.title ?? 'Khóa học',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Lesson info
                      Text(
                        'Bài ${enrollment.completedLessons + 1} · '
                        '${course?.totalDurationMins ?? 0} phút',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vGap12,

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: cs.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          AppSpacing.hGap12,
                          Text(
                            '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap12,

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FilledButton.icon(
                                onPressed: onContinue,
                                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                label: const Text('Tiếp tục học'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hGap8,
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: cs.onSurfaceVariant,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MyCourseCard extends StatelessWidget {
  const MyCourseCard({
    super.key,
    required this.enrollment,
    required this.onTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 160,
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with progress badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: course?.thumbnailUrl != null
                          ? Image.network(
                              course!.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cs.primaryContainer,
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            )
                          : Container(
                              color: cs.primaryContainer,
                              child: Icon(
                                Icons.auto_stories_outlined,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                  // Progress badge
                  Positioned(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course?.title ?? 'Khóa học',
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap4,

                    // Instructor
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            (course?.instructorName ?? 'T')[0].toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        AppSpacing.hGap4,
                        Expanded(
                          child: Text(
                            course?.instructorName ?? 'Giảng viên',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap8,

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        AppSpacing.hGap8,
                        Text(
                          '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
