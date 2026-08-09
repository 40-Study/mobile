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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Column(
        children: [
          // Month header
          _MonthHeader(
            currentMonth: currentMonth,
            onPrevMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
          ),
          AppSpacing.vGap16,

          // Weekday headers
          _WeekdayHeaders(),
          AppSpacing.vGap8,

          // Calendar grid
          ..._buildWeeks(context),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    final newMonth = DateTime(currentMonth.year, currentMonth.month + delta);
    onMonthChanged?.call(newMonth);
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

      if (weeks.length > 6) break;
    }

    return weeks;
  }

  Widget _buildWeek(BuildContext context, DateTime weekStart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          return Expanded(
            child: _DayCell(
              date: date,
              currentMonth: currentMonth,
              selectedDate: selectedDate,
              hasEvent: eventDates.any((d) => _isSameDay(d, date)),
              onTap: date.month == currentMonth.month
                  ? () => onDateSelected?.call(date)
                  : null,
            ),
          );
        }),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.currentMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime currentMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevMonth,
          tooltip: 'Tháng trước',
        ),
        Column(
          children: [
            Text(
              _monthName(currentMonth.month),
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              '${currentMonth.year}',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNextMonth,
          tooltip: 'Tháng sau',
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Tháng Một',
      'Tháng Hai',
      'Tháng Ba',
      'Tháng Tư',
      'Tháng Năm',
      'Tháng Sáu',
      'Tháng Bảy',
      'Tháng Tám',
      'Tháng Chín',
      'Tháng Mười',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[month - 1];
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final isWeekend = entry.key >= 5;
        return Expanded(
          child: Center(
            child: Text(
              entry.value,
              style: tt.labelSmall?.copyWith(
                color: isWeekend
                    ? cs.primary.withValues(alpha: 0.7)
                    : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.currentMonth,
    required this.selectedDate,
    required this.hasEvent,
    this.onTap,
  });

  final DateTime date;
  final DateTime currentMonth;
  final DateTime selectedDate;
  final bool hasEvent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isCurrentMonth = date.month == currentMonth.month;
    final isToday = _isToday(date);
    final isSelected = _isSameDay(date, selectedDate);
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : isToday
                  ? cs.primaryContainer.withValues(alpha: 0.5)
                  : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isToday && !isSelected
              ? Border.all(color: cs.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: tt.bodyMedium?.copyWith(
                color: _textColor(cs, isSelected, isCurrentMonth, isWeekend),
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (hasEvent && isCurrentMonth) ...[
              const SizedBox(height: 2),
              _EventDot(isSelected: isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Color _textColor(ColorScheme cs, bool isSelected, bool isCurrentMonth, bool isWeekend) {
    if (isSelected) return cs.onPrimary;
    if (!isCurrentMonth) return cs.onSurfaceVariant.withValues(alpha: 0.3);
    if (isWeekend) return cs.primary.withValues(alpha: 0.8);
    return cs.onSurface;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EventDot extends StatelessWidget {
  const _EventDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? cs.onPrimary : cs.tertiary,
      ),
    );
  }
}
