import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class CalendarDayItem {
  const CalendarDayItem({
    required this.label,
    required this.day,
    required this.date,
    this.isToday = false,
    this.hasSchedule = false,
  });
  final String label;
  final int day;
  final DateTime date;
  final bool isToday;
  final bool hasSchedule;
}

class ScheduleCalendarStrip extends StatelessWidget {
  const ScheduleCalendarStrip({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CalendarDayItem> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final textColor = cs.onSurface;
    final textColorSecondary = cs.onSurface.withValues(alpha: 0.6);
    final unselectedBg = cs.surfaceContainerLowest;
    final borderColor = cs.outline;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenMargin,
        ),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              decoration: BoxDecoration(
                gradient: isSelected ? cs.gradientPrimary : null,
                color: isSelected ? null : unselectedBg,
                borderRadius: AppRadius.borderLg,
                border: isSelected
                    ? null
                    : Border.all(
                        color: day.isToday ? cs.primary : borderColor,
                        width: day.isToday ? 2 : 1,
                      ),
                boxShadow: isSelected ? cs.shadowPrimary : cs.shadowCard,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.label,
                    style: tt.labelSmall?.copyWith(
                      color: isSelected
                          ? cs.onPrimary.withValues(alpha: 0.85)
                          : textColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${day.day}',
                    style: tt.titleMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (day.isToday && !isSelected) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
