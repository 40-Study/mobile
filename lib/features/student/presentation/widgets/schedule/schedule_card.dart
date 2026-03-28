import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  final StudentScheduleModel schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = schedule.isLive;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: isLive
              ? cs.surfaceTintedPrimary
              : cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isLive ? cs.primary : cs.outline,
            width: isLive ? 1.5 : 1,
          ),
          boxShadow: isLive ? cs.shadowPrimary : cs.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimeAndStatusRow(schedule: schedule),
            const SizedBox(height: AppSpacing.xs),
            _LocationLine(schedule: schedule),
            const SizedBox(height: AppSpacing.md),
            Text(
              schedule.className ?? '',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              schedule.title ?? '',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            _TeacherAndActionRow(schedule: schedule),
          ],
        ),
      ),
    );
  }
}

class _TimeAndStatusRow extends StatelessWidget {
  const _TimeAndStatusRow({required this.schedule});
  final StudentScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          _timeRange(),
          style: tt.labelLarge?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _StatusBadge(schedule: schedule),
      ],
    );
  }

  String _timeRange() {
    final start = schedule.timeDisplay;
    final end = _endTimeStr();
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  String _endTimeStr() {
    if (schedule.endTime == null) return '';
    try {
      final dt = DateTime.parse(schedule.endTime!);
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.schedule});
  final StudentScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = schedule.isLive;
    final isUpcoming = schedule.isUpcoming;

    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final String label;

    if (isLive) {
      bgColor = cs.primary;
      textColor = cs.onPrimary;
      borderColor = cs.primary;
      label = 'DANG DIEN RA';
    } else if (isUpcoming) {
      bgColor = cs.primaryContainer;
      textColor = cs.onPrimaryContainer;
      borderColor = cs.primary.withValues(alpha: 0.3);
      label = 'SAP DIEN RA';
    } else {
      bgColor = cs.surfaceContainerLow;
      textColor = cs.onSurfaceVariant;
      borderColor = cs.outline;
      label = 'Chua mo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.schedule});
  final StudentScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final text = schedule.meetingUrl != null
        ? 'Phong truc tuyen A${schedule.id.hashCode.abs() % 9 + 1}'
        : 'Phong 402 - Co so Quan 1';

    return Row(
      children: [
        Icon(
          schedule.meetingUrl != null
              ? Icons.videocam_outlined
              : Icons.location_on_outlined,
          size: AppIconSize.sm,
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TeacherAndActionRow extends StatelessWidget {
  const _TeacherAndActionRow({required this.schedule});
  final StudentScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = schedule.isLive;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primaryContainer,
          child: Icon(
            Icons.person_rounded,
            size: AppIconSize.sm,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            schedule.teacherName ?? '',
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isLive) _JoinClassButton() else _NotOpenButton(),
      ],
    );
  }
}

class _JoinClassButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: cs.gradientPrimary,
        borderRadius: AppRadius.borderXxl,
        boxShadow: cs.shadowPrimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_rounded,
            size: AppIconSize.sm,
            color: cs.onPrimary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Vao lop',
            style: tt.labelMedium?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotOpenButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.borderXxl,
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        'Chua mo',
        style: tt.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
