import 'package:flutter/material.dart';
import 'package:study/data/motivational_quotes.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline_item.dart';
import 'package:study/theme/theme.dart';

export 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({super.key, required this.items});

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
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 20,
                    color: cs.primary,
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
                        style: tt.bodySmall?.copyWith(color: cs.slate500),
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
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cs.primaryContainer, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                      AppSpacing.hGap8,
                      Text(
                        'Quote hôm nay',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
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

    if (items.length == 1) {
      return ScheduleSingleCard(data: items.first);
    }

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(16),
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

class ScheduleSingleCard extends StatelessWidget {
  const ScheduleSingleCard({super.key, required this.data});

  final ScheduleTimelineItemData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final times = data.time.split(' - ');
    final accent = _getAccentColor(cs, data.type);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : cs.surface,
          borderRadius: BorderRadius.circular(16),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: data.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  // 1. Time Capsule Block
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDBEAFE),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          times.first,
                          style: const TextStyle(
                            color: Color(0xFF3D5FC4),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (times.length > 1) ...[
                          const SizedBox(height: 1),
                          Text(
                            times.last,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Class Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.slate900,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              _getSubtitleIcon(data),
                              size: 13,
                              color: cs.slate400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.subtitle,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.slate500,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3. Type Badge & Chevron
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _getTypeLabel(data.type),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccentColor(ColorScheme cs, ScheduleItemType type) {
    return switch (type) {
      ScheduleItemType.livestream => cs.error,
      ScheduleItemType.video => const Color(0xFF3D5FC4),
      ScheduleItemType.quiz => cs.tertiary,
      ScheduleItemType.deadline => cs.secondary,
    };
  }

  String _getTypeLabel(ScheduleItemType type) {
    return switch (type) {
      ScheduleItemType.livestream => 'Trực tuyến',
      ScheduleItemType.video => 'Video',
      ScheduleItemType.quiz => 'Kiểm tra',
      ScheduleItemType.deadline => 'Hạn nộp',
    };
  }

  IconData _getSubtitleIcon(ScheduleTimelineItemData data) {
    if (data.subtitle.startsWith('GV:')) {
      return Icons.person_outline_rounded;
    }
    return switch (data.type) {
      ScheduleItemType.livestream => Icons.sensors_rounded,
      ScheduleItemType.video => Icons.ondemand_video_rounded,
      ScheduleItemType.quiz => Icons.assignment_outlined,
      ScheduleItemType.deadline => Icons.alarm_rounded,
    };
  }
}
