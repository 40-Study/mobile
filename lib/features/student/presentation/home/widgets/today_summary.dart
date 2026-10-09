import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Thẻ tóm tắt nhanh số ca học và bài tập hôm nay
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.calendar_month_rounded,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: cs.blue600,
              value: '$scheduleCount',
              label: 'ca học hôm nay',
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: cs.outlineVariant.withValues(alpha: 0.6),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.assignment_outlined,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              value: '$assignmentCount',
              label: 'bài cần làm',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          AppSpacing.hGap8,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.slate900,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
