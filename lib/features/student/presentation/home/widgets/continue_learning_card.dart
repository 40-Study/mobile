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

  static String _getInstructorInitial(String? name) {
    if (name == null || name.trim().isEmpty) return '4';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.last.isNotEmpty ? words.last[0].toUpperCase() : 'T';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final progressLabel = enrollment.progressPercentage.toStringAsFixed(0);
    final course = enrollment.course;
    final instructorName = course?.instructorName ?? '40Study';

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
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onContinueTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag TIẾP TỤC HỌC thanh lịch góc trên bên trái
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'TIẾP TỤC HỌC',
                    style: tt.labelSmall?.copyWith(
                      color: cs.blue600,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                AppSpacing.vGap12,
                LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = constraints.maxWidth < 340 ? 80.0 : 88.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _CourseCover(
                          size: imageSize,
                          imageUrl: course?.thumbnailUrl,
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                course?.title ?? 'Khóa học của bạn',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.slate900,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vGap4,
                              // Thông tin bài học & Giảng viên kèm avatar mini
                              Row(
                                children: [
                                  Text(
                                    'Bài ${enrollment.completedLessons + 1} • ',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.slate500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInstructorInitial(instructorName),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: cs.blue600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      instructorName,
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.slate600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vGap8,
                              // Thanh tiến độ & phần trăm
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 5,
                                        backgroundColor:
                                            const Color(0xFFEFF6FF),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          cs.blue600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppSpacing.hGap8,
                                  Text(
                                    '$progressLabel%',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.blue600,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hGap12,
                        // Nút tròn xanh CTA mũi tên (Affordance)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
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
  const _CourseCover({required this.size, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PlaceholderCover(cs: cs),
              )
            else
              _PlaceholderCover(cs: cs),
            Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.sm,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 20,
                  color: cs.blue600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: Icon(
        Icons.menu_book_rounded,
        size: 28,
        color: cs.blue600,
      ),
    );
  }
}
