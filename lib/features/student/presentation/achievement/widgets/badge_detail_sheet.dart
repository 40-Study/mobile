import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/achievement/all_achievements_screen.dart';
import 'package:study/features/student/presentation/achievement/widgets/badge_card.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({super.key, required this.badge});

  final AchievementBadgeData badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isLocked = badge.status == BadgeStatus.locked;
    final isInProgress = badge.status == BadgeStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap24,
          HexagonBadge(
            icon: badge.icon,
            color: isLocked ? cs.outlineVariant : badge.color,
            isLocked: isLocked,
            isInProgress: isInProgress,
          ),
          AppSpacing.vGap16,
          Text(badge.title,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          AppSpacing.vGap8,
          Text(badge.description,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
          AppSpacing.vGap16,
          if (badge.status == BadgeStatus.earned && badge.earnedAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                  '${l10n.earned}: ${badge.earnedAt!.day}/${badge.earnedAt!.month}/${badge.earnedAt!.year}',
                  style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
          if (isInProgress) ...[
            AppSpacing.vGap8,
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: badge.progressPercent,
                      minHeight: 8,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(badge.color),
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                      '${badge.progress} / ${badge.target} (${(badge.progressPercent * 100).round()}%)',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
          if (isLocked) ...[
            AppSpacing.vGap8,
            Text('${badge.target - badge.progress} ${l10n.inProgress}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
          AppSpacing.vGap24,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }
}
