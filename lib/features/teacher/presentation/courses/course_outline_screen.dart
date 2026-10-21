import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';

import 'course_form_widgets.dart';
import 'editors/outline_item_editor.dart';
import 'lesson_contents_screen.dart';
import 'widgets/course_section_card.dart';
import 'widgets/course_lesson_row.dart';

class TeacherCourseOutlineScreen extends StatefulWidget {
  const TeacherCourseOutlineScreen({
    super.key,
    required this.api,
    required this.courseId,
    required this.writable,
  });
  final TeacherApi api;
  final String courseId;
  final bool writable;
  @override
  State<TeacherCourseOutlineScreen> createState() =>
      _TeacherCourseOutlineScreenState();
}

class _TeacherCourseOutlineScreenState
    extends State<TeacherCourseOutlineScreen> {
  int _revision = 0;
  bool _busy = false;
  Object? _error;
  String get _path => '/courses/${widget.courseId}/sections/';
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

  Future<void> _edit({
    Map<String, dynamic>? section,
    Map<String, dynamic>? lesson,
    String? sectionId,
    int count = 0,
  }) async {
    final isLesson = sectionId != null;
    final existing = isLesson ? lesson : section;
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => OutlineItemEditor(
          api: widget.api,
          path: isLesson ? '/sections/$sectionId/lessons/' : _path,
          updatePath: isLesson
              ? '/lessons/${lesson?['id']}'
              : '$_path${section?['id']}',
          lesson: isLesson,
          initial: existing,
          order: count,
        ),
      ),
    );
    if (mounted) setState(() => _revision++);
  }

  Future<void> _delete(String path, String name, bool section) async {
    if (await courseConfirm(
          context,
          'Xóa ${section ? 'chương' : 'bài học'}?',
          'Xóa “$name” cùng toàn bộ ${section ? 'bài học và ' : ''}nội dung bên trong. Thao tác không thể hoàn tác.',
          confirm: 'Xóa',
        ) &&
        mounted) {
      await _mutate(() => widget.api.delete(path));
    }
  }

  Future<void> _move(
    List<Map<String, dynamic>> items,
    int from,
    int to,
    String path,
  ) async {
    final reordered = List<Map<String, dynamic>>.of(items);
    reordered.insert(to, reordered.removeAt(from));
    await _mutate(
      () => widget.api.put(path, data: teacherCourseReorder(reordered)),
    );
  }

  Future<void> _openLesson(Map<String, dynamic> lesson) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherLessonContentsScreen(
          api: widget.api,
          courseId: widget.courseId,
          lessonId: '${lesson['id']}',
          title: '${lesson['title']}',
          writable: widget.writable,
        ),
      ),
    );
    if (mounted) setState(() => _revision++);
  }

  Widget _controls({
    required VoidCallback edit,
    required VoidCallback remove,
    VoidCallback? up,
    VoidCallback? down,
  }) => PopupMenuButton<String>(
    tooltip: 'Thao tác',
    enabled: !_busy,
    onSelected: (v) {
      switch (v) {
        case 'edit':
          edit();
        case 'delete':
          remove();
        case 'up':
          up?.call();
        case 'down':
          down?.call();
      }
    },
    itemBuilder: (_) => [
      const PopupMenuItem(value: 'edit', child: Text('Sửa thông tin')),
      PopupMenuItem(
        value: 'up',
        enabled: up != null,
        child: const Text('Di chuyển lên'),
      ),
      PopupMenuItem(
        value: 'down',
        enabled: down != null,
        child: const Text('Di chuyển xuống'),
      ),
      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    appBar: AppBar(
      title: const Text('Giáo trình'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => _revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(_revision),
      load: () => widget.api.get(_path),
      builder: (context, raw) {
        final sections = teacherList(raw, keys: const ['sections']);
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        return ListView(
          padding: AppSpacing.paddingScreenAll,
          children: [
            if (!widget.writable) ...[
              TeacherSurface(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, color: cs.primary),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chỉ xem giáo trình',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          AppSpacing.vGap4,
                          Text(
                            'Giáo trình chỉ đọc theo trạng thái hiện tại của khóa.',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGap24,
            ],
            if (sections.isNotEmpty) ...[
              Text(
                '${sections.length} chương · ${sections.fold<int>(0, (total, section) => total + teacherList(section['lessons']).length)} bài học',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              AppSpacing.vGap8,
              Text(
                widget.writable
                    ? 'Sắp xếp kiến thức theo từng chương. Mở bài học để soạn nội dung.'
                    : 'Mở từng chương để xem các bài học và học liệu.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              AppSpacing.vGap24,
            ],
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              TeacherErrorView(
                error: _error!,
                onRetry: () => setState(() => _revision++),
              ),
            if (sections.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có chương. Thêm chương đầu tiên để bắt đầu soạn giáo trình.',
                ),
              ),
            for (var index = 0; index < sections.length; index++)
              Builder(
                builder: (context) {
                  final section = sections[index];
                  final lessons = teacherList(section['lessons']);
                  return CourseSectionCard(
                    section: section,
                    index: index,
                    lessonCount: lessons.length,
                    writable: widget.writable,
                    busy: _busy,
                    onAddLesson: () => _edit(
                      sectionId: '${section['id']}',
                      count: lessons.length,
                    ),
                    controls: widget.writable
                        ? _controls(
                            edit: () => _edit(section: section),
                            remove: () => _delete(
                              '$_path${section['id']}',
                              '${section['title']}',
                              true,
                            ),
                            up: index > 0
                                ? () => _move(
                                    sections,
                                    index,
                                    index - 1,
                                    '${_path}reorder',
                                  )
                                : null,
                            down: index + 1 < sections.length
                                ? () => _move(
                                    sections,
                                    index,
                                    index + 1,
                                    '${_path}reorder',
                                  )
                                : null,
                          )
                        : null,
                    lessonRows: [
                      for (
                        var lessonIndex = 0;
                        lessonIndex < lessons.length;
                        lessonIndex++
                      )
                        CourseLessonRow(
                          lesson: lessons[lessonIndex],
                          index: lessonIndex,
                          onOpen: () => _openLesson(lessons[lessonIndex]),
                          controls: widget.writable
                              ? _controls(
                                  edit: () => _edit(
                                    lesson: lessons[lessonIndex],
                                    sectionId: '${section['id']}',
                                  ),
                                  remove: () => _delete(
                                    '/lessons/${lessons[lessonIndex]['id']}',
                                    '${lessons[lessonIndex]['title']}',
                                    false,
                                  ),
                                  up: lessonIndex > 0
                                      ? () => _move(
                                          lessons,
                                          lessonIndex,
                                          lessonIndex - 1,
                                          '/sections/${section['id']}/lessons/reorder',
                                        )
                                      : null,
                                  down: lessonIndex + 1 < lessons.length
                                      ? () => _move(
                                          lessons,
                                          lessonIndex,
                                          lessonIndex + 1,
                                          '/sections/${section['id']}/lessons/reorder',
                                        )
                                      : null,
                                )
                              : null,
                        ),
                    ],
                  );
                },
              ),
            if (widget.writable)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _edit(count: sections.length),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm chương'),
                ),
              ),
          ],
        );
      },
    ),
  );
}
