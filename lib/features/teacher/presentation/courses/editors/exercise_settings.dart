import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import '../course_form_widgets.dart';

class TeacherExerciseSettings extends StatefulWidget {
  const TeacherExerciseSettings({required this.api, this.initial});
  final TeacherApi api;
  final Map<String, dynamic>? initial;
  @override
  State<TeacherExerciseSettings> createState() =>
      _TeacherExerciseSettingsState();
}

class _TeacherExerciseSettingsState extends State<TeacherExerciseSettings> {
  late final _title = TextEditingController(
    text: widget.initial?['title']?.toString(),
  );
  late final _description = TextEditingController(
    text: widget.initial?['description']?.toString(),
  );
  late final _language = TextEditingController(
    text:
        (widget.initial?['language'] as List<dynamic>?)?.join(', ') ?? 'python',
  );
  late final _starter = TextEditingController(
    text: widget.initial?['starter_code']?.toString(),
  );
  late final _time = TextEditingController(
    text: '${widget.initial?['time_limit'] ?? 2}',
  );
  late final _memory = TextEditingController(
    text: '${widget.initial?['memory_limit'] ?? 256}',
  );
  late final _pass = TextEditingController(
    text: '${widget.initial?['pass_percentage'] ?? 100}',
  );
  late String _difficulty =
      widget.initial?['difficulty']?.toString() ?? 'medium';
  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _language,
      _starter,
      _time,
      _memory,
      _pass,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positive(String? value) =>
      (int.tryParse(value ?? '') ?? 0) > 0 ? null : 'Nhập số nguyên lớn hơn 0';
  @override
  Widget build(BuildContext context) => CourseFormPage(
    title: 'Đề bài lập trình',
    fields: [
      courseField(
        _title,
        'Tên đề',
        validator: (v) => (v ?? '').trim().length < 3 || v!.length > 255
            ? 'Tên từ 3 đến 255 ký tự'
            : null,
      ),
      courseField(_description, 'Mô tả đề', required: true, lines: 6),
      DropdownButtonFormField<String>(
        initialValue: _difficulty,
        decoration: const InputDecoration(labelText: 'Độ khó'),
        items: const [
          DropdownMenuItem(value: 'easy', child: Text('Dễ')),
          DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
          DropdownMenuItem(value: 'hard', child: Text('Khó')),
        ],
        onChanged: (v) => setState(() => _difficulty = v!),
      ),
      courseField(
        _language,
        'Ngôn ngữ lập trình',
        required: true,
        helper: 'Mã ngôn ngữ phân cách bằng dấu phẩy: python, go, javascript',
        validator: (v) =>
            (v ?? '').split(',').map((s) => s.trim()).any((s) => s.isEmpty)
            ? 'Nhập ít nhất một mã ngôn ngữ; không để trống giữa các dấu phẩy'
            : null,
      ),
      courseField(_starter, 'Mã khởi đầu', lines: 6),
      courseField(
        _time,
        'Giới hạn thời gian / testcase (giây)',
        keyboard: TextInputType.number,
        validator: _positive,
      ),
      courseField(
        _memory,
        'Giới hạn bộ nhớ (MB)',
        keyboard: TextInputType.number,
        validator: _positive,
      ),
      courseField(
        _pass,
        'Tỷ lệ testcase cần đạt (%)',
        keyboard: TextInputType.number,
        validator: (v) {
          final n = int.tryParse(v ?? '');
          return n == null || n < 1 || n > 100 ? 'Nhập từ 1 đến 100' : null;
        },
      ),
    ],
    onSave: () {
      final data = {
        'title': _title.text.trim(),
        'description': _description.text,
        'language': _language.text.split(',').map((s) => s.trim()).toList(),
        'starter_code': _starter.text,
        'difficulty': _difficulty,
        'time_limit': int.parse(_time.text),
        'memory_limit': int.parse(_memory.text),
        'pass_percentage': int.parse(_pass.text),
      };
      return widget.initial == null
          ? widget.api.post('/exercises/', data: data)
          : widget.api.put('/exercises/${widget.initial!['id']}', data: data);
    },
  );
}
