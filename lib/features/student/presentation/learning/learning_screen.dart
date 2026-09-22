import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/all_courses_screen.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/explore_courses_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/widgets.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';
import 'package:study/widgets/section_header.dart';
import 'package:study/widgets/tab_screen_header.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(const LearningStarted());
  }

  void _navigateToCourseDetail(String enrollmentId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => CourseDetailBloc(diContainer<StudentRepository>())
            ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LearningBloc, LearningState>(
          builder: (context, state) {
            return switch (state) {
              LearningInitial() || LearningInProgress() =>
                _buildLoading(context),
              LearningFailure(:final message) => _buildError(context, message),
              LearningSuccess() => _buildContent(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Header skeleton
        Container(
          height: 40,
          width: 150,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        AppSpacing.vGap8,
        Container(
          height: 20,
          width: 200,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
        AppSpacing.vGap24,
        // Continue learning skeleton
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        AppSpacing.vGap24,
        // My courses skeleton
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => AppSpacing.hGap12,
            itemBuilder: (_, _) => Container(
              width: 160,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              'Không thể tải nội dung học tập',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () =>
                  context.read<LearningBloc>().add(const LearningStarted()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LearningSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (state.enrollments.isEmpty) {
      return _buildEmptyState(context);
    }

    final continueLearning = _getContinueLearning(state);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LearningBloc>().add(const LearningRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(
            child: TabScreenHeader(
              title: 'Learning',
              subtitle: 'Mỗi ngày một bước tiến.',
            ),
          ),

          // Continue Learning
          if (continueLearning != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: ContinueLearningCard(
                  enrollment: continueLearning,
                  onContinue: () => _navigateToCourseDetail(continueLearning.id),
                ),
              ),
            ),
          ],

          // My Courses
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xl,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: SectionHeader(
                title: 'Khóa học của tôi',
                actionLabel: 'Xem tất cả',
                onActionTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllCoursesScreen()),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: Builder(builder: (context) {
                // Sort: in-progress first, completed last
                final sorted = List.of(state.enrollments)
                  ..sort((a, b) {
                    final aCompleted = a.progressPercentage >= 100;
                    final bCompleted = b.progressPercentage >= 100;
                    if (aCompleted != bCompleted) {
                      return aCompleted ? 1 : -1;
                    }
                    return 0;
                  });
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => AppSpacing.hGap12,
                  itemBuilder: (context, index) {
                    final enrollment = sorted[index];
                    return MyCourseCard(
                      enrollment: enrollment,
                      onTap: () => _navigateToCourseDetail(enrollment.id),
                    );
                  },
                );
              }),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: FilterChipsRow(
                selectedFilter: state.filter,
                onFilterChanged: (filter) {
                  context
                      .read<LearningBloc>()
                      .add(LearningFilterChanged(filter));
                },
              ),
            ),
          ),

          // Recent Learning
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHeader(title: 'Gần đây'),
            ),
          ),
          const SliverToBoxAdapter(child: AppSpacing.vGap8),

          if (state.filteredEnrollments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: EmptyState(
                  style: EmptyStateStyle.compactCard,
                  icon: Icons.school_outlined,
                  message: _emptyFilterMessage(state.filter),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final enrollment = state.filteredEnrollments[index];
                    return RecentLearningItem(
                      enrollment: enrollment,
                      onTap: () => _navigateToCourseDetail(enrollment.id),
                    );
                  },
                  childCount: state.filteredEnrollments.length.clamp(0, 5),
                ),
              ),
            ),

          // Recommendations
          if (state.recommendedCourses.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: SectionHeader(
                  title: 'Gợi ý cho bạn',
                  actionLabel: 'Xem tất cả',
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExploreCoursesScreen()),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.recommendedCourses.length > 6
                      ? 6
                      : state.recommendedCourses.length,
                  separatorBuilder: (_, __) => AppSpacing.hGap12,
                  itemBuilder: (context, index) {
                    return RecommendationCard(
                      course: state.recommendedCourses[index],
                    );
                  },
                ),
              ),
            ),
          ],

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: EmptyState(
          style: EmptyStateStyle.fullPage,
          icon: Icons.school_outlined,
          title: 'Bạn chưa tham gia khóa học nào',
          message: 'Khám phá các khóa học phù hợp với bạn.',
          actionLabel: 'Khám phá khóa học',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllCoursesScreen()),
          ),
        ),
      ),
    );
  }

  EnrollmentModel? _getContinueLearning(LearningSuccess state) {
    final inProgress = state.enrollments.where(
      (e) => e.status == 'active' && e.progressPercentage < 100,
    );
    if (inProgress.isEmpty) return null;

    return inProgress.reduce((a, b) {
      final aTime = a.lastAccessedAt ?? DateTime(1970);
      final bTime = b.lastAccessedAt ?? DateTime(1970);
      return aTime.isAfter(bTime) ? a : b;
    });
  }

  String _emptyFilterMessage(EnrollmentFilter filter) {
    return switch (filter) {
      EnrollmentFilter.all => 'Không có khóa học nào.',
      EnrollmentFilter.inProgress => 'Không có khóa học nào đang học.',
      EnrollmentFilter.completed => 'Bạn chưa hoàn thành khóa học nào.',
      EnrollmentFilter.upcoming => 'Không có khóa học nào sắp tới.',
    };
  }
}
