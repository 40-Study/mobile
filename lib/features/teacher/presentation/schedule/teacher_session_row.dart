import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

String teacherSessionStateLabel(TeacherOccurrence session, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final endParts = session.end.split(':');
  final end = DateTime(
    session.date.year,
    session.date.month,
    session.date.day,
    int.tryParse(endParts.first) ?? 0,
    int.tryParse(endParts.last) ?? 0,
  );
  if (session.status == 'scheduled' && end.isBefore(clock))
    return 'Quá giờ · Chưa bắt đầu';
  return session.projected
      ? 'Dự kiến · chưa tạo buổi'
      : teacherStatus(session.status);
}

class TeacherSessionRow extends StatelessWidget {
  const TeacherSessionRow({
    super.key,
    required this.session,
    required this.api,
    required this.workplaceLabel,
    this.compact = false,
    this.onChanged,
  });
  final TeacherOccurrence session;
  final TeacherApi api;
  final String workplaceLabel;
  final bool compact;
  final VoidCallback? onChanged;

  String _getStatusForDot() {
    final label = teacherSessionStateLabel(session);
    if (label.startsWith('Quá giờ')) return 'overdue';
    final confirmStatus = session.json['hour_confirmation_status']?.toString();
    if (confirmStatus == 'needs_info') return 'needs_info';
    return session.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final label = teacherSessionStateLabel(session);
    final role = session.json['teacher_role']?.toString();
    final studentCount = (session.json['student_count'] as int?) ?? 0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                session.classData.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (role != null) TeacherRoleBadge(role: role),
          ],
        ),
        if (!compact && session.topic.isNotEmpty) ...[
          AppSpacing.vGap4,
          Text(
            session.topic,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        AppSpacing.vGap8,
        Row(
          children: [
            TeacherSessionStatusLabel(label: label, status: session.status),
            if (studentCount > 0) ...[
              AppSpacing.hGap12,
              TeacherStudentCountBadge(count: studentCount),
            ],
          ],
        ),
      ],
    );
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF010120).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
          onTap: () async {
            await teacherPush<Object?>(
              context,
              TeacherSessionScreen(
                api: api,
                classId: session.classId,
                sessionId: session.sessionId,
                occurrence: session,
                workplaceLabel: workplaceLabel,
              ),
            );
            onChanged?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: largeText
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TeacherStatusDot(status: _getStatusForDot()),
                          AppSpacing.hGap8,
                          Text(
                            '${session.start}–${session.end}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap8,
                      content,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time column with status dot
                      SizedBox(
                        width: 68,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TeacherStatusDot(
                                  status: _getStatusForDot(),
                                  size: 8,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    session.start,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!compact)
                              Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Text(
                                  session.end,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: compact ? 44 : 68,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.primary,
                              cs.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Expanded(child: content),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
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
      'in_progress' => (cs.primaryContainer, cs.onPrimaryContainer),
      'completed' => (
        AchievementColors.green.withValues(alpha: 0.15),
        AchievementColors.green,
      ),
      'cancelled' => (cs.errorContainer, cs.onErrorContainer),
      _ when label.startsWith('Quá giờ') => (
        AchievementColors.yellow.withValues(alpha: 0.15),
        AchievementColors.yellow,
      ),
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
