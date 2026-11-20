import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

/// Màn hình hoàn tất buổi dạy (T06 theo spec).
/// Hiển thị tóm tắt điểm danh, giờ được tính, ô nhập nội dung đã dạy.
class TeacherCompleteSessionScreen extends StatefulWidget {
  const TeacherCompleteSessionScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.className,
    required this.date,
  });

  final TeacherApi api;
  final String classId;
  final String sessionId;
  final String className;
  final String date;

  @override
  State<TeacherCompleteSessionScreen> createState() =>
      _TeacherCompleteSessionScreenState();
}

class _TeacherCompleteSessionScreenState
    extends State<TeacherCompleteSessionScreen> {
  late Future<_SessionCompleteData> _future;
  final _notesController = TextEditingController();
  bool _saving = false;
  Object? _error;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<_SessionCompleteData> _load() async {
    // Load session details
    final session = teacherPayload(
      await widget.api.get(
        '/classes/${widget.classId}/sessions/${widget.sessionId}',
      ),
    );

    // Load attendance summary
    final attendance = teacherList(
      await widget.api.get('/sessions/${widget.sessionId}/attendances'),
    ).map(teacherMap).toList();

    // Load students để biết tổng số
    final students = await teacherAllPages(
      widget.api,
      '/classes/${widget.classId}/students',
      'students',
    );

    // Calculate stats
    var present = 0;
    var late = 0;
    var absent = 0;
    for (final a in attendance) {
      switch (a['status']) {
        case 'present':
          present++;
        case 'late':
          late++;
        case 'absent':
          absent++;
      }
    }
    final unmarked = students.length - attendance.length;

    // Duration
    final startTime = session['start_time']?.toString() ?? '00:00';
    final endTime = session['end_time']?.toString() ?? '00:00';
    final duration = _calculateDuration(startTime, endTime);

    // Pre-fill notes if exists
    final existingNotes = session['notes']?.toString() ?? '';
    if (existingNotes.isNotEmpty && _notesController.text.isEmpty) {
      _notesController.text = existingNotes;
    }

    return _SessionCompleteData(
      session: session,
      totalStudents: students.length,
      present: present,
      late: late,
      absent: absent,
      unmarked: unmarked,
      duration: duration,
    );
  }

  int _calculateDuration(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMin = (int.tryParse(startParts.first) ?? 0) * 60 +
        (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
    final endMin = (int.tryParse(endParts.first) ?? 0) * 60 +
        (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);
    return endMin > startMin ? endMin - startMin : 0;
  }

  Future<void> _complete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hoàn tất?'),
        content: const Text(
          'Sau khi hoàn tất, buổi học sẽ được ghi nhận và chuyển sang chờ xác nhận. '
          'Bạn không thể sửa điểm danh sau khi hoàn tất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận hoàn tất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.api.put(
        '/classes/${widget.classId}/sessions/${widget.sessionId}',
        data: {
          'status': 'completed',
          'notes': _notesController.text,
        },
      );

      if (!mounted) return;

      // Show success animation
      await _showSuccessDialog();

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AchievementColors.green,
              size: 64,
            ),
            AppSpacing.vGap16,
            Text(
              'Đã hoàn tất buổi dạy!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap8,
            Text(
              'Giờ dạy đang chờ xác nhận.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hoàn tất buổi dạy')),
      body: FutureBuilder<_SessionCompleteData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final hours = data.duration ~/ 60;
          final mins = data.duration % 60;
          final durationText = hours > 0
              ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
              : '$mins phút';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.paddingScreenAll,
                  children: [
                    // Session info
                    Text(
                      widget.className,
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.date,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.vGap24,

                    // Duration card (read-only)
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: cs.onPrimaryContainer,
                          ),
                          AppSpacing.hGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giờ được tính',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  durationText,
                                  style: tt.titleMedium?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Chỉ đọc',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vGap16,

                    // Attendance summary
                    Text(
                      'Tóm tắt điểm danh',
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.vGap8,
                    _AttendanceSummaryCard(
                      present: data.present,
                      late: data.late,
                      absent: data.absent,
                      unmarked: data.unmarked,
                    ),
                    if (data.unmarked > 0) ...[
                      AppSpacing.vGap8,
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: AchievementColors.yellow.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: AchievementColors.yellow,
                              size: 20,
                            ),
                            AppSpacing.hGap8,
                            Expanded(
                              child: Text(
                                'Còn ${data.unmarked} học viên chưa điểm danh',
                                style: tt.bodySmall?.copyWith(
                                  color: AchievementColors.yellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    AppSpacing.vGap24,

                    // Notes input
                    Text(
                      'Nội dung đã dạy',
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.vGap8,
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Mô tả nội dung đã dạy trong buổi học...',
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                    ),
                    if (_dirty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Đã lưu nháp',
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                          ),
                        ),
                      ),

                    if (_error != null) ...[
                      AppSpacing.vGap16,
                      Text(
                        'Lỗi: $_error',
                        style: tt.bodySmall?.copyWith(color: cs.error),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _complete,
                      child: Text(_saving ? 'Đang xử lý...' : 'Xác nhận hoàn tất'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessionCompleteData {
  const _SessionCompleteData({
    required this.session,
    required this.totalStudents,
    required this.present,
    required this.late,
    required this.absent,
    required this.unmarked,
    required this.duration,
  });

  final Map<String, dynamic> session;
  final int totalStudents;
  final int present;
  final int late;
  final int absent;
  final int unmarked;
  final int duration;
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.present,
    required this.late,
    required this.absent,
    required this.unmarked,
  });

  final int present;
  final int late;
  final int absent;
  final int unmarked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Có mặt',
            value: present,
            color: AchievementColors.green,
          ),
          _StatItem(
            label: 'Muộn',
            value: late,
            color: AchievementColors.yellow,
          ),
          _StatItem(
            label: 'Vắng',
            value: absent,
            color: AchievementColors.red,
          ),
          if (unmarked > 0)
            _StatItem(
              label: 'Chưa',
              value: unmarked,
              color: cs.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: tt.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
