import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_timeline.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_list_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_reminders_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_needs_info_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/session_card.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({
    super.key,
    required this.api,
    this.leaveApi,
    required this.organizationId,
    required this.workplaceLabel,
    this.teacherName,
    this.onNavigateToReport,
    this.onNeedsAttentionCountChanged,
    this.onSessionChanged,
    this.now = DateTime.now,
  });
  final TeacherApi api;
  final TeacherApi? leaveApi;
  final String? organizationId;
  final String workplaceLabel;
  final String? teacherName;

  /// Callback để chuyển sang tab Báo cáo (tap vào dòng tổng tháng)
  final ValueChanged<DateTime>? onNavigateToReport;

  /// Callback để sync số buổi cần xử lý lên WorkplaceController
  final void Function(int count)? onNeedsAttentionCountChanged;
  final VoidCallback? onSessionChanged;
  final DateTime Function() now;

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  late DateTime _selected;
  late Future<_ScheduleData> _future;
  String? _classId;
  bool _month = false;
  final _classNames = <String, String>{};
  bool _showOnlyNeedsAttention = false;
  final _agendaKey = GlobalKey();
  int _loadRevision = 0;
  int _attendanceEpoch = 0;
  int _attendanceRunning = 0;
  final _attendance = <String, bool?>{};
  final _attendancePending = <String>{};
  final _attendancePermissions = <String, Future<bool>>{};
  late final AppLifecycleListener _lifecycle;
  Timer? _minuteTimer;

  @override
  void initState() {
    super.initState();
    final now = widget.now();
    _selected = DateTime(now.year, now.month, now.day);
    _future = _load();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _scheduleMinuteTick();
        _reload();
      },
    );
    _scheduleMinuteTick();
  }

  @override
  void didUpdateWidget(covariant TeacherScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId ||
        oldWidget.api != widget.api) {
      _classId = null;
      _classNames.clear();
      _showOnlyNeedsAttention = false;
      _invalidateAttendance();
      _future = _load();
    }
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _scheduleMinuteTick() {
    _minuteTimer?.cancel();
    final now = widget.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _minuteTimer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleMinuteTick();
    });
  }

  void _invalidateAttendance() {
    _attendanceEpoch++;
    _attendance.clear();
    _attendancePending.clear();
    _attendancePermissions.clear();
  }

  DateTime get _weekStart => DateTime(
    _selected.year,
    _selected.month,
    _selected.day - _selected.weekday + 1,
  );

  String _formatSelectedDate() {
    final now = widget.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selected.year, _selected.month, _selected.day);

    if (selected == today) return 'Hôm nay';
    if (selected == today.add(const Duration(days: 1))) return 'Ngày mai';
    if (selected == today.subtract(const Duration(days: 1))) return 'Hôm qua';

    final weekdays = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return '${weekdays[_selected.weekday]}, ${DateFormat('dd/MM').format(_selected)}';
  }

  Future<_ScheduleData> _load() async {
    final revision = ++_loadRevision;
    final api = widget.api;
    final organizationId = widget.organizationId;
    final selected = _selected;
    final monthStart = DateTime(selected.year, selected.month);
    final monthEnd = DateTime(selected.year, selected.month + 1, 0);
    final weekStart = _weekStart;
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
    );
    final from = weekStart.isBefore(monthStart) ? weekStart : monthStart;
    final to = weekEnd.isAfter(monthEnd) ? weekEnd : monthEnd;
    final classes = await teacherAssignedClasses(api);
    if (!mounted || revision != _loadRevision)
      return const _ScheduleData.empty();
    final today = widget.now();
    final results = await Future.wait([
      teacherLoadTimetable(
        api,
        organizationId,
        from,
        to,
        assignedClasses: classes,
      ),
      teacherLoadTimetable(
        api,
        organizationId,
        DateTime(today.year, today.month),
        DateTime(today.year, today.month, today.day + 30),
        assignedClasses: classes,
      ),
    ]);
    if (!mounted || revision != _loadRevision)
      return const _ScheduleData.empty();
    final sessions = results[0];
    final todaySessions = results[1];
    final monthSessions = sessions.where(
      (s) => s.date.year == selected.year && s.date.month == selected.month,
    );

    final now = widget.now();

    // Tìm buổi cần xử lý: quá giờ chưa hoàn tất hoặc cần bổ sung
    final needsAttention = <TeacherOccurrence>[];
    final currentMonth = todaySessions.where(
      (s) => s.date.year == now.year && s.date.month == now.month,
    );
    final overdueIds = currentMonth
        .where((s) => _isOverdue(s, now))
        .map((s) => s.classId)
        .toSet();
    final writable = await Future.wait(
      overdueIds.map((id) async {
        try {
          final detail = TeacherClassData(
            teacherPayload(await api.get('/classes/$id')),
          );
          return detail.canManage ? id : null;
        } catch (_) {
          return null;
        }
      }),
    );
    for (final s in currentMonth) {
      final confirmStatus = s.json['hour_confirmation_status']?.toString();
      if (confirmStatus == 'needs_info' ||
          (writable.contains(s.classId) && _isOverdue(s, now))) {
        needsAttention.add(s);
      }
    }

    // Tính tổng tháng (chỉ buổi hoàn tất)
    var monthCompletedSessions = 0;
    var monthMinutes = 0;
    for (final s in monthSessions) {
      if (!s.projected && s.status == 'completed') {
        monthCompletedSessions++;
        final startTime = s.json['start_time']?.toString() ?? '00:00';
        final endTime = s.json['end_time']?.toString() ?? '00:00';
        final startParts = startTime.split(':');
        final endParts = endTime.split(':');
        final startMin =
            (int.tryParse(startParts.first) ?? 0) * 60 +
            (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
        final endMin =
            (int.tryParse(endParts.first) ?? 0) * 60 +
            (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);
        if (endMin > startMin) monthMinutes += endMin - startMin;
      }
    }

    // Sync needsAttention count lên WorkplaceController
    if (mounted && revision == _loadRevision) {
      widget.onNeedsAttentionCountChanged?.call(needsAttention.length);
    }

    return _ScheduleData(
      sessions: sessions,
      classes: classes.where((c) => c.inScope(organizationId)).toList(),
      needsAttention: needsAttention,
      monthCompletedSessions: monthCompletedSessions,
      monthMinutes: monthMinutes,
    );
  }

  void _sessionChanged() {
    if (!mounted) return;
    _reload();
    widget.onSessionChanged?.call();
  }

  void _reload() => setState(() {
    _invalidateAttendance();
    _future = _load();
  });

  DateTime _sessionEnd(TeacherOccurrence session) {
    final endParts = session.end.split(':');
    return DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      int.tryParse(endParts.first) ?? 23,
      endParts.length > 1 ? int.tryParse(endParts[1]) ?? 59 : 59,
    );
  }

  bool _isOverdue(TeacherOccurrence session, DateTime now) =>
      !session.projected &&
      session.json['teacher_role'] != 'assistant' &&
      session.json['hour_confirmation_status'] != 'needs_info' &&
      (session.status == 'scheduled' || session.status == 'in_progress') &&
      !_sessionEnd(session).isAfter(now);

  /// Quick start session via swipe (navigate to complete screen)
  Future<bool> _quickStartSession(TeacherOccurrence session) async {
    // Navigate to session screen để hoàn tất
    final result = await teacherPush<bool>(
      context,
      TeacherSessionScreen(
        api: widget.api,
        classId: session.classId,
        sessionId: session.sessionId,
        occurrence: session,
        workplaceLabel: widget.workplaceLabel,
      ),
    );
    if (result == true) _sessionChanged();
    return false; // Không dismiss item
  }

  /// Navigate to session detail screen
  Future<void> _navigateToSession(TeacherOccurrence session) async {
    final result = await teacherPush<bool>(
      context,
      TeacherSessionScreen(
        api: widget.api,
        classId: session.classId,
        sessionId: session.sessionId,
        occurrence: session,
        workplaceLabel: widget.workplaceLabel,
      ),
    );
    if (result == true) _sessionChanged();
  }

  /// Long-press preview cho session
  Future<void> _showSessionPreview(
    BuildContext context,
    TeacherOccurrence session,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final role = session.json['teacher_role']?.toString();
    final studentCount = session.json['student_count'];

    final openDetail = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  TeacherClassIcon(className: session.classData.name, size: 48),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.classData.name,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(session.date),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (role != null) TeacherRoleBadge(role: role),
                ],
              ),
              AppSpacing.vGap16,
              // Info rows
              _PreviewInfoRow(
                icon: Icons.access_time,
                label: 'Thời gian',
                value: '${session.start} - ${session.end}',
              ),
              if (session.topic.isNotEmpty)
                _PreviewInfoRow(
                  icon: Icons.subject,
                  label: 'Chủ đề',
                  value: session.topic,
                ),
              if (studentCount is num)
                _PreviewInfoRow(
                  icon: Icons.people_outline,
                  label: 'Học viên',
                  value: '$studentCount',
                ),
              _PreviewInfoRow(
                icon: Icons.info_outline,
                label: 'Trạng thái',
                value: teacherSessionStateLabel(session),
              ),
              AppSpacing.vGap16,
              // Actions
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xem chi tiết'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (openDetail == true && mounted) await _navigateToSession(session);
  }

  void _move(int direction) => setState(() {
    _selected = _month
        ? _inMonth(_selected.month + direction)
        : DateTime(
            _selected.year,
            _selected.month,
            _selected.day + 7 * direction,
          );
    _future = _load();
  });

  DateTime _inMonth(int month) {
    final start = DateTime(_selected.year, month);
    final last = DateTime(start.year, start.month + 1, 0).day;
    return DateTime(
      start.year,
      start.month,
      _selected.day > last ? last : _selected.day,
    );
  }

  Future<void> _filter() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: AppSpacing.paddingScreenAll,
                child: Text(
                  'Lọc theo lớp',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: const Text('Tất cả lớp'),
                selected: _classId == null,
                trailing: _classId == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, ''),
              ),
              for (final entry in _classNames.entries)
                ListTile(
                  title: Text(entry.value),
                  selected: _classId == entry.key,
                  trailing: _classId == entry.key
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, entry.key),
                ),
            ],
          ),
        ),
      ),
    );
    if (selection != null && mounted)
      setState(() => _classId = selection.isEmpty ? null : selection);
  }

  bool get _isToday => teacherDate(_selected) == teacherDate(widget.now());

  void _selectDay(DateTime date) {
    final sameMonth =
        date.year == _selected.year && date.month == _selected.month;
    setState(() {
      final previousWeek = _weekStart;
      _selected = date;
      if (!sameMonth || previousWeek != _weekStart) _future = _load();
    });
    if (!_month) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchor = _agendaKey.currentContext;
      if (mounted && anchor != null && _selected == date) {
        Scrollable.ensureVisible(
          anchor,
          alignment: 0.25,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  void _today() {
    final now = widget.now();
    setState(() {
      _selected = DateUtils.dateOnly(now);
      _showOnlyNeedsAttention = false;
      _invalidateAttendance();
      _future = _load();
    });
  }

  Widget _calendarMenu(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Tùy chọn lịch dạy',
    icon: const Icon(Icons.more_vert),
    onSelected: (value) {
      if (value == 'leave')
        teacherPush<Object?>(
          context,
          TeacherLeaveListScreen(
            api: widget.leaveApi ?? widget.api,
            organizationId: widget.organizationId,
            workplaceLabel: widget.workplaceLabel,
          ),
        );
      if (value == 'reminders')
        teacherPush<Object?>(context, TeacherRemindersScreen(api: widget.api));
      if (value == 'refresh') _reload();
      if (value == 'sample-needs-info') {
        teacherPush<void>(
          context,
          TeacherNeedsInfoScreen(
            api: widget.api,
            classId: 'sample-class',
            sessionId: 'sample-session',
            className: 'Buổi dạy mẫu',
            date: teacherDate(widget.now()),
            sample: true,
            initial: const {
              'start_time': '09:00',
              'end_time': '10:30',
              'rejection_reason': 'Bổ sung nội dung đã dạy.',
            },
          ),
        );
      }
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'leave', child: Text('Xin nghỉ')),
      PopupMenuItem(value: 'reminders', child: Text('Nhắc lịch')),
      if (teacherDevSamplesEnabled)
        PopupMenuItem(
          value: 'sample-needs-info',
          child: Text('Thử gửi bổ sung giờ dạy'),
        ),
      PopupMenuItem(value: 'refresh', child: Text('Tải lại')),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: teacherScheduleBackground(context),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<_ScheduleData>(
              future: _future,
              builder: (context, snapshot) {
                final done = snapshot.connectionState == ConnectionState.done;
                final ready = done && snapshot.hasData;
                final data = ready
                    ? snapshot.data!
                    : const _ScheduleData.empty();
                final sessions = data.sessions;
                if (ready) {
                  _classNames
                    ..clear()
                    ..addEntries(
                      data.classes.map((c) => MapEntry(c.id, c.name)),
                    );
                }

                final daySessions = sessions
                    .where(
                      (session) => DateUtils.isSameDay(session.date, _selected),
                    )
                    .toList();
                final rows = _showOnlyNeedsAttention
                    ? data.needsAttention
                    : daySessions
                          .where(
                            (session) =>
                                _classId == null || session.classId == _classId,
                          )
                          .toList();
                final now = widget.now();
                final next = !_showOnlyNeedsAttention && _isToday
                    ? _heroSession(rows, now)
                    : null;
                if (ready && !_showOnlyNeedsAttention) {
                  _scheduleAttendanceReads(
                    _month ? daySessions : sessions,
                    now,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (!_showOnlyNeedsAttention) ...[
                        // Expandable Calendar (week/month)
                        TeacherExpandableCalendar(
                          selectedDate: _selected,
                          weekStart: _weekStart,
                          isExpanded: _month,
                          sessions: sessions,
                          classFilter: _classId,
                          now: now,
                          onToday: _today,
                          dotFor: (session) => _dotFor(session, now),
                          onDateSelected: _selectDay,
                          onToggleExpand: () =>
                              setState(() => _month = !_month),
                          onWeekChanged: (delta) => _move(delta),
                        ),
                        AppSpacing.vGap12,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              if (_classNames.length > 1 || _classId != null)
                                OutlinedButton.icon(
                                  onPressed: ready ? _filter : null,
                                  icon: const Icon(Icons.filter_list),
                                  label: Text(
                                    _classId == null
                                        ? 'Tất cả lớp'
                                        : _classNames[_classId] ??
                                              'Lớp đã chọn',
                                  ),
                                ),
                              if (data.needsAttention.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => setState(
                                    () => _showOnlyNeedsAttention = true,
                                  ),
                                  icon: const Icon(Icons.chevron_right),
                                  label: Text(
                                    'Cần xử lý · ${data.needsAttention.length} buổi',
                                  ),
                                ),
                              _calendarMenu(context),
                            ],
                          ),
                        ),
                        Padding(
                          key: _agendaKey,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            ready && rows.isNotEmpty
                                ? '${rows.length} buổi dạy · ${_formatSelectedDate()}'
                                : _formatSelectedDate(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],

                      if (done && snapshot.hasError)
                        _buildErrorState(context, snapshot.error!)
                      else if (!ready)
                        const Center(child: CircularProgressIndicator())
                      else if (rows.isEmpty && !_showOnlyNeedsAttention)
                        _buildEmptyDayState(data),
                      if (_showOnlyNeedsAttention) ...[
                        Padding(
                          padding: AppSpacing.paddingHorizontalLg,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${data.needsAttention.length} buổi cần xử lý',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  _showOnlyNeedsAttention = false;
                                }),
                                child: const Text('Xem lịch'),
                              ),
                            ],
                          ),
                        ),
                        // Empty state khi không còn buổi cần xử lý
                        if (ready && data.needsAttention.isEmpty)
                          const TeacherEmptyStateInline(
                            icon: Icons.check_circle_outline,
                            message:
                                'Không còn buổi nào cần xử lý.\nTất cả đã hoàn tất!',
                          ),
                      ],

                      if (_showOnlyNeedsAttention)
                        for (final session in rows)
                          Padding(
                            padding: AppSpacing.paddingHorizontalLg,
                            child: _swipeSession(
                              session,
                              data,
                              now,
                              GestureDetector(
                                onLongPress: () =>
                                    _showSessionPreview(context, session),
                                child: TeacherSessionRow(
                                  onChanged: _sessionChanged,
                                  includeDate: true,
                                  session: session,
                                  api: widget.api,
                                  workplaceLabel: widget.workplaceLabel,
                                ),
                              ),
                            ),
                          )
                      else if (rows.isNotEmpty)
                        TeacherScheduleTimeline(
                          rows: rows,
                          daySessions: daySessions,
                          dotFor: (session) => _dotFor(session, now),
                          buildCard: (session) => _swipeSession(
                            session,
                            data,
                            now,
                            _timelineCard(session, now, hero: session == next),
                          ),
                        ),

                      // Dòng tổng tháng cuối danh sách
                      if (!_showOnlyNeedsAttention &&
                          data.monthCompletedSessions > 0)
                        _buildMonthlySummary(context, data),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState(_ScheduleData data) {
    final weekEnd = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day + 6,
    );
    final hasSessions = data.sessions.any(
      (s) => _month
          ? s.date.month == _selected.month && s.date.year == _selected.year
          : !s.date.isBefore(_weekStart) && !s.date.isAfter(weekEnd),
    );
    final String message;
    if (data.classes.isEmpty) {
      message = 'Bạn chưa được phân công lớp tại nơi làm việc này.';
    } else if (_classId != null) {
      message = 'Lớp đã chọn không có buổi dạy trong ngày này.';
    } else if (hasSessions) {
      message = 'Không có buổi dạy trong ngày này.';
    } else {
      message = _month
          ? 'Không có buổi dạy trong tháng này.'
          : 'Không có buổi dạy trong tuần này.';
    }
    return TeacherEmptyStateInline(
      icon: Icons.event_available_outlined,
      message: message,
    );
  }

  bool _isOpenSession(TeacherOccurrence session) =>
      session.status == 'scheduled' ||
      session.status == 'in_progress' ||
      (session.projected && session.status == 'active');

  TeacherCalendarDot _dotFor(TeacherOccurrence session, DateTime now) {
    if (session.status == 'completed') return TeacherCalendarDot.completed;
    final start = teacherScheduleTime(session, session.start);
    if (_isOpenSession(session) && start != null) {
      if (start.isAfter(now)) return TeacherCalendarDot.upcoming;
      if (_attendance[session.sessionId] == false)
        return TeacherCalendarDot.unmarked;
    }
    return TeacherCalendarDot.neutral;
  }

  void _scheduleAttendanceReads(
    List<TeacherOccurrence> sessions,
    DateTime now,
  ) {
    if (_attendanceRunning >= 4) return;
    final first = _month ? _selected : _weekStart;
    final last = DateTime(
      first.year,
      first.month,
      first.day + (_month ? 0 : 6),
    );
    final candidates = sessions
        .where((session) {
          final id = session.sessionId;
          final start = teacherScheduleTime(session, session.start);
          final date = DateUtils.dateOnly(session.date);
          return id != null &&
              id.isNotEmpty &&
              !_attendance.containsKey(id) &&
              !_attendancePending.contains(id) &&
              (_classId == null || session.classId == _classId) &&
              !date.isBefore(first) &&
              !date.isAfter(last) &&
              _isOpenSession(session) &&
              start != null &&
              !start.isAfter(now);
        })
        .take(4 - _attendanceRunning)
        .toList();
    if (candidates.isEmpty) return;

    final revision = _loadRevision;
    final epoch = _attendanceEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          revision != _loadRevision ||
          epoch != _attendanceEpoch ||
          _showOnlyNeedsAttention)
        return;
      for (final session in candidates) {
        final id = session.sessionId!;
        if (_attendanceRunning >= 4) break;
        if (_attendance.containsKey(id) || !_attendancePending.add(id))
          continue;
        _attendanceRunning++;
        unawaited(_readAttendance(id, epoch));
      }
    });
  }

  Future<void> _readAttendance(String id, int epoch) async {
    bool? hasAttendance;
    try {
      final response = await widget.api.get('/sessions/$id/attendances');
      final rows = response is Map ? response['data'] : response;
      if (rows is List &&
          rows.every((row) => row is Map && row['student_id'] != null)) {
        hasAttendance = rows.isNotEmpty;
      }
    } catch (_) {
      // Unknown attendance stays neutral and can be retried on refresh.
    } finally {
      _attendanceRunning--;
    }
    if (!mounted) return;
    setState(() {
      if (epoch == _attendanceEpoch) {
        _attendancePending.remove(id);
        _attendance[id] = hasAttendance;
      }
    });
  }

  TeacherOccurrence? _heroSession(List<TeacherOccurrence> rows, DateTime now) {
    TeacherOccurrence? due;
    TeacherOccurrence? upcoming;
    for (final row in rows) {
      if (!_isOpenSession(row)) continue;
      final start = teacherScheduleTime(row, row.start);
      final end = teacherScheduleTime(row, row.end);
      if (start == null ||
          end == null ||
          !end.isAfter(start) ||
          !end.isAfter(now))
        continue;
      if (start.isAfter(now)) {
        upcoming ??= row;
      } else {
        if (!row.projected && row.status == 'in_progress') return row;
        due ??= row;
      }
    }
    return due ?? upcoming;
  }

  String _heroLabel(TeacherOccurrence session, DateTime now) {
    final start = teacherScheduleTime(session, session.start)!;
    final end = teacherScheduleTime(session, session.end)!;
    if (start.isAfter(now)) {
      final minutes = (start.difference(now).inSeconds / 60).ceil().clamp(
        1,
        1440,
      );
      return 'SẮP BẮT ĐẦU SAU $minutes PHÚT';
    }
    if (!session.projected && session.status == 'in_progress') {
      final minutes = (end.difference(now).inSeconds / 60).ceil().clamp(
        1,
        1440,
      );
      return 'ĐANG DIỄN RA • CÒN $minutes PHÚT';
    }
    return 'ĐẾN GIỜ DẠY';
  }

  Future<bool> _canTakeAttendance(TeacherOccurrence session) async {
    final api = widget.api;
    try {
      final responses = await Future.wait([
        api.get('/classes/${session.classId}'),
        api.get('/classes/${session.classId}/sessions/${session.sessionId}'),
      ]);
      final detail = TeacherClassData(teacherPayload(responses[0]));
      final current = teacherPayload(responses[1]);
      final role = current['teacher_role'] ?? session.json['teacher_role'];
      return detail.canManage &&
          role != 'assistant' &&
          (current['status'] == 'scheduled' ||
              current['status'] == 'in_progress');
    } catch (_) {
      return false;
    }
  }

  void _openAttendance(TeacherOccurrence session) {
    teacherPush<Object?>(
      context,
      TeacherAttendanceScreen(
        api: widget.api,
        classId: session.classId,
        sessionId: session.sessionId!,
        title: session.classData.name,
        sessionDate: teacherDate(session.date),
        startTime: session.start,
        endTime: session.end,
        onSaved: _sessionChanged,
      ),
    );
  }

  Widget _timelineCard(
    TeacherOccurrence session,
    DateTime now, {
    required bool hero,
  }) {
    final liveId =
        session.json['livestream_session_id']?.toString().trim() ?? '';
    final roomLink = session.json['room_link']?.toString().trim() ?? '';
    Widget card({bool canAttend = false}) => TeacherTimelineCard(
      session: session,
      now: now,
      dot: _dotFor(session, now),
      heroLabel: hero ? _heroLabel(session, now) : null,
      onDetails: () => _navigateToSession(session),
      onPreview: () => _showSessionPreview(context, session),
      onAttendance: canAttend ? () => _openAttendance(session) : null,
      onJoin: hero && (liveId.isNotEmpty || roomLink.isNotEmpty)
          ? () {
              if (liveId.isNotEmpty) {
                teacherPush<void>(
                  context,
                  TeacherLiveSessionScreen(api: widget.api, sessionId: liveId),
                );
              } else {
                launchTeacherUrl(context, roomLink);
              }
            }
          : null,
    );
    final id = session.sessionId;
    if (!hero ||
        id == null ||
        id.isEmpty ||
        widget.api is TeacherPreviewApi ||
        session.json['teacher_role'] == 'assistant')
      return card();

    return FutureBuilder<bool>(
      future: _attendancePermissions.putIfAbsent(
        id,
        () => _canTakeAttendance(session),
      ),
      builder: (context, snapshot) => card(
        canAttend:
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true,
      ),
    );
  }

  Widget _swipeSession(
    TeacherOccurrence session,
    _ScheduleData data,
    DateTime now,
    Widget child,
  ) => TeacherSwipeToAction(
    itemKey: ValueKey((
      session.classId,
      session.sessionId,
      session.json['schedule_id'],
      session.date,
      session.start,
    )),
    icon: Icons.play_arrow_rounded,
    label: 'Hoàn tất',
    color: AchievementColors.green,
    enabled:
        _isOverdue(session, now) &&
        data.needsAttention.any((row) => row.sessionId == session.sessionId),
    direction: DismissDirection.startToEnd,
    onAction: () => _quickStartSession(session),
    child: child,
  );

  /// State 04: Lỗi mạng
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(teacherErrorMessage(error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dòng tổng tháng cuối danh sách
  Widget _buildMonthlySummary(BuildContext context, _ScheduleData data) {
    final cs = Theme.of(context).colorScheme;
    final hours = data.monthMinutes ~/ 60;
    final mins = data.monthMinutes % 60;
    final hoursText = hours > 0
        ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
        : '$mins phút';

    return Padding(
      padding: AppSpacing.paddingHorizontalLg.copyWith(top: AppSpacing.lg),
      child: Material(
        color: teacherScheduleCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: teacherScheduleBorder(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onNavigateToReport == null
              ? null
              : () => widget.onNavigateToReport!(
                  DateTime(_selected.year, _selected.month),
                ),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Icon(Icons.bar_chart_outlined, color: cs.primary, size: 20),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    '${data.monthCompletedSessions} buổi hoàn tất · $hoursText · ${_selected.month}/${_selected.year}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class chứa tất cả dữ liệu cần thiết cho ScheduleScreen
class _ScheduleData {
  const _ScheduleData({
    required this.sessions,
    required this.classes,
    required this.needsAttention,
    required this.monthCompletedSessions,
    required this.monthMinutes,
  });

  const _ScheduleData.empty()
    : this(
        sessions: const [],
        classes: const [],
        needsAttention: const [],
        monthCompletedSessions: 0,
        monthMinutes: 0,
      );
  final List<TeacherClassData> classes;
  final List<TeacherOccurrence> sessions;
  final List<TeacherOccurrence> needsAttention;
  final int monthCompletedSessions;
  final int monthMinutes;
}

class _PreviewInfoRow extends StatelessWidget {
  const _PreviewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          AppSpacing.hGap8,
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
