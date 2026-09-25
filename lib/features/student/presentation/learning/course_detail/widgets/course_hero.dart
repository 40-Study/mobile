import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/presentation/learning/widgets/thumbnail_placeholder.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class CourseHero extends StatelessWidget {
  const CourseHero({super.key, required this.state});

  final CourseDetailSuccess state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;
    final enrollment = state.enrollment;
    final isCompleted = enrollment.progressPercentage >= 100;
    final isActive = enrollment.progressPercentage > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 140,
                  height: 100,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 24),
              ),
            ],
          ),
          AppSpacing.hGap16,

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : isActive
                            ? cs.primary.withValues(alpha: 0.1)
                            : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    isCompleted
                        ? 'Hoàn thành'
                        : isActive
                            ? 'Đang học'
                            : 'Chưa bắt đầu',
                    style: tt.labelSmall?.copyWith(
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? cs.primary
                              : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.vGap8,
                Text(
                  course?.title ?? 'Khóa học',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap8,
                Row(
                  children: [
                    CachedAvatar(
                      url: course?.instructorAvatar,
                      radius: 12,
                      backgroundColor: cs.primaryContainer,
                      name: course?.instructorName ?? 'T',
                    ),
                    AppSpacing.hGap8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course?.instructorName ?? 'Giảng viên',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap8,
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      course?.averageRating.toStringAsFixed(1) ?? '0.0',
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ' (${_formatCount(course?.totalRatings ?? 0)})',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${_formatCount(course?.totalStudents ?? 0)} học viên',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
