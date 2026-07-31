import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key, required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly chart
        Text(
          'Gio hoc trong tuan',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vGap12,
        _WeeklyChart(hours: stats.weeklyStudyHours ?? []),
        AppSpacing.vGap24,

        // Stats grid
        Text(
          'Thong ke chi tiet',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vGap12,
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.school,
                value: '${stats.completedCourses}/${stats.totalCourses}',
                label: 'Khoa hoc',
                color: cs.primary,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: _StatCard(
                icon: Icons.play_lesson,
                value: '${stats.completedLessons}/${stats.totalLessons}',
                label: 'Bai hoc',
                color: Colors.green,
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.quiz,
                value: '${stats.totalQuizScore.toStringAsFixed(1)}%',
                label: 'Diem quiz TB',
                color: Colors.orange,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: _StatCard(
                icon: Icons.access_time,
                value: '${stats.totalStudyHours.toStringAsFixed(1)}h',
                label: 'Tong gio hoc',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.hours});

  final List<double> hours;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final maxHour = hours.isEmpty ? 1.0 : hours.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final value = index < hours.length ? hours[index] : 0.0;
          final height = maxHour > 0 ? (value / maxHour) * 60 : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height.clamp(4.0, 60.0),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    days[index],
                    style: tt.labelSmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.vGap8,
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
