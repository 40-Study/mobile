import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherContentResourcePicker extends StatefulWidget {
  const TeacherContentResourcePicker({
    required this.api,
    required this.type,
    required this.lessonId,
  });
  final TeacherApi api;
  final String type;
  final String lessonId;
  @override
  State<TeacherContentResourcePicker> createState() =>
      _TeacherContentResourcePickerState();
}

class _TeacherContentResourcePickerState
    extends State<TeacherContentResourcePicker> {
  int _page = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.type == 'quiz' ? 'Quiz trong bài học' : 'Thư viện bài lập trình',
      ),
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(_page),
      load: () => widget.api.get(
        widget.type == 'quiz'
            ? '/lessons/${widget.lessonId}/quizzes'
            : '/exercises/',
        query: {'page': _page, 'page_size': 20},
      ),
      builder: (context, raw) {
        final items = teacherList(raw, keys: const ['quizzes']);
        final total =
            int.tryParse('${teacherMap(raw)['total']}') ?? items.length;
        return ListView(
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có nội dung phù hợp. Quay lại để soạn nội dung mới.',
                ),
              ),
            for (final item in items)
              ListTile(
                title: Text('${item['title']}'),
                subtitle: Text(
                  widget.type == 'quiz'
                      ? '${item['question_count'] ?? 0} câu hỏi'
                      : '${item['difficulty'] ?? ''}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, item),
              ),
            if (widget.type != 'quiz')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Trang trước',
                    onPressed: _page > 1 ? () => setState(() => _page--) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Trang $_page'),
                  IconButton(
                    tooltip: 'Trang sau',
                    onPressed: _page * 20 < total
                        ? () => setState(() => _page++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
          ],
        );
      },
    ),
  );
}
