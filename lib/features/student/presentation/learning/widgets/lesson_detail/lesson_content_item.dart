import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/theme/theme.dart';

/// Item hiển thị 1 content trong lesson (video, article, etc.)
class LessonContentItem extends StatefulWidget {
  const LessonContentItem({
    super.key,
    required this.index,
    required this.content,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocked = false,
  });

  final int index;
  final LessonContentModel content;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  State<LessonContentItem> createState() => _LessonContentItemState();
}

class _LessonContentItemState extends State<LessonContentItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isCurrent;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final durationMins = (widget.content.duration / 60).ceil();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Column(
            children: [
              StatusIcon(
                isCompleted: widget.isCompleted,
                isCurrent: widget.isCurrent,
                isLocked: widget.isLocked,
              ),
              if (!widget.isLocked)
                Container(
                  width: 2,
                  height: _isExpanded ? 100 : 40,
                  color: widget.isCompleted
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          ),
          AppSpacing.hGap12,

          // Content
          Expanded(
            child: InkWell(
              onTap: widget.isLocked ? null : () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: widget.isCurrent
                      ? cs.primary.withValues(alpha: 0.05)
                      : cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: widget.isCurrent
                        ? cs.primary.withValues(alpha: 0.3)
                        : cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Type icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.isCurrent
                                ? cs.primary.withValues(alpha: 0.1)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Icon(
                            _getTypeIcon(widget.content.type),
                            size: 18,
                            color: widget.isCurrent ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.hGap12,

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.index + 1}. ${widget.content.title}',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: widget.isLocked ? cs.onSurfaceVariant : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_getTypeLabel(widget.content.type)} • ${durationMins > 0 ? '$durationMins:00' : '0:30'}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        StatusBadge(
                          isCompleted: widget.isCompleted,
                          isCurrent: widget.isCurrent,
                          isLocked: widget.isLocked,
                        ),
                        AppSpacing.hGap4,
                        Icon(
                          _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // Expanded sub-contents
                    if (_isExpanded && !widget.isLocked) ...[
                      AppSpacing.vGap12,
                      SubContentItem(
                        number: '${widget.index + 1}.1',
                        title: 'Dễ học, dễ đọc',
                        duration: '01:20',
                        isCompleted: true,
                      ),
                      SubContentItem(
                        number: '${widget.index + 1}.2',
                        title: 'Đa nền tảng',
                        duration: '01:35',
                        isCompleted: true,
                      ),
                      SubContentItem(
                        number: '${widget.index + 1}.3',
                        title: 'Thư viện phong phú',
                        duration: '01:40',
                        progress: 50,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) => switch (type) {
        'video' => Icons.play_circle_outline_rounded,
        'article' => Icons.description_outlined,
        'exercise' => Icons.help_outline_rounded,
        _ => Icons.play_circle_outline_rounded,
      };

  String _getTypeLabel(String type) => switch (type) {
        'video' => 'Video',
        'article' => 'Tài liệu',
        'exercise' => 'Quiz',
        _ => 'Video',
      };
}

/// Icon trạng thái content (completed, current, locked)
class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
  });

  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, size: 14, color: cs.onPrimary),
      );
    }

    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          ),
        ),
      );
    }

    if (isLocked) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
        child: Icon(Icons.lock_outline_rounded, size: 12, color: cs.onSurfaceVariant),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: cs.surface,
        shape: BoxShape.circle,
        border: Border.all(color: cs.outlineVariant),
      ),
    );
  }
}

/// Badge hiển thị trạng thái content
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
  });

  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Đã xem', style: tt.labelSmall?.copyWith(color: cs.primary)),
          AppSpacing.hGap4,
          Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
        ],
      );
    }

    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text('Đang xem', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
      );
    }

    if (isLocked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Khóa', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          AppSpacing.hGap4,
          Icon(Icons.lock_outline_rounded, size: 14, color: cs.onSurfaceVariant),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text('Chưa học', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
    );
  }
}

/// Item sub-content trong expanded state
class SubContentItem extends StatelessWidget {
  const SubContentItem({
    super.key,
    required this.number,
    required this.title,
    required this.duration,
    this.isCompleted = false,
    this.progress,
  });

  final String number;
  final String title;
  final String duration;
  final bool isCompleted;
  final int? progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number $title', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                Text(duration, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_circle_rounded, size: 18, color: cs.primary)
          else if (progress != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    value: progress! / 100,
                    strokeWidth: 2,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                AppSpacing.hGap4,
                Text('$progress%', style: tt.labelSmall?.copyWith(color: cs.primary)),
              ],
            ),
        ],
      ),
    );
  }
}
