import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({
    super.key,
    required this.performance,
    this.onTap,
  });

  final ChildPerformanceModel performance;
  final VoidCallback? onTap;

  Color _scoreColor(double score, double maxScore) {
    final percentage = score / maxScore;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scoreColor = _scoreColor(performance.score, performance.maxScore);
    final percentage = (performance.score / performance.maxScore * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Score indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: scoreColor.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  performance.score.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performance.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (performance.className != null) ...[
                        Icon(
                          Icons.class_outlined,
                          size: 14,
                          color: cs.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          performance.className!,
                          style: TextStyle(
                            color: cs.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: cs.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        performance.date,
                        style: TextStyle(
                          color: cs.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress percentage
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
