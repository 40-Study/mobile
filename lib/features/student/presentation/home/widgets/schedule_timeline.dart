import 'package:flutter/material.dart';
import 'package:study/data/motivational_quotes.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline_item.dart';
import 'package:study/theme/theme.dart';

export 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.items,
  });

  final List<ScheduleTimelineItemData> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (items.isEmpty) {
      final quote = MotivationalQuote.scheduleForDate(DateTime.now());

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 20,
                    color: cs.blue600,
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hôm nay không có ca học',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bạn có thể tự ôn tập hoặc nghỉ ngơi để nạp'
                        ' năng lượng!',
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.vGap16,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: cs.blue100,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 16,
                        color: cs.blue600,
                      ),
                      AppSpacing.hGap8,
                      Text(
                        'Quote hôm nay',
                        style: tt.labelSmall?.copyWith(
                          color: cs.blue600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap8,
                  Text(
                    '"${quote.quote}"',
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate700,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— ForteX —',
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate400,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (index) {
          return ScheduleTimelineItem(
            data: items[index],
            isFirst: index == 0,
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}
