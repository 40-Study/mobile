import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import '../course_form_widgets.dart';

class OutlineItemEditor extends StatefulWidget {
  const OutlineItemEditor({
    super.key,
    required this.api,
    required this.path,
    required this.updatePath,
    required this.lesson,
    required this.order,
    this.initial,
  });
  final TeacherApi api;
  final String path;
  final String updatePath;
  final bool lesson;
  final int order;
  final Map<String, dynamic>? initial;
  @override
  State<OutlineItemEditor> createState() => _OutlineItemEditorState();
}

class _OutlineItemEditorState extends State<OutlineItemEditor> {
  late final _title = TextEditingController(
    text: widget.initial?['title']?.toString(),
  );
  late final _description = TextEditingController(
    text: widget.initial?['description']?.toString(),
  );
  late final _minutes = TextEditingController(
    text: '${widget.initial?['duration_minutes'] ?? 0}',
  );
  late bool _preview = widget.initial?['is_preview'] == true;
  late bool _mandatory = widget.initial?['is_mandatory'] == true;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title:
        '${widget.initial == null ? 'Thêm' : 'Sửa'} ${widget.lesson ? 'bài học' : 'chương'}',
    fields: [
      courseField(
        _title,
        'Tiêu đề',
        validator: (v) => (v ?? '').trim().length < 2 || v!.length > 255
            ? 'Nhập từ 2 đến 255 ký tự'
            : null,
      ),
      courseField(_description, 'Mô tả', lines: 3),
      if (widget.lesson) ...[
        courseField(
          _minutes,
          'Thời lượng (phút)',
          keyboard: TextInputType.number,
          validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0
              ? 'Nhập số phút không âm'
              : null,
        ),
        courseSwitch(
          'Cho phép xem trước',
          _preview,
          (v) => setState(() => _preview = v),
        ),
        courseSwitch(
          'Bài học bắt buộc',
          _mandatory,
          (v) => setState(() => _mandatory = v),
        ),
      ],
    ],
    onSave: () {
      final payload = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        if (widget.initial == null) 'display_order': widget.order,
        if (widget.lesson) 'duration_minutes': int.parse(_minutes.text),
        if (widget.lesson) 'is_preview': _preview,
        if (widget.lesson) 'is_mandatory': _mandatory,
      };
      return widget.initial == null
          ? widget.api.post(widget.path, data: payload)
          : widget.api.put(widget.updatePath, data: payload);
    },
  );
}
