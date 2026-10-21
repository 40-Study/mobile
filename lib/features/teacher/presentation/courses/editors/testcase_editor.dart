import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import '../course_form_widgets.dart';

class TeacherTestcaseEditor extends StatefulWidget {
  const TeacherTestcaseEditor({
    required this.api,
    required this.exerciseId,
    required this.order,
    required this.import,
  });
  final TeacherApi api;
  final String exerciseId;
  final int order;
  final bool import;
  @override
  State<TeacherTestcaseEditor> createState() => _TeacherTestcaseEditorState();
}

class _TeacherTestcaseEditorState extends State<TeacherTestcaseEditor> {
  final _input = TextEditingController();
  final _expected = TextEditingController();
  final _json = TextEditingController();
  bool _hidden = false;
  @override
  void dispose() {
    _input.dispose();
    _expected.dispose();
    _json.dispose();
    super.dispose();
  }

  List<dynamic> _parseImport() {
    final raw = jsonDecode(_json.text);
    final items = raw is Map ? raw['test_cases'] : raw;
    if (items is! List ||
        items.isEmpty ||
        items.any(
          (item) =>
              item is! Map ||
              item['input'] is! String ||
              (item['input'] as String).isEmpty ||
              item['expected_output'] is! String ||
              (item['expected_output'] as String).isEmpty ||
              (item['is_hidden'] != null && item['is_hidden'] is! bool) ||
              (item['display_order'] != null &&
                  (item['display_order'] is! int ||
                      (item['display_order'] as int) < 0)),
        )) {
      throw const FormatException(
        'Cần mảng testcase: input/expected_output là chuỗi không trống, is_hidden là boolean, display_order là số nguyên không âm.',
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title: widget.import ? 'Nhập testcase JSON' : 'Thêm testcase',
    fields: [
      if (widget.import) ...[
        const SelectableText(
          '[{"input":"1 2","expected_output":"3","is_hidden":false,"display_order":0}]',
        ),
        courseField(
          _json,
          'Mảng testcase JSON',
          lines: 12,
          validator: (_) {
            try {
              _parseImport();
              return null;
            } on Object catch (_) {
              return 'JSON không hợp lệ; kiểm tra input, expected_output, is_hidden và display_order';
            }
          },
        ),
      ] else ...[
        courseField(_input, 'Đầu vào', required: true, lines: 4),
        courseField(_expected, 'Kết quả mong đợi', required: true, lines: 4),
        courseSwitch(
          'Ẩn testcase với học viên',
          _hidden,
          (v) => setState(() => _hidden = v),
          subtitle: 'Testcase ẩn vẫn được dùng để chấm bài.',
        ),
      ],
    ],
    onSave: () => widget.import
        ? widget.api.post(
            '/exercises/${widget.exerciseId}/testcases/import',
            data: {'test_cases': _parseImport()},
          )
        : widget.api.post(
            '/exercises/${widget.exerciseId}/testcases',
            data: {
              'input': _input.text,
              'expected_output': _expected.text,
              'is_hidden': _hidden,
              'display_order': widget.order,
            },
          ),
  );
}
