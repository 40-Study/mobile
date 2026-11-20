import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Status types cho Teacher badges.
enum TeacherStatus {
  pending,
  approved,
  rejected,
  needsInfo,
  confirmed,
  inProgress,
  completed,
  cancelled,
  scheduled,
  overdue,
}

/// Badge size options.
enum TeacherBadgeSize { small, medium, large }

/// Unified status badge component cho Teacher UI.
///
/// Thay thế tất cả badge implementations khác nhau trong teacher screens.
/// Màu sắc dùng từ theme/AchievementColors (không hardcode).
class TeacherStatusBadge extends StatelessWidget {
  const TeacherStatusBadge({
    super.key,
    required this.status,
    this.size = TeacherBadgeSize.medium,
    this.label,
  });

  /// Factory từ status string (backend values)
  factory TeacherStatusBadge.fromString(String status, {String? label}) {
    final teacherStatus = switch (status) {
      'pending' => TeacherStatus.pending,
      'approved' => TeacherStatus.approved,
      'rejected' => TeacherStatus.rejected,
      'needs_info' => TeacherStatus.needsInfo,
      'confirmed' => TeacherStatus.confirmed,
      'in_progress' => TeacherStatus.inProgress,
      'completed' => TeacherStatus.completed,
      'cancelled' => TeacherStatus.cancelled,
      'scheduled' => TeacherStatus.scheduled,
      _ => TeacherStatus.pending,
    };
    return TeacherStatusBadge(status: teacherStatus, label: label);
  }

  final TeacherStatus status;
  final TeacherBadgeSize size;
  final String? label;

  String get _defaultLabel => switch (status) {
        TeacherStatus.pending => 'Chờ duyệt',
        TeacherStatus.approved => 'Đã duyệt',
        TeacherStatus.rejected => 'Từ chối',
        TeacherStatus.needsInfo => 'Cần bổ sung',
        TeacherStatus.confirmed => 'Đã xác nhận',
        TeacherStatus.inProgress => 'Đang diễn ra',
        TeacherStatus.completed => 'Hoàn thành',
        TeacherStatus.cancelled => 'Đã hủy',
        TeacherStatus.scheduled => 'Đã lên lịch',
        TeacherStatus.overdue => 'Quá giờ',
      };

  (Color, Color) _colors(ColorScheme cs) => switch (status) {
        TeacherStatus.pending => (
            AchievementColors.yellow.withValues(alpha: 0.15),
            AchievementColors.yellow,
          ),
        TeacherStatus.approved => (
            AchievementColors.green.withValues(alpha: 0.15),
            AchievementColors.green,
          ),
        TeacherStatus.rejected => (
            AchievementColors.red.withValues(alpha: 0.15),
            AchievementColors.red,
          ),
        TeacherStatus.needsInfo => (
            AchievementColors.red.withValues(alpha: 0.15),
            AchievementColors.red,
          ),
        TeacherStatus.confirmed => (
            cs.primary.withValues(alpha: 0.15),
            cs.primary,
          ),
        TeacherStatus.inProgress => (
            cs.primaryContainer,
            cs.onPrimaryContainer,
          ),
        TeacherStatus.completed => (
            AchievementColors.green.withValues(alpha: 0.15),
            AchievementColors.green,
          ),
        TeacherStatus.cancelled => (
            cs.errorContainer,
            cs.onErrorContainer,
          ),
        TeacherStatus.scheduled => (
            cs.surfaceContainerHigh,
            cs.onSurfaceVariant,
          ),
        TeacherStatus.overdue => (
            cs.tertiaryContainer,
            cs.onTertiaryContainer,
          ),
      };

  EdgeInsets get _padding => switch (size) {
        TeacherBadgeSize.small =>
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        TeacherBadgeSize.medium =>
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        TeacherBadgeSize.large =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      };

  double get _borderRadius => switch (size) {
        TeacherBadgeSize.small => 4,
        TeacherBadgeSize.medium => 6,
        TeacherBadgeSize.large => 8,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = _colors(cs);
    final textStyle = switch (size) {
      TeacherBadgeSize.small => Theme.of(context).textTheme.labelSmall,
      TeacherBadgeSize.medium => Theme.of(context).textTheme.labelSmall,
      TeacherBadgeSize.large => Theme.of(context).textTheme.labelMedium,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: _padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Text(
        label ?? _defaultLabel,
        style: textStyle?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Attention badge (đỏ) cho số items cần xử lý.
class TeacherAttentionBadge extends StatelessWidget {
  const TeacherAttentionBadge({
    super.key,
    required this.count,
    this.showZero = false,
  });

  final int count;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AchievementColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
