import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/timeline_dot.dart';

enum ScheduleItemType { livestream, video, quiz, deadline }

class ScheduleTimelineItemData {
  const ScheduleTimelineItemData({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isActive = false,
    this.onTap,
    this.actionLabel,
  });

  final String time;
  final String title;
  final String subtitle;
  final ScheduleItemType type;
  final bool isActive;
  final VoidCallback? onTap;
  final String? actionLabel;
}

class ScheduleTimelineItem extends StatelessWidget {
  const ScheduleTimelineItem({
    super.key,
    required this.data,
    this.isLast = false,
  });

  final ScheduleTimelineItemData data;
  final bool isLast;

  IconData get _icon {
    switch (data.type) {
      case ScheduleItemType.livestream:
        return Icons.videocam;
      case ScheduleItemType.video:
        return Icons.play_circle_outline;
      case ScheduleItemType.quiz:
        return Icons.quiz_outlined;
      case ScheduleItemType.deadline:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                TimelineDot(isActive: data.isActive),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.time,
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    data.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Row(
                    children: [
                      Icon(
                        _icon,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      AppSpacing.hGap4,
                      Expanded(
                        child: Text(
                          data.subtitle,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (data.actionLabel != null && data.onTap != null) ...[
                    AppSpacing.vGap8,
                    TextButton(
                      onPressed: data.onTap,
                      child: Text(data.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
