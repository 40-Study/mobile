import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Status dot indicator cho session rows.
/// Hiển thị trạng thái buổi học bằng màu sắc trực quan.
class TeacherStatusDot extends StatelessWidget {
  const TeacherStatusDot({
    super.key,
    required this.status,
    this.size = 10,
    this.animated = true,
  });

  final String status;
  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (color, shouldPulse) = switch (status) {
      'in_progress' => (AchievementColors.green, true),
      'completed' => (AchievementColors.green, false),
      'cancelled' => (cs.error, false),
      'needs_info' => (AchievementColors.yellow, true),
      'overdue' => (AchievementColors.red, true),
      _ => (cs.primary, false),
    };

    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shouldPulse
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );

    if (animated && shouldPulse) {
      return _PulsingDot(color: color, size: size);
    }

    return dot;
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.4 * _animation.value),
              blurRadius: 6 * _animation.value,
              spreadRadius: 2 * _animation.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// Role badge hiển thị vai trò giáo viên
class TeacherRoleBadge extends StatelessWidget {
  const TeacherRoleBadge({
    super.key,
    required this.role,
  });

  final String? role;

  @override
  Widget build(BuildContext context) {
    if (role == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (label, color) = switch (role) {
      'main' => ('Chính', cs.primary),
      'substitute' => ('Dạy thay', AchievementColors.orange),
      'assistant' => ('Trợ giảng', AchievementColors.blue),
      _ => (null, cs.onSurfaceVariant),
    };

    if (label == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Class icon với background màu (dùng cho class, không phải người)
class TeacherClassIcon extends StatelessWidget {
  const TeacherClassIcon({
    super.key,
    required this.className,
    this.size = 48,
    this.color,
  });

  final String className;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Generate color from class name
    final effectiveColor = color ?? _colorFromString(className, cs);
    final initial = className.isNotEmpty ? className[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: Text(
          initial,
          style: tt.titleMedium?.copyWith(
            color: effectiveColor,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Color _colorFromString(String s, ColorScheme cs) {
    if (s.isEmpty) return cs.primary;
    final colors = [
      AchievementColors.blue,
      AchievementColors.purple,
      AchievementColors.green,
      AchievementColors.orange,
      AchievementColors.pink,
      AchievementColors.teal,
    ];
    final hash = s.codeUnits.fold(0, (prev, c) => prev + c);
    return colors[hash % colors.length];
  }
}

/// Student count badge với icon
class TeacherStudentCountBadge extends StatelessWidget {
  const TeacherStudentCountBadge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_outline,
          size: 14,
          color: cs.onSurfaceVariant,
        ),
        AppSpacing.hGap4,
        Text(
          '$count',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Progress bar cho class/course progress
class TeacherProgressBar extends StatelessWidget {
  const TeacherProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    this.color,
    this.backgroundColor,
  });

  /// Progress value from 0.0 to 1.0
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.primary;
    final effectiveBg = backgroundColor ?? cs.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: effectiveBg),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveColor,
                      effectiveColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats card cho dashboard
class TeacherStatsCard extends StatelessWidget {
  const TeacherStatsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveColor = color ?? cs.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010120).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: effectiveColor,
                  ),
                ),
                AppSpacing.vGap12,
                Text(
                  value,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
