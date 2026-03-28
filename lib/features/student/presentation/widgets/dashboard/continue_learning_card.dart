import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.courseName,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    this.onTap,
  });

  final String courseName;
  final int progress;
  final int totalLessons;
  final int completedLessons;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderXxl,
        gradient: cs.gradientPrimary,
        boxShadow: cs.shadowPrimary,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.scrim.withValues(alpha: 0.35),
                    Colors.transparent,
                    cs.scrim.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bai $completedLessons/$totalLessons',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$progress% da hoan thanh',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.onPrimary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.scrim.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: cs.onPrimary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  courseName,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
