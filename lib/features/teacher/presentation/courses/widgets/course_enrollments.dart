import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class CourseEnrollments extends StatefulWidget {
  const CourseEnrollments({
    super.key,
    required this.api,
    required this.courseId,
  });
  final TeacherApi api;
  final String courseId;
  @override
  State<CourseEnrollments> createState() => _CourseEnrollmentsState();
}

class _CourseEnrollmentsState extends State<CourseEnrollments> {
  int _page = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Học viên khóa học')),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(_page),
      load: () => widget.api.get(
        '/courses/${widget.courseId}/enrollments',
        query: {'page': _page, 'page_size': 20},
      ),
      builder: (context, raw) {
        final data = teacherMap(raw);
        final items = teacherList(raw, keys: const ['enrollments']);
        final total = int.tryParse('${data['total']}') ?? items.length;
        return ListView(
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Chưa có học viên đăng ký khóa này.'),
              ),
            for (final item in items)
              ListTile(
                title: Text('${item['user_name'] ?? item['user_id']}'),
                subtitle: Text(
                  'Tiến độ ${item['progress_percentage'] ?? 0}%\nĐăng ký: ${item['enrolled_at'] ?? ''}',
                ),
                isThreeLine: true,
                trailing: item['completed_at'] != null
                    ? const Tooltip(
                        message: 'Đã hoàn thành',
                        child: Icon(Icons.check_circle_outline),
                      )
                    : null,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Trang trước',
                  onPressed: _page > 1 ? () => setState(() => _page--) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Trang $_page · $total học viên'),
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
