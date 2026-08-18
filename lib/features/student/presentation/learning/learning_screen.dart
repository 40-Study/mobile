import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/presentation/search/search_screen.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';
import 'package:study/widgets/section_header.dart';

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
          create: (_) => CourseDetailBloc(StudentRepositoryImpl())
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
            separatorBuilder: (_, __) => AppSpacing.hGap12,
            itemBuilder: (_, __) => Container(
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Learning',
                              style: tt.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mỗi ngày một bước tiến.',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const SearchScreen(),
                            ),
                          ),
                          icon: Icon(
                            Icons.search_rounded,
                            color: cs.onSurfaceVariant,
                            size: 22,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 42,
                          ),
                        ),
                      ),
                      AppSpacing.hGap8,
                      // Notification
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              ),
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: cs.onSurfaceVariant,
                                size: 22,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 42,
                                minHeight: 42,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cs.surfaceContainerLowest,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
                child: _ContinueLearningCard(
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
                onActionTap: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: state.enrollments.length,
                separatorBuilder: (_, __) => AppSpacing.hGap12,
                itemBuilder: (context, index) {
                  final enrollment = state.enrollments[index];
                  return _MyCourseCard(
                    enrollment: enrollment,
                    onTap: () => _navigateToCourseDetail(enrollment.id),
                  );
                },
              ),
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
              child: _FilterChipsRow(
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
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
                    return _RecentLearningItem(
                      enrollment: enrollment,
                      onTap: () => _navigateToCourseDetail(enrollment.id),
                    );
                  },
                  childCount: state.filteredEnrollments.length.clamp(0, 5),
                ),
              ),
            ),

          // Recommendations
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
                onActionTap: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => AppSpacing.hGap12,
                itemBuilder: (context, index) {
                  return _RecommendationCard(index: index);
                },
              ),
            ),
          ),

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
          onAction: () {},
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

// ============================================================================
// Continue Learning Card
// ============================================================================

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.enrollment,
    required this.onContinue,
  });

  final EnrollmentModel enrollment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Tiếp tục học',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đang học',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Card
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.soft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: 120,
                    height: 140,
                    child: course?.thumbnailUrl != null
                        ? Image.network(
                            course!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ThumbnailPlaceholder(cs: cs),
                          )
                        : _ThumbnailPlaceholder(cs: cs),
                  ),
                ),
                AppSpacing.hGap16,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        course?.categoryName ?? 'Khóa học',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        course?.title ?? 'Khóa học',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Lesson info
                      Text(
                        'Bài ${enrollment.completedLessons + 1} · '
                        '${course?.totalDurationMins ?? 0} phút',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vGap12,

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: cs.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          AppSpacing.hGap12,
                          Text(
                            '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap12,

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FilledButton.icon(
                                onPressed: onContinue,
                                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                label: const Text('Tiếp tục học'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hGap8,
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: cs.onSurfaceVariant,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.primaryContainer,
      child: Icon(
        Icons.auto_stories_outlined,
        color: cs.onPrimaryContainer,
        size: 32,
      ),
    );
  }
}

// ============================================================================
// My Course Card
// ============================================================================

class _MyCourseCard extends StatelessWidget {
  const _MyCourseCard({
    required this.enrollment,
    required this.onTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 160,
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with progress badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: course?.thumbnailUrl != null
                          ? Image.network(
                              course!.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: cs.primaryContainer,
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            )
                          : Container(
                              color: cs.primaryContainer,
                              child: Icon(
                                Icons.auto_stories_outlined,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                  // Progress badge
                  Positioned(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course?.title ?? 'Khóa học',
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap4,

                    // Instructor
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            (course?.instructorName ?? 'T')[0].toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        AppSpacing.hGap4,
                        Expanded(
                          child: Text(
                            course?.instructorName ?? 'Giảng viên',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap8,

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        AppSpacing.hGap8,
                        Text(
                          '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
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

// ============================================================================
// Filter Chips
// ============================================================================

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final EnrollmentFilter selectedFilter;
  final ValueChanged<EnrollmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: selectedFilter == EnrollmentFilter.all,
            onTap: () => onFilterChanged(EnrollmentFilter.all),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Đang học',
            isSelected: selectedFilter == EnrollmentFilter.inProgress,
            onTap: () => onFilterChanged(EnrollmentFilter.inProgress),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Chưa bắt đầu',
            isSelected: selectedFilter == EnrollmentFilter.upcoming,
            onTap: () => onFilterChanged(EnrollmentFilter.upcoming),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Đã hoàn thành',
            isSelected: selectedFilter == EnrollmentFilter.completed,
            onTap: () => onFilterChanged(EnrollmentFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isSelected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 10,
            ),
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Recent Learning Item
// ============================================================================

class _RecentLearningItem extends StatelessWidget {
  const _RecentLearningItem({
    required this.enrollment,
    required this.onTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final isCompleted =
        enrollment.progressPercentage >= 100 || enrollment.completedAt != null;

    // Determine content type icon
    final (icon, _) = _getContentType(enrollment);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(icon, color: cs.primary, size: 20),
                ),
                AppSpacing.hGap12,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course?.title ?? 'Khóa học',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course?.categoryName ?? "Khóa học"} · Video',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,

                // Status/time
                if (isCompleted)
                  Text(
                    'Đã hoàn thành',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    '${enrollment.completedLessons}/${enrollment.totalLessons}',
                    style: tt.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                AppSpacing.hGap8,

                // Action
                if (isCompleted)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: cs.primary,
                      size: 18,
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                  ),

                AppSpacing.hGap4,

                // More options
                Icon(
                  Icons.more_vert_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getContentType(EnrollmentModel enrollment) {
    final cs = WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);

    // Default video type - can be extended based on actual data
    return (Icons.play_circle_outline_rounded, cs);
  }
}

// ============================================================================
// Recommendation Card
// ============================================================================

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 160,
        height: 120,
        child: Container(
          color: cs.surfaceContainerLow,
          child: Center(
            child: Icon(
              Icons.auto_stories_outlined,
              color: cs.onSurfaceVariant,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
