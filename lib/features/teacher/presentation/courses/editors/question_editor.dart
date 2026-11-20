import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import '../course_form_widgets.dart';

const teacherQuestionTypes = {
  'single_choice': 'Một đáp án',
  'multiple_choice': 'Nhiều đáp án',
  'true_false': 'Đúng / Sai',
  'fill_blank': 'Điền chỗ trống',
  'essay': 'Tự luận',
};

class TeacherQuestionEditor extends StatefulWidget {
  const TeacherQuestionEditor({
    required this.api,
    required this.quizId,
    required this.order,
    this.initial,
  });
  final TeacherApi api;
  final String quizId;
  final int order;
  final Map<String, dynamic>? initial;
  @override
  State<TeacherQuestionEditor> createState() => _TeacherQuestionEditorState();
}

class _TeacherQuestionEditorState extends State<TeacherQuestionEditor> {
  late String _type =
      widget.initial?['question_type']?.toString() ?? 'single_choice';
  late final _question = TextEditingController(
    text: widget.initial?['question_text']?.toString(),
  );
  late final _explanation = TextEditingController(
    text: widget.initial?['explanation']?.toString(),
  );
  late final _points = TextEditingController(
    text: '${widget.initial?['points'] ?? 1}',
  );
  late final _answers = <TextEditingController>[
    for (final a in teacherList(widget.initial?['answers']))
      TextEditingController(text: '${a['answer_text']}'),
  ];
  late final _correct = <bool>[
    for (final a in teacherList(widget.initial?['answers']))
      a['is_correct'] == true,
  ];
  final List<TextEditingController> _removed = [];
  @override
  void initState() {
    super.initState();
    if (_answers.isEmpty) {
      _answers.addAll([TextEditingController(), TextEditingController()]);
      _correct.addAll([true, false]);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _question,
      _explanation,
      _points,
      ..._answers,
      ..._removed,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateAnswers() {
    if (_type == 'essay') return null;
    if (_answers.isEmpty || _answers.any((a) => a.text.trim().isEmpty)) {
      return 'Nhập nội dung tất cả đáp án';
    }
    final count = _correct.where((c) => c).length;
    if (['single_choice', 'true_false'].contains(_type) && count != 1) {
      return 'Chọn đúng một đáp án đúng';
    }
    if (_type == 'true_false' && _answers.length != 2) {
      return 'Câu đúng/sai cần hai đáp án';
    }
    if (_type == 'multiple_choice' && count < 1) {
      return 'Chọn ít nhất một đáp án đúng';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title: widget.initial == null ? 'Thêm câu hỏi' : 'Sửa câu hỏi',
    fields: [
      courseField(_question, 'Câu hỏi', required: true, lines: 3),
      DropdownButtonFormField<String>(
        initialValue: _type,
        decoration: const InputDecoration(labelText: 'Loại câu hỏi'),
        items: teacherQuestionTypes.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => setState(() => _type = v!),
      ),
      courseField(
        _points,
        'Điểm',
        keyboard: TextInputType.number,
        validator: (v) {
          final n = double.tryParse(v ?? '');
          return n != null && n.isFinite && n > 0
              ? null
              : 'Điểm phải lớn hơn 0';
        },
      ),
      if (_type == 'essay')
        const Text(
          'Backend chưa hỗ trợ chấm thủ công câu tự luận trong quiz. Không dùng câu này để hứa hẹn luồng chấm tay.',
        ),
      if (_type != 'essay') ...[
        Text(
          _type == 'fill_blank'
              ? 'Các đáp án được chấp nhận'
              : 'Đánh dấu đáp án đúng',
        ),
        for (var i = 0; i < _answers.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_type != 'fill_blank')
                Checkbox(
                  value: _correct[i],
                  onChanged: (v) => setState(() => _correct[i] = v ?? false),
                ),
              Expanded(
                child: courseField(
                  _answers[i],
                  'Đáp án ${i + 1}',
                  required: true,
                ),
              ),
              IconButton(
                tooltip: 'Xóa đáp án ${i + 1}',
                onPressed: () => setState(() {
                  _removed.add(_answers.removeAt(i));
                  _correct.removeAt(i);
                }),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        TextButton.icon(
          onPressed: () => setState(() {
            _answers.add(TextEditingController());
            _correct.add(false);
          }),
          icon: const Icon(Icons.add),
          label: const Text('Thêm đáp án'),
        ),
        FormField<void>(
          validator: (_) => _validateAnswers(),
          builder: (field) => field.hasError
              ? Text(
                  field.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : const SizedBox.shrink(),
        ),
      ],
      courseField(_explanation, 'Giải thích đáp án', lines: 3),
    ],
    onSave: () {
      final data = {
        'question_text': _question.text,
        'question_type': _type,
        'points': double.parse(_points.text),
        'explanation': _explanation.text,
        if (widget.initial == null) 'display_order': widget.order,
        'answers': _type == 'essay'
            ? <Map<String, dynamic>>[]
            : [
                for (var i = 0; i < _answers.length; i++)
                  {
                    'answer_text': _answers[i].text,
                    'is_correct': _type == 'fill_blank' || _correct[i],
                    'display_order': i,
                  },
              ],
      };
      final path = '/quizzes/${widget.quizId}/questions/';
      return widget.initial == null
          ? widget.api.post(path, data: data)
          : widget.api.put('$path${widget.initial!['id']}', data: data);
    },
  );
}
