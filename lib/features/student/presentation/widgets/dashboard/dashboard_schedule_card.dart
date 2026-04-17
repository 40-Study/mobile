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
                          style: tt.labelMedium?.copyWith(
                            color: isUpcoming
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '• $time',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onError,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
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
