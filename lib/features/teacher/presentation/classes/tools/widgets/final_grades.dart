import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/app_spacing.dart';
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
    if (busy || !widget.canWrite) return;
    if (!await teacherToolConfirm(
      context,
      action == 'calculate'
          ? 'Tính điểm tổng kết của cả lớp từ các điểm đã lưu?'
          : 'Chốt kết quả tổng kết của cả lớp? Hãy xem lại từng học viên trước khi xác nhận.',
    )) {
      return;
    }
    if (!mounted || busy) return;
    setState(() => busy = true);
    try {
      await widget.api.post('/classes/${widget.classId}/final-grades/$action');
      if (mounted) {
        setState(() => revision++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'calculate'
                  ? 'Đã tính tổng kết của lớp.'
                  : 'Đã chốt kết quả của lớp.',
            ),
          ),
        );
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
    appBar: AppBar(title: const Text('Tổng kết lớp')),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(revision),
      load: () =>
          toolPages(widget.api, '/classes/${widget.classId}/final-grades'),
      builder: (context, rows) {
        final pending = rows.where((row) => row['finalized_at'] == null);
        final wouldChangeResult = pending.any(
          (row) => row['status'] != 'passed',
        );
        final finalizedCount = rows.length - pending.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rows.isNotEmpty || widget.canWrite)
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rows.isNotEmpty)
                      Text(
                        '${rows.length} học viên · $finalizedCount đã chốt · ${pending.length} chưa chốt',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    if (widget.canWrite)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          OutlinedButton(
                            onPressed: busy ? null : () => action('calculate'),
                            child: const Text('Tính tổng kết'),
                          ),
                          FilledButton(
                            onPressed:
                                busy || pending.isEmpty || wouldChangeResult
                                ? null
                                : () => action('finalize'),
                            child: const Text('Chốt kết quả'),
                          ),
                        ],
                      ),
                    if (widget.canWrite && wouldChangeResult)
                      const Text(
                        'Chưa thể chốt lớp có kết quả khác Đạt. Máy chủ hiện chuyển mọi kết quả chưa chốt thành Đạt khi chốt cả lớp.',
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
                            [
                              '${r['letter_grade'] ?? '—'} · ${_resultLabel(r['status'])} · Hạng ${r['rank'] ?? '—'}',
                              _finalizedLabel(r['finalized_at']),
                              if (r['notes'] case final String notes
                                  when notes.isNotEmpty)
                                notes,
                            ].join('\n'),
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
                                      fields: {
                                        'Nhận xét': '${r['notes'] ?? ''}',
                                      },
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
        );
      },
    ),
  );
}

String _resultLabel(Object? status) => switch (status) {
  'passed' => 'Đạt',
  'failed' => 'Chưa đạt',
  'in_progress' => 'Đang tính',
  _ => 'Chưa có kết quả',
};

String _finalizedLabel(Object? value) {
  if (value == null) return 'Chưa chốt';
  final date = DateTime.tryParse(value.toString())?.toLocal();
  return date == null
      ? 'Đã chốt'
      : 'Đã chốt ${DateFormat('dd/MM/yyyy · HH:mm').format(date)}';
}
