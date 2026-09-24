import 'package:flutter/material.dart';

import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/theme/theme.dart';

/// Bộ chọn chế độ xem lịch học (Hôm nay / Tuần này / Tháng này).
class ScheduleSegmentedControl extends StatelessWidget {
  const ScheduleSegmentedControl({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final ParentScheduleTab selectedTab;
  final ValueChanged<ParentScheduleTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: AppRadius.borderFull,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          _buildSegment(
            context,
            title: 'Hôm nay',
            tab: ParentScheduleTab.today,
            cs: cs,
            tt: tt,
          ),
          _buildSegment(
            context,
            title: 'Tuần này',
            tab: ParentScheduleTab.week,
            cs: cs,
            tt: tt,
          ),
          _buildSegment(
            context,
            title: 'Tháng này',
            tab: ParentScheduleTab.month,
            cs: cs,
            tt: tt,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required String title,
    required ParentScheduleTab tab,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final isSelected = selectedTab == tab;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: AppRadius.borderFull,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTabChanged(tab),
            borderRadius: AppRadius.borderFull,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  title,
                  style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.blue600 : cs.slate600,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
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
