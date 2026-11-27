import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_leave_api.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/theme/theme.dart';

class TeacherLeaveCreateScreen extends StatefulWidget {
  const TeacherLeaveCreateScreen({
    super.key,
    required this.api,
    this.organizationId,
    this.workplaceLabel,
    this.prefilledDate,
  });
  final TeacherApi api;
  final String? organizationId;
  final String? workplaceLabel;
  final DateTime? prefilledDate;

  @override
  State<TeacherLeaveCreateScreen> createState() =>
      _TeacherLeaveCreateScreenState();
}

class _TeacherLeaveCreateScreenState extends State<TeacherLeaveCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;
  List<TeacherOccurrence> _affectedSessions = [];
  bool _loadingSessions = false;
  Object? _sessionsError;
  Object? _submitError;
  int _requestRevision = 0;
  bool _submitting = false;

  bool get _readOnly => widget.api is TeacherPreviewApi;
  bool get _canSubmit =>
      !_readOnly &&
      !_submitting &&
      !_loadingSessions &&
      _sessionsError == null &&
      _fromDate != null &&
      _toDate != null;

  @override
  void initState() {
    super.initState();
    final prefilledDate = widget.prefilledDate;
    if (prefilledDate != null) {
      final today = DateUtils.dateOnly(DateTime.now());
      final date = DateUtils.dateOnly(prefilledDate);
      final lastDate = DateTime(today.year, today.month, today.day + 365);
      if (date.isBefore(today) || date.isAfter(lastDate)) return;
      _fromDate = date;
      _toDate = date;
      _loadAffectedSessions();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final lastDate = DateTime(now.year, now.month, now.day + 365);
    final from = _fromDate;
    final to = _toDate;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: lastDate,
      initialDateRange:
          from != null &&
              to != null &&
              !from.isBefore(now) &&
              !to.isAfter(lastDate)
          ? DateTimeRange(start: from, end: to)
          : null,
      helpText: 'Chọn ngày xin nghỉ',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      saveText: 'Lưu',
    );
    if (picked != null && mounted && !_submitting) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadAffectedSessions();
    }
  }

  Future<void> _loadAffectedSessions() async {
    final from = _fromDate;
    final to = _toDate;
    if (from == null || to == null) return;
    final revision = ++_requestRevision;
    setState(() {
      _loadingSessions = true;
      _sessionsError = null;
      _affectedSessions = [];
    });
    try {
      final classes = await teacherAssignedClasses(widget.api);
      if (!mounted || revision != _requestRevision) return;
      final sessions = <TeacherOccurrence>[];
      for (var start = from; !start.isAfter(to);) {
        final limit = DateTime(start.year, start.month, start.day + 119);
        final end = limit.isBefore(to) ? limit : to;
        sessions.addAll(
          await teacherLoadTimetable(
            widget.api,
            widget.organizationId,
            start,
            end,
            assignedClasses: classes,
          ),
        );
        if (!mounted || revision != _requestRevision) return;
        start = DateTime(end.year, end.month, end.day + 1);
      }
      setState(() {
        _affectedSessions = sessions;
        _loadingSessions = false;
      });
    } catch (error) {
      if (mounted && revision == _requestRevision) {
        setState(() {
          _sessionsError = error;
          _loadingSessions = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || !_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      await widget.api.post(
        '/me/leave-requests',
        data: {
          'organization_id': widget.organizationId,
          'from_date': teacherDate(_fromDate!),
          'to_date': teacherDate(_toDate!),
          'reason': _reasonController.text.trim(),
          if (teacherUsingSampleLeave(widget.api))
            'affected_sessions': [
              for (final session in _affectedSessions)
                {
                  'id': session.sessionId ?? session.classId,
                  'class_name': session.classData.name,
                  'date': teacherDate(session.date),
                  'time': '${session.start} – ${session.end}',
                },
            ],
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              teacherUsingSampleLeave(widget.api)
                  ? 'Đã lưu đơn xin nghỉ mẫu'
                  : 'Đã gửi đơn xin nghỉ',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitError = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tạo đơn xin nghỉ')),
        bottomNavigationBar: _readOnly
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_submitError case final error?) ...[
                        Text(
                          teacherErrorMessage(error),
                          style: TextStyle(color: cs.error),
                        ),
                        AppSpacing.vGap8,
                      ],
                      FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: Text(_submitting ? 'Đang gửi…' : 'Gửi đơn'),
                      ),
                    ],
                  ),
                ),
              ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.paddingScreenAll,
            children: [
              if (widget.workplaceLabel case final label?) ...[
                Text('Nơi làm việc · $label'),
                const SizedBox(height: 16),
              ],
              // Date picker
              Text(
                'Ngày xin nghỉ',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _selectDateRange,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _fromDate != null && _toDate != null
                      ? _fromDate == _toDate
                            ? dateFormat.format(_fromDate!)
                            : '${dateFormat.format(_fromDate!)} - ${dateFormat.format(_toDate!)}'
                      : 'Chọn ngày',
                ),
              ),

              const SizedBox(height: 24),

              // Affected sessions
              Text(
                'Buổi học bị ảnh hưởng',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (_loadingSessions)
                const Center(child: CircularProgressIndicator())
              else if (_fromDate == null)
                Text(
                  'Chọn ngày để xem buổi học bị ảnh hưởng',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )
              else if (_sessionsError != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chưa kiểm tra được lịch.'),
                    Text(
                      teacherErrorMessage(_sessionsError!),
                      style: TextStyle(color: cs.error),
                    ),
                    TextButton(
                      onPressed: _loadAffectedSessions,
                      child: const Text('Thử lại'),
                    ),
                  ],
                )
              else if (_affectedSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AchievementColors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không có buổi học nào trong khoảng thời gian này',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: cs.onTertiaryContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_affectedSessions.length} buổi sẽ bị ảnh hưởng',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: cs.onTertiaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      for (final session in _affectedSessions)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.school_outlined, size: 20),
                          title: Text(session.classData.name),
                          subtitle: Text(
                            '${dateFormat.format(session.date)} · ${session.start} - ${session.end}',
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Reason
              Text(
                'Lý do xin nghỉ',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                readOnly: _submitting || _readOnly,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do xin nghỉ...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do';
                  }
                  if (value.trim().length < 10) {
                    return 'Lý do cần ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Text(
                _readOnly
                    ? 'Dữ liệu mẫu · Chỉ xem giao diện'
                    : teacherUsingSampleLeave(widget.api)
                    ? 'Đơn mẫu chỉ lưu trong phiên này. Lịch thật không thay đổi.'
                    : 'Lịch dạy được cập nhật sau khi đơn được duyệt.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
