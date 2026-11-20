import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import '../course_form_widgets.dart';

class TeacherQuizSettings extends StatefulWidget {
  const TeacherQuizSettings({
    required this.api,
    required this.courseId,
    required this.lessonId,
    this.initial,
  });
  final TeacherApi api;
  final String courseId;
  final String lessonId;
  final Map<String, dynamic>? initial;
  @override
  State<TeacherQuizSettings> createState() => _TeacherQuizSettingsState();
}

class _TeacherQuizSettingsState extends State<TeacherQuizSettings> {
  late final _title = TextEditingController(
    text: widget.initial?['title']?.toString(),
  );
  late final _description = TextEditingController(
    text: widget.initial?['description']?.toString(),
  );
  late final _pass = TextEditingController(
    text: '${widget.initial?['pass_percentage'] ?? 70}',
  );
  late final _attempts = TextEditingController(
    text: '${widget.initial?['max_attempts'] ?? 3}',
  );
  late final _minutes = TextEditingController(
    text: widget.initial?['time_limit_minutes']?.toString(),
  );
  late bool _shuffleQuestions = widget.initial?['shuffle_questions'] == true;
  late bool _shuffleAnswers = widget.initial?['shuffle_answers'] == true;
  late bool _showCorrect = widget.initial?['show_correct_answers'] == true;
  @override
  void dispose() {
    for (final c in [_title, _description, _pass, _attempts, _minutes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title: 'Cấu hình quiz',
    fields: [
      courseField(
        _title,
        'Tên quiz',
        validator: (v) => (v ?? '').trim().length < 3 || v!.length > 255
            ? 'Tên từ 3 đến 255 ký tự'
            : null,
      ),
      courseField(_description, 'Mô tả', lines: 3),
      courseField(
        _pass,
        'Điểm đạt (%)',
        keyboard: TextInputType.number,
        validator: (v) {
          final n = double.tryParse(v ?? '');
          return n == null || !n.isFinite || n < 0 || n > 100
              ? 'Nhập từ 0 đến 100'
              : null;
        },
      ),
      courseField(
        _attempts,
        'Số lượt làm tối đa',
        keyboard: TextInputType.number,
        validator: (v) {
          final n = int.tryParse(v ?? '');
          return n == null || n < 1 || n > 100 ? 'Nhập từ 1 đến 100' : null;
        },
      ),
      courseField(
        _minutes,
        'Giới hạn thời gian (phút, tùy chọn)',
        keyboard: TextInputType.number,
        validator: (v) => (v ?? '').isEmpty || (int.tryParse(v!) ?? 0) > 0
            ? null
            : 'Nhập số phút lớn hơn 0',
      ),
      courseSwitch(
        'Trộn câu hỏi',
        _shuffleQuestions,
        (v) => setState(() => _shuffleQuestions = v),
      ),
      courseSwitch(
        'Trộn đáp án',
        _shuffleAnswers,
        (v) => setState(() => _shuffleAnswers = v),
      ),
      courseSwitch(
        'Cho xem đáp án sau khi nộp',
        _showCorrect,
        (v) => setState(() => _showCorrect = v),
      ),
    ],
    onSave: () {
      final data = {
        'title': _title.text.trim(),
        'description': _description.text,
        'pass_percentage': double.parse(_pass.text),
        'max_attempts': int.parse(_attempts.text),
        'time_limit_minutes': _minutes.text.trim().isEmpty
            ? null
            : int.parse(_minutes.text),
        'shuffle_questions': _shuffleQuestions,
        'shuffle_answers': _shuffleAnswers,
        'show_correct_answers': _showCorrect,
        if (widget.initial == null) 'course_id': widget.courseId,
        if (widget.initial == null) 'lesson_id': widget.lessonId,
      };
      return widget.initial == null
          ? widget.api.post('/quizzes/', data: data)
          : widget.api.put('/quizzes/${widget.initial!['id']}', data: data);
    },
  );
}
