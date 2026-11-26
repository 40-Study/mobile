import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_list_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

/// Báo cáo giờ dạy theo spec mốc 1a (T10).
/// Hiển thị tổng buổi hoàn tất, giờ dạy, nhóm theo trạng thái xác nhận.
class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({
    super.key,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
  });

  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

class _TeacherReportScreenState extends State<TeacherReportScreen> {
  late DateTime _month;
  late Future<TeacherReportData> _future;
  String? _classId;
  final _classNames = <String, String>{};
  bool _statusSectionExpanded = true; // Cho collapsible "Chi tiết theo trạng thái"

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _future = _load();
  }

  Future<TeacherReportData> _load() async {
    final from = _month;
    final to = DateTime(_month.year, _month.month + 1, 0);

    // Load timetable để lấy buổi hoàn tất
    final classes = await teacherAssignedClasses(widget.api);
    final inScope = classes
        .where((c) => c.inScope(widget.organizationId))
        .toList();

    // Load all sessions cho tháng này
    final raw = teacherPayload(
      await widget.api.get(
        '/me/timetable',
        query: {
          'sessions_from': teacherDate(from),
          'sessions_to': teacherDate(to),
        },
      ),
    );

    final entries = teacherList(raw, keys: const ['entries'])
        .map(teacherMap)
        .toList();

    // Filter chỉ buổi có session_id và trong phạm vi nơi làm việc
    final classIds = inScope.map((c) => c.id).toSet();
    final sessions = entries.where((e) {
      final classId = e['class_id']?.toString();
      final sessionId = e['session_id'];
      final date = DateTime.tryParse('${e['date']}');
      if (classId == null || sessionId == null || date == null) return false;
      if (!classIds.contains(classId)) return false;
      if (_classId != null && classId != _classId) return false;
      return !date.isBefore(from) && !date.isAfter(to);
    }).toList();

    // Clear và rebuild class names để tránh stale data
    _classNames.clear();
    for (final c in inScope) {
      _classNames[c.id] = c.name;
    }

    // Calculate stats
    int totalSessions = 0;
    int totalMinutes = 0;
    int confirmedMinutes = 0;
    int pendingMinutes = 0;
    int needsInfoMinutes = 0;
    final confirmedSessions = <Map<String, dynamic>>[];
    final pendingSessions = <Map<String, dynamic>>[];
    final needsInfoSessions = <Map<String, dynamic>>[];

    // Stats theo vai trò
    int mainSessions = 0;
    int substituteSessions = 0;
    int assistantSessions = 0;

    for (final session in sessions) {
      if (session['status'] != 'completed') continue;

      totalSessions++;
      final duration = _durationMinutes(session);
      totalMinutes += duration;

      // Vai trò: main, substitute, assistant
      final role = session['teacher_role']?.toString();
      switch (role) {
        case 'main':
          mainSessions++;
        case 'substitute':
          substituteSessions++;
        case 'assistant':
          assistantSessions++;
      }

      // Trạng thái xác nhận giờ: confirmed, pending, needs_info
      final confirmStatus = session['hour_confirmation_status']?.toString() ?? 'pending';

      switch (confirmStatus) {
        case 'confirmed':
          confirmedMinutes += duration;
          confirmedSessions.add(session);
        case 'needs_info':
          needsInfoMinutes += duration;
          needsInfoSessions.add(session);
        default: // pending hoặc không có
          pendingMinutes += duration;
          pendingSessions.add(session);
      }
    }

    return TeacherReportData(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      confirmedMinutes: confirmedMinutes,
      pendingMinutes: pendingMinutes,
      needsInfoMinutes: needsInfoMinutes,
      confirmedSessions: confirmedSessions,
      pendingSessions: pendingSessions,
      needsInfoSessions: needsInfoSessions,
      classes: inScope,
      mainSessions: mainSessions,
      substituteSessions: substituteSessions,
      assistantSessions: assistantSessions,
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

  void _reload() => setState(() => _future = _load());

  void _changeMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _future = _load();
  });

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
    if (selection != null && mounted) {
      setState(() {
        _classId = selection.isEmpty ? null : selection;
        _future = _load();
      });
    }
  }

  void _openGroup(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> sessions,
    List<TeacherClassData> classes,
  ) {
    teacherPush<void>(
      context,
      TeacherReportListScreen(
        api: widget.api,
        title: title,
        sessions: sessions,
        classes: classes,
        workplaceLabel: widget.workplaceLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Tháng trước',
                  ),
                  Expanded(
                    child: Text(
                      'Tháng ${_month.month}/${_month.year}',
                      textAlign: TextAlign.center,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Tháng sau',
                  ),
                ],
              ),
              AppSpacing.vGap8,
              OutlinedButton.icon(
                onPressed: _filter,
                icon: const Icon(Icons.filter_list),
                label: Text(
                  _classId == null
                      ? 'Tất cả lớp'
                      : _classNames[_classId] ?? 'Lớp đã chọn',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<TeacherReportData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!;
              final hasReviewProcess = data.confirmedMinutes > 0 ||
                  data.needsInfoMinutes > 0 ||
                  data.pendingSessions.isNotEmpty;

              return RefreshIndicator(
                onRefresh: () async {
                  _reload();
                  await _future;
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.paddingScreenAll,
                  children: [
                    // Summary card
                    _SummaryCard(
                      totalSessions: data.totalSessions,
                      totalMinutes: data.totalMinutes,
                      onTap: data.totalSessions > 0
                          ? () => _openGroup(
                              context,
                              'Tất cả buổi hoàn tất',
                              [
                                ...data.confirmedSessions,
                                ...data.pendingSessions,
                                ...data.needsInfoSessions,
                              ],
                              data.classes,
                            )
                          : null,
                    ),

                    // Breakdown theo vai trò (nếu có nhiều vai trò)
                    if (data.hasRoleBreakdown) ...[
                      AppSpacing.vGap12,
                      _RoleBreakdownRow(
                        mainSessions: data.mainSessions,
                        substituteSessions: data.substituteSessions,
                        assistantSessions: data.assistantSessions,
                      ),
                    ],

                    if (data.totalSessions == 0) ...[
                      AppSpacing.vGap24,
                      _EmptyState(month: _month, classId: _classId),
                    ] else if (hasReviewProcess) ...[
                      AppSpacing.vGap24,
                      // Collapsible section cho chi tiết theo trạng thái
                      TeacherCollapsibleSection(
                        title: 'Chi tiết theo trạng thái',
                        icon: Icons.pie_chart_outline,
                        initiallyExpanded: _statusSectionExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _statusSectionExpanded = expanded);
                        },
                        child: Column(
                          children: [
                            AppSpacing.vGap8,
                            if (data.confirmedSessions.isNotEmpty)
                              _StatusCard(
                                icon: Icons.check_circle_outline,
                                iconColor: AchievementColors.green,
                                title: 'Đã xác nhận',
                                sessions: data.confirmedSessions.length,
                                minutes: data.confirmedMinutes,
                                onTap: () => _openGroup(
                                  context,
                                  'Giờ đã xác nhận',
                                  data.confirmedSessions,
                                  data.classes,
                                ),
                              ),
                            if (data.pendingSessions.isNotEmpty)
                              _StatusCard(
                                icon: Icons.hourglass_empty,
                                iconColor: AchievementColors.yellow,
                                title: 'Chờ xác nhận',
                                sessions: data.pendingSessions.length,
                                minutes: data.pendingMinutes,
                                onTap: () => _openGroup(
                                  context,
                                  'Giờ chờ xác nhận',
                                  data.pendingSessions,
                                  data.classes,
                                ),
                              ),
                            if (data.needsInfoSessions.isNotEmpty)
                              _StatusCard(
                                icon: Icons.info_outline,
                                iconColor: AchievementColors.red,
                                title: 'Cần bổ sung',
                                sessions: data.needsInfoSessions.length,
                                minutes: data.needsInfoMinutes,
                                onTap: () => _openGroup(
                                  context,
                                  'Giờ cần bổ sung',
                                  data.needsInfoSessions,
                                  data.classes,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    AppSpacing.vGap24,
                    // Trung tâm đã rời - chỉ hiện khi có nhiều trung tâm
                    OutlinedButton.icon(
                      onPressed: () => _showLeftOrganizations(context),
                      icon: const Icon(Icons.history),
                      label: const Text('Trung tâm đã rời'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLeftOrganizations(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingScreenAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trung tâm đã rời',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.vGap8,
              Text(
                'Lịch sử giờ dạy tại các trung tâm bạn đã rời sẽ hiển thị ở đây. '
                'Dữ liệu chỉ bao gồm ngày, tên lớp, số phút và trạng thái xác nhận.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGap16,
              const Center(
                child: Text('Chưa có trung tâm đã rời'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherReportData {
  const TeacherReportData({
    required this.totalSessions,
    required this.totalMinutes,
    required this.confirmedMinutes,
    required this.pendingMinutes,
    required this.needsInfoMinutes,
    required this.confirmedSessions,
    required this.pendingSessions,
    required this.needsInfoSessions,
    required this.classes,
    this.mainSessions = 0,
    this.substituteSessions = 0,
    this.assistantSessions = 0,
  });

  final int totalSessions;
  final int totalMinutes;
  final int confirmedMinutes;
  final int pendingMinutes;
  final int needsInfoMinutes;
  final List<Map<String, dynamic>> confirmedSessions;
  final List<Map<String, dynamic>> pendingSessions;
  final List<Map<String, dynamic>> needsInfoSessions;
  final List<TeacherClassData> classes;

  /// Stats theo vai trò
  final int mainSessions;
  final int substituteSessions;
  final int assistantSessions;

  /// Có hiển thị breakdown theo vai trò không (khi có nhiều hơn một vai trò)
  bool get hasRoleBreakdown =>
      (mainSessions > 0 ? 1 : 0) +
          (substituteSessions > 0 ? 1 : 0) +
          (assistantSessions > 0 ? 1 : 0) >
      1;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalSessions,
    required this.totalMinutes,
    this.onTap,
  });

  final int totalSessions;
  final int totalMinutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.layeredCard,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: AppRadius.borderLg,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: AppSpacing.paddingXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.onPrimary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: cs.onPrimary,
                            size: 20,
                          ),
                        ),
                        AppSpacing.hGap12,
                        Text(
                          'Tổng kết tháng',
                          style: tt.titleSmall?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (onTap != null)
                          Icon(
                            Icons.arrow_forward,
                            color: cs.onPrimary,
                            size: 20,
                          ),
                      ],
                    ),
                    AppSpacing.vGap24,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$totalSessions',
                                style: tt.displaySmall?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                'buổi hoàn tất',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onPrimary.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: cs.onPrimary.withValues(alpha: 0.2),
                        ),
                        AppSpacing.hGap16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$hours',
                                    style: tt.displaySmall?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    'h',
                                    style: tt.titleLarge?.copyWith(
                                      color: cs.onPrimary.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (mins > 0) ...[
                                    AppSpacing.hGap4,
                                    Text(
                                      '$mins',
                                      style: tt.headlineSmall?.copyWith(
                                        color: cs.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'p',
                                      style: tt.titleMedium?.copyWith(
                                        color: cs.onPrimary.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              AppSpacing.vGap4,
                              Text(
                                'giờ dạy',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onPrimary.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sessions,
    required this.minutes,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final int sessions;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final hoursText = hours > 0
        ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
        : '$mins phút';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF010120).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderMd,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '$sessions',
                              style: tt.labelLarge?.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' buổi · ',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              hoursText,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.month, this.classId});

  final DateTime month;
  final String? classId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            AppSpacing.vGap12,
            Text(
              classId != null
                  ? 'Không có buổi hoàn tất cho lớp này trong tháng ${month.month}/${month.year}'
                  : 'Không có buổi hoàn tất trong tháng ${month.month}/${month.year}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (classId != null) ...[
              AppSpacing.vGap8,
              Text(
                'Thử xóa bộ lọc hoặc chọn tháng khác.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hiển thị breakdown theo vai trò
class _RoleBreakdownRow extends StatelessWidget {
  const _RoleBreakdownRow({
    required this.mainSessions,
    required this.substituteSessions,
    required this.assistantSessions,
  });

  final int mainSessions;
  final int substituteSessions;
  final int assistantSessions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final parts = <String>[];

    if (mainSessions > 0) parts.add('$mainSessions buổi Chính');
    if (substituteSessions > 0) parts.add('$substituteSessions buổi Dạy thay');
    if (assistantSessions > 0) parts.add('$assistantSessions buổi Trợ giảng');

    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 18,
            color: cs.onSurfaceVariant,
          ),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              parts.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
