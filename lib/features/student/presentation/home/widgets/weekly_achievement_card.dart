import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/theme/theme.dart';

class WeeklyAchievementCard extends StatelessWidget {
  const WeeklyAchievementCard({
    super.key,
    required this.stats,
    required this.earnedBadgeCount,
    this.onTap,
  });

  final StudentStatsModel stats;
  final int earnedBadgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final xpProgress = stats.nextLevelXp == 0
        ? 0.0
        : (stats.currentXp / stats.nextLevelXp).clamp(0.0, 1.0);
    final activeDays = stats.streakDays.clamp(0, 7);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: cs.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: cs.tertiary,
                      ),
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chuỗi học ${stats.streakDays} ngày',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.vGap4,
                          Text(
                            '$earnedBadgeCount huy hiệu đã mở khóa',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                Row(
                  children: List.generate(7, (index) {
                    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    final isActive = index < activeDays;
                    final isLatest = activeDays > 0 && index == activeDays - 1;

                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            labels[index],
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.vGap8,
                          Container(
                            width: isLatest ? 13 : 8,
                            height: isLatest ? 13 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? cs.primary
                                  : cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: isLatest
                                  ? Border.all(
                                      color: cs.primaryContainer,
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                AppSpacing.vGap16,
                Row(
                  children: [
                    Text(
                      'Cấp độ ${stats.level}',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stats.currentXp}/${stats.nextLevelXp} XP',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
