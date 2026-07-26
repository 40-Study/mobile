import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline_item.dart';
import 'package:study/theme/theme.dart';

export 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.items,
    this.emptyMessage = 'Khong co lich hoc hom nay',
  });

  final List<ScheduleTimelineItemData> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              AppSpacing.vGap8,
              Text(
                emptyMessage,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return ScheduleTimelineItem(
            data: items[index],
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}
