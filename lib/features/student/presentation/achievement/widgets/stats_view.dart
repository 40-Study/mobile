import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key, required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GitHub-style contribution grid
        Text(
          'Hoạt động học tập',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vGap12,
        const _ContributionGrid(),
        AppSpacing.vGap24,

        // Stats grid
        Text(
          'Thống kê chi tiết',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vGap12,
        _StatsGrid(stats: stats),
      ],
    );
  }
}

class _ContributionGrid extends StatelessWidget {
  const _ContributionGrid();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Generate mock data cho 12 tuần (84 ngày)
    final now = DateTime.now();
    final contributions = _generateMockContributions(now);
    final weeks = 12;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Row(
              children: _buildMonthLabels(now, weeks, tt, cs),
            ),
          ),

          // Grid với day labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                children: ['', 'T2', '', 'T4', '', 'T6', '']
                    .map((d) => SizedBox(
                          height: 12,
                          child: Text(
                            d,
                            style: tt.labelSmall?.copyWith(
                              fontSize: 9,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              AppSpacing.hGap4,

              // Contribution squares
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: List.generate(weeks, (weekIndex) {
                      return Column(
                        children: List.generate(7, (dayIndex) {
                          final index = weekIndex * 7 + dayIndex;
                          final level = index < contributions.length
                              ? contributions[index]
                              : 0;
                          return _ContributionCell(level: level);
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vGap12,

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ít',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              AppSpacing.hGap4,
              ...List.generate(5, (i) => _ContributionCell(level: i)),
              AppSpacing.hGap4,
              Text(
                'Nhiều',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthLabels(
    DateTime now,
    int weeks,
    TextTheme tt,
    ColorScheme cs,
  ) {
    final months = <String>[];
    final startDate = now.subtract(Duration(days: weeks * 7));

    for (var i = 0; i < weeks; i += 4) {
      final date = startDate.add(Duration(days: i * 7));
      final monthName = _monthShort(date.month);
      if (months.isEmpty || months.last != monthName) {
        months.add(monthName);
      }
    }

    return months
        .map((m) => Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Text(
                m,
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ))
        .toList();
  }

  String _monthShort(int month) {
    const months = [
      'Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6',
      'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12',
    ];
    return months[month - 1];
  }

  List<int> _generateMockContributions(DateTime now) {
    // Mock data - random levels 0-4
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(84, (i) {
      final seed = (random + i * 17) % 100;
      if (seed < 30) return 0;
      if (seed < 50) return 1;
      if (seed < 70) return 2;
      if (seed < 85) return 3;
      return 4;
    });
  }
}

class _ContributionCell extends StatelessWidget {
  const _ContributionCell({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final color = switch (level) {
      0 => cs.surfaceContainer,
      1 => cs.primary.withValues(alpha: 0.2),
      2 => cs.primary.withValues(alpha: 0.4),
      3 => cs.primary.withValues(alpha: 0.7),
      _ => cs.primary,
    };

    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.school,
                value: '${stats.completedCourses}/${stats.totalCourses}',
                label: 'Khóa học',
                color: cs.primary,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: _StatCard(
                icon: Icons.play_lesson,
                value: '${stats.completedLessons}/${stats.totalLessons}',
                label: 'Bài học',
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
                label: 'Điểm quiz TB',
                color: Colors.orange,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: _StatCard(
                icon: Icons.access_time,
                value: '${stats.totalStudyHours.toStringAsFixed(1)}h',
                label: 'Tổng giờ học',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
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
