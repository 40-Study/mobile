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
              colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(l10n.enrollNow),
              ),
            ],
          ),
        ),
      );
    }

    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final isCompleted = enrollment.progressPercentage >= 100;

    // Completed: just show certificate button
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: FilledButton(
          onPressed: onViewCertificate,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 18),
              const SizedBox(width: 4),
              Text(l10n.viewCertificateButton),
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
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(l10n.progress, style: tt.labelMedium)),
                      const SizedBox(width: 4),
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
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    l10n.lessonsCompleted(enrollment.completedLessons, enrollment.totalLessons),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap16,
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 18),
                  const SizedBox(width: 4),
                  Text(l10n.continueLearning),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
