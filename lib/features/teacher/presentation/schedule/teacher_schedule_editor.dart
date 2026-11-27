import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/theme/theme.dart';

class TeacherScheduleEditor extends StatefulWidget {
  const TeacherScheduleEditor({
    super.key,
    required this.api,
    required this.classId,
    this.sessionId,
    this.scheduleId,
    this.recurring = false,
    this.generate = false,
    this.initialDate,
    this.initial = const {},
  });
  final TeacherApi api;
  final String classId;
  final String? sessionId;
  final String? scheduleId;
  final bool recurring;
  final bool generate;
  final DateTime? initialDate;
  final Map<String, dynamic> initial;
  @override
  State<TeacherScheduleEditor> createState() => _TeacherScheduleEditorState();
}

class _TeacherScheduleEditorState extends State<TeacherScheduleEditor> {
  final _form = GlobalKey<FormState>();
  late DateTime _date;
  DateTime? _until;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late int _weekday;
  late TextEditingController _topic;
  late TextEditingController _notes;
  late TextEditingController _room;
  bool _dirty = false;
  bool _saving = false;
  bool _showValidation = false;
  Object? _error;

  String? get _dateError {
    if (widget.generate && _until == null) return 'Chọn ngày kết thúc.';
    if (_until?.isBefore(_date) == true) {
      return 'Ngày kết thúc phải từ ngày bắt đầu trở đi.';
    }
    return null;
  }

  String? get _timeError =>
      !widget.generate &&
          _end.hour * 60 + _end.minute <= _start.hour * 60 + _start.minute
      ? 'Giờ kết thúc phải sau giờ bắt đầu.'
      : null;

  String get _title => widget.generate
      ? 'Sinh buổi từ lịch định kỳ'
      : widget.recurring
      ? (widget.scheduleId == null ? 'Thêm lịch định kỳ' : 'Sửa lịch định kỳ')
      : (widget.sessionId == null ? 'Tạo buổi học' : 'Sửa buổi học');
  @override
  void initState() {
    super.initState();
    _date =
        widget.initialDate ??
        DateTime.tryParse(
          '${widget.initial['date'] ?? widget.initial['effective_from']}',
        ) ??
        DateTime.now();
    _until = DateTime.tryParse('${widget.initial['effective_until']}');
    _weekday =
        (widget.initial['day_of_week'] as num?)?.toInt() ?? _date.weekday % 7;
    _start = _parseTime(
      widget.initial['start_time'],
      const TimeOfDay(hour: 8, minute: 0),
    );
    _end = _parseTime(
      widget.initial['end_time'],
      const TimeOfDay(hour: 9, minute: 0),
    );
    _topic = TextEditingController(text: '${widget.initial['topic'] ?? ''}');
    _notes = TextEditingController(text: '${widget.initial['notes'] ?? ''}');
    _room = TextEditingController(text: '${widget.initial['room'] ?? ''}');
  }

  TimeOfDay _parseTime(dynamic value, TimeOfDay fallback) {
    final parts = teacherTime(value).split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        hour < 0 ||
        hour > 23 ||
        minute == null ||
        minute < 0 ||
        minute > 59) {
      return fallback;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _time(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  @override
  void dispose() {
    _topic.dispose();
    _notes.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool end) async {
    final date = await showDatePicker(
      context: context,
      initialDate: end ? _until ?? _date : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        if (end) {
          _until = date;
        } else {
          _date = date;
        }
        _dirty = true;
      });
    }
  }

  Future<void> _pickTime(bool end) async {
    final time = await showTimePicker(
      context: context,
      initialTime: end ? _end : _start,
    );
    if (time != null && mounted) {
      setState(() {
        if (end) {
          _end = time;
        } else {
          _start = time;
        }
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_dateError != null || _timeError != null) {
      setState(() {
        _showValidation = true;
        _error = null;
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final detail = TeacherClassData(
        teacherPayload(await widget.api.get('/classes/${widget.classId}')),
      );
      if (!detail.canManage) {
        throw const FormatException(
          'Lớp chỉ đọc hoặc bạn không có quyền sửa lịch.',
        );
      }
      final base = '/classes/${widget.classId}';
      Object result = true;
      if (widget.generate) {
        await widget.api.post(
          '$base/sessions/generate',
          data: {
            'start_date': teacherDate(_date),
            'end_date': teacherDate(_until!),
          },
        );
      } else {
        final data = widget.recurring
            ? <String, dynamic>{
                'day_of_week': _weekday,
                'start_time': _time(_start),
                'end_time': _time(_end),
                'room': _room.text.trim(),
                'effective_from': teacherDate(_date),
                if (_until != null) 'effective_until': teacherDate(_until!),
              }
            : <String, dynamic>{
                'date': teacherDate(_date),
                'start_time': _time(_start),
                'end_time': _time(_end),
                'topic': _topic.text.trim(),
                'notes': _notes.text.trim(),
              };
        final path = widget.recurring ? '$base/schedules' : '$base/sessions';
        final id = widget.recurring ? widget.scheduleId : widget.sessionId;
        if (id == null) {
          final response = await widget.api.post(path, data: data);
          if (!widget.recurring) {
            final createdId = teacherPayload(response)['id']?.toString().trim();
            if (createdId != null && createdId.isNotEmpty) result = createdId;
          }
        } else {
          await widget.api.put('$path/$id', data: data);
        }
      }
      if (mounted) {
        setState(() {
          _dirty = false;
          _saving = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, result);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _saving = false;
        });
      }
    }
  }

  Future<void> _discard() async {
    if (_saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lịch chưa lưu'),
        content: const Text('Bỏ thay đổi và quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục chỉnh'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _dirty = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _discard();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(_title)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving
                  ? 'Đang lưu…'
                  : widget.generate
                  ? 'Sinh buổi học'
                  : widget.recurring
                  ? 'Lưu lịch định kỳ'
                  : widget.sessionId == null
                  ? 'Tạo buổi học'
                  : 'Lưu buổi học',
            ),
          ),
        ),
      ),
      body: Form(
        key: _form,
        onChanged: () => setState(() => _dirty = true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.generate) ...[
              const Text(
                'Chọn khoảng ngày để tạo buổi học từ các lịch định kỳ đang áp dụng.',
              ),
              AppSpacing.vGap16,
            ],
            if (widget.recurring)
              DropdownButtonFormField<int>(
                initialValue: _weekday,
                decoration: const InputDecoration(labelText: 'Ngày trong tuần'),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(i == 0 ? 'Chủ nhật' : 'Thứ ${i + 1}'),
                  ),
                ),
                onChanged: _saving
                    ? null
                    : (day) => setState(() {
                        _weekday = day!;
                        _dirty = true;
                      }),
              ),
            ListTile(
              title: Text(
                widget.recurring || widget.generate ? 'Từ ngày' : 'Ngày học',
              ),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _saving ? null : () => _pickDate(false),
            ),
            if (widget.recurring || widget.generate)
              ListTile(
                title: const Text('Đến ngày'),
                subtitle: Text(
                  _until == null
                      ? (widget.generate ? 'Bắt buộc chọn' : 'Không giới hạn')
                      : DateFormat('dd/MM/yyyy').format(_until!),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _saving ? null : () => _pickDate(true),
              ),
            if (_showValidation && _dateError != null)
              Padding(
                padding: AppSpacing.paddingHorizontalLg,
                child: Text(
                  _dateError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (!widget.generate) ...[
              ListTile(
                title: const Text('Bắt đầu'),
                subtitle: Text(_time(_start)),
                trailing: const Icon(Icons.schedule_outlined),
                onTap: _saving ? null : () => _pickTime(false),
              ),
              ListTile(
                title: const Text('Kết thúc'),
                subtitle: Text(_time(_end)),
                trailing: const Icon(Icons.schedule_outlined),
                onTap: _saving ? null : () => _pickTime(true),
              ),
              if (_showValidation && _timeError != null)
                Padding(
                  padding: AppSpacing.paddingHorizontalLg,
                  child: Text(
                    _timeError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              AppSpacing.vGap12,
              if (widget.recurring)
                TextFormField(
                  controller: _room,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Phòng học'),
                )
              else ...[
                TextFormField(
                  controller: _topic,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Chủ đề'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  enabled: !_saving,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
              ],
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Chưa lưu được. ${teacherErrorMessage(_error!)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
