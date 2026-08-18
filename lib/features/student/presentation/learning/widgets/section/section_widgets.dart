import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/theme/theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.sectionIndex,
    required this.section,
    required this.isExpanded,
    required this.onToggle,
    required this.onLessonTap,
  });

  final int sectionIndex;
  final SectionModel section;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(LessonModel) onLessonTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lessons = section.lessons ?? [];
    final completedCount = lessons.where((l) => l.progress?.status == 'completed').length;
    final progress = lessons.isEmpty ? 0.0 : completedCount / lessons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.md),
              bottom: isExpanded ? Radius.zero : const Radius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${sectionIndex + 1}',
                      style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buổi ${sectionIndex + 1}: ${section.title}',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        Row(
                          children: [
                            Text(
                              '${lessons.length} bài • ${section.totalDurationMins} phút',
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            if (completedCount > 0) ...[
                              AppSpacing.hGap8,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: progress >= 1
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : cs.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  progress >= 1 ? 'Hoàn thành' : '$completedCount/${lessons.length}',
                                  style: tt.labelSmall?.copyWith(
                                    color: progress >= 1 ? Colors.green : cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (progress > 0 && progress < 1) ...[
                          AppSpacing.vGap8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && lessons.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Column(
                children: lessons.asMap().entries.map((entry) {
                  final lessonIndex = entry.key;
                  final lesson = entry.value;
                  return SectionLessonItem(
                    lessonIndex: lessonIndex,
                    lesson: lesson,
                    isLast: lessonIndex == lessons.length - 1,
                    onTap: () => onLessonTap(lesson),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionLessonItem extends StatefulWidget {
  const SectionLessonItem({
    super.key,
    required this.lessonIndex,
    required this.lesson,
    required this.isLast,
    required this.onTap,
  });

  final int lessonIndex;
  final LessonModel lesson;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<SectionLessonItem> createState() => _SectionLessonItemState();
}

class _SectionLessonItemState extends State<SectionLessonItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lesson = widget.lesson;
    final lessonIndex = widget.lessonIndex;
    final isCompleted = lesson.progress?.status == 'completed';
    final isInProgress = lesson.progress?.status == 'in_progress';
    final contents = lesson.contents ?? [];
    final hasContents = contents.isNotEmpty;

    return Column(
      children: [
        InkWell(
          onTap: hasContents
              ? () => setState(() => _isExpanded = !_isExpanded)
              : widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isInProgress ? cs.primary.withValues(alpha: 0.05) : null,
              border: !widget.isLast && !_isExpanded
                  ? Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)))
                  : null,
            ),
            child: Row(
              children: [
                LessonStatusIcon(isCompleted: isCompleted, isInProgress: isInProgress),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bài ${lessonIndex + 1}. ${lesson.title}',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (hasContents) ...[
                            Text(
                              '${contents.length} bài học nhỏ',
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            Text(' • ', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                          Text(
                            '${lesson.durationMinutes} phút',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasContents)
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  )
                else if (isCompleted)
                  Text('Hoàn thành', style: tt.labelSmall?.copyWith(color: cs.primary))
                else if (isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${(lesson.progress?.progressPercentage ?? 0).toStringAsFixed(0)}%',
                      style: tt.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                AppSpacing.hGap4,
                Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (_isExpanded && hasContents)
          Container(
            margin: const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3), width: 2)),
            ),
            child: Column(
              children: contents.asMap().entries.map((entry) {
                final contentIndex = entry.key;
                final content = entry.value;
                final durationMins = (content.duration / 60).ceil();
                return InkWell(
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            content.type == 'video' ? Icons.play_arrow_rounded :
                            content.type == 'exercise' ? Icons.edit_note_rounded :
                            Icons.article_outlined,
                            size: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: Text(
                            '${lessonIndex + 1}.${contentIndex + 1} ${content.title}',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${durationMins > 0 ? durationMins : 1} phút',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class LessonStatusIcon extends StatelessWidget {
  const LessonStatusIcon({super.key, required this.isCompleted, required this.isInProgress});
  final bool isCompleted;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, color: cs.onPrimary, size: 16),
      );
    }

    if (isInProgress) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 2),
        ),
        child: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 16),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant, size: 14),
    );
  }
}
