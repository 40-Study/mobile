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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: data.isActive
              ? accent.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      times.first,
                      style: tt.labelMedium?.copyWith(
                        color: data.isActive ? cs.primary : cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    if (times.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        times.last,
                        style: tt.labelSmall?.copyWith(
                          color: cs.slate400,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.hGap8,
              SizedBox(
                width: 16,
                child: CustomPaint(
                  painter: _TimelineAxisPainter(
                    color: cs.outlineVariant.withValues(alpha: 0.6),
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
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: data.isActive
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.25),
                                blurRadius: 4,
                                spreadRadius: 2,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.slate900,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          _deriveSubtitleIcon(data),
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
                  _typeLabel,
                  style: tt.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
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
    );
  }

  IconData _deriveSubtitleIcon(ScheduleTimelineItemData data) {
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

  Color _accentColor(ColorScheme cs) {
    return switch (data.type) {
      ScheduleItemType.livestream => cs.error,
      ScheduleItemType.video => const Color(0xFF3D5FC4),
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
