import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';

class AttendanceListItem extends StatelessWidget {
  const AttendanceListItem({
    super.key,
    required this.attendance,
    this.onTap,
  });

  final ChildAttendanceModel attendance;
  final VoidCallback? onTap;

  IconData _getStatusIcon() {
    switch (attendance.attendanceStatus) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.excused:
        return Icons.assignment_turned_in;
    }
  }

  Color _getStatusColor(ColorScheme cs) {
    switch (attendance.attendanceStatus) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return cs.error;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return cs.primary;
    }
  }

  String _getStatusText() {
    switch (attendance.attendanceStatus) {
      case AttendanceStatus.present:
        return 'Co mat';
      case AttendanceStatus.absent:
        return 'Vang';
      case AttendanceStatus.late:
        return 'Muon';
      case AttendanceStatus.excused:
        return 'Co phep';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(cs).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(cs),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.className ?? 'Lop hoc',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(attendance.date),
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(cs).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(cs),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (attendance.note != null && attendance.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      attendance.note!,
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return date;
    }
  }
}
