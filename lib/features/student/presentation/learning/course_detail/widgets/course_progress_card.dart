import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CourseProgressCard extends StatelessWidget {
  const CourseProgressCard({
    super.key,
    required this.state,
    required this.onContinue,
    required this.onViewCertificate,
  });

  final CourseDetailSuccess state;
  final VoidCallback onContinue;
  final VoidCallback onViewCertificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;
    final enrollment = state.enrollment;
    final course = state.course;
    final isEnrolled = enrollment.id.isNotEmpty && enrollment.status != 'preview';

    // Non-enrolled: show enroll card
    if (!isEnrolled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, const Color(0xFF2A48A5)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.isFree == true ? l10n.freeCourse : '${course?.price.toStringAsFixed(0) ?? 0}đ',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${l10n.lessonCount(course?.totalLessons ?? 0)} • ${l10n.minuteCount(course?.totalDurationMins ?? 0)}',
                      style: tt.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.enrollmentDeveloping)),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(
                  l10n.enrollNow,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final isCompleted = enrollment.progressPercentage >= 100;

    // Completed: show celebratory banner with certificate button
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFF059669),
                  size: 22,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chúc mừng! Khóa học đã hoàn thành',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    Text(
                      'Bạn có thể xem và tải chứng chỉ của mình',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              FilledButton(
                onPressed: onViewCertificate,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: Text(
                  l10n.viewCertificateButton,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // In progress
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          l10n.progress,
                          style: tt.labelMedium?.copyWith(
                            color: cs.slate600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap8,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          cs.outlineVariant.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                    l10n.lessonsCompleted(
                      enrollment.completedLessons,
                      enrollment.totalLessons,
                    ),
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap16,
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    l10n.continueLearning,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
