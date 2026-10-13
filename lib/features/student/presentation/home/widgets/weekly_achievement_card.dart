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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final xpProgress = stats.nextLevelXp == 0
        ? 0.0
        : (stats.currentXp / stats.nextLevelXp).clamp(0.0, 1.0);
    final activeDays = stats.streakDays.clamp(0, 7);

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFEA580C),
                        size: 24,
                      ),
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chuỗi học ${stats.streakDays} ngày',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.slate900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$earnedBadgeCount huy hiệu đã mở khóa',
                            style: tt.bodySmall?.copyWith(
                              color: cs.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.slate400,
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
                              color: cs.slate500,
                              fontSize: 11,
                            ),
                          ),
                          AppSpacing.vGap8,
                          Container(
                            width: isLatest ? 12 : 8,
                            height: isLatest ? 12 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEA580C)
                                  : cs.slate200,
                              shape: BoxShape.circle,
                              border: isLatest
                                  ? Border.all(
                                      color: const Color(0xFFFFEDD5),
                                      width: 2.5,
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
                        fontWeight: FontWeight.w700,
                        color: cs.slate900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stats.currentXp}/${stats.nextLevelXp} XP',
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 6,
                    backgroundColor: cs.primaryContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
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
