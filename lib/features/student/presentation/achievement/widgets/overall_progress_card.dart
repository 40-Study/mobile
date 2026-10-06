import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/achievement/widgets/badge_card.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class OverallProgressCard extends StatelessWidget {
  const OverallProgressCard({
    super.key,
    required this.earnedCount,
    required this.inProgressCount,
    required this.lockedCount,
    required this.totalCount,
  });

  final int earnedCount;
  final int inProgressCount;
  final int lockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final percent = totalCount > 0 ? (earnedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
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
                Text(l10n.overallProgress,
                    style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                AppSpacing.vGap8,
                Text('$percent%',
                    style: tt.displaySmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w700)),
                AppSpacing.vGap4,
                Text(l10n.badgesEarned(earnedCount, totalCount),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            children: [
              CircularProgress(
                percent: percent / 100,
                size: 80,
                strokeWidth: 6,
              ),
              AppSpacing.vGap12,
              Row(
                children: [
                  StatusDot(
                      color: cs.primary, count: earnedCount, label: l10n.earned),
                ],
              ),
              AppSpacing.vGap4,
              Row(
                children: [
                  StatusDot(
                      color: AchievementColors.blue,
                      count: inProgressCount,
                      label: l10n.inProgress),
                ],
              ),
              AppSpacing.vGap4,
              Row(
                children: [
                  StatusDot(
                      color: cs.outlineVariant,
                      count: lockedCount,
                      label: l10n.notEarned),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.color,
    required this.count,
    required this.label,
  });

  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        AppSpacing.hGap8,
        Text('$count',
            style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        AppSpacing.hGap4,
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
