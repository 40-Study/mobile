import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_reminders_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_list_screen.dart';
import 'package:study/features/teacher/presentation/widgets/session_card.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({
    super.key,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
    this.teacherName,
    this.onNavigateToReport,
    this.onNeedsAttentionCountChanged,
  });
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;
  final String? teacherName;

  /// Callback để chuyển sang tab Báo cáo (tap vào dòng tổng tháng)
  final VoidCallback? onNavigateToReport;

  /// Callback để sync số buổi cần xử lý lên WorkplaceController
  final void Function(int count)? onNeedsAttentionCountChanged;

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
  bool _needsAttentionExpanded = false; // Cho collapsible section

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _future = _load();
  }

  DateTime get _weekStart => DateTime(
    _selected.year,
    _selected.month,
    _selected.day - _selected.weekday + 1,
  );

  String _formatSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selected.year, _selected.month, _selected.day);

    if (selected == today) return 'Hôm nay';
    if (selected == today.add(const Duration(days: 1))) return 'Ngày mai';
    if (selected == today.subtract(const Duration(days: 1))) return 'Hôm qua';

    final weekdays = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return '${weekdays[_selected.weekday]}, ${DateFormat('dd/MM').format(_selected)}';
  }

  Future<_ScheduleData> _load() async {
    // Luôn load cả tháng để tránh call API 2 lần
    final monthStart = DateTime(_selected.year, _selected.month);
    final monthEnd = DateTime(_selected.year, _selected.month + 1, 0);

    final monthSessions = await teacherLoadTimetable(
      widget.api,
      widget.organizationId,
      monthStart,
      monthEnd,
    );

    // Filter cho tuần nếu ở week mode
    final weekEnd = DateTime(_weekStart.year, _weekStart.month, _weekStart.day + 6);
    final sessions = _month
        ? monthSessions
        : monthSessions.where((s) {
            return !s.date.isBefore(_weekStart) && !s.date.isAfter(weekEnd);
          }).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Tìm buổi cần xử lý: quá giờ chưa hoàn tất hoặc cần bổ sung
    final needsAttention = <TeacherOccurrence>[];
    for (final s in monthSessions) {
      final role = s.json['teacher_role']?.toString();
      final confirmStatus = s.json['hour_confirmation_status']?.toString();

      // Cần bổ sung (returned by center)
      if (confirmStatus == 'needs_info') {
        needsAttention.add(s);
        continue;
      }

      // Quá giờ chưa hoàn tất (chỉ cho giáo viên chính/dạy thay)
      if (role != 'assistant' &&
          s.status == 'scheduled' &&
          s.sessionId != null) {
        final endParts = s.end.split(':');
        final endTime = DateTime(
          s.date.year,
          s.date.month,
          s.date.day,
          int.tryParse(endParts.first) ?? 23,
          int.tryParse(endParts.last) ?? 59,
        );
        if (endTime.isBefore(now)) {
          needsAttention.add(s);
        }
      }
    }

    // Tìm buổi tiếp theo (chưa kết thúc hoặc sắp bắt đầu)
    TeacherOccurrence? nextSession;
    for (final s in sessions) {
      if (s.status == 'cancelled') continue;
      final endParts = s.end.split(':');
      final endTime = DateTime(
        s.date.year,
        s.date.month,
        s.date.day,
        int.tryParse(endParts.first) ?? 23,
        int.tryParse(endParts.last) ?? 59,
      );
      // Hiện buổi đang diễn ra hoặc sắp bắt đầu
      if (endTime.isAfter(now)) {
        nextSession = s;
        break;
      }
    }

    // Tính tổng tháng (chỉ buổi hoàn tất)
    var monthCompletedSessions = 0;
    var monthMinutes = 0;
    for (final s in monthSessions) {
      if (s.status == 'completed' || s.json['status'] == 'completed') {
        monthCompletedSessions++;
        final startTime = s.json['start_time']?.toString() ?? '00:00';
        final endTime = s.json['end_time']?.toString() ?? '00:00';
        final startParts = startTime.split(':');
        final endParts = endTime.split(':');
        final startMin = (int.tryParse(startParts.first) ?? 0) * 60 +
            (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
        final endMin = (int.tryParse(endParts.first) ?? 0) * 60 +
            (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);
        if (endMin > startMin) monthMinutes += endMin - startMin;
      }
    }

    // Sync needsAttention count lên WorkplaceController
    widget.onNeedsAttentionCountChanged?.call(needsAttention.length);

    return _ScheduleData(
      sessions: sessions,
      needsAttention: needsAttention,
      nextSession: nextSession,
      monthCompletedSessions: monthCompletedSessions,
      monthMinutes: monthMinutes,
    );
  }

  void _reload() => setState(() {
    _future = _load();
  });

  /// Check if session is overdue and can be quick-started
  bool _isOverdue(TeacherOccurrence session) {
    if (session.status != 'scheduled') return false;
    if (session.sessionId == null) return false;
    final role = session.json['teacher_role']?.toString();
    if (role == 'assistant') return false; // Trợ giảng không cần hoàn tất

    final now = DateTime.now();
    final endParts = session.end.split(':');
    final endTime = DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      int.tryParse(endParts.first) ?? 23,
      int.tryParse(endParts.last) ?? 59,
    );
    return endTime.isBefore(now);
  }

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
    if (result == true) _reload();
    return false; // Không dismiss item
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final topSurfaceColor = isLight ? Colors.white : cs.surface;

    return Scaffold(
      backgroundColor: topSurfaceColor,
      body: Column(
        children: [
          // Hero Section
          TeacherHeroSection(
            greeting: TeacherHeroSection.getGreeting(),
            name: TeacherHeroSection.getFirstName(widget.teacherName),
            chips: [
              TeacherSummaryChip(
                icon: Icons.calendar_today_outlined,
                label: _formatSelectedDate(),
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    _selected = DateTime(now.year, now.month, now.day);
                    _showOnlyNeedsAttention = false;
                    _future = _load();
                  });
                },
              ),
            ],
            trailing: PopupMenuButton<String>(
              tooltip: 'Tùy chọn lịch dạy',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'leave')
                  teacherPush<Object?>(
                    context,
                    TeacherLeaveListScreen(
                      api: widget.api,
                      organizationId: widget.organizationId,
                    ),
                  );
                if (value == 'reminders')
                  teacherPush<Object?>(
                    context,
                    TeacherRemindersScreen(api: widget.api),
                  );
                if (value == 'refresh') _reload();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'leave', child: Text('Xin nghỉ')),
                PopupMenuItem(value: 'reminders', child: Text('Nhắc lịch')),
                PopupMenuItem(value: 'refresh', child: Text('Tải lại')),
              ],
            ),
          ),
          // View toggle
          Padding(
            padding: AppSpacing.paddingHorizontalXl,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tuần')),
                      ButtonSegment(value: true, label: Text('Tháng')),
                    ],
                    selected: {_month},
                    onSelectionChanged: (value) => setState(() {
                      _month = value.first;
                      _showOnlyNeedsAttention = false;
                      _future = _load();
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Week navigation (only show in week mode)
          if (!_month)
            Padding(
              padding: AppSpacing.paddingHorizontalXl,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _move(-1),
                    tooltip: 'Kỳ trước',
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${DateFormat('dd/MM').format(_weekStart)} – ${DateFormat('dd/MM').format(_weekStart.add(const Duration(days: 6)))}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _move(1),
                    tooltip: 'Kỳ sau',
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          AppSpacing.vGap8,
          Expanded(
        child: FutureBuilder<_ScheduleData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error!);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            final sessions = data.sessions;

            // State 01: Chưa được giao lớp
            if (sessions.isEmpty && data.monthCompletedSessions == 0) {
              return _buildNoClassState(context);
            }

            final classes = {
              for (final session in sessions)
                session.classId: session.classData.name,
            };
            _classNames.addAll(classes);

            // Filter rows dựa trên mode
            List<TeacherOccurrence> rows;
            if (_showOnlyNeedsAttention) {
              rows = data.needsAttention;
            } else {
              rows = sessions
                  .where(
                    (s) =>
                        teacherDate(s.date) == teacherDate(_selected) &&
                        (_classId == null || s.classId == _classId),
                  )
                  .toList();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Mục "Cần xử lý" - collapsible section
                  if (data.needsAttention.isNotEmpty && !_showOnlyNeedsAttention)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: _buildNeedsAttentionSection(context, data),
                    ),
                  if (_showOnlyNeedsAttention)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${data.needsAttention.length} buổi cần xử lý',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
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

                  // Thẻ "Buổi tiếp theo" (hiện ngay sau Cần xử lý)
                  if (!_showOnlyNeedsAttention && data.nextSession != null)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl.copyWith(
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: NextSessionCard(
                        session: data.nextSession!,
                        api: widget.api,
                        workplaceLabel: widget.workplaceLabel,
                        onChanged: _reload,
                      ),
                    ),

                  if (!_showOnlyNeedsAttention) ...[
                    if (_month)
                      Padding(
                        padding: AppSpacing.paddingHorizontalXl,
                        child: Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          child: CalendarDatePicker(
                            key: ValueKey('${_selected.year}-${_selected.month}'),
                            initialDate: _selected,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            onDateChanged: (date) =>
                                setState(() => _selected = date),
                            onDisplayedMonthChanged: (date) => setState(() {
                              _selected = _inMonth(
                                date.month + (date.year - _selected.year) * 12,
                              );
                              _future = _load();
                            }),
                          ),
                        ),
                      )
                    else
                      _buildWeekStrip(context, sessions),
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _filter,
                          icon: const Icon(Icons.filter_list),
                          label: Text(
                            _classId == null
                                ? 'Tất cả lớp'
                                : _classNames[_classId] ?? 'Lớp đã chọn',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: AppSpacing.paddingScreenAll,
                      child: Text(
                        '${rows.length} buổi dạy · ${DateFormat('dd/MM/yyyy').format(_selected)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  // State 02: Hôm nay không có lịch
                  if (rows.isEmpty && !_showOnlyNeedsAttention)
                    _buildEmptyDayState(context, data),

                  for (final session in rows)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: TeacherSwipeToAction(
                        itemKey: Key('session_${session.sessionId ?? session.classId}_${session.date}'),
                        icon: Icons.play_arrow_rounded,
                        label: 'Hoàn tất',
                        color: AchievementColors.green,
                        enabled: _isOverdue(session),
                        direction: DismissDirection.startToEnd,
                        onAction: () => _quickStartSession(session),
                        child: TeacherSessionRow(
                          onChanged: _reload,
                          session: session,
                          api: widget.api,
                          workplaceLabel: widget.workplaceLabel,
                        ),
                      ),
                    ),

                  // Dòng tổng tháng cuối danh sách
                  if (!_showOnlyNeedsAttention && data.monthCompletedSessions > 0)
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

  /// State 01: Chưa được giao lớp
  Widget _buildNoClassState(BuildContext context) {
    return const TeacherEmptyState(
      icon: Icons.school_outlined,
      title: 'Chưa có lịch dạy',
      subtitle: 'Lịch sẽ hiện khi bạn được phân công lớp.\nLiên hệ trung tâm nếu bạn cần được phân công.',
    );
  }

  /// State 02: Hôm nay không có lịch
  Widget _buildEmptyDayState(BuildContext context, _ScheduleData data) {
    return TeacherEmptyStateInline(
      icon: Icons.event_available_outlined,
      message: data.nextSession != null
          ? 'Không có buổi dạy trong ngày này.\nBuổi tiếp theo: ${DateFormat('dd/MM').format(data.nextSession!.date)} lúc ${data.nextSession!.start}'
          : 'Không có buổi dạy trong ngày này.',
    );
  }

  /// Section "Cần xử lý" collapsible
  Widget _buildNeedsAttentionSection(BuildContext context, _ScheduleData data) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TeacherCollapsibleCard(
      title: 'Cần xử lý',
      subtitle: 'Buổi quá giờ hoặc cần bổ sung thông tin',
      icon: Icons.warning_amber_outlined,
      iconColor: AchievementColors.red,
      badgeCount: data.needsAttention.length,
      badgeColor: AchievementColors.red,
      initiallyExpanded: _needsAttentionExpanded,
      onExpansionChanged: (expanded) {
        setState(() => _needsAttentionExpanded = expanded);
      },
      child: Column(
        children: [
          for (var i = 0; i < data.needsAttention.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            _NeedsAttentionItem(
              session: data.needsAttention[i],
              onTap: () {
                // Navigate to session detail
                setState(() => _showOnlyNeedsAttention = true);
              },
            ),
          ],
          // Link xem tất cả nếu có nhiều items
          if (data.needsAttention.length > 3) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _showOnlyNeedsAttention = true),
              child: Text(
                'Xem tất cả ${data.needsAttention.length} buổi',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
            Text(
              teacherErrorMessage(error),
              textAlign: TextAlign.center,
            ),
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
      padding: AppSpacing.paddingHorizontalXl.copyWith(top: AppSpacing.lg),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onNavigateToReport,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  color: cs.primary,
                  size: 20,
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    '${data.monthCompletedSessions} buổi · $hoursText tháng này',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekStrip(BuildContext context, List<TeacherOccurrence> sessions) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      // Swipe horizontal để chuyển tuần
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        // Swipe phải → tuần trước, swipe trái → tuần sau
        if (velocity > 300) {
          _move(-1);
        } else if (velocity < -300) {
          _move(1);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.paddingHorizontalXl,
          child: Row(
            children: [
            for (var i = 0; i < 7; i++)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Builder(
                  builder: (context) {
                    final day = DateTime(
                      _weekStart.year,
                      _weekStart.month,
                      _weekStart.day + i,
                    );
                    final daySessions = sessions
                        .where(
                          (s) =>
                              teacherDate(s.date) == teacherDate(day) &&
                              (_classId == null || s.classId == _classId),
                        )
                        .toList();
                    final count = daySessions.length;
                    final hasNeedsAttention = daySessions.any((s) {
                      final confirmStatus =
                          s.json['hour_confirmation_status']?.toString();
                      return confirmStatus == 'needs_info';
                    });
                    final selected = teacherDate(day) == teacherDate(_selected);
                    final today = teacherDate(day) == teacherDate(DateTime.now());

                    return GestureDetector(
                      onTap: () => setState(() => _selected = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: today ? 72 : 56,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primary
                              : cs.surfaceContainerLowest,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : today
                                    ? cs.primary
                                    : cs.outlineVariant.withValues(alpha: 0.5),
                            width: today && !selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              today
                                  ? 'Hôm nay'
                                  : const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i],
                              style: tt.labelSmall?.copyWith(
                                color: selected
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                                fontSize: today ? 10 : 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd').format(day),
                              style: tt.titleLarge?.copyWith(
                                color: selected ? cs.onPrimary : cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (count > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasNeedsAttention)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? cs.onPrimary
                                            : AchievementColors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(
                                    '$count',
                                    style: tt.labelMedium?.copyWith(
                                      color: selected
                                          ? cs.onPrimary
                                          : cs.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '—',
                                style: tt.labelSmall?.copyWith(
                                  color: selected
                                      ? cs.onPrimary.withValues(alpha: 0.5)
                                      : cs.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
    required this.needsAttention,
    required this.nextSession,
    required this.monthCompletedSessions,
    required this.monthMinutes,
  });

  final List<TeacherOccurrence> sessions;
  final List<TeacherOccurrence> needsAttention;
  final TeacherOccurrence? nextSession;
  final int monthCompletedSessions;
  final int monthMinutes;
}

/// Item trong collapsible "Cần xử lý" section
class _NeedsAttentionItem extends StatelessWidget {
  const _NeedsAttentionItem({
    required this.session,
    required this.onTap,
  });

  final TeacherOccurrence session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final confirmStatus = session.json['hour_confirmation_status']?.toString();
    final isNeedsInfo = confirmStatus == 'needs_info';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isNeedsInfo
                    ? AchievementColors.yellow
                    : AchievementColors.red,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.hGap12,
            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.classData.name,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${DateFormat('dd/MM').format(session.date)} · ${session.start} - ${session.end}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: (isNeedsInfo
                        ? AchievementColors.yellow
                        : AchievementColors.red)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isNeedsInfo ? 'Cần bổ sung' : 'Quá giờ',
                style: tt.labelSmall?.copyWith(
                  color: isNeedsInfo
                      ? AchievementColors.yellow
                      : AchievementColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
