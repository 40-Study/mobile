import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_data.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_list_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherReportScreen extends StatefulWidget {
  const TeacherReportScreen({
    super.key,
    this.initialMonth,
    this.monthRequestRevision = 0,
    this.refreshRevision = 0,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
  });

  final DateTime? initialMonth;
  final int monthRequestRevision;
  final int refreshRevision;
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;

  @override
  State<TeacherReportScreen> createState() => _TeacherReportScreenState();
}

class _TeacherReportScreenState extends State<TeacherReportScreen>
    with AutomaticKeepAliveClientMixin {
  late DateTime _month;
  late Future<TeacherReportData> _future;
  String? _classId;
  String? _className;

  @override
  bool get wantKeepAlive => true;

  DateTime get _currentMonth => _monthStart(DateTime.now());

  DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

  @override
  void initState() {
    super.initState();
    _month = _monthStart(widget.initialMonth ?? DateTime.now());
    _future = _load();
  }

  @override
  void didUpdateWidget(TeacherReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scopeChanged =
        oldWidget.organizationId != widget.organizationId ||
        oldWidget.api != widget.api;
    final requested =
        oldWidget.monthRequestRevision != widget.monthRequestRevision;
    final refreshed = oldWidget.refreshRevision != widget.refreshRevision;
    if (scopeChanged) {
      _month = _currentMonth;
      _classId = _className = null;
    } else if (requested) {
      _month = _monthStart(widget.initialMonth ?? DateTime.now());
    }
    if (scopeChanged || requested || refreshed) _future = _load();
  }

  Future<TeacherReportData> _load() =>
      TeacherReportData.load(widget.api, widget.organizationId, _month);

  void _selectMonth(DateTime month) {
    final next = _monthStart(month);
    if (next == _month || next.year < 1 || next.year > 9999) return;
    setState(() {
      _month = next;
      _future = _load();
    });
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _refresh() async {
    _reload();
    try {
      await _future;
    } catch (_) {
      // The report body displays the error and retry action.
    }
  }

  Future<void> _pickMonth() async {
    final month = await showDialog<DateTime>(
      context: context,
      builder: (_) => _ReportMonthPicker(initialMonth: _month),
    );
    if (mounted && month != null) _selectMonth(month);
  }

  void _clearClass() => setState(() => _classId = _className = null);

  String _classLabel(TeacherReportData? data) =>
      data?.classes.where((row) => row.id == _classId).firstOrNull?.name ??
      _className ??
      'Tất cả lớp';

  Future<void> _filter(TeacherReportData data) async {
    final scope = widget.organizationId;
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Lọc theo lớp')),
            ListTile(
              title: const Text('Tất cả lớp'),
              selected: _classId == null,
              onTap: () => Navigator.pop(context, ''),
            ),
            for (final row in data.classes)
              ListTile(
                title: Text(row.name),
                selected: _classId == row.id,
                onTap: () => Navigator.pop(context, row.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selection == null || scope != widget.organizationId) return;
    if (selection.isEmpty) {
      _clearClass();
    } else {
      setState(() {
        _classId = selection;
        _className = data.classes.firstWhere((row) => row.id == selection).name;
      });
    }
  }

  void _openGroup(TeacherReportData data, TeacherReportStatus? status) {
    final month = _month;
    final api = widget.api;
    final organizationId = widget.organizationId;
    teacherPush<void>(
      context,
      TeacherReportListScreen(
        api: api,
        month: month,
        title: status?.label ?? 'Tất cả buổi đã hoàn tất',
        data: data,
        classId: _classId,
        classLabel: _classLabel(data),
        workplaceLabel: widget.workplaceLabel,
        status: status,
        reload: () async {
          final previous = _future;
          final next = await TeacherReportData.load(api, organizationId, month);
          if (mounted &&
              widget.api == api &&
              widget.organizationId == organizationId &&
              _month == month &&
              _future == previous) {
            setState(() => _future = Future.value(next));
          }
          return next;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final before = DateTime(_month.year, _month.month - 1);
    final after = DateTime(_month.year, _month.month + 1);
    return FutureBuilder<TeacherReportData>(
      key: ValueKey((widget.api, widget.organizationId, _month)),
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final data = snapshot.data;
        return Column(
          children: [
            Padding(
              padding: AppSpacing.paddingHorizontalLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: before.year < 1
                            ? null
                            : () => _selectMonth(before),
                        tooltip: 'Tháng trước',
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _pickMonth,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(
                            teacherReportMonthLabel(_month),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: after.year > 9999
                            ? null
                            : () => _selectMonth(after),
                        tooltip: 'Tháng sau',
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      OutlinedButton.icon(
                        onPressed: data == null ? null : () => _filter(data),
                        icon: const Icon(Icons.filter_list),
                        label: Text(
                          _classLabel(data),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_month != _currentMonth)
                        TextButton(
                          onPressed: () => _selectMonth(_currentMonth),
                          child: const Text('Về tháng hiện tại'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 2,
              child: loading && data != null
                  ? const LinearProgressIndicator()
                  : null,
            ),
            Expanded(
              child: data != null
                  ? _reportBody(data)
                  : loading
                  ? const Center(child: CircularProgressIndicator())
                  : TeacherErrorView(
                      error:
                          snapshot.error ?? StateError('Chưa tải được báo cáo'),
                      onRetry: _reload,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _reportBody(TeacherReportData data) {
    final rows = data.group(_classId, null);
    final totalMinutes = teacherReportTotalMinutes(rows);
    final groups = <TeacherReportStatus, List<TeacherReportSession>>{
      for (final status in TeacherReportStatus.values)
        status: data.group(_classId, status),
    };
    final unknown = groups[TeacherReportStatus.unknown]!.length;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingLg,
        children: [
          if (rows.isEmpty)
            TeacherEmptyState(
              icon: Icons.bar_chart_outlined,
              title: _classId == null
                  ? 'Không có buổi hoàn tất trong tháng ${_month.month}/${_month.year}'
                  : 'Lớp đã chọn chưa có buổi hoàn tất',
              actionLabel: _classId == null ? null : 'Xóa bộ lọc',
              onAction: _classId == null ? null : _clearClass,
            )
          else ...[
            Card(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderLg,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buổi đã hoàn tất',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.vGap12,
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final count = _metric(
                          context,
                          'Số buổi',
                          '${rows.length}',
                        );
                        final duration = _metric(
                          context,
                          'Tổng thời lượng',
                          totalMinutes == null
                              ? 'Chưa có dữ liệu'
                              : teacherReportDuration(totalMinutes),
                        );
                        if (constraints.maxWidth < 260 ||
                            MediaQuery.textScalerOf(context).scale(14) > 20) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [count, AppSpacing.vGap8, duration],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: count),
                            AppSpacing.hGap12,
                            Expanded(child: duration),
                          ],
                        );
                      },
                    ),
                    AppSpacing.vGap8,
                    if (totalMinutes != null &&
                        rows.any((row) => row.minutes == null))
                      Text(
                        'Tổng chỉ gồm các buổi có thời lượng.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (unknown == rows.length)
                      Text(
                        'Chưa có thông tin xác nhận giờ.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _openGroup(data, null),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Xem danh sách'),
                    ),
                  ],
                ),
              ),
            ),
            if (unknown != rows.length)
              TeacherCollapsibleSection(
                title: 'Chi tiết theo trạng thái',
                icon: Icons.pie_chart_outline,
                child: Column(
                  children: [
                    for (final entry in groups.entries)
                      if (entry.value.isNotEmpty)
                        ListTile(
                          title: Text(entry.key.label),
                          subtitle: Text(
                            '${entry.value.length} buổi · ${teacherReportDuration(teacherReportTotalMinutes(entry.value))}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openGroup(data, entry.key),
                        ),
                  ],
                ),
              ),
            _roleBreakdown(rows),
          ],
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _roleBreakdown(List<TeacherReportSession> rows) {
    const labels = {
      'main': 'Giáo viên chính',
      'substitute': 'Dạy thay',
      'assistant': 'Trợ giảng',
    };
    final counts = <String, int>{};
    for (final row in rows) {
      final label =
          labels[row.occurrence.json['teacher_role']] ?? 'Chưa rõ vai trò';
      counts.update(label, (count) => count + 1, ifAbsent: () => 1);
    }
    if (counts.length <= 1) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final entry in counts.entries)
          Chip(label: Text('${entry.key} · ${entry.value} buổi')),
      ],
    );
  }
}

class _ReportMonthPicker extends StatefulWidget {
  const _ReportMonthPicker({required this.initialMonth});
  final DateTime initialMonth;

  @override
  State<_ReportMonthPicker> createState() => _ReportMonthPickerState();
}

class _ReportMonthPickerState extends State<_ReportMonthPicker> {
  final _form = GlobalKey<FormState>();
  late final _year = TextEditingController(text: '${widget.initialMonth.year}');
  late int _month = widget.initialMonth.month;

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Chọn tháng báo cáo'),
    scrollable: true,
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _year,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Năm'),
            validator: (value) {
              final year = int.tryParse(value?.trim() ?? '');
              return year == null || year < 1 || year > 9999
                  ? 'Nhập năm hợp lệ.'
                  : null;
            },
          ),
          AppSpacing.vGap12,
          DropdownButtonFormField<int>(
            initialValue: _month,
            decoration: const InputDecoration(labelText: 'Tháng'),
            items: [
              for (var i = 1; i <= 12; i++)
                DropdownMenuItem(value: i, child: Text('Tháng $i')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _month = value);
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(
              context,
              DateTime(int.parse(_year.text.trim()), _month),
            );
          }
        },
        child: const Text('Xem báo cáo'),
      ),
    ],
  );
}
