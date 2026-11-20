import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

import 'course_form_widgets.dart';
import 'content/lesson_content_editor.dart';
import 'content/article_preview.dart';

class TeacherLessonContentsScreen extends StatefulWidget {
  const TeacherLessonContentsScreen({
    super.key,
    required this.api,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.writable,
  });
  final TeacherApi api;
  final String courseId;
  final String lessonId;
  final String title;
  final bool writable;
  @override
  State<TeacherLessonContentsScreen> createState() =>
      _TeacherLessonContentsScreenState();
}

class _TeacherLessonContentsScreenState
    extends State<TeacherLessonContentsScreen> {
  int _revision = 0;
  bool _busy = false;
  Object? _error;
  String get _path => '/lessons/${widget.lessonId}/contents/';
  Future<void> _edit(
    String type, {
    Map<String, dynamic>? initial,
    int order = 0,
  }) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherLessonContentEditor(
          api: widget.api,
          courseId: widget.courseId,
          lessonId: widget.lessonId,
          type: type,
          initial: initial,
          order: order,
        ),
      ),
    );
    if (mounted) setState(() => _revision++);
  }

  Future<void> _mutate(Future<dynamic> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) setState(() => _revision++);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _move(
    List<Map<String, dynamic>> items,
    int index,
    int offset,
  ) async {
    final reordered = List<Map<String, dynamic>>.of(items);
    reordered.insert(index + offset, reordered.removeAt(index));
    await _mutate(
      () => widget.api.put(
        '${_path}reorder',
        data: teacherCourseReorder(reordered),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(_revision),
      load: () => widget.api.get(_path),
      builder: (context, raw) {
        final items = teacherList(raw, keys: const ['contents']);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!widget.writable)
              const Text('Chỉ đọc: trạng thái khóa không cho phép chỉnh sửa.'),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              TeacherErrorView(
                error: _error!,
                onRetry: () => setState(() => _revision++),
              ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có nội dung. Thêm bài đọc, video, quiz hoặc bài lập trình.',
                ),
              ),
            for (var index = 0; index < items.length; index++)
              Builder(
                builder: (context) {
                  final item = items[index];
                  final type = '${item['type']}';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${item['title'] ?? teacherContentNames[type]}',
                        ),
                        subtitle: Text(teacherContentNames[type] ?? type),
                        onTap: widget.writable
                            ? () => _edit(type, initial: item)
                            : type == 'article'
                            ? () => showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('${item['title'] ?? 'Bài đọc'}'),
                                  content: SingleChildScrollView(
                                    child: TeacherArticlePreview(
                                      body: '${item['article_body'] ?? ''}',
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        trailing: widget.writable
                            ? PopupMenuButton<String>(
                                enabled: !_busy,
                                tooltip: 'Thao tác nội dung',
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Chỉnh sửa'),
                                  ),
                                  PopupMenuItem(
                                    value: 'up',
                                    enabled: index > 0,
                                    child: const Text('Di chuyển lên'),
                                  ),
                                  PopupMenuItem(
                                    value: 'down',
                                    enabled: index + 1 < items.length,
                                    child: const Text('Di chuyển xuống'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa nội dung'),
                                  ),
                                ],
                                onSelected: (v) async {
                                  if (v == 'edit') {
                                    await _edit(type, initial: item);
                                  }
                                  if (v == 'up') await _move(items, index, -1);
                                  if (v == 'down') await _move(items, index, 1);
                                  if (v == 'delete' &&
                                      await courseConfirm(
                                        context,
                                        'Xóa nội dung?',
                                        'Gỡ nội dung khỏi bài học. Quiz/bài lập trình liên kết vẫn được giữ lại.',
                                        confirm: 'Xóa',
                                      ) &&
                                      mounted) {
                                    await _mutate(
                                      () => widget.api.delete(
                                        '$_path${item['id']}',
                                      ),
                                    );
                                  }
                                },
                              )
                            : null,
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
              ),
            if (widget.writable)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in teacherContentNames.keys)
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _edit(type, order: items.length),
                        icon: const Icon(Icons.add),
                        label: Text(teacherContentNames[type]!),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    ),
  );
}
