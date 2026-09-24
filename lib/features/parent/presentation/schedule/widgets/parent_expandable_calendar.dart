import 'package:flutter/material.dart';

import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/theme/theme.dart';

/// Quyển lịch thông minh dành cho Phụ huynh:
/// - Chế độ Thu gọn (Weekly View): 1 tuần chứa ngày được chọn, badge tổng ca
/// - Chế độ Mở rộng (Monthly View): Lưới full tháng, multi-color dots theo con,
///   nút chuyển tháng và thanh chú thích (Legend) môn học của con ở chân card.
class ParentExpandableCalendar extends StatelessWidget {
  const ParentExpandableCalendar({
    super.key,
    required this.selectedDate,
    required this.currentMonth,
    required this.isExpanded,
    required this.eventsMap,
    required this.children,
    required this.selectedChildId,
    required this.totalSessionsInWeek,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onToggleExpand,
  });

  final DateTime selectedDate;
  final DateTime currentMonth;
  final bool isExpanded;
  final Map<DateTime, List<String>> eventsMap;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final int totalSessionsInWeek;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onToggleExpand;

  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 280),
        crossFadeState: isExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: _buildWeekView(context, cs, tt),
        secondChild: _buildMonthView(context, cs, tt),
      ),
    );
  }

  // =========================================================================
  // TRẠNG THÁI 1: THU GỌN (WEEKLY VIEW - MẪU ẢNH 2)
  // =========================================================================
  Widget _buildWeekView(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final sunday = weekDays[6];

    final weekNumber = _weekOfYear(monday);
    final String weekTitle;
    if (monday.month == sunday.month) {
      weekTitle = 'Tuần $weekNumber · ${monday.day} - ${sunday.day} '
          'Tháng ${monday.month}';
    } else {
      weekTitle =
          'Tuần $weekNumber · ${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
    }

    return Column(
      children: [
        // Header Tuần: Icon + Tiêu đề tuần + Badge số buổi học + Nút mở rộng
        Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: cs.blue600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onToggleExpand,
                child: Text(
                  weekTitle,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Badge số buổi học trong tuần
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: AppRadius.borderFull,
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 0.8,
                ),
              ),
              child: Text(
                '• $totalSessionsInWeek buổi học trong tuần',
                style: tt.labelSmall?.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Nút mở rộng sang lịch tháng
            IconButton(
              onPressed: onToggleExpand,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: cs.slate600,
              tooltip: 'Mở rộng lịch tháng',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Dải 7 ngày capsule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((day) {
            return _buildWeekDayCapsule(context, cs, tt, day);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeekDayCapsule(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    DateTime day,
  ) {
    final isSelected = _isSameDay(day, selectedDate);
    final weekdayLabel = _weekdayLabels[day.weekday - 1];
    final childIds = _getChildIdsForDate(day);

    // Style ngày chọn theo Ảnh 2: Capsule xanh nhạt bo tròn
    final capsuleBg = isSelected ? const Color(0xFFEFF6FF) : Colors.transparent;
    final textColor = isSelected ? cs.blue600 : cs.slate900;
    final weekdayColor = isSelected ? cs.blue600 : cs.slate500;

    return Expanded(
      child: GestureDetector(
        onTap: () => onDateSelected(day),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: capsuleBg,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: cs.blue600.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekdayLabel,
                style: tt.labelSmall?.copyWith(
                  color: weekdayColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: tt.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              // Multi-color dots
              _buildDotsRow(childIds),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TRẠNG THÁI 2: MỞ RỘNG (MONTHLY VIEW - MẪU ẢNH 3)
  // =========================================================================
  Widget _buildMonthView(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final y = currentMonth.year;
    final m = currentMonth.month;
    final firstDayOfMonth = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;

    // Tính offset ngày đầu tuần (Thứ 2 = index 0)
    final startWeekday = firstDayOfMonth.weekday; // 1 = T2, 7 = CN
    final leadingEmptyDays = startWeekday - 1;

    // Số ngày tháng trước
    final daysInPrevMonth = DateTime(y, m, 0).day;

    // Tổng số ô hiển thị (bội số của 7)
    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: [
        // Header Tháng: Tiêu đề tháng, năm + Icon + 2 nút < > + Nút thu gọn
        Row(
          children: [
            Text(
              'Tháng $m, $y',
              style: tt.titleMedium?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.calendar_month_outlined,
              color: cs.blue600,
              size: 19,
            ),
            const Spacer(),
            // Nút chuyển tháng trước
            _buildRoundNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => onMonthChanged(DateTime(y, m - 1, 1)),
              cs: cs,
            ),
            const SizedBox(width: 8),
            // Nút chuyển tháng sau
            _buildRoundNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => onMonthChanged(DateTime(y, m + 1, 1)),
              cs: cs,
            ),
            const SizedBox(width: 6),
            // Nút thu gọn về tuần
            IconButton(
              onPressed: onToggleExpand,
              icon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 22,
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: cs.slate600,
              tooltip: 'Thu gọn về tuần',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Hàng tiêu đề thứ: T2 -> CN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekdayLabels.map((label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate400,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Lưới các ngày trong tháng (Grid 7 cột)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            if (index < leadingEmptyDays) {
              // Ngày tháng trước (chữ mờ)
              final prevDay =
                  daysInPrevMonth - (leadingEmptyDays - index - 1);
              return Center(
                child: Text(
                  '$prevDay',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate300,
                    fontSize: 13,
                  ),
                ),
              );
            }

            final dayNumber = index - leadingEmptyDays + 1;
            if (dayNumber > daysInMonth) {
              // Ngày tháng sau (chữ mờ)
              final nextDay = dayNumber - daysInMonth;
              return Center(
                child: Text(
                  '$nextDay',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate300,
                    fontSize: 13,
                  ),
                ),
              );
            }

            final day = DateTime(y, m, dayNumber);
            final isSelected = _isSameDay(day, selectedDate);
            final childIds = _getChildIdsForDate(day);

            return GestureDetector(
              onTap: () => onDateSelected(day),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Số ngày tròn
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? cs.blue600 : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: tt.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : cs.slate800,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Multi-color dots
                  _buildDotsRow(childIds),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // Thanh Chú thích (Legend) ở chân lịch tháng
        _buildLegend(cs, tt),
      ],
    );
  }

  Widget _buildRoundNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, size: 18, color: cs.slate700),
      ),
    );
  }

  // =========================================================================
  // MULTI-COLOR DOTS VÀ LEGEND (CHÚ THÍCH)
  // =========================================================================
  Widget _buildDotsRow(List<String> childIds) {
    if (childIds.isEmpty) {
      return const SizedBox(height: 5);
    }

    return SizedBox(
      height: 5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: childIds.map((cId) {
          final dotColor = _getColorForChild(cId);
          return Container(
            width: 4.5,
            height: 4.5,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: const Color(0xFF2563EB),
            text: 'Minh (Toán, Tin, Lý)',
            cs: cs,
            tt: tt,
          ),
          const SizedBox(width: 16),
          _buildLegendItem(
            color: const Color(0xFFEC4899),
            text: 'Lan (Anh, Văn)',
            cs: cs,
            tt: tt,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: tt.labelSmall?.copyWith(
            color: cs.slate700,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  List<String> _getChildIdsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final rawList = eventsMap[key] ?? [];

    if (selectedChildId != null && selectedChildId!.isNotEmpty) {
      return rawList.contains(selectedChildId) ? [selectedChildId!] : [];
    }
    return rawList;
  }

  Color _getColorForChild(String childId) {
    if (childId.contains('minh')) {
      return const Color(0xFF2563EB); // Xanh dương
    }
    if (childId.contains('lan')) {
      return const Color(0xFFEC4899); // Hồng tím
    }
    final matched = children.where((c) => c.id == childId).firstOrNull;
    if (matched != null) {
      return matched.badgeColor;
    }
    return const Color(0xFF2563EB);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
