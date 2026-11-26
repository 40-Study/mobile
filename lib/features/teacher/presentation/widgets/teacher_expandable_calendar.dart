import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/theme/theme.dart';

/// Calendar có thể mở rộng từ week view sang month view.
/// Dành cho Teacher schedule screen.
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
    this.classFilter,
  });

  final DateTime selectedDate;
  final DateTime weekStart;
  final bool isExpanded;
  final List<TeacherOccurrence> sessions;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onWeekChanged; // -1 or 1
  final String? classFilter;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: AppSpacing.paddingHorizontalXl,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010120).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 280),
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildWeekView(context, cs),
        secondChild: _buildMonthView(context, cs),
      ),
    );
  }

  // =========================================================================
  // WEEK VIEW (collapsed)
  // =========================================================================
  Widget _buildWeekView(BuildContext context, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final weekDays = List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
    final sunday = weekDays[6];

    // Week title
    final String weekTitle;
    if (weekStart.month == sunday.month) {
      weekTitle =
          '${weekStart.day} - ${sunday.day} Tháng ${weekStart.month}';
    } else {
      weekTitle =
          '${weekStart.day}/${weekStart.month} - ${sunday.day}/${sunday.month}';
    }

    // Count sessions in week
    final weekSessions = sessions.where((s) {
      final date = s.date;
      return !date.isBefore(weekStart) &&
          !date.isAfter(sunday) &&
          (classFilter == null || s.classId == classFilter);
    }).length;

    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              // Nav prev
              _NavButton(
                icon: Icons.chevron_left,
                onTap: () => onWeekChanged(-1),
                cs: cs,
              ),
              AppSpacing.hGap8,
              // Title
              Expanded(
                child: GestureDetector(
                  onTap: onToggleExpand,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: cs.primary,
                        size: 18,
                      ),
                      AppSpacing.hGap8,
                      Text(
                        weekTitle,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hGap8,
              // Nav next
              _NavButton(
                icon: Icons.chevron_right,
                onTap: () => onWeekChanged(1),
                cs: cs,
              ),
              AppSpacing.hGap8,
              // Session count badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  '$weekSessions buổi',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.hGap4,
              // Expand button
              IconButton(
                onPressed: onToggleExpand,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: cs.onSurfaceVariant,
                tooltip: 'Mở rộng lịch tháng',
              ),
            ],
          ),
          AppSpacing.vGap12,
          // Week days strip
          Row(
            children: weekDays.map((day) {
              return Expanded(
                child: _WeekDayCell(
                  day: day,
                  isSelected: _isSameDay(day, selectedDate),
                  isToday: _isSameDay(day, DateTime.now()),
                  sessionCount: _getSessionCount(day),
                  hasNeedsAttention: _hasNeedsAttention(day),
                  onTap: () => onDateSelected(day),
                  cs: cs,
                  tt: tt,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // MONTH VIEW (expanded)
  // =========================================================================
  Widget _buildMonthView(BuildContext context, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final y = selectedDate.year;
    final m = selectedDate.month;
    final firstDayOfMonth = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;

    // Calculate offset (Monday = 0)
    final startWeekday = firstDayOfMonth.weekday;
    final leadingEmptyDays = startWeekday - 1;

    // Days in previous month
    final daysInPrevMonth = DateTime(y, m, 0).day;

    // Total cells
    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        children: [
          // Month header
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                onTap: () => onWeekChanged(-4), // Approximate month
                cs: cs,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onToggleExpand,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tháng $m, $y',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.hGap8,
                      Icon(
                        Icons.calendar_month_outlined,
                        color: cs.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right,
                onTap: () => onWeekChanged(4),
                cs: cs,
              ),
              AppSpacing.hGap8,
              IconButton(
                onPressed: onToggleExpand,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: cs.onSurfaceVariant,
                tooltip: 'Thu gọn về tuần',
              ),
            ],
          ),
          AppSpacing.vGap12,
          // Weekday headers
          Row(
            children: _weekdayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.vGap8,
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyDays) {
                final prevDay = daysInPrevMonth - (leadingEmptyDays - index - 1);
                return Center(
                  child: Text(
                    '$prevDay',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }

              final dayNumber = index - leadingEmptyDays + 1;
              if (dayNumber > daysInMonth) {
                final nextDay = dayNumber - daysInMonth;
                return Center(
                  child: Text(
                    '$nextDay',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }

              final day = DateTime(y, m, dayNumber);
              final isSelected = _isSameDay(day, selectedDate);
              final isToday = _isSameDay(day, DateTime.now());
              final count = _getSessionCount(day);
              final hasAttention = _hasNeedsAttention(day);

              return GestureDetector(
                onTap: () => onDateSelected(day),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : isToday
                                ? cs.primaryContainer.withValues(alpha: 0.5)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: cs.primary, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        '$dayNumber',
                        style: tt.bodyMedium?.copyWith(
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                          fontWeight:
                              isSelected || isToday ? FontWeight.w700 : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (count > 0 || hasAttention)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasAttention)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: AchievementColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (count > 0)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      )
                    else
                      const SizedBox(height: 5),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _getSessionCount(DateTime day) {
    return sessions.where((s) {
      return _isSameDay(s.date, day) &&
          (classFilter == null || s.classId == classFilter);
    }).length;
  }

  bool _hasNeedsAttention(DateTime day) {
    return sessions.any((s) {
      if (!_isSameDay(s.date, day)) return false;
      if (classFilter != null && s.classId != classFilter) return false;
      final confirmStatus = s.json['hour_confirmation_status']?.toString();
      return confirmStatus == 'needs_info';
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderFull,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.sessionCount,
    required this.hasNeedsAttention,
    required this.onTap,
    required this.cs,
    required this.tt,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final int sessionCount;
  final bool hasNeedsAttention;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : isToday
                  ? cs.primaryContainer.withValues(alpha: 0.3)
                  : Colors.transparent,
          borderRadius: AppRadius.borderMd,
          border: isToday && !isSelected
              ? Border.all(color: cs.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isToday ? 'Nay' : _weekdays[day.weekday - 1],
              style: tt.labelSmall?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: isToday ? 10 : 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd').format(day),
              style: tt.titleMedium?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (sessionCount > 0 || hasNeedsAttention)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasNeedsAttention)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? cs.onPrimary : AchievementColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '$sessionCount',
                    style: tt.labelMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            else
              Text(
                '—',
                style: tt.labelSmall?.copyWith(
                  color: isSelected
                      ? cs.onPrimary.withValues(alpha: 0.5)
                      : cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
