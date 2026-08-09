import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

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
    this.isFirst = false,
    this.isLast = false,
  });

  final ScheduleTimelineItemData data;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = _accentColor(cs);
    final times = data.time.split(' - ');

    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: data.isActive
              ? accent.withValues(alpha: 0.035)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        times.first,
                        style: tt.labelMedium?.copyWith(
                          color: data.isActive ? cs.primary : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (times.length > 1)
                        Text(
                          times.last,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hGap8,
              SizedBox(
                width: 16,
                child: CustomPaint(
                  painter: _TimelineAxisPainter(
                    color: cs.outline,
                    isFirst: isFirst,
                    isLast: isLast,
                  ),
                  child: Center(
                    child: Container(
                      width: data.isActive ? 10 : 8,
                      height: data.isActive ? 10 : 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.surfaceContainerLowest,
                          width: 2,
                        ),
                        boxShadow: data.isActive
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.22),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap4,
                      Text(
                        data.subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _typeLabel,
                    style: tt.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentColor(ColorScheme cs) {
    return switch (data.type) {
      ScheduleItemType.livestream => cs.error,
      ScheduleItemType.video => cs.primary,
      ScheduleItemType.quiz => cs.tertiary,
      ScheduleItemType.deadline => cs.secondary,
    };
  }

  String get _typeLabel {
    return switch (data.type) {
      ScheduleItemType.livestream => 'Trực tuyến',
      ScheduleItemType.video => 'Video',
      ScheduleItemType.quiz => 'Kiểm tra',
      ScheduleItemType.deadline => 'Hạn nộp',
    };
  }
}

class _TimelineAxisPainter extends CustomPainter {
  const _TimelineAxisPainter({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, isFirst ? center.dy : 0),
      Offset(center.dx, isLast ? center.dy : size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TimelineAxisPainter oldDelegate) {
    return color != oldDelegate.color ||
        isFirst != oldDelegate.isFirst ||
        isLast != oldDelegate.isLast;
  }
}
