import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/theme/app_colors.dart';

class TeacherCourseContentTab extends StatelessWidget {
  const TeacherCourseContentTab({super.key, required this.detail});

  final TeacherCourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${detail.chapters.length} Chương',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${detail.publishedLessons}/${detail.totalLessons} bài học đã xuất bản',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Add new chapter
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm chương'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chapters list
        Expanded(
          child: detail.chapters.isEmpty
              ? _EmptyChapters()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenMargin,
                    0,
                    AppLayout.screenMargin,
                    AppSpacing.massive,
                  ),
                  itemCount: detail.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = detail.chapters[index];
                    return _ChapterCard(
                      key: ValueKey(chapter.id),
                      chapter: chapter,
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyChapters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có nội dung',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thêm chương và bài học cho khóa học của bạn',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                // TODO: Add first chapter
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm chương đầu tiên'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    super.key,
    required this.chapter,
    required this.index,
  });

  final TeacherChapterModel chapter;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: cs.shadowCard,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: chapter.isAllPublished
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: chapter.isAllPublished ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(
            chapter.title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${chapter.publishedLessons}/${chapter.totalLessons} bài học',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Edit chapter
                },
                icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.drag_handle,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
          children: [
            if (chapter.lessons.isNotEmpty)
              ...chapter.lessons.asMap().entries.map((entry) {
                return _LessonItem(
                  lesson: entry.value,
                  index: entry.key,
                  isLast: entry.key == chapter.lessons.length - 1,
                );
              }),
            // Add lesson button
            InkWell(
              onTap: () {
                // TODO: Add lesson
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18, color: cs.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Thêm bài học',
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  const _LessonItem({
    required this.lesson,
    required this.index,
    this.isLast = false,
  });

  final TeacherLessonModel lesson;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (statusIcon, statusColor) = switch (lesson.status) {
      TeacherLessonStatus.published => (
          Icons.check_circle,
          Colors.green,
        ),
      TeacherLessonStatus.draft => (
          Icons.edit_note,
          cs.tertiary,
        ),
      TeacherLessonStatus.processing => (
          Icons.hourglass_empty,
          cs.secondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (lesson.duration != null) ...[
                      Icon(Icons.schedule,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        lesson.duration!,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    if (lesson.isPublished) ...[
                      Icon(Icons.visibility_outlined,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.viewCount} lượt xem',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Edit lesson
            },
            icon: Icon(Icons.more_vert, size: 18, color: cs.onSurfaceVariant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
