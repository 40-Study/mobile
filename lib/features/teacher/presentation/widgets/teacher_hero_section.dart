import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Hero section cho Teacher screens với greeting và summary chips.
/// Pattern tương tự Student home hero.
class TeacherHeroSection extends StatelessWidget {
  const TeacherHeroSection({
    super.key,
    required this.greeting,
    required this.name,
    this.chips = const [],
    this.trailing,
  });

  /// Lời chào (Chào buổi sáng, Chào buổi chiều, etc.)
  final String greeting;

  /// Tên người dùng (first name)
  final String name;

  /// Summary chips hiển thị bên dưới greeting
  final List<TeacherSummaryChip> chips;

  /// Widget trailing (notification icon, etc.)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$greeting, $name',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.slate900,
                    letterSpacing: -0.5,
                    fontSize: 24,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (chips.isNotEmpty) ...[
            AppSpacing.vGap12,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  /// Factory tạo greeting dựa trên giờ hiện tại
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  /// Factory lấy first name từ full name
  static String getFirstName(String? name) {
    final normalized = name?.trim();
    if (normalized == null || normalized.isEmpty) return 'thầy/cô';
    return normalized.split(RegExp(r'\s+')).last;
  }
}

/// Summary chip hiển thị thông tin tóm tắt (số buổi, số cần xử lý, etc.)
class TeacherSummaryChip extends StatelessWidget {
  const TeacherSummaryChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.isWarning = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool isWarning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final effectiveColor = color ??
        (isWarning ? AchievementColors.red : cs.primary);
    final backgroundColor = effectiveColor.withValues(alpha: 0.1);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: effectiveColor,
              ),
              AppSpacing.hGap4,
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Countdown badge hiển thị thời gian đếm ngược tới buổi học
class TeacherCountdownBadge extends StatefulWidget {
  const TeacherCountdownBadge({
    super.key,
    required this.targetTime,
    this.prefix = 'Còn',
    this.onExpired,
  });

  /// Thời điểm mục tiêu để đếm ngược
  final DateTime targetTime;

  /// Prefix text (mặc định: "Còn")
  final String prefix;

  /// Callback khi hết giờ
  final VoidCallback? onExpired;

  @override
  State<TeacherCountdownBadge> createState() => _TeacherCountdownBadgeState();
}

class _TeacherCountdownBadgeState extends State<TeacherCountdownBadge> {
  late Duration _remaining;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    _remaining = widget.targetTime.difference(now);
    if (_remaining.isNegative && !_expired) {
      _expired = true;
      widget.onExpired?.call();
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(_updateRemaining);
        if (!_expired) _startTimer();
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Đang diễn ra';
    if (d.inDays > 0) return '${d.inDays} ngày';
    if (d.inHours > 0) {
      final mins = d.inMinutes % 60;
      return mins > 0 ? '${d.inHours}h${mins}p' : '${d.inHours} giờ';
    }
    if (d.inMinutes > 0) return '${d.inMinutes} phút';
    return '${d.inSeconds} giây';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Màu sắc dựa trên thời gian còn lại
    final Color badgeColor;
    if (_remaining.isNegative) {
      badgeColor = AchievementColors.green;
    } else if (_remaining.inMinutes <= 15) {
      badgeColor = AchievementColors.red;
    } else if (_remaining.inMinutes <= 60) {
      badgeColor = AchievementColors.yellow;
    } else {
      badgeColor = cs.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _remaining.isNegative
                ? Icons.play_circle_filled
                : Icons.timer_outlined,
            size: 14,
            color: badgeColor,
          ),
          AppSpacing.hGap4,
          Text(
            _remaining.isNegative
                ? _formatDuration(_remaining)
                : '${widget.prefix} ${_formatDuration(_remaining)}',
            style: tt.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
