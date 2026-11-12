import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Dải thông báo Cột mốc Học vụ & Trạng thái Mở khóa (Milestone Unlock Strip)
/// Thiết kế phẳng, tối giản học thuật, không dùng Card lơ lửng
class MilestoneUnlockStrip extends StatelessWidget {
  const MilestoneUnlockStrip({
    super.key,
    required this.isPassed,
    this.nextLessonTitle,
    this.remainingAttempts = 2,
  });

  final bool isPassed;
  final String? nextLessonTitle;
  final int remainingAttempts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Color stripBg;
    final Color stripBorder;
    final Color iconColor;
    final IconData icon;
    final String headline;
    final String subtitle;

    if (isPassed) {
      stripBg = const Color(0xFFF0FDF4); // Soft Emerald Mint
      stripBorder = const Color(0xFF10B981).withValues(alpha: 0.3);
      iconColor = const Color(0xFF059669);
      icon = Icons.lock_open_rounded;
      headline = 'BÀI HỌC KẾ TIẾP ĐÃ ĐƯỢC MỞ KHÓA';
      subtitle = nextLessonTitle != null && nextLessonTitle!.isNotEmpty
          ? nextLessonTitle!
          : 'Sẵn sàng tiến tới bài học tiếp theo trong lộ trình';
    } else {
      stripBg = const Color(0xFFFFFBEB); // Soft Amber
      stripBorder = const Color(0xFFF59E0B).withValues(alpha: 0.3);
      iconColor = const Color(0xFFD97706);
      icon = Icons.lock_clock_rounded;
      headline = 'BÀI HỌC KẾ TIẾP TẠM KHÓA (CẦN ĐẠT ≥ 70%)';
      subtitle =
          'Bạn còn $remainingAttempts lượt làm lại • Ôn lại bài giảng và thử lại để mở khóa';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: stripBg,
        borderRadius: BorderRadius.circular(6), // Bo góc 6px sắc sảo
        border: Border.all(color: stripBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.slate800,
                    height: 1.3,
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
