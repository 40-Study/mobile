import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/data/models/recommended_course_item.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/theme/theme.dart';

class RecommendedCourseTile extends StatelessWidget {
  const RecommendedCourseTile({
    super.key,
    required this.item,
  });

  final RecommendedCourseItem item;

  void _onTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => diContainer<CourseDetailBloc>()
            ..add(CourseDetailStarted(item.course.id, isEnrollment: false)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = item.course;
    final hasImage =
        course.thumbnailUrl != null && course.thumbnailUrl!.trim().isNotEmpty;

    final (reasonIcon, reasonColor) = _resolveReasonStyle(item.matchType, cs);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: () => _onTap(context),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Reason Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: reasonColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: reasonColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(reasonIcon, size: 12, color: reasonColor),
                        const SizedBox(width: 4),
                        Text(
                          item.reason,
                          style: TextStyle(
                            color: reasonColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Main Course Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: hasImage
                              ? CachedNetworkImage(
                                  imageUrl: course.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) =>
                                      _buildFallbackThumbnail(cs),
                                  errorWidget: (_, _, _) =>
                                      _buildFallbackThumbnail(cs),
                                )
                              : _buildFallbackThumbnail(cs),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.slate900,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                if (course.averageRating > 0) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    course.averageRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: cs.slate800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    ' • ',
                                    style: TextStyle(color: cs.slate400),
                                  ),
                                ],
                                Expanded(
                                  child: Text(
                                    course.instructorName ?? 'ForteX Academy',
                                    style: TextStyle(
                                      color: cs.slate500,
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (course.totalLessons > 0) ...[
                                  Text(
                                    '${course.totalLessons} bài',
                                    style: TextStyle(
                                      color: cs.slate400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: cs.slate400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(ColorScheme cs) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        Icons.school_rounded,
        color: cs.primary,
        size: 24,
      ),
    );
  }

  (IconData, Color) _resolveReasonStyle(
    RecommendationMatchType type,
    ColorScheme cs,
  ) {
    return switch (type) {
      RecommendationMatchType.learningTrack => (
          Icons.auto_stories_rounded,
          cs.primary,
        ),
      RecommendationMatchType.searchHistory => (
          Icons.manage_search_rounded,
          const Color(0xFF6366F1),
        ),
      RecommendationMatchType.topRated => (
          Icons.workspace_premium_rounded,
          const Color(0xFFD97706),
        ),
      RecommendationMatchType.trending => (
          Icons.local_fire_department_rounded,
          const Color(0xFFEA580C),
        ),
    };
  }
}
