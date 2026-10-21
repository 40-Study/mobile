import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import '../tool_form.dart';

class TeacherFinalGrades extends StatefulWidget {
  const TeacherFinalGrades({
    required this.api,
    required this.classId,
    required this.canWrite,
  });
  final TeacherApi api;
  final String classId;
  final bool canWrite;
  @override
  State<TeacherFinalGrades> createState() => _TeacherFinalGradesState();
}

class _TeacherFinalGradesState extends State<TeacherFinalGrades> {
  int revision = 0;
  bool busy = false;
  Future<void> action(String action) async {
    if (!await teacherToolConfirm(
      context,
      action == 'calculate'
          ? 'Tính lại điểm tổng kết từ các điểm đã lưu?'
          : 'Chốt kết quả tổng kết của cả lớp? Hãy xem lại từng học viên trước khi xác nhận.',
    )) {
      return;
    }
    if (!mounted || busy) return;
    setState(() => busy = true);
    try {
      await widget.api.post('/classes/${widget.classId}/final-grades/$action');
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
    appBar: AppBar(title: const Text('Tổng kết lớp')),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(revision),
      load: () =>
          toolPages(widget.api, '/classes/${widget.classId}/final-grades'),
      builder: (context, rows) => Column(
        children: [
          if (widget.canWrite)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: busy ? null : () => action('calculate'),
                    child: const Text('Tính tổng kết'),
                  ),
                  FilledButton(
                    onPressed: busy || rows.isEmpty
                        ? null
                        : () => action('finalize'),
                    child: const Text('Chốt kết quả'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: rows.isEmpty
                ? const Center(child: Text('Chưa tính tổng kết.'))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      return ListTile(
                        title: Text(
                          '${r['student_name']} · ${r['weighted_average']}',
                        ),
                        subtitle: Text(
                          '${r['letter_grade'] ?? '—'} · ${r['status']} · Hạng ${r['rank'] ?? '—'}\n${r['notes'] ?? ''}\n${r['finalized_at'] == null ? 'Chưa chốt' : 'Đã chốt: ${r['finalized_at']}'}',
                        ),
                        isThreeLine: true,
                        trailing: widget.canWrite && !busy
                            ? IconButton(
                                tooltip: 'Sửa nhận xét tổng kết',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final saved = await teacherToolForm(
                                    context,
                                    title: 'Nhận xét tổng kết',
                                    fields: {'Nhận xét': '${r['notes'] ?? ''}'},
                                    save: (v) async {
                                      await widget.api.put(
                                        '/classes/${widget.classId}/final-grades/${r['id']}',
                                        data: {'notes': v['Nhận xét']},
                                      );
                                    },
                                  );
                                  if (saved && mounted) {
                                    setState(() => revision++);
                                  }
                                },
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
