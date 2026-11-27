import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_complete_session_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_needs_info_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_editor.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/features/teacher/presentation/widgets/session_card.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherSessionScreen extends StatefulWidget {
  const TeacherSessionScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.workplaceLabel,
    this.occurrence,
  });
  final TeacherApi api;
  final String classId;
  final String? sessionId;
  final String workplaceLabel;
  final TeacherOccurrence? occurrence;
  @override
  State<TeacherSessionScreen> createState() => _TeacherSessionScreenState();
}

class _TeacherSessionScreenState extends State<TeacherSessionScreen> {
  late Future<(TeacherClassData, Map<String, dynamic>)> _future;
  late String? _sessionId = widget.sessionId;
  bool _createdWithoutId = false;
  bool _saving = false;
  bool _changed = false;
  Object? _error;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(TeacherClassData, Map<String, dynamic>)> _load() async {
    final detail = TeacherClassData(
      teacherPayload(await widget.api.get('/classes/${widget.classId}')),
    );
    final session = _sessionId == null
        ? widget.occurrence!.json
        : teacherPayload(
            await widget.api.get(
              '/classes/${widget.classId}/sessions/${_sessionId}',
            ),
          );
    return (detail, session);
  }

  void _reload() => setState(() {
    _future = _load();
  });

  Future<void> _cancel(String className, String schedule) async {
    if (_saving) return;
    var draftReason = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy buổi học?'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(className),
            if (schedule.isNotEmpty) Text(schedule),
            AppSpacing.vGap8,
            const Text('Buổi dạy sẽ chuyển sang trạng thái Đã hủy.'),
            AppSpacing.vGap12,
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Lý do hủy'),
              onChanged: (value) => draftReason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, draftReason.trim()),
            child: const Text('Hủy buổi học'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.delete(
        '/classes/${widget.classId}/sessions/${_sessionId}',
        data: {'cancel_reason': reason},
      );
      if (mounted) _markChanged();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _markChanged() {
    _changed = true;
    _reload();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_changed && !_saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_saving) Navigator.of(context).pop(true);
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Chi tiết buổi dạy')),
      body: FutureBuilder<(TeacherClassData, Map<String, dynamic>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
          }
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (detail, session) = snapshot.data!;
          final canManage =
              detail.canManage && widget.api is! TeacherPreviewApi;
          final sessionId = _sessionId;
          final projected = sessionId == null;
          final rawDate = widget.occurrence != null && projected
              ? teacherDate(widget.occurrence!.date)
              : session['date']?.toString() ?? '';
          final sessionDate = DateTime.tryParse(rawDate.split('T').first);
          final date = sessionDate == null ? rawDate : teacherDate(sessionDate);
          final displayDate = sessionDate == null
              ? date
              : DateFormat('dd/MM/yyyy').format(sessionDate);
          final start = teacherTime(session['start_time']);
          final end = teacherTime(session['end_time']);
          final schedule = [
            displayDate,
            if (start.isNotEmpty && end.isNotEmpty) '$start–$end',
          ].where((value) => value.isNotEmpty).join(' · ');
          final status = session['status']?.toString() ?? 'scheduled';
          final cancelled = status == 'cancelled';
          final completed = status == 'completed';
          final role =
              (session['teacher_role'] ??
                      widget.occurrence?.json['teacher_role'])
                  ?.toString();
          final isAssistant = role == 'assistant';
          final confirmStatus =
              (session['hour_confirmation_status'] ??
                      widget.occurrence?.json['hour_confirmation_status'])
                  ?.toString();
          final needsInfo = confirmStatus == 'needs_info';
          final rejectionReason =
              (session['rejection_reason'] ??
                      widget.occurrence?.json['rejection_reason'])
                  ?.toString()
                  .trim() ??
              '';
          final roomLink =
              (session['room_link'] ?? widget.occurrence?.json['room_link'])
                  ?.toString()
                  .trim() ??
              '';
          final livestreamId =
              (session['livestream_session_id'] ??
                      widget.occurrence?.json['livestream_session_id'])
                  ?.toString()
                  .trim() ??
              '';
          final canJoin =
              !cancelled && (livestreamId.isNotEmpty || roomLink.isNotEmpty);
          final canEdit =
              canManage && !cancelled && !isAssistant && sessionId != null;
          final ended = _hasEnded(date, end);
          final canComplete = canEdit && !completed && ended && !needsInfo;
          final canCreate =
              !_createdWithoutId && projected && canManage && !isAssistant;
          final cs = Theme.of(context).colorScheme;
          final tt = Theme.of(context).textTheme;
          final topic = session['topic']?.toString().trim() ?? '';
          final notes = session['notes']?.toString().trim() ?? '';
          final room = session['room']?.toString().trim() ?? '';
          final cancelReason =
              session['cancel_reason']?.toString().trim() ?? '';
          final statusLabel = switch (status) {
            _ when _createdWithoutId => 'Đã tạo buổi học',
            _ when projected => 'Lịch dự kiến · chưa tạo buổi',
            'scheduled' when ended => 'Quá giờ · Chưa bắt đầu',
            'in_progress' when ended => 'Quá giờ · Chưa hoàn tất',
            _ => teacherStatus(status),
          };

          Future<void> openEditor() async {
            final result = await teacherPush<Object?>(
              context,
              TeacherScheduleEditor(
                api: widget.api,
                classId: detail.id,
                sessionId: sessionId,
                initialDate: projected ? widget.occurrence?.date : null,
                initial: session,
              ),
            );
            if (!mounted) return;
            if (result is String) {
              _sessionId = result;
            } else if (result == true && projected) {
              _createdWithoutId = true;
            } else if (result != true) {
              return;
            }
            _markChanged();
          }

          final actions = <(IconData, String, VoidCallback)>[
            if (needsInfo && sessionId != null)
              (
                Icons.info_outline,
                'Xem yêu cầu bổ sung',
                () => teacherPush<void>(
                  context,
                  TeacherNeedsInfoScreen(
                    api: widget.api,
                    classId: detail.id,
                    sessionId: sessionId,
                    className: detail.name,
                    date: date,
                    isAssistant: isAssistant,
                    initial: {...?widget.occurrence?.json, ...session},
                  ),
                ),
              ),
            if (canComplete)
              (
                Icons.check_circle_outline,
                'Hoàn tất buổi dạy',
                () async {
                  final result = await teacherPush<bool>(
                    context,
                    TeacherCompleteSessionScreen(
                      onAttendanceSaved: _markChanged,
                      api: widget.api,
                      classId: detail.id,
                      sessionId: sessionId,
                      className: detail.name,
                      date: date,
                    ),
                  );
                  if (result == true && mounted) _markChanged();
                },
              ),
            if (canJoin)
              (
                Icons.videocam_outlined,
                'Vào phòng học',
                () {
                  if (livestreamId.isNotEmpty) {
                    teacherPush<void>(
                      context,
                      TeacherLiveSessionScreen(
                        api: widget.api,
                        sessionId: livestreamId,
                      ),
                    );
                  } else {
                    launchTeacherUrl(context, roomLink);
                  }
                },
              ),
            if (canCreate)
              (Icons.event_available_outlined, 'Tạo buổi học', openEditor),
            if (canEdit)
              (
                Icons.fact_check_outlined,
                'Điểm danh',
                () => teacherPush<Object?>(
                  context,
                  TeacherAttendanceScreen(
                    onSaved: _markChanged,
                    api: widget.api,
                    classId: detail.id,
                    sessionId: sessionId,
                    title: detail.name,
                    sessionDate: date,
                    startTime: start,
                    endTime: end,
                  ),
                ),
              ),
          ];
          final primary = actions.firstOrNull;

          final showsConfirmation =
              completed || needsInfo || confirmStatus == 'confirmed';
          final hasContent =
              topic.isNotEmpty || notes.isNotEmpty || room.isNotEmpty;
          final notices = [
            if (cancelled && cancelReason.isNotEmpty)
              'Lý do hủy: $cancelReason',
            if (detail.archived) 'Lớp đã lưu trữ · Chỉ xem',
            if (!projected && !cancelled && !completed && isAssistant)
              'Chờ giáo viên chính hoàn tất',
            if (_createdWithoutId) 'Quay lại Lịch để xem buổi mới.',
            if (role == 'substitute')
              'Người dạy thay chỉ xem được buổi được giao.',
          ];
          final related = <(IconData, String, VoidCallback)>[
            ...actions.skip(1),
            if (role != 'substitute')
              (
                Icons.school_outlined,
                'Lớp và học viên',
                () => teacherPush<Object?>(
                  context,
                  TeacherClassScreen(
                    api: widget.api,
                    classId: detail.id,
                    workplaceLabel: widget.workplaceLabel,
                  ),
                ),
              ),
            (
              Icons.video_camera_front_outlined,
              'Phiên trực tuyến của lớp',
              () => teacherPush<Object?>(
                context,
                TeacherLiveSessionsScreen(api: widget.api, classId: detail.id),
              ),
            ),
          ];

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: SafeArea(
              top: false,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.paddingLg,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  detail.name,
                                  style: tt.titleLarge?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (canEdit)
                                PopupMenuButton<bool>(
                                  tooltip: 'Quản lý buổi học',
                                  iconColor: cs.onPrimaryContainer,
                                  enabled: !_saving,
                                  onSelected: (cancel) {
                                    if (cancel) {
                                      _cancel(detail.name, schedule);
                                    } else {
                                      openEditor();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: false,
                                      child: Text('Chỉnh sửa buổi học'),
                                    ),
                                    PopupMenuItem(
                                      value: true,
                                      child: Text('Hủy buổi học'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            children: [
                              if (displayDate.isNotEmpty)
                                _SessionMeta(
                                  icon: Icons.calendar_today_outlined,
                                  text: displayDate,
                                ),
                              if (start.isNotEmpty && end.isNotEmpty)
                                _SessionMeta(
                                  icon: Icons.schedule,
                                  text: '$start–$end',
                                ),
                              if (widget.workplaceLabel.trim().isNotEmpty)
                                _SessionMeta(
                                  icon: Icons.place_outlined,
                                  text: widget.workplaceLabel,
                                ),
                            ],
                          ),
                          AppSpacing.vGap12,
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              TeacherSessionStatusLabel(
                                label: statusLabel,
                                status: status,
                              ),
                              if (role == 'main' ||
                                  role == 'substitute' ||
                                  role == 'assistant')
                                TeacherRoleBadge(role: role!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasContent ||
                      showsConfirmation ||
                      notices.isNotEmpty) ...[
                    AppSpacing.vGap12,
                    TeacherSurface(
                      showShadow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notices.isNotEmpty) ...[
                            for (final notice in notices)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: Text(
                                  notice,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cancelled
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                          if (hasContent) ...[
                            if (notices.isNotEmpty) AppSpacing.vGap8,
                            Text('Nội dung buổi học', style: tt.titleSmall),
                            if (topic.isNotEmpty) ...[
                              AppSpacing.vGap4,
                              Text(topic, style: tt.bodyLarge),
                            ],
                            if (notes.isNotEmpty) ...[
                              AppSpacing.vGap4,
                              Text(
                                notes,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (room.isNotEmpty) ...[
                              AppSpacing.vGap8,
                              Text('Phòng: $room', style: tt.bodyMedium),
                            ],
                          ],
                          if (showsConfirmation) ...[
                            if (hasContent || notices.isNotEmpty)
                              const Divider(height: AppSpacing.xl),
                            Text('Xác nhận giờ dạy', style: tt.titleSmall),
                            AppSpacing.vGap4,
                            Text(
                              switch (confirmStatus) {
                                'needs_info' => 'Cần bổ sung',
                                'confirmed' => 'Đã xác nhận',
                                'pending' => 'Chờ xác nhận',
                                _ => 'Chưa có thông tin xác nhận',
                              },
                              style: tt.bodyMedium?.copyWith(
                                color: needsInfo
                                    ? cs.error
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                            if (needsInfo && rejectionReason.isNotEmpty) ...[
                              AppSpacing.vGap4,
                              Text(rejectionReason, style: tt.bodyMedium),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    AppSpacing.vGap12,
                    Text(
                      'Chưa cập nhật được. ${teacherErrorMessage(_error!)}',
                      style: tt.bodyMedium?.copyWith(color: cs.error),
                    ),
                  ],
                  if (primary != null) ...[
                    AppSpacing.vGap16,
                    FilledButton.icon(
                      onPressed: _saving ? null : primary.$3,
                      icon: Icon(primary.$1),
                      label: Text(primary.$2),
                    ),
                  ],
                  AppSpacing.vGap12,
                  TeacherSurface(
                    showShadow: false,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < related.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, indent: AppSpacing.lg),
                          ListTile(
                            leading: Icon(related[i].$1, color: cs.primary),
                            title: Text(related[i].$2),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _saving ? null : related[i].$3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _SessionMeta extends StatelessWidget {
  const _SessionMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.sm, color: color),
        AppSpacing.hGap4,
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

bool _hasEnded(String date, String end) {
  final time = DateTime.tryParse('$date $end');
  return time != null && !time.isAfter(DateTime.now());
}
