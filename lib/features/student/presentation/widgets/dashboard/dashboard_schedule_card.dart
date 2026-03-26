import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class DashboardScheduleCard extends StatelessWidget {
  const DashboardScheduleCard({
    super.key,
    required this.label,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.location,
    this.isUpcoming = false,
    this.isLive = false,
    this.onTap,
  });

  final String label;
  final String time;
  final String title;
  final String subtitle;
  final String location;
  final bool isUpcoming;
  final bool isLive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: isUpcoming
              ? cs.surfaceTintedPrimary
              : cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXl,
          border: isUpcoming
              ? Border.all(
                  color: cs.primary.withValues(alpha: 0.25),
                  width: 1.5,
                )
              : Border.all(color: cs.outline.withValues(alpha: 0.5)),
          boxShadow: isUpcoming ? cs.shadowPrimary : cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: tt.labelSmall?.copyWith(
                            color: isUpcoming
                                ? cs.primary
                                : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $time',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onError,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isUpcoming ? cs.gradientPrimary : null,
                color: isUpcoming
                    ? null
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isUpcoming
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isUpcoming ? Icons.videocam_rounded : Icons.more_horiz,
                color: isUpcoming ? cs.onPrimary : cs.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
