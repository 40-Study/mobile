import 'package:cached_network_image/cached_network_image.dart';
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

  static String _getInstructorInitial(String? name) {
    if (name == null || name.trim().isEmpty) return 'T';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.last.isNotEmpty ? words.last[0].toUpperCase() : 'T';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final isCompleted = enrollment.progressPercentage >= 100;

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
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.08)
                    : cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check_rounded, size: 14, color: Colors.green)
                  else
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
                    isCompleted ? 'Hoàn thành' : 'Đang học',
                    style: tt.labelSmall?.copyWith(
                      color: isCompleted ? Colors.green : cs.primary,
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
                        ? CachedNetworkImage(
                            imageUrl: course!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => ThumbnailPlaceholder(cs: cs),
                            errorWidget: (_, _, _) => ThumbnailPlaceholder(cs: cs),
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

                      // Lesson info & Giảng viên
                      Row(
                        children: [
                          Text(
                            'Bài ${enrollment.completedLessons + 1} · '
                            '${course?.totalDurationMins ?? 0} phút',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInstructorInitial(course?.instructorName),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cs.blue600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course?.instructorName ?? 'Giảng viên',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap12,

                      // Progress bar or completed text
                      if (isCompleted)
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 18, color: Colors.green),
                            AppSpacing.hGap8,
                            Text(
                              'Đã hoàn thành khóa học',
                              style: tt.labelMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else ...[
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
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
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
                                  icon: const Icon(Icons.play_arrow_rounded,
                                      size: 18),
                                  label: const Text('Tiếp tục học'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AppSpacing.hGap8,
                            Container(
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLowest,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.5),
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

  static String _getInstructorInitial(String? name) {
    if (name == null || name.trim().isEmpty) return 'T';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.last.isNotEmpty ? words.last[0].toUpperCase() : 'T';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final isCompleted = enrollment.progressPercentage >= 100;

    return Container(
      width: 172,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with badge
              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: course?.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: course!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: const Color(0xFFEFF6FF),
                              child: Icon(
                                Icons.school_rounded,
                                color: cs.blue600,
                                size: 28,
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: const Color(0xFFEFF6FF),
                              child: Icon(
                                Icons.school_rounded,
                                color: cs.blue600,
                                size: 28,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFEFF6FF),
                            child: Icon(
                              Icons.school_rounded,
                              color: cs.blue600,
                              size: 28,
                            ),
                          ),
                  ),
                  // Badge góc trên bên trái
                  Positioned(
                    left: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFECFDF5)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: isCompleted
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 11,
                                  color: Color(0xFF059669),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Hoàn thành',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '${enrollment.progressPercentage.toStringAsFixed(0)}'
                              '%',
                              style: TextStyle(
                                color: cs.blue600,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        course?.title ?? 'Khóa học',
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Instructor
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInstructorInitial(course?.instructorName),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cs.blue600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course?.instructorName ?? 'Giảng viên',
                              style: tt.bodySmall?.copyWith(
                                color: cs.slate600,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Progress bar or completed text
                      if (isCompleted)
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đã hoàn tất',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFEFF6FF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.blue600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
