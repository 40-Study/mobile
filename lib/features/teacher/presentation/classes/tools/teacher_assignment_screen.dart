import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';
import '../../../data/teacher_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';

import 'assignment_format.dart';
import 'teacher_assignment_detail.dart';

class TeacherAssignmentScreen extends StatefulWidget {
  const TeacherAssignmentScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.canWrite,
    this.embedded = false,
  });
  final TeacherApi api;
  final String classId;
  final bool canWrite;
  final bool embedded;
  @override
  State<TeacherAssignmentScreen> createState() =>
      _TeacherAssignmentScreenState();
}

class _TeacherAssignmentScreenState extends State<TeacherAssignmentScreen> {
  int revision = 0;
  Future<void> create() async {
    final saved = await teacherToolForm(
      context,
      title: 'Bài tập lập trình mới',
      choices: const {
        'Độ khó': {'easy': 'Dễ', 'medium': 'Trung bình', 'hard': 'Khó'},
        'Loại bài tập': {'homework': 'Bài tập về nhà', 'project': 'Dự án'},
        'Cho nộp muộn': {'true': 'Cho phép', 'false': 'Không cho phép'},
      },
      dateFields: const {'Bắt đầu', 'Hạn nộp'},
      fields: {
        'Loại bài tập': 'homework',
        'Tiêu đề': '',
        'Nội dung đề': '',
        'Ngôn ngữ (phân cách dấu phẩy)': 'python',
        'Độ khó': 'easy',
        'Code mẫu': '',
        'Bắt đầu': '',
        'Hạn nộp': '',
        'Cho nộp muộn': 'false',
        'Trừ điểm muộn (%)': '0',
        'Số ngày nộp muộn tối đa': '0',
        'Thời gian ân hạn (phút)': '0',
      },
      validate: (v) {
        if (v['Tiêu đề']!.length < 3 || v['Nội dung đề']!.isEmpty) {
          return 'Nhập tiêu đề ít nhất 3 ký tự và nội dung đề.';
        }
        if (!['easy', 'medium', 'hard'].contains(v['Độ khó'])) {
          return 'Độ khó không hợp lệ.';
        }
        if (v['Ngôn ngữ (phân cách dấu phẩy)']!
            .split(',')
            .every((s) => s.trim().isEmpty)) {
          return 'Chọn ít nhất một ngôn ngữ.';
        }
        final start = v['Bắt đầu']!, end = v['Hạn nộp']!;
        if ((start.isNotEmpty && DateTime.tryParse(start) == null) ||
            (end.isNotEmpty && DateTime.tryParse(end) == null)) {
          return 'Vui lòng chọn lại thời gian bắt đầu và hạn nộp.';
        }
        if (start.isNotEmpty &&
            end.isNotEmpty &&
            !DateTime.parse(end).isAfter(DateTime.parse(start))) {
          return 'Hạn nộp phải sau thời điểm bắt đầu.';
        }
        if (!['true', 'false'].contains(v['Cho nộp muộn'])) {
          return 'Cho nộp muộn nhận true hoặc false.';
        }
        for (final key in [
          'Trừ điểm muộn (%)',
          'Số ngày nộp muộn tối đa',
          'Thời gian ân hạn (phút)',
        ]) {
          final n = int.tryParse(v[key]!);
          if (n == null || n < 0 || (key.contains('%') && n > 100)) {
            return '$key không hợp lệ.';
          }
        }
        return null;
      },
      save: (v) async {
        await widget.api.post(
          '/assignments',
          data: {
            'class_id': widget.classId,
            'type': v['Loại bài tập'],
            'title': v['Tiêu đề'],
            'description': v['Nội dung đề'],
            'difficulty': v['Độ khó'],
            'language': v['Ngôn ngữ (phân cách dấu phẩy)']!
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            'starter_code': v['Code mẫu'],
            'time_limit': 2,
            'memory_limit': 256,
            if (v['Bắt đầu']!.isNotEmpty)
              'start_time': DateTime.parse(
                v['Bắt đầu']!,
              ).toUtc().toIso8601String(),
            if (v['Hạn nộp']!.isNotEmpty)
              'end_time': DateTime.parse(
                v['Hạn nộp']!,
              ).toUtc().toIso8601String(),
            'allow_late_submission': v['Cho nộp muộn'] == 'true',
            'late_penalty_percent': int.parse(v['Trừ điểm muộn (%)']!),
            'max_late_days': int.parse(v['Số ngày nộp muộn tối đa']!),
            'grace_period_minutes': int.parse(v['Thời gian ân hạn (phút)']!),
          },
        );
      },
    );
    if (saved && mounted) setState(() => revision++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.embedded
        ? null
        : AppBar(
            title: const Text('Bài tập lập trình'),
            actions: [
              if (widget.canWrite)
                IconButton(
                  onPressed: create,
                  tooltip: 'Tạo bài tập',
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
    body: Column(
      children: [
        if (widget.embedded && widget.canWrite)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: TextButton.icon(
                onPressed: create,
                icon: const Icon(Icons.add),
                label: const Text('Tạo bài tập'),
              ),
            ),
          ),
        Expanded(
          child: TeacherAsyncView<List<Map<String, dynamic>>>(
            key: ValueKey(revision),
            load: () =>
                toolPages(widget.api, '/classes/${widget.classId}/assignments'),
            builder: (context, rows) => rows.isEmpty
                ? const Center(child: Text('Chưa có bài tập lập trình.'))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => ListTile(
                      title: Text('${rows[i]['title']}'),
                      subtitle: Text(
                        '${teacherAssignmentDeadline(rows[i]['end_time'])}\n${rows[i]['is_published'] == true ? 'Đã công bố' : 'Bản nháp'} · ${teacherAssignmentDifficulty(rows[i]['difficulty'])}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TeacherAssignmentDetail(
                              api: widget.api,
                              id: '${rows[i]['id']}',
                              canWrite: widget.canWrite,
                            ),
                          ),
                        );
                        if (mounted) setState(() => revision++);
                      },
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
