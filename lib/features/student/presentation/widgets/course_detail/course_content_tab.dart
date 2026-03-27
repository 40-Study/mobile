import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/course_detail_model.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class CourseContentTab extends StatelessWidget {
  const CourseContentTab({super.key, required this.detail});
  final CourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.xxl,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      itemCount: detail.chapters.length,
      itemBuilder: (context, index) {
        return ChapterSection(chapter: detail.chapters[index]);
      },
    );
  }
}

class ChapterSection extends StatelessWidget {
  const ChapterSection({super.key, required this.chapter});
  final ChapterModel chapter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final statusText = chapter.isAllCompleted
        ? '${chapter.completedLessons}/${chapter.totalLessons} Hoan thanh'
        : chapter.status == 'in_progress'
            ? 'Dang hoc ${chapter.completedLessons}/${chapter.totalLessons}'
            : '${chapter.totalLessons} bai hoc';

    final statusColor = chapter.isAllCompleted
        ? cs.tertiary
        : chapter.status == 'in_progress'
            ? cs.primary
            : cs.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  chapter.title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  statusText,
                  style: tt.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...chapter.lessons.map(
            (lesson) => LessonTile(lesson: lesson),
          ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({super.key, required this.lesson});
  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = lesson.status == LessonStatus.completed;
    final isInProgress = lesson.status == LessonStatus.inProgress;
    final isLocked = lesson.status == LessonStatus.locked;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
                final repository = context.read<StudentRepository>();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider(
                      create: (_) => LessonDetailCubit(
                        repository: repository,
                        lessonId: lesson.id,
                      ),
                      child: LessonDetailScreen(
                        lessonId: lesson.id,
                        lessonTitle: lesson.title,
                      ),
                    ),
                  ),
                );
              },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isInProgress
                ? cs.surfaceTintedPrimary
                : cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isInProgress
                  ? cs.primary.withValues(alpha: 0.2)
                  : cs.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? cs.tertiary.withValues(alpha: 0.12)
                    : isInProgress
                        ? cs.primary.withValues(alpha: 0.12)
                        : cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : isInProgress
                        ? Icons.play_circle_rounded
                        : Icons.lock_outline_rounded,
                size: AppIconSize.md,
                color: isCompleted
                    ? cs.tertiary
                    : isInProgress
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight:
                          isInProgress ? FontWeight.w600 : FontWeight.w400,
                      color: isLocked
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    isInProgress && lesson.currentTime != null
                        ? '${lesson.currentTime} / ${lesson.totalTime}'
                        : lesson.duration ?? '',
                    style: tt.labelSmall?.copyWith(
                      color: isInProgress ? cs.primary : cs.onSurfaceVariant,
                      fontWeight:
                          isInProgress ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
