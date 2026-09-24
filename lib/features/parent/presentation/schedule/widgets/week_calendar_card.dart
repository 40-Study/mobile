import 'package:flutter/material.dart';

import 'package:study/theme/theme.dart';

/// Thẻ dải lịch tuần tương tác với 7 ngày dạng capsule và dấu chấm buổi học.
class WeekCalendarCard extends StatelessWidget {
  const WeekCalendarCard({
    super.key,
    required this.anchorWeekDate,
    required this.selectedDate,
    required this.eventDates,
    required this.totalSessionsInWeek,
    required this.onDateSelected,
    required this.onWeekChanged,
  });

  final DateTime anchorWeekDate;
  final DateTime selectedDate;
  final List<DateTime> eventDates;
  final int totalSessionsInWeek;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onWeekChanged;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Tính 7 ngày trong tuần từ Thứ 2 đến Chủ nhật
    final monday = anchorWeekDate.subtract(
      Duration(days: anchorWeekDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final sunday = weekDays[6];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header tuần: Icon + Tên tuần + Nút prev/next + Badge số ca học
          _buildHeader(context, cs, tt, monday, sunday),
          const SizedBox(height: 14),
          // Dải 7 ngày capsule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              return _buildDayCapsule(context, cs, tt, day);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    DateTime monday,
    DateTime sunday,
  ) {
    final String weekTitle;
    if (monday.month == sunday.month) {
      weekTitle = 'Tuần ${monday.day} - ${sunday.day} Th${monday.month}';
    } else {
      weekTitle =
          'Tuần ${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_month_outlined,
          color: cs.blue600,
          size: 19,
        ),
        const SizedBox(width: 8),
        Text(
          weekTitle,
          style: tt.titleSmall?.copyWith(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        const Spacer(),
        // Badge tổng ca học tuần
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: AppRadius.borderFull,
            border: Border.all(
              color: const Color(0xFFBFDBFE),
              width: 0.8,
            ),
          ),
          child: Text(
            '$totalSessionsInWeek ca học',
            style: tt.labelSmall?.copyWith(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Nút chuyển tuần trước
        InkWell(
          onTap: () => onWeekChanged(
            anchorWeekDate.subtract(const Duration(days: 7)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: cs.slate600,
            ),
          ),
        ),
        // Nút chuyển tuần sau
        InkWell(
          onTap: () => onWeekChanged(
            anchorWeekDate.add(const Duration(days: 7)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.slate600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCapsule(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    DateTime day,
  ) {
    final isSelected = _isSameDay(day, selectedDate);
    final isToday = _isSameDay(day, DateTime.now());
    final hasEvent = eventDates.any((d) => _isSameDay(d, day));
    final weekdayIndex = day.weekday - 1;
    final weekdayLabel = _weekdayLabels[weekdayIndex];

    final capsuleBg = isSelected ? cs.blue600 : Colors.transparent;
    final weekdayColor = isSelected
        ? Colors.white.withValues(alpha: 0.85)
        : (isToday ? cs.blue600 : cs.slate500);
    final dayNumColor = isSelected
        ? Colors.white
        : (isToday ? cs.blue600 : cs.slate800);
    final dotColor = isSelected ? Colors.white : cs.blue600;

    return Expanded(
      child: GestureDetector(
        onTap: () => onDateSelected(day),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: capsuleBg,
            borderRadius: BorderRadius.circular(20),
            border: isToday && !isSelected
                ? Border.all(color: cs.blue600.withValues(alpha: 0.5), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thứ (T2, T3...)
              Text(
                weekdayLabel,
                style: tt.labelSmall?.copyWith(
                  color: weekdayColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 4),
              // Số ngày (16, 17...)
              Text(
                '${day.day}',
                style: tt.titleSmall?.copyWith(
                  color: dayNumColor,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              // Chấm dot biểu thị có buổi học
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: hasEvent ? dotColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
