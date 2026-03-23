import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/models/models.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onJoinTap,
  });

  final TeacherScheduleModel schedule;
  final VoidCallback? onJoinTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final dateTime = DateTime.tryParse(schedule.startTime);
    final dayOfWeek = dateTime != null
        ? 'T${dateTime.weekday + 1}'
        : '';
    final dayOfMonth = dateTime?.day.toString() ?? '';
    final timeStr = dateTime != null
        ? DateFormat('HH:mm').format(dateTime)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date column
          Column(
            children: [
              Text(
                dayOfWeek,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                dayOfMonth,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      schedule.meetingType == 'Meet'
                          ? Icons.videocam_outlined
                          : Icons.people_outline,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.studentCount > 0
                          ? '${schedule.studentCount} Học viên'
                          : schedule.meetingType,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Join button
          if (schedule.meetingType == 'Meet')
            FilledButton(
              onPressed: onJoinTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Vào lớp'),
            ),
        ],
      ),
    );
  }
}
