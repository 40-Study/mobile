import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class CourseHeroHeader extends StatelessWidget {
  const CourseHeroHeader({
    super.key,
    required this.detail,
    this.onContinue,
  });
  final CourseDetailModel detail;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e),
                cs.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              if (detail.badge != null)
                Positioned(
                  left: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: AppRadius.borderXs,
                    ),
                    child: Text(
                      detail.badge!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                child: ProgressRing(
                  progress: detail.progress,
                  size: 56,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                bottom: AppSpacing.massive,
                right: AppSpacing.lg,
                child: Text(
                  'Tien do hoc tap',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Text(
            'Ban da hoan thanh ${detail.completedLessons}'
            '/${detail.totalLessons} bai hoc',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Text(
            detail.title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: cs.gradientPrimary,
                borderRadius: AppRadius.borderMd,
                boxShadow: cs.shadowPrimary,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.borderMd,
                child: InkWell(
                  onTap: onContinue,
                  borderRadius: AppRadius.borderMd,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_filled_rounded,
                            color: cs.onPrimary, size: AppIconSize.lg),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Tiep tuc hoc',
                          style: tt.titleSmall?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 56});
  final int progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: size - 12,
            height: size - 12,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$progress%',
              style: tt.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
