import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class StatsHeroCard extends StatelessWidget {
  const StatsHeroCard({super.key, required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final xpProgress = stats.currentXp / stats.nextLevelXp;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '${stats.level}',
                    style: tt.titleLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấp độ ${stats.level}',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${stats.nextLevelXp - stats.currentXp} XP để lên cấp',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '${stats.currentXp}/${stats.nextLevelXp}',
                style: tt.labelMedium?.copyWith(color: cs.primary),
              ),
            ],
          ),
          AppSpacing.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: xpProgress.clamp(0.0, 1.0),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department_outlined,
                  value: '${stats.streakDays}',
                  label: 'ngày liên tục',
                  color: cs.tertiary,
                ),
              ),
              _Divider(color: cs.outlineVariant),
              Expanded(
                child: _StatItem(
                  icon: Icons.task_alt_outlined,
                  value: '${stats.completedCourses}',
                  label: 'khóa hoàn tất',
                  color: cs.secondary,
                ),
              ),
              _Divider(color: cs.outlineVariant),
              Expanded(
                child: _StatItem(
                  icon: Icons.schedule_outlined,
                  value: '${stats.totalStudyHours.toStringAsFixed(0)}h',
                  label: 'đã học',
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: color);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 21),
        AppSpacing.vGap4,
        Text(
          value,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
