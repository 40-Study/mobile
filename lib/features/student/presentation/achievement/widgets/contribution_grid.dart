import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/contribution_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ContributionGrid extends StatelessWidget {
  const ContributionGrid({super.key, this.contributionData = const []});

  final List<ContributionModel> contributionData;
  static const _weeks = 12;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final contributions = _mapToLevels(contributionData);
    final totalDays = contributions.where((l) => l > 0).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.learningActivity,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l10n.daysLearned(totalDays),
                    style: tt.labelMedium
                        ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          AppSpacing.vGap16,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 2),
                          _dayLabel('', tt, cs),
                          _dayLabel('T2', tt, cs),
                          _dayLabel('', tt, cs),
                          _dayLabel('T4', tt, cs),
                          _dayLabel('', tt, cs),
                          _dayLabel('T6', tt, cs),
                          _dayLabel('', tt, cs),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize =
                              (constraints.maxWidth - (_weeks - 1) * 3) / _weeks;
                          final size = cellSize.clamp(12.0, 18.0);

                          return Column(
                            children: [
                              ...List.generate(7, (dayIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(_weeks, (weekIndex) {
                                      final index = weekIndex * 7 + dayIndex;
                                      final level = index < contributions.length
                                          ? contributions[index]
                                          : 0;
                                      return ContributionCell(
                                          level: level, size: size, cs: cs);
                                    }),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vGap12,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.less, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
              AppSpacing.hGap8,
              ...List.generate(
                  5,
                  (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ContributionCell(level: i, size: 14, cs: cs),
                      )),
              AppSpacing.hGap8,
              Text(l10n.more, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayLabel(String text, TextTheme tt, ColorScheme cs) {
    return SizedBox(
      height: 17,
      child: text.isEmpty
          ? null
          : Text(text, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
    );
  }

  // Map API contributions to grid levels
  List<int> _mapToLevels(List<ContributionModel> data) {
    if (data.isEmpty) return List.filled(_weeks * 7, 0);

    final now = DateTime.now();
    final result = List.filled(_weeks * 7, 0);
    final startDate = now.subtract(Duration(days: _weeks * 7 - 1));

    for (final item in data) {
      final date = DateTime.tryParse(item.date);
      if (date == null) continue;

      final diff = date.difference(startDate).inDays;
      if (diff >= 0 && diff < _weeks * 7) {
        // Map count to level 0-4
        final level = switch (item.count) {
          0 => 0,
          1 => 1,
          2 || 3 => 2,
          4 || 5 => 3,
          _ => 4,
        };
        result[diff] = level;
      }
    }
    return result;
  }
}

class ContributionCell extends StatelessWidget {
  const ContributionCell({
    super.key,
    required this.level,
    required this.size,
    required this.cs,
  });

  final int level;
  final double size;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final colors = [
      cs.surfaceContainerHighest,
      cs.primary.withValues(alpha: 0.2),
      cs.primary.withValues(alpha: 0.4),
      cs.primary.withValues(alpha: 0.6),
      cs.primary,
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[level.clamp(0, 4)],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
