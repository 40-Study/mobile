import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_editor.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/theme/app_spacing.dart';

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
  bool _saving = false;
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

  Future<void> _cancel() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy buổi học?'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Lý do hủy'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Hủy buổi học'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.put(
        '/classes/${widget.classId}/sessions/${_sessionId}',
        data: {'status': 'cancelled', 'cancel_reason': reason},
      );
      if (mounted) _reload();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chi tiết buổi dạy')),
    body: FutureBuilder<(TeacherClassData, Map<String, dynamic>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final (detail, session) = snapshot.data!;
        final projected = _sessionId == null;
        final date = projected
            ? teacherDate(widget.occurrence!.date)
            : '${session['date']}';
        final cancelled = session['status'] == 'cancelled';
        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: ListView(
            padding: AppSpacing.paddingScreenAll,
            children: [
              TeacherSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.workplaceLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${teacherTime(session['start_time'])}–${teacherTime(session['end_time'])}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                date,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TeacherSessionStatusLabel(
                      label: projected
                          ? 'Lịch dự kiến · chưa tạo buổi'
                          : teacherStatus(session['status']),
                      status: session['status']?.toString() ?? 'scheduled',
                    ),
                  ],
                ),
              ),
              if ('${session['topic'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Nội dung buổi học',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('${session['topic']}'),
              ],
              if ('${session['notes'] ?? ''}'.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${session['notes']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (session['room'] != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.meeting_room_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text('Phòng: ${session['room']}'),
                ),
              if (cancelled)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Lý do hủy: ${session['cancel_reason'] ?? 'Không có'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (detail.archived)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Lớp đã lưu trữ, hiện chỉ được xem.'),
                ),
              const SizedBox(height: 24),
              if (!projected && !cancelled && detail.canManage)
                FilledButton.icon(
                  icon: const Icon(Icons.fact_check_outlined),
                  onPressed: _saving
                      ? null
                      : () => teacherPush<Object?>(
                          context,
                          TeacherAttendanceScreen(
                            api: widget.api,
                            classId: detail.id,
                            sessionId: _sessionId!,
                            title: '${detail.name} · $date',
                          ),
                        ),
                  label: const Text('Điểm danh'),
                ),
              if (projected && detail.canManage)
                FilledButton(
                  onPressed: () async {
                    final result = await teacherPush<Object?>(
                      context,
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        initialDate: widget.occurrence!.date,
                        initial: session,
                      ),
                    );
                    if (mounted) {
                      if (result is String) _sessionId = result;
                      _reload();
                    }
                  },
                  child: const Text('Tạo buổi học để điểm danh'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => teacherPush<Object?>(
                  context,
                  TeacherClassScreen(
                    api: widget.api,
                    classId: detail.id,
                    workplaceLabel: widget.workplaceLabel,
                  ),
                ),
                child: const Text('Xem lớp và học viên'),
              ),
              if (!projected && detail.canManage && !cancelled) ...[
                const SizedBox(height: 16),
                Text(
                  'Quản lý buổi học',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          await teacherPush<Object?>(
                            context,
                            TeacherScheduleEditor(
                              api: widget.api,
                              classId: detail.id,
                              sessionId: _sessionId,
                              initial: session,
                            ),
                          );
                          if (mounted) _reload();
                        },
                  child: const Text('Chỉnh sửa buổi học'),
                ),
                TextButton(
                  onPressed: _saving ? null : _cancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(_saving ? 'Đang cập nhật…' : 'Hủy buổi học'),
                ),
              ],
              if (session['livestream_session_id'] != null)
                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () => teacherPush<Object?>(
                          context,
                          TeacherLiveSessionScreen(
                            api: widget.api,
                            sessionId: session['livestream_session_id']
                                .toString(),
                          ),
                        ),
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Xem phòng dạy trực tuyến'),
                ),
              OutlinedButton(
                onPressed: () => teacherPush<Object?>(
                  context,
                  TeacherLiveSessionsScreen(
                    api: widget.api,
                    classId: detail.id,
                  ),
                ),
                child: const Text('Các phiên trực tuyến của lớp'),
              ),
              if (_error != null)
                Text(
                  'Chưa cập nhật được: $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        );
      },
    ),
  );
}
