import 'package:flutter/material.dart';
import '../../../data/teacher_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';

import 'assignment_format.dart';
import 'teacher_assignment_records.dart';

class TeacherAssignmentDetail extends StatefulWidget {
  const TeacherAssignmentDetail({
    required this.api,
    required this.id,
    required this.canWrite,
  });
  final TeacherApi api;
  final String id;
  final bool canWrite;
  @override
  State<TeacherAssignmentDetail> createState() =>
      _TeacherAssignmentDetailState();
}

class _TeacherAssignmentDetailState extends State<TeacherAssignmentDetail> {
  int revision = 0;
  bool busy = false;
  Future<void> mutate(String action) async {
    if (!await teacherToolConfirm(
      context,
      action == 'publish'
          ? 'Công bố bài tập cho học viên?'
          : 'Thu hồi công bố bài tập?',
    )) {
      return;
    }
    if (!mounted || busy) return;
    setState(() => busy = true);
    try {
      await widget.api.post('/assignments/${widget.id}/$action');
      if (mounted) setState(() => revision++);
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
    appBar: AppBar(title: const Text('Chi tiết bài tập')),
    body: TeacherAsyncView<Map<String, dynamic>>(
      key: ValueKey(revision),
      load: () async =>
          toolPayload(await widget.api.get('/assignments/${widget.id}')),
      builder: (context, a) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${a['title']}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(a['is_published'] == true ? 'Đã công bố' : 'Bản nháp'),
          const SizedBox(height: 16),
          SelectableText('${a['description']}'),
          const SizedBox(height: 16),
          Text(
            'Ngôn ngữ: ${(a['language'] as List? ?? []).join(', ')}\n${teacherAssignmentDeadline(a['end_time'])}',
          ),
          if (widget.canWrite)
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: busy
                      ? null
                      : () => mutate(
                          a['is_published'] == true ? 'unpublish' : 'publish',
                        ),
                  child: Text(
                    a['is_published'] == true ? 'Thu hồi' : 'Công bố',
                  ),
                ),
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final saved = await teacherToolForm(
                            context,
                            title: 'Sửa nội dung bài tập',
                            fields: {
                              'Tiêu đề': '${a['title']}',
                              'Nội dung đề': '${a['description']}',
                              'Code mẫu': '${a['starter_code'] ?? ''}',
                            },
                            validate: (v) =>
                                v['Tiêu đề']!.length < 3 ||
                                    v['Nội dung đề']!.isEmpty
                                ? 'Điền đủ tiêu đề và nội dung.'
                                : null,
                            save: (v) async {
                              await widget.api.put(
                                '/assignments/${widget.id}',
                                data: {
                                  'title': v['Tiêu đề'],
                                  'description': v['Nội dung đề'],
                                  'starter_code': v['Code mẫu'],
                                },
                              );
                            },
                          );
                          if (saved && mounted) setState(() => revision++);
                        },
                  child: const Text('Sửa'),
                ),
              ],
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Testcase'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => teacherPush<void>(
              context,
              TeacherAssignmentRecords(
                api: widget.api,
                id: widget.id,
                tests: true,
                canWrite: widget.canWrite,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bài nộp'),
            subtitle: const Text(
              'Mỗi dòng là một lần nộp, không phải số học viên.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => teacherPush<void>(
              context,
              TeacherAssignmentRecords(
                api: widget.api,
                id: widget.id,
                tests: false,
                canWrite: false,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
