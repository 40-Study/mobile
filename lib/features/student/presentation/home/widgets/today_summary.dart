import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Nhóm thẻ tóm tắt nhanh dạng Capsule Pills thanh mảnh (không viền cứng, không shadow),
/// đóng vai trò bổ trợ tự nhiên cho Lời chào Hero Greeting.
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

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _PillBadge(
          icon: Icons.calendar_month_rounded,
          iconColor: cs.blue600,
          bgColor: const Color(0xFFEFF6FF),
          textColor: cs.blue700,
          label: '$scheduleCount ca học hôm nay',
        ),
        _PillBadge(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
          label: '$assignmentCount bài cần làm',
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.textColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
