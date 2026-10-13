import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/theme.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.enrollment, this.onTap});

  final EnrollmentModel enrollment;
  final VoidCallback? onTap;

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
    final progressLabel = enrollment.progressPercentage.toStringAsFixed(0);
    final isCompleted = enrollment.progressPercentage >= 100;
    final progressColor = isCompleted ? const Color(0xFF059669) : cs.blue600;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    image: course?.thumbnailUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              course!.thumbnailUrl!,
                            ),
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
                          color: cs.slate900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap4,
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInstructorInitial(course?.instructorName),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cs.blue600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              course?.instructorName ?? 'Giảng viên',
                              style: tt.bodySmall?.copyWith(
                                color: cs.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap8,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${enrollment.completedLessons}/'
                              '${enrollment.totalLessons} bài',
                              style: tt.bodySmall?.copyWith(
                                color: cs.slate500,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text(
                                'Hoàn thành',
                                style: TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Text(
                              '$progressLabel%',
                              style: tt.labelSmall?.copyWith(
                                color: cs.blue600,
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
                          backgroundColor:
                              cs.outlineVariant.withValues(alpha: 0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right_rounded, color: cs.slate400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
