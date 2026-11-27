import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';

import '../../../data/teacher_api.dart';
import '../../../data/teacher_preview_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'assignment_format.dart';
import 'tool_form.dart';

class TeacherAssignmentRecords extends StatefulWidget {
  const TeacherAssignmentRecords({
    required this.api,
    required this.id,
    required this.tests,
    required this.canWrite,
    this.canViewHidden = false,
  });
  final TeacherApi api;
  final String id;
  final bool tests, canWrite, canViewHidden;
  @override
  State<TeacherAssignmentRecords> createState() =>
      _TeacherAssignmentRecordsState();
}

class _TeacherAssignmentRecordsState extends State<TeacherAssignmentRecords> {
  int revision = 0;
  bool busy = false;
  String query = '';

  bool get canWrite =>
      widget.tests && widget.canWrite && widget.api is! TeacherPreviewApi;
  String get testPath => '/assignments/${widget.id}/testcases';

  Future<void> _addCase() async {
    final saved = await teacherToolForm(
      context,
      title: 'Thêm ca kiểm thử',
      choices: const {
        'Hiển thị': {'true': 'Ẩn với học viên', 'false': 'Công khai'},
      },
      fields: const {
        'Dữ liệu đầu vào': '',
        'Kết quả mong đợi': '',
        'Hiển thị': 'true',
      },
      rawFields: const {'Dữ liệu đầu vào', 'Kết quả mong đợi'},
      validate: (values) =>
          values['Dữ liệu đầu vào']!.isEmpty ||
              values['Kết quả mong đợi']!.isEmpty
          ? 'Nhập dữ liệu đầu vào và kết quả mong đợi.'
          : null,
      save: (values) async {
        await widget.api.post(
          testPath,
          data: {
            'input': values['Dữ liệu đầu vào'],
            'expected_output': values['Kết quả mong đợi'],
            'is_hidden': values['Hiển thị'] == 'true',
            'display_order': 0,
          },
        );
      },
    );
    if (saved && mounted) setState(() => revision++);
  }

  Future<void> _removeCase(Map<String, dynamic> row, int index) async {
    final id = row['id'];
    if (id == null || busy) return;
    final confirmed = await teacherToolConfirm(
      context,
      'Xóa ca kiểm thử ${index + 1}?',
    );
    if (!confirmed || !mounted || busy) return;
    setState(() => busy = true);
    try {
      await widget.api.delete('$testPath/$id');
      if (mounted) setState(() => revision++);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<List<Map<String, dynamic>>> _load() async {
    if (widget.tests) {
      return toolPages(
        widget.api,
        testPath,
        keys: const ['testcases'],
        query: {
          if (widget.canViewHidden || widget.canWrite) 'include_hidden': true,
        },
      );
    }
    final rows = await toolPages(
      widget.api,
      '/submissions/assignment/${widget.id}',
      keys: const ['submissions'],
    );
    rows.sort((a, b) => _timestamp(b).compareTo(_timestamp(a)));
    return rows;
  }

  String _studentName(Map<String, dynamic> row) {
    final user = teacherMap(row['user']);
    return (user['full_name'] ??
            user['username'] ??
            user['user_name'] ??
            row['student_name'] ??
            row['user_name'] ??
            'Học viên')
        .toString();
  }

  Object? _submissionTime(Map<String, dynamic> row) =>
      row['created_at'] ?? row['submitted_at'];

  int _timestamp(Map<String, dynamic> row) =>
      DateTime.tryParse('${_submissionTime(row)}')?.millisecondsSinceEpoch ?? 0;

  String _visibility(Map<String, dynamic> row) =>
      row['is_hidden'] == true ? 'Ẩn với học viên' : 'Công khai';

  void _showDetail(String title, List<(String, String)> fields) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (label, value) in fields) ...[
                  Text(
                    label,
                    style: Theme.of(dialogContext).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value,
                    style:
                        label == 'Dữ liệu đầu vào' ||
                            label == 'Kết quả mong đợi'
                        ? const TextStyle(fontFamily: 'monospace')
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _testcaseTile(Map<String, dynamic> row, int index) => ListTile(
    title: Text('Ca kiểm thử ${index + 1}'),
    subtitle: Text(_visibility(row)),
    onTap: () => _showDetail('Ca kiểm thử ${index + 1}', [
      ('Hiển thị', _visibility(row)),
      ('Dữ liệu đầu vào', '${row['input'] ?? 'Không được cung cấp'}'),
      (
        'Kết quả mong đợi',
        '${row['expected_output'] ?? 'Không được cung cấp'}',
      ),
    ]),
    trailing: canWrite
        ? IconButton(
            tooltip: 'Xóa ca kiểm thử ${index + 1}',
            icon: const Icon(Icons.delete_outline),
            onPressed: busy ? null : () => _removeCase(row, index),
          )
        : const Icon(Icons.chevron_right),
  );

  Widget _submissionTile(Map<String, dynamic> row) {
    final name = _studentName(row);
    final verdict = teacherAssignmentVerdict(row['verdict']);
    final submitted = teacherAssignmentLocalTime(_submissionTime(row));
    return ListTile(
      title: Text(name),
      subtitle: Text(
        [
          verdict,
          if (row['language'] != null) '${row['language']}',
          if (row['test_cases_passed'] != null &&
              row['total_test_cases'] != null)
            '${row['test_cases_passed']}/${row['total_test_cases']} ca kiểm thử',
          if (submitted != 'Chưa đặt') submitted,
        ].join(' · '),
      ),
      onTap: () => teacherPush<void>(
        context,
        _SubmissionDetail(
          row: row,
          studentName: name,
          verdict: verdict,
          submittedAt: submitted,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildRows(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return Center(
        child: Text(widget.tests ? 'Chưa có ca kiểm thử.' : 'Chưa có bài nộp.'),
      );
    }
    if (widget.tests) {
      return ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) => _testcaseTile(rows[index], index),
      );
    }
    final shown = rows.where((row) {
      final user = teacherMap(row['user']);
      return '${_studentName(row)} ${user['username'] ?? user['user_name'] ?? row['user_name'] ?? ''}'
          .toLowerCase()
          .contains(query);
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Tìm theo học viên',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const Center(child: Text('Không tìm thấy lần nộp phù hợp.'))
              : ListView.separated(
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _submissionTile(shown[index]),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.tests ? 'Bộ kiểm thử' : 'Các lần nộp'),
      actions: [
        if (canWrite)
          IconButton(
            tooltip: 'Thêm ca kiểm thử',
            icon: const Icon(Icons.add),
            onPressed: busy ? null : _addCase,
          ),
      ],
    ),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(revision),
      load: _load,
      builder: (context, rows) => _buildRows(rows),
    ),
  );
}

class _SubmissionDetail extends StatelessWidget {
  const _SubmissionDetail({
    required this.row,
    required this.studentName,
    required this.verdict,
    required this.submittedAt,
  });

  final Map<String, dynamic> row;
  final String studentName;
  final String verdict;
  final String submittedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final runTime = row['execution_time'] ?? row['execution_time_ms'];
    final memory = row['memory_used'] ?? row['memory_used_kb'];
    final passedTests = row['test_cases_passed'];
    final allTests = row['total_test_cases'];
    final details = [
      if (passedTests != null && allTests != null)
        'Ca kiểm thử: $passedTests/$allTests',
      if (runTime != null) 'Thời gian chạy: $runTime ms',
      if (memory != null) 'Bộ nhớ: $memory KB',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài nộp')),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Text(studentName, style: theme.textTheme.headlineSmall),
          if (submittedAt != 'Chưa đặt') Text(submittedAt),
          AppSpacing.vGap16,
          Text('Kết quả', style: theme.textTheme.titleMedium),
          Text(
            verdict,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (row['score'] != null) Text('Điểm: ${row['score']}'),
          if (details.isNotEmpty) ...[
            AppSpacing.vGap16,
            Text('Chi tiết chấm', style: theme.textTheme.titleMedium),
            for (final detail in details) Text(detail),
          ],
          AppSpacing.vGap16,
          Text('Mã bài nộp', style: theme.textTheme.titleMedium),
          if (row['language'] != null) Text('${row['language']}'),
          AppSpacing.vGap8,
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: SelectableText(
                '${row['code'] ?? 'Không được cung cấp'}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
