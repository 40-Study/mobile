import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/screens/course_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.enrollment,
    required this.index,
  });

  final EnrollmentModel enrollment;
  final int index;

  Color _progressColor(ColorScheme cs) {
    if (enrollment.progress >= 70) return cs.primary;
    if (enrollment.progress >= 40) return cs.secondary;
    return cs.primary;
  }

  Color _progressBgColor(ColorScheme cs) {
    return cs.primaryContainer.withValues(alpha: 0.4);
  }

  Color _cardBg(ColorScheme cs) {
    if (enrollment.isCompleted) {
      return cs.surfaceContainerHigh;
    }
    if (enrollment.isPending) {
      return cs.surfaceTintedPrimary;
    }
    return cs.surfaceContainerLowest;
  }

  double get _contentOpacity {
    if (enrollment.isCompleted) return 0.55;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progressColor = _progressColor(cs);
    final isCompleted = enrollment.isCompleted;
    final isPending = enrollment.isPending;
    final textColor = isCompleted
        ? cs.onSurface.withValues(alpha: 0.5)
        : cs.onSurface;
    final subColor = isCompleted
        ? cs.onSurfaceVariant.withValues(alpha: 0.45)
        : cs.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg(cs),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(
            alpha: isCompleted ? 0.1 : 0.15,
          ),
        ),
        boxShadow: isCompleted ? null : cs.shadowCard,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderLg,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => CourseDetailCubit(
                    enrollmentId: enrollment.id,
                    courseId: enrollment.courseId,
                  ),
                  child: CourseDetailScreen(
                    enrollmentId: enrollment.id,
                    courseId: enrollment.courseId,
                    courseTitle: enrollment.courseName ?? '',
                  ),
                ),
              ),
            );
          },
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: AppLayout.cardPadding,
            child: Opacity(
              opacity: _contentOpacity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseThumbnail(
                    enrollment: enrollment,
                    index: index,
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                enrollment.courseName ?? 'Khoa hoc',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            MoreButton(cs: cs),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: AppIconSize.xs,
                              color: subColor,
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                enrollment.instructorName ?? '',
                                style: tt.bodySmall?.copyWith(
                                  color: subColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        ProgressSection(
                          enrollment: enrollment,
                          progressColor: progressColor,
                          progressBgColor: _progressBgColor(cs),
                        ),
                        if (isPending) ...[
                          SizedBox(height: AppSpacing.sm),
                          PendingBadge(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PendingBadge extends StatelessWidget {
  const PendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderXs,
        border: Border.all(
          color: cs.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: AppIconSize.xs,
            color: cs.tertiary,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            'Doi khai giang',
            style: tt.labelSmall?.copyWith(
              color: cs.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.enrollment,
    required this.index,
  });

  final EnrollmentModel enrollment;
  final int index;

  static const _thumbnailGradients = [
    [Color(0xFF1a1a2e), Color(0xFF16213e)],
    [Color(0xFF0f3460), Color(0xFF533483)],
    [Color(0xFF2d3436), Color(0xFF636e72)],
    [Color(0xFF2c3e50), Color(0xFF3498db)],
    [Color(0xFF1B1B2F), Color(0xFF162447)],
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = _thumbnailGradients[index % _thumbnailGradients.length];

    if (enrollment.courseThumbnail != null &&
        enrollment.courseThumbnail!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: Image.network(
          enrollment.courseThumbnail!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderThumbnail(cs, colors),
        ),
      );
    }

    return _placeholderThumbnail(cs, colors);
  }

  Widget _placeholderThumbnail(ColorScheme cs, List<Color> colors) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderMd,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          enrollment.isCompleted
              ? Icons.check_circle_outline_rounded
              : enrollment.isPending
                  ? Icons.hourglass_top_rounded
                  : Icons.play_circle_outline_rounded,
          size: AppIconSize.xxl,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class MoreButton extends StatelessWidget {
  const MoreButton({super.key, required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppIconSize.lg,
      height: AppIconSize.lg,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: AppIconSize.sm,
        icon: Icon(
          Icons.more_horiz_rounded,
          color: cs.onSurfaceVariant,
        ),
        onPressed: () {
          // TODO: Show course options
        },
      ),
    );
  }
}

class ProgressSection extends StatelessWidget {
  const ProgressSection({
    super.key,
    required this.enrollment,
    required this.progressColor,
    required this.progressBgColor,
  });

  final EnrollmentModel enrollment;
  final Color progressColor;
  final Color progressBgColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (enrollment.isCompleted) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          borderRadius: AppRadius.borderXs,
        ),
      );
    }

    if (enrollment.isPending) {
      return Row(
        children: [
          Text(
            '0/${enrollment.totalLessons} Bai hoc',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            'Chua bat dau',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderXs,
              ),
              child: Text(
                '${enrollment.progress}% Hoan thanh',
                style: tt.labelSmall?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${enrollment.completedLessons}/${enrollment.totalLessons}'
              ' Bai hoc',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.borderXs,
          child: LinearProgressIndicator(
            value: enrollment.progress / 100,
            backgroundColor: progressBgColor,
            color: progressColor,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
