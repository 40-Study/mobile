import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_video_upload_screen.dart';
import '../course_form_widgets.dart';
import '../exercise_editor_screen.dart';
import '../quiz_editor_screen.dart';
import 'article_preview.dart';
import 'content_resource_picker.dart';

const teacherContentNames = {
  'article': 'Bài đọc',
  'video': 'Video',
  'quiz': 'Quiz',
  'exercise': 'Bài lập trình',
  'livestream': 'Livestream',
};

class TeacherLessonContentEditor extends StatefulWidget {
  const TeacherLessonContentEditor({
    required this.api,
    required this.courseId,
    required this.lessonId,
    required this.type,
    required this.order,
    this.initial,
  });
  final TeacherApi api;
  final String courseId;
  final String lessonId;
  final String type;
  final int order;
  final Map<String, dynamic>? initial;
  @override
  State<TeacherLessonContentEditor> createState() =>
      _TeacherLessonContentEditorState();
}

class _TeacherLessonContentEditorState
    extends State<TeacherLessonContentEditor> {
  late final _title = TextEditingController(
    text: widget.initial?['title']?.toString(),
  );
  late final _body = TextEditingController(
    text: widget.initial?['article_body']?.toString(),
  );
  late final _url = TextEditingController(
    text: widget.initial?['video_upload_id'] == null
        ? (widget.initial?['video_url']?.toString())
        : '/api/hls/${widget.initial!['video_upload_id']}/master.m3u8',
  );
  late final _subtitle = TextEditingController(
    text: widget.initial?['subtitle_url']?.toString(),
  );
  late final _duration = TextEditingController(
    text: '${widget.initial?['duration'] ?? 0}',
  );
  late final _resource = TextEditingController(
    text: widget.initial?['${widget.type}_id']?.toString(),
  );
  late bool _mandatory = widget.initial?['is_mandatory'] == true;
  bool _preview = false;
  final _resourceField = GlobalKey<FormFieldState<String>>();
  String? _resourceTitle;
  @override
  void dispose() {
    for (final c in [_title, _body, _url, _subtitle, _duration, _resource]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _resourceEditor() async {
    final id = _resource.text.trim();
    final page = widget.type == 'quiz'
        ? TeacherQuizEditorScreen(
            api: widget.api,
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            quizId: id.isEmpty ? null : id,
          )
        : TeacherExerciseEditorScreen(
            api: widget.api,
            exerciseId: id.isEmpty ? null : id,
          );
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result != null && mounted) {
      final resource = teacherMap(result);
      if (resource['id'] != null) {
        setState(() {
          _resource.text = '${resource['id']}';
          _resourceTitle = resource['title']?.toString();
        });
        _resourceField.currentState?.didChange(_resource.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title:
        '${widget.initial == null ? 'Thêm' : 'Sửa'} ${teacherContentNames[widget.type]}',
    fields: [
      courseField(_title, 'Tiêu đề nội dung', required: true),
      if (widget.type == 'article') ...[
        courseField(
          _body,
          'Nội dung bài đọc (HTML)',
          lines: 12,
          validator: (v) => (v ?? '').trim().isEmpty
              ? 'Nhập nội dung bài đọc'
              : v!.length > 200000
              ? 'Tối đa 200.000 ký tự'
              : null,
          helper: 'Hỗ trợ HTML; ví dụ <h2>Tiêu đề</h2><p>Nội dung</p>',
        ),
        TextButton.icon(
          onPressed: () => setState(() => _preview = !_preview),
          icon: const Icon(Icons.visibility_outlined),
          label: Text(_preview ? 'Đóng xem trước' : 'Xem trước bài đọc'),
        ),
        if (_preview) TeacherArticlePreview(body: _body.text),
      ],
      if (widget.type == 'video') ...[
        OutlinedButton.icon(
          onPressed: () => Navigator.push<dynamic>(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherVideoUploadScreen(
                api: widget.api,
                courseId: widget.courseId,
                onUploaded: (upload) {
                  if (upload['upload_id'] == null || !mounted) return;
                  setState(() {
                    _url.text = '/api/hls/${upload['upload_id']}/master.m3u8';
                    if (upload['duration'] is num)
                      _duration.text = '${(upload['duration'] as num).round()}';
                  });
                },
              ),
            ),
          ),
          icon: const Icon(Icons.upload_file),
          label: const Text('Tải video từ thiết bị'),
        ),

        courseField(
          _url,
          'URL video đã tải lên',
          required: true,
          keyboard: TextInputType.url,
          helper:
              'Dùng URL thuộc tài khoản của bạn. Máy chủ kiểm tra quyền sở hữu.',
        ),
        courseField(
          _subtitle,
          'URL phụ đề VTT (tùy chọn)',
          keyboard: TextInputType.url,
          helper: 'Để trống để gỡ phụ đề',
        ),
        courseField(
          _duration,
          'Thời lượng (giây)',
          keyboard: TextInputType.number,
          validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0
              ? 'Nhập số giây không âm'
              : null,
        ),
      ],
      if (['quiz', 'exercise'].contains(widget.type)) ...[
        FormField<String>(
          key: _resourceField,
          initialValue: _resource.text,
          validator: (_) =>
              _resource.text.isEmpty ? 'Chọn nội dung trước khi lưu' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _resource.text.isEmpty
                    ? 'Chưa chọn nội dung'
                    : _resourceTitle ?? 'Đã chọn nội dung liên kết',
              ),
              if (field.hasError)
                Text(
                  field.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final selection = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherContentResourcePicker(
                        api: widget.api,
                        type: widget.type,
                        lessonId: widget.lessonId,
                      ),
                    ),
                  );
                  if (selection != null && mounted) {
                    setState(() {
                      _resource.text = '${selection['id']}';
                      _resourceTitle = '${selection['title']}';
                    });
                    field.didChange(_resource.text);
                  }
                },
                icon: const Icon(Icons.library_books_outlined),
                label: const Text('Chọn từ thư viện'),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _resourceEditor,
          icon: const Icon(Icons.edit_note),
          label: Text(
            _resource.text.isEmpty
                ? 'Soạn nội dung mới'
                : 'Chỉnh sửa nội dung đã chọn',
          ),
        ),
        const Text('Nội dung chỉ được gắn vào bài học khi bạn bấm Lưu.'),
      ],
      if (widget.type == 'livestream')
        const Text(
          'Nội dung livestream được tạo trong giáo trình. Liên kết lớp và lịch dạy được quản lý trong mục lớp học; không tự tạo một buổi học khi lưu nội dung này.',
        ),
      courseSwitch(
        'Nội dung bắt buộc',
        _mandatory,
        (v) => setState(() => _mandatory = v),
      ),
    ],
    onSave: () {
      final data = <String, dynamic>{
        if (widget.initial == null) 'type': widget.type,
        'title': _title.text.trim(),
        'is_mandatory': _mandatory,
        if (widget.initial == null) 'display_order': widget.order,
        if (widget.type == 'article') 'article_body': _body.text,
        if (widget.type == 'video') ...{
          'video_url': _url.text.trim(),
          'duration': int.parse(_duration.text),
          'subtitle_url': _subtitle.text.trim(),
        },
        if (['quiz', 'exercise'].contains(widget.type))
          '${widget.type}_id': _resource.text.trim(),
      };
      final path = '/lessons/${widget.lessonId}/contents/';
      return widget.initial == null
          ? widget.api.post(path, data: data)
          : widget.api.put('$path${widget.initial!['id']}', data: data);
    },
  );
}
