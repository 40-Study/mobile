import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

import 'course_form_widgets.dart';
import 'course_metadata_editor.dart';
import 'course_outline_screen.dart';
import 'widgets/course_detail_header.dart';
import 'widgets/course_outline_action.dart';
import 'widgets/course_management_actions.dart';
import 'widgets/course_review_section.dart';
import 'widgets/course_enrollments.dart';

class TeacherCourseDetailScreen extends StatefulWidget {
  const TeacherCourseDetailScreen({
    super.key,
    required this.api,
    required this.courseId,
  });
  final TeacherApi api;
  final String courseId;
  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  int _generation = 0;
  bool _busy = false;
  Object? _error;
  void _reload() => setState(() => _generation++);
  Future<void> _review(Map<String, dynamic> course) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _performReview(course);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _performReview(Map<String, dynamic> course) async {
    final pending = course['status'] == 'pending_review';
    if (!pending) {
      try {
        final sections = teacherList(
          await widget.api.get('/courses/${widget.courseId}/sections/'),
          keys: const ['sections'],
        );
        if (!mounted) return;
        final lessons = [
          for (final section in sections) ...teacherList(section['lessons']),
        ];
        final empty = <String>[];
        for (final lesson in lessons) {
          final contents = teacherList(
            await widget.api.get('/lessons/${lesson['id']}/contents/'),
            keys: const ['contents'],
          );
          if (contents.isEmpty) empty.add('${lesson['title']}');
        }
        if (!mounted) return;
        if (lessons.isEmpty || empty.isNotEmpty) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Giáo trình chưa sẵn sàng'),
              content: Text(
                lessons.isEmpty
                    ? 'Thêm ít nhất một bài học trước khi gửi duyệt.'
                    : 'Các bài chưa có nội dung:\n${empty.join('\n')}',
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _open(
                      TeacherCourseOutlineScreen(
                        api: widget.api,
                        courseId: widget.courseId,
                        writable: teacherCourseWritable(course),
                      ),
                    );
                  },
                  child: const Text('Mở giáo trình'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đã hiểu'),
                ),
              ],
            ),
          );
          return;
        }
      } catch (error) {
        if (mounted) setState(() => _error = error);
        return;
      }
    }
    if (!mounted) return;
    if (!await courseConfirm(
      context,
      pending ? 'Rút yêu cầu duyệt?' : 'Gửi khóa học để duyệt?',
      pending
          ? 'Khóa trở về nháp để bạn tiếp tục chỉnh sửa.'
          : 'Giáo trình đã có nội dung. Hệ thống sẽ kiểm tra lại trước khi tiếp nhận. Bạn không thể chỉnh sửa khi đang chờ duyệt.',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.post(
        '/courses/${widget.courseId}/${pending ? 'withdraw-review' : 'submit-review'}',
      );
      if (mounted) _reload();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    appBar: AppBar(
      title: const Text('Quản lý khóa cá nhân'),
      actions: [
        IconButton(
          onPressed: _reload,
          tooltip: 'Tải lại',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(_generation),
      load: () => widget.api.get('/courses/${widget.courseId}'),
      builder: (context, raw) {
        final course = teacherMap(raw);
        final writable = teacherCourseWritable(course);
        final status = '${course['status'] ?? ''}';
        void openOutline() => _open(
          TeacherCourseOutlineScreen(
            api: widget.api,
            courseId: widget.courseId,
            writable: writable,
          ),
        );
        return ListView(
          padding: AppSpacing.paddingScreenAll,
          children: [
            CourseDetailHeader(course: course),
            AppSpacing.vGap24,
            CourseOutlineAction(writable: writable, onOpen: openOutline),
            AppSpacing.vGap24,
            CourseManagementActions(
              writable: writable,
              onEdit: () =>
                  _open(CourseMetadataEditor(api: widget.api, course: course)),
              onEnrollments: () => _open(
                CourseEnrollments(api: widget.api, courseId: widget.courseId),
              ),
            ),
            if (course['rejection_reason'] != null ||
                !writable ||
                ['draft', 'rejected', 'pending_review'].contains(status)) ...[
              AppSpacing.vGap24,
              CourseReviewSection(
                course: course,
                busy: _busy,
                error: _error,
                onReview: () => _review(course),
                onRetry: _reload,
              ),
            ],
          ],
        );
      },
    ),
  );
}
