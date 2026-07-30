import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.eventDates,
    this.onDateSelected,
    this.onMonthChanged,
  });

  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> eventDates;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _monthYearText(currentMonth),
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // Weekday headers
          Row(
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: tt.labelSmall?.copyWith(
                            color: cs.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          AppSpacing.vGap8,

          // Calendar grid
          ..._buildWeeks(context),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    final newMonth = DateTime(
      currentMonth.year,
      currentMonth.month + delta,
    );
    onMonthChanged?.call(newMonth);
  }

  String _monthYearText(DateTime date) {
    const months = [
      'Thang 1', 'Thang 2', 'Thang 3', 'Thang 4',
      'Thang 5', 'Thang 6', 'Thang 7', 'Thang 8',
      'Thang 9', 'Thang 10', 'Thang 11', 'Thang 12',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  List<Widget> _buildWeeks(BuildContext context) {
    final weeks = <Widget>[];
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Find first Monday
    var weekStart = firstDay.subtract(
      Duration(days: (firstDay.weekday - 1) % 7),
    );

    while (weekStart.isBefore(lastDay) ||
        weekStart.month == currentMonth.month) {
      weeks.add(_buildWeek(context, weekStart));
      weekStart = weekStart.add(const Duration(days: 7));

      if (weeks.length > 6) break; // Max 6 weeks
    }

    return weeks;
  }

  Widget _buildWeek(BuildContext context, DateTime weekStart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          return Expanded(child: _buildDay(context, date));
        }),
      ),
    );
  }

  Widget _buildDay(BuildContext context, DateTime date) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isCurrentMonth = date.month == currentMonth.month;
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);
    final hasEvent = eventDates.any((d) => _isSameDay(d, date));
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return GestureDetector(
      onTap: isCurrentMonth ? () => onDateSelected?.call(date) : null,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: cs.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: tt.bodyMedium?.copyWith(
                color: isSelected
                    ? cs.onPrimary
                    : !isCurrentMonth
                        ? cs.outline.withValues(alpha: 0.4)
                        : isWeekend
                            ? cs.outline
                            : cs.onSurface,
                fontWeight: isToday || isSelected ? FontWeight.w600 : null,
              ),
            ),
            if (hasEvent && isCurrentMonth)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? cs.onPrimary : cs.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
