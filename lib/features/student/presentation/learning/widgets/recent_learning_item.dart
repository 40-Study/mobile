import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/theme.dart';

class RecentLearningItem extends StatelessWidget {
  const RecentLearningItem({
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final course = enrollment.course;
    final isCompleted =
        enrollment.progressPercentage >= 100 || enrollment.completedAt != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFECFDF5)
                          : cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded,
                      color: isCompleted
                          ? const Color(0xFF059669)
                          : cs.primary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hGap12,

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course?.title ?? 'Khóa học',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${course?.categoryName ?? "Khóa học"} • '
                          '${course?.instructorName ?? "Giảng viên"}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.slate500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,

                  // Status/time
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Đã hoàn thành',
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${enrollment.completedLessons}/${enrollment.totalLessons} bài',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  AppSpacing.hGap8,

                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.slate400,
                    size: 20,
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
