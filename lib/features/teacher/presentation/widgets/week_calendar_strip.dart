import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/theme/theme.dart';

/// Horizontal date picker hiển thị 7 ngày trong tuần.
/// Dùng cho tab Lịch theo spec mốc 1a.
class WeekCalendarStrip extends StatelessWidget {
  const WeekCalendarStrip({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.onDateSelected,
    this.sessionCounts = const {},
  });

  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Map từ date string (yyyy-MM-dd) -> số buổi trong ngày
  final Map<String, int> sessionCounts;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(7, (i) {
          final day = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day + i,
          );
          final dayDate = DateTime(day.year, day.month, day.day);
          final isToday = dayDate == todayDate;
          final isSelected = dayDate ==
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
          final dateKey = DateFormat('yyyy-MM-dd').format(day);
          final count = sessionCounts[dateKey] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _DayChip(
              day: day,
              isToday: isToday,
              isSelected: isSelected,
              sessionCount: count,
              onTap: () => onDateSelected(day),
            ),
          );
        }),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.sessionCount,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final int sessionCount;
  final VoidCallback onTap;

  static const _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final dayLabel = isToday ? 'Hôm nay' : _weekDays[day.weekday - 1];
    final dateLabel = DateFormat('dd').format(day);
    final countLabel = '$sessionCount buổi';

    return ChoiceChip(
      showCheckmark: false,
      selectedColor: cs.primary,
      backgroundColor: cs.surfaceContainerLowest,
      side: BorderSide(
        color: isToday && !isSelected ? cs.primary : cs.outlineVariant,
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: tt.labelSmall?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: tt.titleLarge?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              countLabel,
              style: tt.labelSmall?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
