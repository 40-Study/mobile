import 'package:flutter/material.dart';

import '../../data/teacher_core.dart';

enum TeacherCalendarDot {
  completed(Color(0xFF16A34A), 'Hoàn thành'),
  unmarked(Color(0xFFD97706), 'Chưa điểm danh'),
  upcoming(Color(0xFF2563EB), 'Sắp dạy'),
  neutral(Color(0xFF64748B), 'Có buổi dạy'),
  needsInfo(Color(0xFFDC2626), 'Cần bổ sung');

  const TeacherCalendarDot(this.color, this.label);
  final Color color;
  final String label;
}

const teacherScheduleBlue = Color(0xFF2563EB);
const teacherSchedulePaleBlue = Color(0xFFEFF6FF);

Color teacherScheduleBackground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
    ? const Color(0xFFF4F6F9)
    : Theme.of(context).colorScheme.surface;

Color teacherScheduleCardColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
    ? Colors.white
    : Theme.of(context).colorScheme.surfaceContainerLow;

Color teacherScheduleBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
    ? const Color(0xFFE2E8F0)
    : Theme.of(context).colorScheme.outlineVariant;

class TeacherExpandableCalendar extends StatelessWidget {
  const TeacherExpandableCalendar({
    super.key,
    required this.selectedDate,
    required this.weekStart,
    required this.isExpanded,
    required this.sessions,
    required this.onDateSelected,
    required this.onToggleExpand,
    required this.onWeekChanged,
    required this.onToday,
    required this.now,
    required this.dotFor,
    this.classFilter,
  });

  final DateTime selectedDate;
  final DateTime weekStart;
  final bool isExpanded;
  final List<TeacherOccurrence> sessions;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onWeekChanged;
  final VoidCallback onToday;
  final DateTime now;
  final TeacherCalendarDot Function(TeacherOccurrence) dotFor;
  final String? classFilter;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(selectedDate.year, selectedDate.month);
    final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final sunday = DateTime(weekStart.year, weekStart.month, weekStart.day + 6);
    final first = isExpanded
        ? DateTime(monthStart.year, monthStart.month, 2 - monthStart.weekday)
        : weekStart;
    final weeks = isExpanded
        ? (monthStart.weekday - 1 + monthEnd.day + 6) ~/ 7
        : 1;
    final title = isExpanded
        ? 'Tháng ${selectedDate.month}, ${selectedDate.year}'
        : weekStart.month == sunday.month
        ? '${weekStart.day} - ${sunday.day} Tháng ${sunday.month}'
        : '${weekStart.day}/${weekStart.month} - ${sunday.day}/${sunday.month}';
    final dotsByDay = <String, Set<TeacherCalendarDot>>{};
    for (final session in sessions) {
      if (classFilter != null && session.classId != classFilter) continue;
      final dots = dotsByDay.putIfAbsent(teacherDate(session.date), () => {});
      dots.add(isExpanded ? TeacherCalendarDot.neutral : dotFor(session));
      if (session.json['hour_confirmation_status'] == 'needs_info') {
        dots.add(TeacherCalendarDot.needsInfo);
      }
    }

    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      decoration: BoxDecoration(
        color: teacherScheduleCardColor(context),
        border: Border.all(color: teacherScheduleBorder(context)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _arrow(-1),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _arrow(1),
              const SizedBox(width: 4),
              Flexible(
                child: TextButton(
                  onPressed: onToday,
                  style: TextButton.styleFrom(
                    backgroundColor: dark
                        ? theme.colorScheme.primaryContainer
                        : teacherSchedulePaleBlue,
                    foregroundColor: dark
                        ? theme.colorScheme.onPrimaryContainer
                        : teacherScheduleBlue,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Hôm nay', maxLines: 1),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: IconButton(
                  onPressed: onToggleExpand,
                  tooltip: isExpanded
                      ? 'Thu gọn về tuần'
                      : 'Mở rộng lịch tháng',
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              for (final day in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(day, style: theme.textTheme.labelSmall),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var week = 0; week < weeks; week++)
            Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(
                    child: _day(
                      context,
                      DateTime(
                        first.year,
                        first.month,
                        first.day + week * 7 + column,
                      ),
                      dotsByDay,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _arrow(int delta) {
    final period = isExpanded ? 'month-' : '';
    final direction = delta < 0 ? 'previous' : 'next';
    return SizedBox(
      width: 40,
      child: IconButton(
        key: ValueKey('teacher-calendar-$period$direction'),
        tooltip:
            '${isExpanded ? 'Tháng' : 'Tuần'} ${delta < 0 ? 'trước' : 'sau'}',
        padding: EdgeInsets.zero,
        icon: Icon(delta < 0 ? Icons.chevron_left : Icons.chevron_right),
        onPressed: () => onWeekChanged(delta),
      ),
    );
  }

  Widget _day(
    BuildContext context,
    DateTime day,
    Map<String, Set<TeacherCalendarDot>> dotsByDay,
  ) {
    final theme = Theme.of(context);
    final outside = isExpanded && day.month != selectedDate.month;
    final selected = DateUtils.isSameDay(day, selectedDate);
    final today = DateUtils.isSameDay(day, now);
    final dots = outside
        ? const <TeacherCalendarDot>{}
        : dotsByDay[teacherDate(day)] ?? const {};
    final visibleDots = TeacherCalendarDot.values.where(dots.contains).toList();
    final onTap = outside ? null : () => onDateSelected(day);
    return Semantics(
      onTap: onTap,
      label: [
        '${day.day}/${day.month}/${day.year}',
        if (today) 'Hôm nay',
        ...visibleDots.map((dot) => dot.label),
      ].join(', '),
      selected: selected,
      button: !outside,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        excludeFromSemantics: true,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 40),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? teacherScheduleBlue : null,
                      borderRadius: BorderRadius.circular(10),
                      border: today && !selected
                          ? Border.all(color: teacherScheduleBlue)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${day.day}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : outside
                                      ? theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: .55)
                                      : theme.colorScheme.onSurface,
                                  fontWeight: selected || today
                                      ? FontWeight.w700
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 9,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final dot in visibleDots)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white
                                          : isExpanded &&
                                                dot ==
                                                    TeacherCalendarDot.neutral
                                          ? teacherScheduleBlue
                                          : dot.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
