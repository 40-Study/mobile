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

    if (items.isEmpty) {
      final quote = MotivationalQuote.scheduleForDate(DateTime.now());
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFE8F2FC)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0xFFD0E4F7).withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Illustration
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E4F7).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 48,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 18, color: cs.primary),
                      AppSpacing.hGap8,
                      Text(
                        'Quote hôm nay',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap12,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      '"${quote.quote}"',
                      style: tt.bodyLarge?.copyWith(
                        color: const Color(0xFF2D3748),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                    '— 40Study —',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
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
