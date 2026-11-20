import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Trạng thái điểm danh theo spec mốc 1a
enum AttendanceStatus {
  /// Chưa đánh dấu - không có bản ghi đã lưu
  unmarked,

  /// Có mặt
  present,

  /// Đi muộn
  late,

  /// Vắng
  absent,
}

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
    AttendanceStatus.unmarked => 'Chưa đánh dấu',
    AttendanceStatus.present => 'Có mặt',
    AttendanceStatus.late => 'Đi muộn',
    AttendanceStatus.absent => 'Vắng',
  };

  String get apiValue => switch (this) {
    AttendanceStatus.unmarked => '',
    AttendanceStatus.present => 'present',
    AttendanceStatus.late => 'late',
    AttendanceStatus.absent => 'absent',
  };

  static AttendanceStatus fromApi(String? value) => switch (value) {
    'present' => AttendanceStatus.present,
    'late' => AttendanceStatus.late,
    'absent' => AttendanceStatus.absent,
    _ => AttendanceStatus.unmarked,
  };
}

/// Tile hiển thị học viên với trạng thái điểm danh.
/// Dùng trong màn hình điểm danh (T05 theo spec).
class StudentAttendanceTile extends StatelessWidget {
  const StudentAttendanceTile({
    super.key,
    required this.name,
    required this.status,
    required this.onStatusChanged,
    this.note,
    this.onNoteEdit,
    this.avatarUrl,
    this.isDisabled = false,
  });

  final String name;
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final String? note;
  final VoidCallback? onNoteEdit;
  final String? avatarUrl;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                      )
                    : null,
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Text(
                  name,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          // Status chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in [
                AttendanceStatus.present,
                AttendanceStatus.late,
                AttendanceStatus.absent,
              ])
                _StatusChip(
                  status: s,
                  isSelected: status == s,
                  isDisabled: isDisabled,
                  onTap: () => onStatusChanged(s),
                ),
            ],
          ),
          // Note section
          if (onNoteEdit != null)
            TextButton.icon(
              onPressed: isDisabled ? null : onNoteEdit,
              icon: const Icon(Icons.edit_note, size: 18),
              label: Text(
                note?.isNotEmpty == true ? note! : 'Thêm ghi chú',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Unmarked indicator
          if (status == AttendanceStatus.unmarked)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Chưa điểm danh',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final AttendanceStatus status;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (selectedBg, selectedFg) = switch (status) {
      AttendanceStatus.present => (cs.primaryContainer, cs.onPrimaryContainer),
      AttendanceStatus.late => (
        AchievementColors.yellow.withValues(alpha: 0.2),
        AchievementColors.yellow,
      ),
      AttendanceStatus.absent => (cs.errorContainer, cs.onErrorContainer),
      AttendanceStatus.unmarked => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };

    return ChoiceChip(
      label: Text(status.label),
      selected: isSelected,
      selectedColor: selectedBg,
      labelStyle: TextStyle(
        color: isSelected ? selectedFg : cs.onSurfaceVariant,
      ),
      onSelected: isDisabled ? null : (_) => onTap(),
    );
  }
}
