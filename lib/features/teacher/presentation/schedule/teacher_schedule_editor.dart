import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';

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
  Object? _error;
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
    return parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? fallback.hour,
            minute: int.tryParse(parts[1]) ?? fallback.minute,
          )
        : fallback;
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
    if ((!widget.generate &&
            _end.hour * 60 + _end.minute <= _start.hour * 60 + _start.minute) ||
        (_until != null && _until!.isBefore(_date)) ||
        (widget.generate && _until == null)) {
      setState(
        () => _error = StateError('Kiểm tra giờ kết thúc và khoảng ngày.'),
      );
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
        throw StateError('Lớp chỉ đọc hoặc bạn không có quyền sửa lịch.');
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
            result = teacherPayload(response)['id']?.toString() ?? true;
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
      appBar: AppBar(
        title: Text(
          widget.generate
              ? 'Sinh buổi từ lịch lặp'
              : widget.recurring
              ? 'Lịch dạy định kỳ'
              : 'Thông tin buổi học',
        ),
      ),
      body: Form(
        key: _form,
        onChanged: () => setState(() => _dirty = true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              subtitle: Text(teacherDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _saving ? null : () => _pickDate(false),
            ),
            if (widget.recurring || widget.generate)
              ListTile(
                title: const Text('Đến ngày'),
                subtitle: Text(
                  _until == null
                      ? (widget.generate ? 'Bắt buộc chọn' : 'Không giới hạn')
                      : teacherDate(_until!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _saving ? null : () => _pickDate(true),
              ),
            if (!widget.generate) ...[
              ListTile(
                title: const Text('Bắt đầu'),
                subtitle: Text(_time(_start)),
                onTap: _saving ? null : () => _pickTime(false),
              ),
              ListTile(
                title: const Text('Kết thúc'),
                subtitle: Text(_time(_end)),
                onTap: _saving ? null : () => _pickTime(true),
              ),
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
                  'Chưa lưu được. $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Đang lưu…'
                    : widget.generate
                    ? 'Sinh buổi học'
                    : 'Lưu lịch',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
