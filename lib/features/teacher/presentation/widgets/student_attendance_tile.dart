import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Trạng thái điểm danh của buổi học.
enum AttendanceStatus {
  /// Chưa đánh dấu - không có bản ghi đã lưu
  unmarked,

  /// Có mặt
  present,

  /// Đi muộn
  late,

  /// Vắng
  absent,

  /// Có phép
  excused,
}

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
    AttendanceStatus.unmarked => 'Chưa đánh dấu',
    AttendanceStatus.present => 'Có mặt',
    AttendanceStatus.late => 'Đi muộn',
    AttendanceStatus.absent => 'Vắng',
    AttendanceStatus.excused => 'Có phép',
  };

  String get apiValue => switch (this) {
    AttendanceStatus.unmarked => '',
    AttendanceStatus.present => 'present',
    AttendanceStatus.late => 'late',
    AttendanceStatus.absent => 'absent',
    AttendanceStatus.excused => 'excused',
  };

  static AttendanceStatus fromApi(String? value) => switch (value) {
    'present' => AttendanceStatus.present,
    'late' => AttendanceStatus.late,
    'absent' => AttendanceStatus.absent,
    'excused' => AttendanceStatus.excused,
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
    this.identifier,
    this.note,
    this.onNoteEdit,
    this.avatarUrl,
    this.isDisabled = false,
  });

  final String name;
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final String? identifier;
  final String? note;
  final VoidCallback? onNoteEdit;
  final String? avatarUrl;
  final bool isDisabled;

  static const _avatarPalette = [
    (Color(0xFF2563EB), Color(0xFF294DA0)),
    (Color(0xFF16A34A), Color(0xFF226246)),
    (Color(0xFFD97706), Color(0xFF8C4617)),
    (Color(0xFF9333EA), Color(0xFF754688)),
    (Color(0xFFDB2777), Color(0xFF8C3559)),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = cs.brightness == Brightness.dark;
    final hasNote = note?.trim().isNotEmpty == true;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final avatarIndex = initial.codeUnits.fold(0, (sum, unit) => sum + unit);
    final (avatarTint, avatarForeground) =
        _avatarPalette[avatarIndex % _avatarPalette.length];
    final cardColor = isDark ? cs.surfaceContainer : Colors.white;
    final noteForeground = hasNote
        ? (isDark ? const Color(0xFFFFDC8D) : const Color(0xFF986111))
        : (isDark ? cs.onSurfaceVariant : const Color(0xFF9CA3AF));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderLg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(
            color: isDark ? cs.outlineVariant : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar + name
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color.alphaBlend(
                      avatarTint.withValues(alpha: 0.16),
                      cardColor,
                    ),
                    foregroundColor: isDark ? cs.onSurface : avatarForeground,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            initial,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (identifier != null)
                          Text(
                            identifier!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        // Note section
                        if (hasNote)
                          Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (status == AttendanceStatus.unmarked) ...[
                    AppSpacing.hGap8,
                    // Unmarked indicator
                    Flexible(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: cs.surfaceContainerHigh,
                          shape: const StadiumBorder(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            'Chưa điểm danh',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (onNoteEdit != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.sm,
                      ),
                      child: IconButton(
                        tooltip: hasNote
                            ? 'Sửa ghi chú điểm danh của $name'
                            : 'Ghi chú điểm danh của $name',
                        onPressed: isDisabled ? null : onNoteEdit,
                        icon: const Icon(Icons.edit_note, size: AppIconSize.md),
                        style: IconButton.styleFrom(
                          foregroundColor: noteForeground,
                          minimumSize: const Size.square(36),
                          visualDensity: VisualDensity.standard,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: AppSpacing.paddingSm,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.vGap8,
              // Status segments
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.surfaceContainerHigh
                      : const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final s in [
                          AttendanceStatus.present,
                          AttendanceStatus.late,
                          AttendanceStatus.absent,
                          AttendanceStatus.excused,
                        ])
                          Expanded(
                            child: _StatusButton(
                              status: s,
                              isSelected: status == s,
                              onPressed: isDisabled
                                  ? null
                                  : () => onStatusChanged(s),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.status,
    required this.isSelected,
    required this.onPressed,
  });

  final AttendanceStatus status;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isDark = cs.brightness == Brightness.dark;
    final (selectedBackground, selectedForeground) = switch (status) {
      AttendanceStatus.present =>
        isDark
            ? (const Color(0xFF173E2B), const Color(0xFFA7EDBF))
            : (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      AttendanceStatus.late =>
        isDark
            ? (const Color(0xFF4D320F), const Color(0xFFFFD59A))
            : (const Color(0xFFFFEDD5), const Color(0xFF9A3412)),
      AttendanceStatus.absent =>
        isDark
            ? (const Color(0xFF4E2428), const Color(0xFFFDB8BF))
            : (const Color(0xFFFEE2E2), const Color(0xFFB42332)),
      AttendanceStatus.excused =>
        isDark
            ? (const Color(0xFF223A61), const Color(0xFFBFD6FF))
            : (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      AttendanceStatus.unmarked => (cs.primaryContainer, cs.onPrimaryContainer),
    };
    const radius = BorderRadius.all(Radius.circular(7.5));
    final background = isSelected ? selectedBackground : Colors.transparent;
    final foreground = isSelected
        ? selectedForeground
        : (isDark ? cs.onSurfaceVariant : const Color(0xFF64748B));

    return Semantics(
      selected: isSelected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: background,
            disabledForegroundColor: foreground,
            minimumSize: const Size(0, 32),
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.all(2),
            shape: const RoundedRectangleBorder(borderRadius: radius),
            textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              height: 1.15,
            ),
          ),
          child: Text(status.label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
