import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/student/presentation/home/widgets/curved_surface_tray.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_advanced_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_messages_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_professional_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';
import 'package:study/widgets/section_header.dart';

import 'teacher_next_session_card.dart';
import 'teacher_quick_actions.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({
    super.key,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
    required this.onSchedule,
    required this.onClasses,
    required this.onCourses,
    this.greetingName,
  });
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;
  final VoidCallback onSchedule;
  final VoidCallback onClasses;
  final VoidCallback onCourses;
  final String? greetingName;
  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _revision = 0;
  bool _openingProfile = false;
  Object? _profileError;
  void _reload() => setState(() => _revision++);
  Future<void> _session(TeacherOccurrence session) async {
    await teacherPush<Object?>(
      context,
      TeacherSessionScreen(
        api: widget.api,
        classId: session.classId,
        sessionId: session.sessionId,
        occurrence: session,
        workplaceLabel: widget.workplaceLabel,
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _professional() async {
    setState(() {
      _openingProfile = true;
      _profileError = null;
    });
    try {
      final application = await teacherLoadApplication(widget.api);
      if (!mounted) return;
      await teacherPush<Object?>(
        context,
        TeacherProfessionalScreen(api: widget.api, application: application),
      );
    } catch (error) {
      if (mounted) setState(() => _profileError = error);
    } finally {
      if (mounted) setState(() => _openingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final greeting = now.hour < 12
        ? 'Chào buổi sáng'
        : now.hour < 18
        ? 'Chào buổi chiều'
        : 'Chào buổi tối';
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: AppSpacing.paddingScreenAll,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.greetingName?.trim().isNotEmpty == true
                          ? 'Chào ${widget.greetingName}'
                          : greeting,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vGap8,
                    Text(
                      DateFormat('dd/MM/yyyy').format(today),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hộp thư',
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => teacherPush<Object?>(
                  context,
                  TeacherMessagesScreen(api: widget.api),
                ),
              ),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        CurvedSurfaceTray(
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TeacherAsyncView<List<TeacherOccurrence>>(
                key: ValueKey(_revision),
                load: () => teacherLoadTimetable(
                  widget.api,
                  widget.organizationId,
                  today,
                  today,
                ),
                builder: (context, sessions) {
                  final upcoming = sessions
                      .where(
                        (s) =>
                            s.status != 'completed' &&
                            s.status != 'cancelled' &&
                            (s.status == 'in_progress' ||
                                s.end.compareTo(
                                      DateFormat('HH:mm').format(now),
                                    ) >=
                                    0),
                      )
                      .toList();
                  final next = upcoming.isEmpty ? null : upcoming.first;
                  var overlap = false;
                  for (var i = 0; i < sessions.length; i++) {
                    for (var j = i + 1; j < sessions.length; j++) {
                      if (sessions[j].start.compareTo(sessions[i].end) < 0 &&
                          sessions[j].end.compareTo(sessions[i].start) > 0)
                        overlap = true;
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sessions.isNotEmpty) ...[
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ActionChip(
                              avatar: Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text('${sessions.length} buổi dạy'),
                              onPressed: widget.onSchedule,
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.task_alt_rounded,
                                size: 16,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              side: BorderSide.none,
                              label: Text(
                                '${sessions.where((s) => s.status == 'completed').length} đã hoàn thành',
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vGap24,
                      ],
                      if (next != null) ...[
                        const SectionHeader(title: 'Buổi tiếp theo'),
                        AppSpacing.vGap12,
                        TeacherNextSessionCard(
                          session: next,
                          onTap: () => _session(next),
                        ),
                      ],
                      if (overlap)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                color: theme.colorScheme.tertiary,
                              ),
                              AppSpacing.hGap8,
                              const Expanded(
                                child: Text(
                                  'Có các buổi trùng giờ. Kiểm tra lịch trước khi bắt đầu.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      TeacherSectionTitle(
                        title: 'Lịch hôm nay',
                        trailing: TextButton(
                          onPressed: widget.onSchedule,
                          child: const Text('Xem lịch'),
                        ),
                      ),
                      if (sessions.isEmpty)
                        TeacherSurface(
                          child: EmptyState(
                            style: EmptyStateStyle.inline,
                            icon: Icons.event_available_outlined,
                            title: 'Hôm nay bạn không có buổi dạy.',
                            message:
                                'Bạn có thể xem lịch sắp tới hoặc tiếp tục chuẩn bị học liệu.',
                            actionLabel: 'Xem lịch dạy',
                            onAction: widget.onSchedule,
                          ),
                        ),
                      for (final session in sessions)
                        TeacherSessionRow(
                          session: session,
                          api: widget.api,
                          workplaceLabel: widget.workplaceLabel,
                          compact: true,
                          onChanged: _reload,
                        ),
                    ],
                  );
                },
              ),
              const TeacherSectionTitle(title: 'Công việc giảng dạy'),
              TeacherQuickActions(
                onClasses: widget.onClasses,
                onCourses: widget.onCourses,
              ),
              AppSpacing.vGap12,
              TeacherSurface(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    TeacherActionTile(
                      icon: Icons.badge_outlined,
                      title: 'Hồ sơ giảng dạy',
                      subtitle: 'Chuyên môn, kinh nghiệm và chứng chỉ',
                      busy: _openingProfile,
                      onTap: _openingProfile ? null : _professional,
                    ),
                    const Divider(height: 1, indent: 68),
                    TeacherActionTile(
                      icon: Icons.apps_rounded,
                      title: 'Công cụ giảng dạy',
                      subtitle: 'Phòng học, trao đổi và học liệu',
                      onTap: () => teacherPush<Object?>(
                        context,
                        TeacherAdvancedScreen(api: widget.api),
                      ),
                    ),
                  ],
                ),
              ),
              if (_profileError != null)
                TeacherErrorView(error: _profileError!, onRetry: _professional),
            ],
          ),
        ),
      ],
    );
  }
}
