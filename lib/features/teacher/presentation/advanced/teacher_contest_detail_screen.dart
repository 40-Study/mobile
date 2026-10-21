import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

import 'teacher_contest_status.dart';
import 'teacher_contest_editor.dart';

class TeacherContestScreen extends StatefulWidget {
  const TeacherContestScreen({super.key, required this.contestId, this.api});
  final String contestId;
  final TeacherApi? api;
  @override
  State<TeacherContestScreen> createState() => _TeacherContestScreenState();
}

class _TeacherContestScreenState extends State<TeacherContestScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0, page = 1;
  bool busy = false;
  Future<void> action(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(name == 'delete' ? 'Xóa bản nháp?' : 'Gửi duyệt cuộc thi?'),
        content: Text(
          name == 'delete'
              ? 'Cuộc thi này sẽ bị xóa.'
              : 'Sau khi gửi, nội dung sẽ được khóa trong thời gian xét duyệt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    try {
      if (name == 'delete') {
        await api.delete('/contests/${widget.contestId}');
        if (mounted) Navigator.pop(context);
      } else {
        await api.post('/contests/${widget.contestId}/submit-review');
        if (mounted) setState(() => revision++);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chi tiết cuộc thi'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(revision),
      load: () => api.get('/contests/manage/${widget.contestId}'),
      builder: (context, raw) {
        final item = teacherMap(raw);
        final editable = ['DRAFT', 'REJECTED'].contains(item['status']);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${item['title']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(contestStatus(item['status'])),
            const SizedBox(height: 16),
            Text('${item['description'] ?? ''}'),
            Text(
              '${item['question_count'] ?? 0} câu · ${item['duration_minutes'] ?? 0} phút',
            ),
            Text('Bắt đầu: ${teacherDisplayDate(item['start_time'])}'),
            Text('Kết thúc: ${teacherDisplayDate(item['end_time'])}'),
            if (item['reject_reason'] != null)
              Text(
                'Lý do cần sửa: ${item['reject_reason']}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (editable) ...[
              FilledButton(
                onPressed: busy ? null : () => action('review'),
                child: const Text('Gửi duyệt'),
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () async {
                        await teacherPush<void>(
                          context,
                          TeacherContestEditor(api: api, initial: item),
                        );
                        if (mounted) setState(() => revision++);
                      },
                child: const Text('Chỉnh sửa'),
              ),
              TextButton(
                onPressed: busy ? null : () => action('delete'),
                child: const Text('Xóa bản nháp'),
              ),
            ],
            const TeacherSectionTitle(title: 'Thí sinh'),
            TeacherAsyncView<dynamic>(
              key: ValueKey('participants-$page-$revision'),
              load: () => api.get(
                '/contests/manage/${widget.contestId}/participants',
                query: {'page': page, 'limit': 20},
              ),
              builder: (context, raw) {
                final people = teacherList(raw);
                final total =
                    (teacherMap(raw)['total_count'] as num?)?.toInt() ??
                    people.length;
                return Column(
                  children: [
                    if (people.isEmpty) const Text('Chưa có thí sinh.'),
                    ...people.map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${p['user_name'] ?? ''}'),
                        subtitle: Text('${p['attempt_status'] ?? ''}'),
                        trailing: Text(
                          p['score'] == null
                              ? 'Chưa có điểm'
                              : '${p['score']} điểm',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: page > 1
                              ? () => setState(() => page--)
                              : null,
                          child: const Text('Trước'),
                        ),
                        Text('$page'),
                        TextButton(
                          onPressed: page * 20 < total
                              ? () => setState(() => page++)
                              : null,
                          child: const Text('Tiếp'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    ),
  );
}
