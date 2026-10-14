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
    required this.allLessons,
    required this.globalStartIndex,
  });

  final int sectionIndex;
  final SectionModel section;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(LessonModel) onLessonTap;
  final List<LessonModel> allLessons;
  final int globalStartIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final lessons = section.lessons ?? [];
    final completedCount = lessons.where((l) => l.progress?.status == 'completed').length;
    final progress = lessons.isEmpty ? 0.0 : completedCount / lessons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.lg),
              bottom: isExpanded ? Radius.zero : const Radius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${sectionIndex + 1}',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buổi ${sectionIndex + 1}: ${section.title}',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.slate900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        Row(
                          children: [
                            Text(
                              '${lessons.length} bài • ${section.totalDurationMins} phút',
                              style: tt.bodySmall?.copyWith(color: cs.slate500),
                            ),
                            if (completedCount > 0) ...[
                              AppSpacing.hGap8,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: progress >= 1
                                      ? const Color(0xFFECFDF5)
                                      : cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  progress >= 1 ? 'Hoàn thành' : '$completedCount/${lessons.length}',
                                  style: TextStyle(
                                    color: progress >= 1
                                        ? const Color(0xFF059669)
                                        : cs.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (progress > 0 && progress < 1) ...[
                          AppSpacing.vGap8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor:
                                  cs.outlineVariant.withValues(alpha: 0.25),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(cs.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: cs.slate400,
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
                  final globalIndex = globalStartIndex + lessonIndex;
                  // Bài đầu tiên luôn mở, các bài sau phải chờ bài trước hoàn thành
                  final isLocked = globalIndex > 0 &&
                      allLessons[globalIndex - 1].progress?.status != 'completed';
                  return SectionLessonItem(
                    lessonIndex: lessonIndex,
                    lesson: lesson,
                    isLast: lessonIndex == lessons.length - 1,
                    isLocked: isLocked,
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
    this.isLocked = false,
  });

  final int lessonIndex;
  final LessonModel lesson;
  final bool isLast;
  final bool isLocked;
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
              : widget.isLocked ? null : widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isInProgress ? const Color(0xFFEFF6FF).withValues(alpha: 0.5) : null,
              border: !widget.isLast && !_isExpanded
                  ? Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)))
                  : null,
            ),
            child: Row(
              children: [
                LessonStatusIcon(
                  isCompleted: isCompleted,
                  isInProgress: isInProgress,
                  isLocked: widget.isLocked,
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bài ${lessonIndex + 1}. ${lesson.title}',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isLocked ? cs.slate400 : cs.slate900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (hasContents) ...[
                            Text(
                              '${contents.length} bài học nhỏ',
                              style: tt.bodySmall?.copyWith(color: cs.slate500),
                            ),
                            Text(' • ', style: tt.bodySmall?.copyWith(color: cs.slate500)),
                          ],
                          Text(
                            '${lesson.durationMinutes} phút',
                            style: tt.bodySmall?.copyWith(color: cs.slate500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasContents)
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: cs.slate500,
                    size: 22,
                  )
                else ...[
                  if (isCompleted)
                    const Text(
                      'Hoàn thành',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (isInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${(lesson.progress?.progressPercentage ?? 0).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  AppSpacing.hGap4,
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.slate400),
                ],
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
                  onTap: widget.isLocked ? null : widget.onTap,
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
  const LessonStatusIcon({
    super.key,
    required this.isCompleted,
    required this.isInProgress,
    this.isLocked = false,
  });
  final bool isCompleted;
  final bool isInProgress;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFECFDF5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Color(0xFF059669),
          size: 16,
        ),
      );
    }

    if (isLocked) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_rounded, color: cs.slate400, size: 14),
      );
    }

    if (isInProgress) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 1.8),
        ),
        child: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 16),
      );
    }

    // Bài chưa bắt đầu nhưng có thể truy cập
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.play_arrow_rounded, color: cs.slate500, size: 16),
    );
  }
}
