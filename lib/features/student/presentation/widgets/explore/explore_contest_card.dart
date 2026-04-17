import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_explore_data.dart';
import 'package:study/features/student/presentation/screens/contest_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class ExploreContestCard extends StatelessWidget {
  const ExploreContestCard({
    super.key,
    required this.contest,
  });
  final MockContest contest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContestDetailScreen(
            title: contest.title,
            participants: contest.participants,
            deadline: contest.deadline,
            icon: contest.icon,
            iconBg: contest.iconBg,
            iconColor: contest.iconColor,
          ),
        ),
      ),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: cs.outline),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: contest.iconBg,
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(contest.icon,
                  size: AppIconSize.xl,
                  color: contest.iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    contest.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: AppIconSize.xs,
                          color: cs.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          contest.participants,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.schedule_rounded,
                          size: AppIconSize.xs,
                          color: cs.error),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          contest.deadline,
                          style: tt.labelSmall?.copyWith(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: AppRadius.borderXxl,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary
                        .withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Tham gia',
                style: tt.labelMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
