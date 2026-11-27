import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

String teacherSessionStateLabel(TeacherOccurrence session, {DateTime? now}) {
  if (session.projected) return 'Dự kiến · chưa tạo buổi';
  final end = DateTime.tryParse('${teacherDate(session.date)} ${session.end}');
  final ended = end != null && !end.isAfter(now ?? DateTime.now());
  return switch (session.status) {
    'scheduled' when ended => 'Quá giờ · Chưa bắt đầu',
    'in_progress' when ended => 'Quá giờ · Chưa hoàn tất',
    _ => teacherStatus(session.status),
  };
}

class TeacherSessionRow extends StatelessWidget {
  const TeacherSessionRow({
    super.key,
    required this.session,
    required this.api,
    required this.workplaceLabel,
    this.compact = false,
    this.includeDate = false,
    this.onChanged,
  });
  final TeacherOccurrence session;
  final TeacherApi api;
  final String workplaceLabel;
  final bool compact;
  final bool includeDate;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final role = session.json['teacher_role']?.toString();
    final studentCount = (session.json['student_count'] as int?) ?? 0;
    final needsInfo = session.json['hour_confirmation_status'] == 'needs_info';
    final timeRange = '${session.start}–${session.end}';
    final schedule = includeDate
        ? '${DateFormat('dd/MM').format(session.date)} · $timeRange'
        : timeRange;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: cs.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: InkWell(
          onTap: () async {
            final changed = await teacherPush<bool>(
              context,
              TeacherSessionScreen(
                api: api,
                classId: session.classId,
                sessionId: session.sessionId,
                occurrence: session,
                workplaceLabel: workplaceLabel,
              ),
            );
            if (changed == true && context.mounted) onChanged?.call();
          },
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            schedule,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TeacherSessionStatusLabel(
                            label: teacherSessionStateLabel(session),
                            status: session.status,
                          ),
                          if (needsInfo)
                            const TeacherSessionStatusLabel(
                              label: 'Cần bổ sung',
                              status: 'needs_info',
                            ),
                        ],
                      ),
                      AppSpacing.vGap4,
                      Text(
                        session.classData.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!compact && session.topic.isNotEmpty) ...[
                        AppSpacing.vGap4,
                        Text(
                          session.topic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (role != null || studentCount > 0) ...[
                        AppSpacing.vGap4,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (role != null) TeacherRoleBadge(role: role),
                            if (studentCount > 0)
                              TeacherStudentCountBadge(count: studentCount),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One consistent textual status for agenda rows and the session detail.
class TeacherSessionStatusLabel extends StatelessWidget {
  const TeacherSessionStatusLabel({
    super.key,
    required this.label,
    required this.status,
  });
  final String label;
  final String status;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      _ when label.startsWith('Quá giờ') => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
      ),
      'in_progress' => (cs.primaryContainer, cs.onPrimaryContainer),
      'completed' => (cs.secondaryContainer, cs.onSecondaryContainer),
      'cancelled' || 'needs_info' => (cs.errorContainer, cs.onErrorContainer),
      _ => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
