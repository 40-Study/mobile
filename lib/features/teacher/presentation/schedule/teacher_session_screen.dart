import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_complete_session_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_needs_info_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_editor.dart';
import 'package:study/features/teacher/presentation/widgets/session_card.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/theme/app_spacing.dart';
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
        final completed = session['status'] == 'completed';

        // Vai trò của người dạy: main, substitute, assistant
        final role = session['teacher_role']?.toString();
        final isAssistant = role == 'assistant';
        final isMainOrSubstitute = role == 'main' || role == 'substitute';
        final roleLabel = switch (role) {
          'main' => 'Chính',
          'substitute' => 'Dạy thay',
          'assistant' => 'Trợ giảng',
          _ => null,
        };

        // Trạng thái xác nhận giờ: pending, confirmed, needs_info
        final confirmStatus = session['hour_confirmation_status']?.toString();
        final needsInfo = confirmStatus == 'needs_info';

        // Link phòng học
        final roomLink = session['room_link']?.toString();
        final hasRoomLink = roomLink != null && roomLink.isNotEmpty;

        // Có thể hoàn tất: buổi đã tạo, chưa hoàn tất, là giáo viên chính/dạy thay
        final canComplete = !projected &&
            !cancelled &&
            !completed &&
            isMainOrSubstitute &&
            _sessionId != null;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            detail.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        // Badge vai trò
                        if (roleLabel != null)
                          _RoleBadge(role: role!, label: roleLabel),
                      ],
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
                    Row(
                      children: [
                        TeacherSessionStatusLabel(
                          label: projected
                              ? 'Lịch dự kiến · chưa tạo buổi'
                              : teacherStatus(session['status']),
                          status: session['status']?.toString() ?? 'scheduled',
                        ),
                        if (needsInfo) ...[
                          AppSpacing.hGap8,
                          _ConfirmStatusBadge(status: 'needs_info'),
                        ] else if (confirmStatus == 'confirmed') ...[
                          AppSpacing.hGap8,
                          _ConfirmStatusBadge(status: 'confirmed'),
                        ] else if (completed && confirmStatus == 'pending') ...[
                          AppSpacing.hGap8,
                          _ConfirmStatusBadge(status: 'pending'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Nút "Vào lớp" - mở link phòng
              if (!cancelled && hasRoomLink) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => launchTeacherUrl(roomLink),
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Vào lớp'),
                  ),
                ),
              ],
              // Nút "Vào lớp" bị tắt khi buổi đã hủy (K12)
              if (cancelled && hasRoomLink) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.videocam_off_outlined),
                    label: const Text('Vào lớp'),
                  ),
                ),
                Text(
                  'Buổi đã hủy, không thể vào lớp',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

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

              // Nút Hoàn tất hoặc Cần bổ sung (cho giáo viên chính/dạy thay)
              if (canComplete && !needsInfo)
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _saving
                      ? null
                      : () async {
                          final result = await teacherPush<bool>(
                            context,
                            TeacherCompleteSessionScreen(
                              api: widget.api,
                              classId: detail.id,
                              sessionId: _sessionId!,
                              className: detail.name,
                              date: date,
                            ),
                          );
                          if (result == true && mounted) _reload();
                        },
                  label: const Text('Hoàn tất buổi dạy'),
                ),

              // Nút mở Cần bổ sung (giờ bị trả về)
              if (needsInfo && isMainOrSubstitute) ...[
                _NeedsInfoCard(
                  rejectionReason: session['rejection_reason']?.toString(),
                  onTap: () async {
                    final result = await teacherPush<bool>(
                      context,
                      TeacherNeedsInfoScreen(
                        api: widget.api,
                        classId: detail.id,
                        sessionId: _sessionId!,
                        className: detail.name,
                        date: date,
                        isAssistant: false,
                      ),
                    );
                    if (result == true && mounted) _reload();
                  },
                ),
              ],

              // Trợ giảng với buổi cần bổ sung: chỉ xem lý do
              if (needsInfo && isAssistant) ...[
                _NeedsInfoCard(
                  rejectionReason: session['rejection_reason']?.toString(),
                  onTap: () => teacherPush<void>(
                    context,
                    TeacherNeedsInfoScreen(
                      api: widget.api,
                      classId: detail.id,
                      sessionId: _sessionId!,
                      className: detail.name,
                      date: date,
                      isAssistant: true,
                    ),
                  ),
                ),
              ],

              // Trợ giảng: thông báo chờ giáo viên chính hoàn tất (K15)
              if (!projected && !cancelled && !completed && isAssistant)
                _AssistantWaitingCard(),

              const SizedBox(height: 12),
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
              // Người dạy thay chỉ thấy buổi được giao, không mở được lớp (K5)
              if (role != 'substitute')
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
              if (role == 'substitute')
                Text(
                  'Người dạy thay chỉ xem được buổi được giao.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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

/// Badge hiển thị vai trò của giáo viên trên buổi dạy
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.label});

  final String role;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (role) {
      'main' => (cs.primaryContainer, cs.onPrimaryContainer),
      'substitute' => (cs.tertiaryContainer, cs.onTertiaryContainer),
      'assistant' => (cs.secondaryContainer, cs.onSecondaryContainer),
      _ => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge hiển thị trạng thái xác nhận giờ
class _ConfirmStatusBadge extends StatelessWidget {
  const _ConfirmStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Đã xác nhận', AchievementColors.green),
      'needs_info' => ('Cần bổ sung', AchievementColors.red),
      'pending' => ('Chờ xác nhận', AchievementColors.yellow),
      _ => ('', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Card hiển thị thông báo cần bổ sung với lý do từ trung tâm
class _NeedsInfoCard extends StatelessWidget {
  const _NeedsInfoCard({this.rejectionReason, required this.onTap});

  final String? rejectionReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AchievementColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AchievementColors.red,
                  size: 24,
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cần bổ sung thông tin',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AchievementColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (rejectionReason != null && rejectionReason!.isNotEmpty)
                        Text(
                          rejectionReason!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AchievementColors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card thông báo cho trợ giảng khi buổi chưa được hoàn tất
class _AssistantWaitingCard extends StatelessWidget {
  const _AssistantWaitingCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.hourglass_empty,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
            AppSpacing.hGap8,
            Expanded(
              child: Text(
                'Chờ giáo viên chính hoàn tất',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
