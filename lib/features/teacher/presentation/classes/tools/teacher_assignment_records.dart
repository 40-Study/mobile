import 'package:flutter/material.dart';
import '../../../data/teacher_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';

class TeacherAssignmentRecords extends StatefulWidget {
  const TeacherAssignmentRecords({
    required this.api,
    required this.id,
    required this.tests,
    required this.canWrite,
  });
  final TeacherApi api;
  final String id;
  final bool tests, canWrite;
  @override
  State<TeacherAssignmentRecords> createState() =>
      _TeacherAssignmentRecordsState();
}

class _TeacherAssignmentRecordsState extends State<TeacherAssignmentRecords> {
  int revision = 0;
  bool busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.tests ? 'Testcase' : 'Các lần nộp'),
      actions: [
        if (widget.tests && widget.canWrite)
          IconButton(
            tooltip: 'Thêm testcase',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final saved = await teacherToolForm(
                context,
                title: 'Testcase mới',
                choices: const {
                  'Ẩn với học viên': {'true': 'Ẩn', 'false': 'Công khai'},
                },
                fields: {
                  'Input': '',
                  'Output mong đợi': '',
                  'Ẩn với học viên': 'true',
                },
                validate: (v) =>
                    v['Input']!.isEmpty ||
                        v['Output mong đợi']!.isEmpty ||
                        !['true', 'false'].contains(v['Ẩn với học viên'])
                    ? 'Điền đủ Input/Output, chọn true hoặc false cho testcase ẩn.'
                    : null,
                save: (v) async {
                  await widget.api.post(
                    '/assignments/${widget.id}/testcases',
                    data: {
                      'input': v['Input'],
                      'expected_output': v['Output mong đợi'],
                      'is_hidden': v['Ẩn với học viên'] == 'true',
                      'display_order': 0,
                    },
                  );
                },
              );
              if (saved && mounted) setState(() => revision++);
            },
          ),
      ],
    ),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(revision),
      load: () => toolPages(
        widget.api,
        widget.tests
            ? '/assignments/${widget.id}/testcases'
            : '/submissions/assignment/${widget.id}',
      ),
      builder: (context, rows) => rows.isEmpty
          ? Center(
              child: Text(
                widget.tests ? 'Chưa có testcase.' : 'Chưa có bài nộp.',
              ),
            )
          : ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final row = rows[i];
                final user = teacherMap(row['user']);
                return ListTile(
                  title: Text(
                    widget.tests
                        ? 'Testcase ${i + 1}${row['is_hidden'] == true ? ' · Ẩn' : ' · Công khai'}'
                        : '${user['full_name'] ?? user['username'] ?? row['user_id']} · ${row['verdict']}',
                  ),
                  subtitle: Text(
                    widget.tests
                        ? 'Input: ${row['input']}\nOutput: ${row['expected_output'] ?? 'Không được cung cấp'}'
                        : '${row['language']} · ${row['test_cases_passed']}/${row['total_test_cases']} testcase\n${row['created_at']}',
                  ),
                  onTap: widget.tests
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Bài nộp · Chỉ đọc'),
                            content: SingleChildScrollView(
                              child: SelectableText(
                                'Kết quả: ${row['verdict']}\nĐiểm: ${row['score']}\nThời gian: ${row['execution_time']} · Bộ nhớ: ${row['memory_used']}\n\n${row['code'] ?? ''}',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        ),
                  trailing: widget.tests && widget.canWrite
                      ? IconButton(
                          tooltip: 'Xóa testcase',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: busy
                              ? null
                              : () async {
                                  if (!await teacherToolConfirm(
                                    context,
                                    'Xóa testcase này?',
                                  )) {
                                    return;
                                  }
                                  if (!mounted) return;
                                  setState(() => busy = true);
                                  try {
                                    await widget.api.delete(
                                      '/assignments/${widget.id}/testcases/${row['id']}',
                                    );
                                    if (mounted) setState(() => revision++);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Không xóa được: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => busy = false);
                                  }
                                },
                        )
                      : null,
                );
              },
            ),
    ),
  );
}
