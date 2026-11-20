import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/theme/theme.dart';

class TeacherLeaveCreateScreen extends StatefulWidget {
  const TeacherLeaveCreateScreen({
    super.key,
    required this.api,
    this.organizationId,
    this.prefilledDate,
  });
  final TeacherApi api;
  final String? organizationId;
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
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDate != null) {
      _fromDate = widget.prefilledDate;
      _toDate = widget.prefilledDate;
      _loadAffectedSessions();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      helpText: 'Chọn ngày xin nghỉ',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      saveText: 'Lưu',
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadAffectedSessions();
    }
  }

  Future<void> _loadAffectedSessions() async {
    if (_fromDate == null || _toDate == null) return;

    setState(() => _loadingSessions = true);
    try {
      final sessions = await teacherLoadTimetable(
        widget.api,
        widget.organizationId,
        _fromDate!,
        _toDate!,
      );
      if (mounted) {
        setState(() {
          _affectedSessions = sessions
              .where((s) => s.status != 'cancelled')
              .toList();
          _loadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSessions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tải được lịch: ${teacherErrorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày xin nghỉ')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.api.post('/me/leave-requests', data: {
        'organization_id': widget.organizationId,
        'from_date': _fromDate!.toIso8601String().substring(0, 10),
        'to_date': _toDate!.toIso8601String().substring(0, 10),
        'reason': _reasonController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đơn xin nghỉ')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(teacherErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo đơn xin nghỉ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingScreenAll,
          children: [
            // Date picker
            Text(
              'Ngày xin nghỉ',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectDateRange,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
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
                    Icon(Icons.check_circle_outline, color: AchievementColors.green, size: 20),
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
                  color: cs.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_outlined, color: cs.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_affectedSessions.length} buổi sẽ bị ảnh hưởng',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: cs.error,
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

            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Gửi đơn'),
            ),

            const SizedBox(height: 16),
            Text(
              'Đơn sẽ được gửi đến trung tâm để duyệt. Lịch dạy vẫn giữ nguyên cho đến khi đơn được chấp nhận.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
