import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

/// Danh sách buổi cấu thành nhóm trong báo cáo (T10 theo spec).
class TeacherReportListScreen extends StatelessWidget {
  const TeacherReportListScreen({
    super.key,
    required this.api,
    required this.title,
    required this.sessions,
    required this.classes,
    required this.workplaceLabel,
  });

  final TeacherApi api;
  final String title;
  final List<Map<String, dynamic>> sessions;
  final List<TeacherClassData> classes;
  final String workplaceLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final classById = {for (final c in classes) c.id: c};

    // Sort by date desc
    final sorted = List<Map<String, dynamic>>.from(sessions)
      ..sort((a, b) {
        final dateA = DateTime.tryParse('${a['date']}') ?? DateTime(2000);
        final dateB = DateTime.tryParse('${b['date']}') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: sorted.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  AppSpacing.vGap12,
                  Text(
                    'Không có buổi nào',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: AppSpacing.paddingScreenAll,
              itemCount: sorted.length,
              separatorBuilder: (_, __) => AppSpacing.vGap8,
              itemBuilder: (context, index) {
                final session = sorted[index];
                final classData = classById[session['class_id']?.toString()];
                final className = classData?.name ?? 'Lớp học';
                final date = session['date']?.toString() ?? '';
                final startTime = teacherTime(session['start_time']);
                final endTime = teacherTime(session['end_time']);
                final duration = _durationMinutes(session);
                final hours = duration ~/ 60;
                final mins = duration % 60;
                final durationText = hours > 0
                    ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
                    : '$mins phút';

                // Vai trò (nếu có)
                final role = session['teacher_role']?.toString();
                final roleLabel = switch (role) {
                  'main' => 'Chính',
                  'substitute' => 'Dạy thay',
                  'assistant' => 'Trợ giảng',
                  _ => null,
                };

                // Trạng thái xác nhận
                final confirmStatus = session['hour_confirmation_status']?.toString() ?? 'pending';
                final (statusLabel, statusColor) = switch (confirmStatus) {
                  'confirmed' => ('Đã xác nhận', AchievementColors.green),
                  'needs_info' => ('Cần bổ sung', AchievementColors.red),
                  _ => ('Chờ xác nhận', AchievementColors.yellow),
                };

                return Material(
                  color: cs.surfaceContainerLowest,
                  borderRadius: AppRadius.borderMd,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: classData != null
                        ? () => teacherPush<void>(
                            context,
                            TeacherSessionScreen(
                              api: api,
                              classId: classData.id,
                              sessionId: session['session_id']?.toString(),
                              workplaceLabel: workplaceLabel,
                            ),
                          )
                        : null,
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  className,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (roleLabel != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh,
                                    borderRadius: AppRadius.borderSm,
                                  ),
                                  child: Text(
                                    roleLabel,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          AppSpacing.vGap4,
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: cs.onSurfaceVariant,
                              ),
                              AppSpacing.hGap4,
                              Text(
                                date,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              AppSpacing.hGap12,
                              Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: cs.onSurfaceVariant,
                              ),
                              AppSpacing.hGap4,
                              Text(
                                '$startTime–$endTime',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Text(
                                  statusLabel,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AppSpacing.hGap12,
                              Text(
                                durationText,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (classData != null)
                                Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: cs.onSurfaceVariant,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  int _durationMinutes(Map<String, dynamic> session) {
    final start = session['start_time']?.toString() ?? '00:00';
    final end = session['end_time']?.toString() ?? '00:00';
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMin = (int.tryParse(startParts.first) ?? 0) * 60 +
        (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
    final endMin = (int.tryParse(endParts.first) ?? 0) * 60 +
        (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);
    return endMin > startMin ? endMin - startMin : 0;
  }
}
