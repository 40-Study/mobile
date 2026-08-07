import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline_item.dart';
import 'package:study/theme/theme.dart';

export 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.items,
    this.emptyMessage = 'Không có lịch học hôm nay',
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
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: AppShadows.sm,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available, size: 48, color: cs.secondary),
              AppSpacing.vGap8,
              Text(
                emptyMessage,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: AppShadows.sm,
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
