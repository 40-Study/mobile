import 'package:flutter/material.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/theme/theme.dart';

/// Daily goals card cho home screen - khác với DailyGoalCard (enrollment-based)
class HomeDailyGoalsCard extends StatelessWidget {
  const HomeDailyGoalsCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goalColor = cs.secondary;

    final storage = DailyGoalsStorage.instance;
    final goals = storage.getGoals(DateTime.now());
    final (completed, total) = storage.getTodayProgress();
    final progress = total > 0 ? completed / total : 0.0;
    final nextGoal = goals.where((g) => !g.isCompleted).firstOrNull;

    // Empty state
    if (goals.isEmpty) {
      return _EmptyGoalsBanner(onTap: onTap, goalColor: goalColor);
    }

    // Has goals
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
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 66,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          color: goalColor,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          backgroundColor: goalColor.withValues(alpha: 0.1),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
                            ? 'Hoàn thành tất cả!'
                            : 'Còn ${total - completed} mục tiêu',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        nextGoal?.title ?? 'Tuyệt vời! Bạn đã hoàn thành.',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyGoalsBanner extends StatelessWidget {
  const _EmptyGoalsBanner({this.onTap, required this.goalColor});

  final VoidCallback? onTap;
  final Color goalColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0xFFC8E6C9).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goalColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flag_rounded, size: 18, color: goalColor),
                      ),
                      AppSpacing.hGap12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hãy đặt mục tiêu',
                            style: tt.titleSmall?.copyWith(
                              color: const Color(0xFF43A047),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'để bắt đầu ngày mới!',
                            style: tt.bodySmall?.copyWith(color: const Color(0xFF66BB6A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.vGap12,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66BB6A),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        AppSpacing.hGap4,
                        Text(
                          'Thêm mục tiêu',
                          style: tt.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.eco_rounded, size: 36, color: goalColor.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
