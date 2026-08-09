import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/section_list.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/theme/theme.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  void _navigateToLesson(
    BuildContext context,
    LessonModel lesson,
    List<LessonModel> allLessons,
  ) {
    final index = allLessons.indexWhere((l) => l.id == lesson.id);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              LessonBloc(StudentRepositoryImpl())
                ..add(LessonStarted(lesson.id)),
          child: LessonDetailScreen(
            currentIndex: index >= 0 ? index : 0,
            totalLessons: allLessons.length,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          return switch (state) {
            CourseDetailInitial() || CourseDetailInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            CourseDetailFailure(:final message) => _buildError(
              context,
              message,
            ),
            CourseDetailSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () => context.read<CourseDetailBloc>().add(
              const CourseDetailRefreshed(),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;
    final enrollment = state.enrollment;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final progressLabel = enrollment.progressPercentage.toStringAsFixed(0);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: cs.primaryContainer,
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    size: 36,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Course info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course?.title ?? 'Khóa học',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap8,
                if (course?.instructorName != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      AppSpacing.hGap4,
                      Text(
                        course!.instructorName!,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    AppSpacing.hGap4,
                    Text(
                      '${course?.totalDurationMins ?? 0} phút',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.hGap16,
                    Icon(
                      Icons.menu_book_outlined,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    AppSpacing.hGap4,
                    Text(
                      '${course?.totalLessons ?? 0} bài học',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                AppSpacing.vGap16,

                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ học tập',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$progressLabel%',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap8,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                        ),
                      ),
                      AppSpacing.vGap8,
                      Text(
                        '${enrollment.completedLessons}/'
                        '${enrollment.totalLessons} bài đã hoàn thành',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGap24,

                Text(
                  'Nội dung khóa học',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.vGap12,
              ],
            ),
          ),
        ),

        // Sections list
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionList(
              sections: state.sections,
              expandedSections: state.expandedSections,
              onSectionToggle: (sectionId) {
                context.read<CourseDetailBloc>().add(
                  CourseDetailSectionToggled(sectionId),
                );
              },
              onLessonTap: (lesson) {
                // Flatten all lessons from sections
                final allLessons = state.sections
                    .expand((s) => s.lessons ?? <LessonModel>[])
                    .toList();
                _navigateToLesson(context, lesson, allLessons);
              },
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: AppSpacing.vGap32),
      ],
    );
  }
}
