import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_row.dart';
import 'package:study/features/teacher/presentation/profile/teacher_reminders_screen.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({
    super.key,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
  });
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;
  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  late DateTime _selected;
  late Future<List<TeacherOccurrence>> _future;
  String? _classId;
  bool _month = false;
  final _classNames = <String, String>{};
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _future = _load();
  }

  DateTime get _weekStart => DateTime(
    _selected.year,
    _selected.month,
    _selected.day - _selected.weekday + 1,
  );
  Future<List<TeacherOccurrence>> _load() => teacherLoadTimetable(
    widget.api,
    widget.organizationId,
    _month ? DateTime(_selected.year, _selected.month) : _weekStart,
    _month
        ? DateTime(_selected.year, _selected.month + 1, 0)
        : DateTime(_weekStart.year, _weekStart.month, _weekStart.day + 6),
  );
  void _reload() => setState(() {
    _future = _load();
  });
  void _move(int direction) => setState(() {
    _selected = _month
        ? _inMonth(_selected.month + direction)
        : DateTime(
            _selected.year,
            _selected.month,
            _selected.day + 7 * direction,
          );
    _future = _load();
  });
  DateTime _inMonth(int month) {
    final start = DateTime(_selected.year, month);
    final last = DateTime(start.year, start.month + 1, 0).day;
    return DateTime(
      start.year,
      start.month,
      _selected.day > last ? last : _selected.day,
    );
  }

  Future<void> _filter() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: AppSpacing.paddingScreenAll,
                child: Text(
                  'Lọc theo lớp',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: const Text('Tất cả lớp'),
                selected: _classId == null,
                trailing: _classId == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, ''),
              ),
              for (final entry in _classNames.entries)
                ListTile(
                  title: Text(entry.value),
                  selected: _classId == entry.key,
                  trailing: _classId == entry.key
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, entry.key),
                ),
            ],
          ),
        ),
      ),
    );
    if (selection != null && mounted)
      setState(() => _classId = selection.isEmpty ? null : selection);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.screenPadding,
          AppSpacing.screenPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tuần')),
                      ButtonSegment(value: true, label: Text('Tháng')),
                    ],
                    selected: {_month},
                    onSelectionChanged: (value) => setState(() {
                      _month = value.first;
                      _future = _load();
                    }),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tùy chọn lịch dạy',
                  onSelected: (value) {
                    if (value == 'reminders')
                      teacherPush<Object?>(
                        context,
                        TeacherRemindersScreen(api: widget.api),
                      );
                    if (value == 'refresh') _reload();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'reminders', child: Text('Nhắc lịch')),
                    PopupMenuItem(value: 'refresh', child: Text('Tải lại')),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                if (!_month)
                  IconButton(
                    onPressed: () => _move(-1),
                    tooltip: 'Kỳ trước',
                    icon: const Icon(Icons.chevron_left),
                  ),
                if (!_month)
                  Expanded(
                    child: Text(
                      _month
                          ? DateFormat('MM/yyyy').format(_selected)
                          : '${DateFormat('dd/MM').format(_weekStart)} – ${DateFormat('dd/MM').format(_weekStart.add(const Duration(days: 6)))}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (!_month)
                  IconButton(
                    onPressed: () => _move(1),
                    tooltip: 'Kỳ sau',
                    icon: const Icon(Icons.chevron_right),
                  ),
                if (_month) const Spacer(),
                TextButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _selected = DateTime(now.year, now.month, now.day);
                      _future = _load();
                    });
                  },
                  child: const Text('Hôm nay'),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: FutureBuilder<List<TeacherOccurrence>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final sessions = snapshot.data!;
            final classes = {
              for (final session in sessions)
                session.classId: session.classData.name,
            };
            _classNames.addAll(classes);
            final rows = sessions
                .where(
                  (s) =>
                      teacherDate(s.date) == teacherDate(_selected) &&
                      (_classId == null || s.classId == _classId),
                )
                .toList();
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (_month)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: Material(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        child: CalendarDatePicker(
                          key: ValueKey('${_selected.year}-${_selected.month}'),
                          initialDate: _selected,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          onDateChanged: (date) =>
                              setState(() => _selected = date),
                          onDisplayedMonthChanged: (date) => setState(() {
                            _selected = _inMonth(
                              date.month + (date.year - _selected.year) * 12,
                            );
                            _future = _load();
                          }),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            for (var i = 0; i < 7; i++)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Builder(
                                  builder: (context) {
                                    final day = DateTime(
                                      _weekStart.year,
                                      _weekStart.month,
                                      _weekStart.day + i,
                                    );
                                    final count = sessions
                                        .where(
                                          (s) =>
                                              teacherDate(s.date) ==
                                                  teacherDate(day) &&
                                              (_classId == null ||
                                                  s.classId == _classId),
                                        )
                                        .length;
                                    final selected =
                                        teacherDate(day) ==
                                        teacherDate(_selected);
                                    final cs = Theme.of(context).colorScheme;
                                    final today =
                                        teacherDate(day) ==
                                        teacherDate(DateTime.now());
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      selectedColor: cs.primary,
                                      backgroundColor:
                                          cs.surfaceContainerLowest,
                                      side: BorderSide(
                                        color: today && !selected
                                            ? cs.primary
                                            : cs.outlineVariant,
                                      ),
                                      label: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 3,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              today
                                                  ? 'Hôm nay'
                                                  : const [
                                                      'T2',
                                                      'T3',
                                                      'T4',
                                                      'T5',
                                                      'T6',
                                                      'T7',
                                                      'CN',
                                                    ][i],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: selected
                                                        ? cs.onPrimary
                                                        : cs.onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('dd').format(day),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    color: selected
                                                        ? cs.onPrimary
                                                        : cs.onSurface,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$count buổi',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: selected
                                                        ? cs.onPrimary
                                                        : cs.onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      selected: selected,
                                      onSelected: (_) =>
                                          setState(() => _selected = day),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: AppSpacing.paddingHorizontalXl,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _filter,
                        icon: const Icon(Icons.filter_list),
                        label: Text(
                          _classId == null
                              ? 'Tất cả lớp'
                              : _classNames[_classId] ?? 'Lớp đã chọn',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.paddingScreenAll,
                    child: Text(
                      '${rows.length} buổi dạy · ${DateFormat('dd/MM/yyyy').format(_selected)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Không có buổi dạy phù hợp trong ngày này.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  for (final session in rows)
                    Padding(
                      padding: AppSpacing.paddingHorizontalXl,
                      child: TeacherSessionRow(
                        onChanged: _reload,
                        session: session,
                        api: widget.api,
                        workplaceLabel: widget.workplaceLabel,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}
