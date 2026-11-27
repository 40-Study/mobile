import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_data.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherReportListScreen extends StatefulWidget {
  const TeacherReportListScreen({
    super.key,
    required this.api,
    required this.month,
    required this.title,
    required this.data,
    required this.classId,
    required this.classLabel,
    required this.workplaceLabel,
    required this.status,
    required this.reload,
  });

  final TeacherApi api;
  final DateTime month;
  final String title;
  final TeacherReportData data;
  final String? classId;
  final String classLabel;
  final String workplaceLabel;
  final TeacherReportStatus? status;
  final Future<TeacherReportData> Function() reload;

  @override
  State<TeacherReportListScreen> createState() =>
      _TeacherReportListScreenState();
}

class _TeacherReportListScreenState extends State<TeacherReportListScreen> {
  late TeacherReportData _data = widget.data;
  bool _refreshing = false;
  Object? _refreshError;
  bool _opening = false;

  Future<void> _reload() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _refreshError = null;
    });
    try {
      final data = await widget.reload();
      if (!mounted) return;
      setState(() {
        _data = data;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _refreshError = error;
        _refreshing = false;
      });
    }
  }

  Future<void> _open(TeacherReportSession row) async {
    if (_opening) return;
    _opening = true;
    try {
      final occurrence = row.occurrence;
      final changed = await teacherPush<bool>(
        context,
        TeacherSessionScreen(
          api: widget.api,
          classId: occurrence.classId,
          sessionId: occurrence.sessionId,
          occurrence: occurrence,
          workplaceLabel: widget.workplaceLabel,
        ),
      );
      if (mounted && changed == true) await _reload();
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = _data.group(widget.classId, widget.status);
    final noConfirmations =
        rows.isNotEmpty &&
        rows.every((row) => row.confirmation == TeacherReportStatus.unknown);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacherReportMonthLabel(widget.month),
                    style: theme.textTheme.titleSmall,
                  ),
                  AppSpacing.vGap4,
                  Text(
                    '${widget.workplaceLabel} · ${widget.classLabel}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 2,
            child: _refreshing ? const LinearProgressIndicator() : null,
          ),
          if (_refreshError case final error?)
            Padding(
              padding: AppSpacing.paddingHorizontalLg,
              child: Row(
                children: [
                  Expanded(child: Text(teacherErrorMessage(error))),
                  TextButton(onPressed: _reload, child: const Text('Thử lại')),
                ],
              ),
            ),
          Expanded(
            key: const ValueKey('report-sessions'),
            child: RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                padding: AppSpacing.paddingLg,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.isEmpty
                    ? 1
                    : rows.length + (noConfirmations ? 1 : 0),
                itemBuilder: (context, index) {
                  final rowIndex = index - (noConfirmations ? 1 : 0);
                  if (rowIndex < 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        'Chưa có thông tin xác nhận giờ.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return rows.isEmpty
                      ? const TeacherEmptyState(
                          icon: Icons.event_note_outlined,
                          title: 'Không còn buổi nào trong nhóm này',
                        )
                      : _ReportSessionCard(
                          row: rows[rowIndex],
                          showStatus: !noConfirmations,
                          onOpen: () => _open(rows[rowIndex]),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSessionCard extends StatelessWidget {
  const _ReportSessionCard({
    required this.row,
    required this.onOpen,
    required this.showStatus,
  });
  final TeacherReportSession row;
  final VoidCallback onOpen;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final occurrence = row.occurrence;
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (row.confirmation) {
      TeacherReportStatus.confirmed => cs.onSecondaryContainer,
      TeacherReportStatus.pending => cs.onTertiaryContainer,
      TeacherReportStatus.needsInfo => cs.error,
      TeacherReportStatus.unknown => cs.onSurfaceVariant,
    };
    final role = switch (occurrence.json['teacher_role']) {
      'main' => 'Giáo viên chính',
      'substitute' => 'Dạy thay',
      'assistant' => 'Trợ giảng',
      _ => null,
    };
    return Card(
      color: cs.surfaceContainerLow,
      elevation: 0,
      child: ListTile(
        title: Text(occurrence.classData.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (occurrence.topic.trim().isNotEmpty)
                Text(
                  occurrence.topic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(occurrence.date)),
                  if (occurrence.start.isNotEmpty && occurrence.end.isNotEmpty)
                    Text('${occurrence.start}–${occurrence.end}'),
                  if (role != null) Text(role),
                ],
              ),
              AppSpacing.vGap4,
              if (showStatus)
                Text(switch (row.confirmation) {
                  TeacherReportStatus.confirmed => 'Giờ dạy đã xác nhận',
                  TeacherReportStatus.pending => 'Giờ dạy chờ xác nhận',
                  _ => row.confirmation.label,
                }, style: TextStyle(color: statusColor)),
              Text(teacherReportDuration(row.minutes)),
            ],
          ),
        ),
      ),
    );
  }
}
