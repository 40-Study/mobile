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
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LessonBloc(StudentRepositoryImpl())
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
            CourseDetailInitial() ||
            CourseDetailInProgress() =>
              const Center(child: CircularProgressIndicator()),
            CourseDetailFailure(:final message) => _buildError(context, message),
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
            onPressed: () => context
                .read<CourseDetailBloc>()
                .add(const CourseDetailRefreshed()),
            child: const Text('Thu lai'),
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

    return CustomScrollView(
      slivers: [
        // Hero app bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary,
                    cs.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: cs.onPrimary.withValues(alpha: 0.5),
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
                  course?.title ?? 'Khoa hoc',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                AppSpacing.vGap8,
                if (course?.instructorName != null)
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: cs.outline),
                      AppSpacing.hGap4,
                      Text(
                        course!.instructorName!,
                        style: tt.bodyMedium?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: cs.outline),
                    AppSpacing.hGap4,
                    Text(
                      '${course?.totalDurationMins ?? 0} phut',
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                    ),
                    AppSpacing.hGap16,
                    Icon(Icons.menu_book, size: 16, color: cs.outline),
                    AppSpacing.hGap4,
                    Text(
                      '${course?.totalLessons ?? 0} bai hoc',
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                    ),
                  ],
                ),
                AppSpacing.vGap16,

                // Progress bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tien do hoc tap',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${enrollment.progressPercentage.toStringAsFixed(0)}%',
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
                          backgroundColor: cs.surfaceContainerHighest,
                          color: cs.primary,
                          minHeight: 8,
                        ),
                      ),
                      AppSpacing.vGap8,
                      Text(
                        '${enrollment.completedLessons}/${enrollment.totalLessons} bai da hoan thanh',
                        style: tt.bodySmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGap24,

                // Sections header
                Text(
                  'Noi dung khoa hoc',
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
                context
                    .read<CourseDetailBloc>()
                    .add(CourseDetailSectionToggled(sectionId));
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
