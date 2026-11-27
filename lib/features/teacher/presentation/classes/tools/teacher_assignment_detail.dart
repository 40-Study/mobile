import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';

import '../../../data/teacher_api.dart';
import '../../../data/teacher_preview_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'assignment_format.dart';
import 'teacher_assignment_records.dart';
import 'tool_form.dart';

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
  bool changed = false;
  bool get canWrite => widget.canWrite && widget.api is! TeacherPreviewApi;

  void _markChanged() {
    if (!mounted) return;
    setState(() {
      changed = true;
      revision++;
    });
  }

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
      _markChanged();
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

  Future<void> _edit(Map<String, dynamic> assignment) async {
    final startsAt = DateTime.tryParse('${assignment['start_time']}');
    final endsAt = DateTime.tryParse('${assignment['end_time']}');
    final saved = await teacherToolForm(
      context,
      title: 'Chỉnh sửa bài tập',
      sectionTitles: const {
        'Tiêu đề': 'Nội dung đề',
        'Code mẫu': 'Mã khởi đầu',
        'Bắt đầu': 'Thời gian nộp',
      },
      rawFields: const {'Code mẫu'},
      dateFields: const {'Bắt đầu', 'Hạn nộp'},
      requiredExistingDates: {
        if (startsAt != null) 'Bắt đầu',
        if (endsAt != null) 'Hạn nộp',
      },
      fields: {
        'Tiêu đề': '${assignment['title'] ?? ''}',
        'Nội dung đề': '${assignment['description'] ?? ''}',
        'Code mẫu': '${assignment['starter_code'] ?? ''}',
        'Bắt đầu': startsAt?.toIso8601String() ?? '',
        'Hạn nộp': endsAt?.toIso8601String() ?? '',
      },
      validate: (values) {
        if (values['Tiêu đề']!.length < 3 || values['Nội dung đề']!.isEmpty) {
          return 'Điền đủ tiêu đề và nội dung.';
        }
        return teacherAssignmentDateError(
          values['Bắt đầu']!,
          values['Hạn nộp']!,
        );
      },
      save: (values) async {
        final start = DateTime.tryParse(values['Bắt đầu']!);
        final end = DateTime.tryParse(values['Hạn nộp']!);
        await widget.api.put(
          '/assignments/${widget.id}',
          data: {
            'title': values['Tiêu đề'],
            'description': values['Nội dung đề'],
            'starter_code': values['Code mẫu'],
            if (start != null &&
                (startsAt == null || !start.isAtSameMomentAs(startsAt)))
              'start_time': start.toUtc().toIso8601String(),
            if (end != null &&
                (endsAt == null || !end.isAtSameMomentAs(endsAt)))
              'end_time': end.toUtc().toIso8601String(),
          },
        );
      },
    );
    if (saved) _markChanged();
  }

  @override
  Widget build(BuildContext context) => PopScope<bool>(
    canPop: !changed && !busy,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && changed && !busy) Navigator.of(context).pop(true);
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài tập')),
      body: TeacherAsyncView<Map<String, dynamic>>(
        key: ValueKey(revision),
        load: () async =>
            toolPayload(await widget.api.get('/assignments/${widget.id}')),
        builder: (context, a) {
          final theme = Theme.of(context);
          final languages = a['language'];
          final published = a['is_published'] == true;
          return ListView(
            padding: AppSpacing.paddingLg,
            children: [
              Text(
                '${a['title'] ?? 'Bài tập'}',
                style: theme.textTheme.headlineSmall,
              ),
              AppSpacing.vGap8,
              Text(
                published ? 'Đã công bố' : 'Bản nháp',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: published
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(teacherAssignmentDeadline(a['end_time'])),
              if (a['start_time'] != null)
                Text('Bắt đầu: ${teacherAssignmentLocalTime(a['start_time'])}'),
              if (!canWrite)
                Text(
                  widget.api is TeacherPreviewApi
                      ? 'Dữ liệu mẫu · Chỉ xem'
                      : 'Chỉ xem',
                ),
              if (canWrite) ...[
                AppSpacing.vGap12,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () => mutate(published ? 'unpublish' : 'publish'),
                      child: Text(published ? 'Thu hồi' : 'Công bố'),
                    ),
                    OutlinedButton(
                      onPressed: busy ? null : () => _edit(a),
                      child: const Text('Sửa'),
                    ),
                  ],
                ),
              ],
              AppSpacing.vGap12,
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inbox_outlined),
                title: const Text('Các lần nộp'),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.rule_outlined),
                title: const Text('Bộ kiểm thử'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => teacherPush<void>(
                  context,
                  TeacherAssignmentRecords(
                    api: widget.api,
                    id: widget.id,
                    tests: true,
                    canWrite: canWrite,
                    canViewHidden:
                        widget.canWrite || widget.api is TeacherPreviewApi,
                  ),
                ),
              ),
              const Divider(),
              AppSpacing.vGap12,
              Text('Nội dung đề', style: theme.textTheme.titleMedium),
              AppSpacing.vGap8,
              if (a['difficulty'] != null)
                Text('Độ khó: ${teacherAssignmentDifficulty(a['difficulty'])}'),
              if (languages is List && languages.isNotEmpty)
                Text('Ngôn ngữ: ${languages.join(', ')}'),
              if (a['description'] case final String description
                  when description.trim().isNotEmpty)
                SelectableText(description)
              else
                const Text('Chưa có mô tả bài tập.'),
            ],
          );
        },
      ),
    ),
  );
}
