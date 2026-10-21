import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

import 'teacher_contest_status.dart';
import 'teacher_contest_detail_screen.dart';
import 'teacher_contest_editor.dart';
export 'teacher_contest_status.dart' show contestStatus;
export 'teacher_contest_detail_screen.dart' show TeacherContestScreen;
export 'teacher_contest_editor.dart' show TeacherContestEditor;

class TeacherContestsScreen extends StatefulWidget {
  const TeacherContestsScreen({super.key, this.api});
  final TeacherApi? api;
  @override
  State<TeacherContestsScreen> createState() => _TeacherContestsScreenState();
}

class _TeacherContestsScreenState extends State<TeacherContestsScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0, page = 1;
  Future<void> open(Widget screen) async {
    await teacherPush<void>(context, screen);
    if (mounted) setState(() => revision++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cuộc thi của tôi'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => open(TeacherContestEditor(api: api)),
      icon: const Icon(Icons.add),
      label: const Text('Tạo cuộc thi'),
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(revision),
      load: () =>
          api.get('/contests/manage', query: {'page': page, 'limit': 20}),
      builder: (context, raw) {
        final data = teacherMap(raw), items = teacherList(raw);
        final total = (data['total_count'] as num?)?.toInt() ?? items.length;
        return ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Chưa có cuộc thi. Tạo từ một bộ câu hỏi của bạn.'),
              ),
            ...items.map(
              (e) => ListTile(
                title: Text('${e['title']}'),
                subtitle: Text(
                  '${contestStatus(e['status'])} · ${e['participant_count'] ?? 0} thí sinh',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => open(
                  TeacherContestScreen(api: api, contestId: '${e['id']}'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: page > 1
                      ? () => setState(() {
                          page--;
                          revision++;
                        })
                      : null,
                  child: const Text('Trước'),
                ),
                Text('Trang $page'),
                TextButton(
                  onPressed: page * 20 < total
                      ? () => setState(() {
                          page++;
                          revision++;
                        })
                      : null,
                  child: const Text('Tiếp'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
