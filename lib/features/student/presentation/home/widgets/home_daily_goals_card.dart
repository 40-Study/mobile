import 'package:flutter/material.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/theme/theme.dart';

/// Daily goals card cho home screen
class HomeDailyGoalsCard extends StatelessWidget {
  const HomeDailyGoalsCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final goalColor = cs.blue600;

    final storage = DailyGoalsStorage.instance;
    final goals = storage.getGoals(DateTime.now());
    final (completed, total) = storage.getTodayProgress();
    final progress = total > 0 ? completed / total : 0.0;
    final nextGoal = goals.where((g) => !g.isCompleted).firstOrNull;

    // Empty state
    if (goals.isEmpty) {
      return _EmptyGoalsBanner(onTap: onTap);
    }

    // Has goals
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
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          color: goalColor,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completed == total
                            ? 'Hoàn thành tất cả mục tiêu!'
                            : 'Còn ${total - completed} mục tiêu hôm nay',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nextGoal?.title ?? 'Tuyệt vời! Bạn đã hoàn thành.',
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),
        ),
      ),
    );
  }
}

class _EmptyGoalsBanner extends StatelessWidget {
  const _EmptyGoalsBanner({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: cs.blue600,
                    size: 22,
                  ),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đặt mục tiêu hôm nay',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tạo 1-2 thói quen học tập để bứt phá',
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: cs.blue600),
                      const SizedBox(width: 2),
                      Text(
                        'Thêm',
                        style: tt.labelSmall?.copyWith(
                          color: cs.blue600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
