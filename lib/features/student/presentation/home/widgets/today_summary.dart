import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Summary row: buổi học + bài cần làm
class TodaySummary extends StatelessWidget {
  const TodaySummary({
    super.key,
    required this.scheduleCount,
    required this.assignmentCount,
  });

  final int scheduleCount;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _SummaryItem(
          icon: Icons.calendar_month_outlined,
          label: '$scheduleCount buổi học',
          color: cs.primary,
        ),
        Container(
          width: 1,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          color: cs.outline,
        ),
        _SummaryItem(
          icon: Icons.task_alt_outlined,
          label: '$assignmentCount bài cần làm',
          color: cs.tertiary,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        AppSpacing.hGap8,
        Text(
          label,
          style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
