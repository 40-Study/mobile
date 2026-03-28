import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class LearningHeatmap extends StatelessWidget {
  const LearningHeatmap({
    super.key,
    this.data,
  });

  final Map<DateTime, int>? data;

  static const _weeks = 14;
  static const _cellSize = 14.0;
  static const _spacing = 3.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final activityData = data ?? _generateMockData();
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: _weeks * 7 - 1));

    final totalDays = activityData.values.where((v) => v > 0).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.grid_view_rounded, color: cs.primary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Hoat dong',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$totalDays ngay',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Heatmap grid
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_weeks, (weekIndex) {
              return Padding(
                padding: EdgeInsets.only(
                  right: weekIndex < _weeks - 1 ? _spacing : 0,
                ),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final date = startDate.add(
                      Duration(days: weekIndex * 7 + dayIndex),
                    );
                    final normalized =
                        DateTime(date.year, date.month, date.day);
                    final level = activityData[normalized] ?? 0;
                    final isToday = _isToday(normalized);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: dayIndex < 6 ? _spacing : 0,
                      ),
                      child: Container(
                        width: _cellSize,
                        height: _cellSize,
                        decoration: BoxDecoration(
                          color: _Cell.colors[level.clamp(0, 4)],
                          borderRadius: BorderRadius.circular(2),
                          border: isToday
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<DateTime, int> _generateMockData() {
    final data = <DateTime, int>{};
    final today = DateTime.now();
    final seed = today.year * 100 + today.month;

    for (var i = 0; i < _weeks * 7; i++) {
      final date = today.subtract(Duration(days: i));
      final normalized = DateTime(date.year, date.month, date.day);
      final hash = (normalized.day * 31 + normalized.month * 12 + seed) % 10;
      data[normalized] = hash < 2 ? 0 : (hash < 4 ? 1 : (hash < 6 ? 2 : (hash < 8 ? 3 : 4)));
    }
    return data;
  }
}

class _Cell {
  static const colors = [
    Color(0xFFEBEDF0),
    Color(0xFF9BE9A8),
    Color(0xFF40C463),
    Color(0xFF30A14E),
    Color(0xFF216E39),
  ];
}
