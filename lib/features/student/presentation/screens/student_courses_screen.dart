import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/student_courses/student_courses_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/widgets/courses/courses_widgets.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentCoursesCubit>().loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
          builder: (context, state) {
            return switch (state) {
              StudentCoursesInitial() ||
              StudentCoursesLoading() =>
                const Center(child: CircularProgressIndicator()),
              StudentCoursesLoaded() => RefreshIndicator(
                  onRefresh: context.read<StudentCoursesCubit>().refresh,
                  child: _CoursesBody(state: state),
                ),
              StudentCoursesFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: AppIconSize.hero, color: cs.error),
                      SizedBox(height: AppSpacing.lg),
                      Text(message),
                      SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () =>
                            context.read<StudentCoursesCubit>().loadCourses(),
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _CoursesBody extends StatelessWidget {
  const _CoursesBody({required this.state});

  final StudentCoursesLoaded state;

  int get _activeCount =>
      state.enrollments.where((e) => e.isActive).length;

  int get _completedCount =>
      state.enrollments.where((e) => e.isCompleted).length;

  int get _pendingCount =>
      state.enrollments.where((e) => e.isPending).length;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xl,
              AppLayout.screenMargin,
              AppSpacing.sm,
            ),
            child: CoursesHeader(
              activeCount: _activeCount,
              completedCount: _completedCount,
              pendingCount: _pendingCount,
              selectedFilter: state.selectedFilter,
              onFilterChanged: (filter) =>
                  context.read<StudentCoursesCubit>().changeFilter(filter),
            ),
          ),
        ),
        if (state.enrollments.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: CoursesEmptyState(),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.sm,
              AppLayout.screenMargin,
              AppSpacing.xxxl,
            ),
            sliver: SliverList.separated(
              itemCount:
                  state.enrollments.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                if (index >= state.enrollments.length) {
                  context.read<StudentCoursesCubit>().loadMore();
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return CourseCard(
                  enrollment: state.enrollments[index],
                  index: index,
                );
              },
            ),
          ),
      ],
    );
  }
}
