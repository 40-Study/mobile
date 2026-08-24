import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/presentation/learning/instructor_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/section/section_widgets.dart';
import 'package:study/features/student/presentation/learning/widgets/thumbnail_placeholder.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToLesson(
    BuildContext context,
    LessonModel lesson,
    List<LessonModel> allLessons,
  ) {
    final index = allLessons.indexWhere((l) => l.id == lesson.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
            CourseDetailInitial() || CourseDetailInProgress() =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            CourseDetailFailure(:final message) => _buildError(context, message),
            CourseDetailSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
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
                child: Icon(Icons.error_outline, color: cs.onErrorContainer),
              ),
              AppSpacing.vGap16,
              Text('Không thể tải khóa học', style: tt.titleMedium),
              AppSpacing.vGap4,
              Text(
                message,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap16,
              FilledButton.icon(
                onPressed: () => context
                    .read<CourseDetailBloc>()
                    .add(const CourseDetailRefreshed()),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // App bar
        SafeArea(
          bottom: false,
          child: _buildAppBar(context),
        ),

        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: _buildHeroSection(context, state)),
              SliverToBoxAdapter(child: _buildProgressCard(context, state)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(tabController: _tabController, cs: cs),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state),
                _buildContentTab(context, state),
                _buildInstructorTab(context, state),
                _buildReviewsTab(context, state),
              ],
            ),
          ),
        ),

        // Bottom bar
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _SoftIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _SoftIconButton(icon: Icons.bookmark_outline_rounded, onTap: () {}),
          AppSpacing.hGap8,
          _SoftIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;
    final enrollment = state.enrollment;
    final isActive = enrollment.status == 'active';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 140,
                  height: 100,
                  child: course?.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: course!.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => ThumbnailPlaceholder(cs: cs),
                          errorWidget: (_, _, _) => ThumbnailPlaceholder(cs: cs),
                        )
                      : ThumbnailPlaceholder(cs: cs),
                ),
              ),
              // Play button overlay
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 24),
              ),
            ],
          ),
          AppSpacing.hGap16,

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? cs.primary.withValues(alpha: 0.1)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    isActive ? 'Đang học' : 'Chưa bắt đầu',
                    style: tt.labelSmall?.copyWith(
                      color: isActive ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.vGap8,

                // Title
                Text(
                  course?.title ?? 'Khóa học',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap8,

                // Instructor
                Row(
                  children: [
                    CachedAvatar(
                      url: course?.instructorAvatar,
                      radius: 12,
                      backgroundColor: cs.primaryContainer,
                      name: course?.instructorName ?? 'T',
                    ),
                    AppSpacing.hGap8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course?.instructorName ?? 'Giảng viên',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap8,

                // Rating + students
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      course?.averageRating.toStringAsFixed(1) ?? '0.0',
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ' (${_formatCount(course?.totalRatings ?? 0)})',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${_formatCount(course?.totalStudents ?? 0)} học viên',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final enrollment = state.enrollment;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final nextLesson = _getNextLesson(state);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Progress info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Tiến độ học tập', style: tt.labelMedium),
                      const Spacer(),
                      Text(
                        '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
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
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    'Bạn đã hoàn thành ${enrollment.completedLessons} / ${enrollment.totalLessons} bài học',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap16,

            // Continue button
            FilledButton(
              onPressed: () {
                if (nextLesson != null) {
                  final allLessons = state.sections
                      .expand((s) => s.lessons ?? <LessonModel>[])
                      .toList();
                  _navigateToLesson(context, nextLesson, allLessons);
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 18),
                      SizedBox(width: 4),
                      Text('Tiếp tục học'),
                    ],
                  ),
                  if (nextLesson != null)
                    Text(
                      'Bài ${_getLessonIndex(state, nextLesson) + 1} • ${nextLesson.title}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Course description
        Text(
          'Giới thiệu khóa học',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.vGap8,
        Text(
          course?.description ?? course?.shortDescription ??
          'Khóa học giúp bạn nắm vững kiến thức và kỹ năng cần thiết.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        AppSpacing.vGap24,

        // Stats row
        Row(
          children: [
            _StatCard(
              icon: Icons.play_circle_outline,
              value: '${course?.totalLessons ?? 0}',
              label: 'Bài học',
            ),
            AppSpacing.hGap12,
            _StatCard(
              icon: Icons.access_time_rounded,
              value: _formatDuration(course?.totalDurationMins ?? 0),
              label: 'Thời lượng',
            ),
            AppSpacing.hGap12,
            _StatCard(
              icon: Icons.signal_cellular_alt_rounded,
              value: course?.level ?? 'Cơ bản',
              label: 'Cấp độ',
            ),
            AppSpacing.hGap12,
            const _StatCard(
              icon: Icons.workspace_premium_outlined,
              value: 'Có',
              label: 'Chứng chỉ',
            ),
          ],
        ),
        AppSpacing.vGap24,

        // Objectives
        if (course?.objectives != null && course!.objectives!.isNotEmpty) ...[
          Text(
            'Bạn sẽ học được',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.objectives!.map((obj) => _ObjectiveItem(text: obj)).toList(),
          ),
          AppSpacing.vGap24,
        ],

        // Course content preview
        Row(
          children: [
            Expanded(
              child: Text(
                'Nội dung khóa học',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
        Text(
          '${course?.totalLessons ?? 0} bài học',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        AppSpacing.vGap12,

        // Preview lessons
        ...state.sections
            .expand((s) => s.lessons ?? <LessonModel>[])
            .take(5)
            .toList()
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          return _LessonPreviewItem(
            index: index,
            lesson: lesson,
            onTap: () {
              final allLessons = state.sections
                  .expand((s) => s.lessons ?? <LessonModel>[])
                  .toList();
              _navigateToLesson(context, lesson, allLessons);
            },
          );
        }),

        AppSpacing.vGap32,
      ],
    );
  }

  Widget _buildContentTab(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final allLessons = state.sections
        .expand((s) => s.lessons ?? <LessonModel>[])
        .toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            Text(
              '${state.sections.length} buổi • ${state.course?.totalLessons ?? allLessons.length} bài học',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Expand all sections
                for (final section in state.sections) {
                  if (!state.expandedSections.contains(section.id)) {
                    context.read<CourseDetailBloc>().add(
                      CourseDetailSectionToggled(section.id),
                    );
                  }
                }
              },
              child: Text('Mở tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Sections (Buổi)
        ...state.sections.asMap().entries.map((entry) {
          final sectionIndex = entry.key;
          final section = entry.value;
          return SectionCard(
            sectionIndex: sectionIndex,
            section: section,
            isExpanded: state.expandedSections.contains(section.id),
            onToggle: () {
              context.read<CourseDetailBloc>().add(
                CourseDetailSectionToggled(section.id),
              );
            },
            onLessonTap: (lesson) => _navigateToLesson(context, lesson, allLessons),
          );
        }),

        AppSpacing.vGap32,
      ],
    );
  }

  Widget _buildInstructorTab(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InstructorDetailScreen(
                  instructorId: course?.instructorId ?? '',
                  instructorName: course?.instructorName ?? 'Giảng viên',
                  instructorAvatar: course?.instructorAvatar,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                CachedAvatar(
                  url: course?.instructorAvatar,
                  radius: 36,
                  backgroundColor: cs.primaryContainer,
                  name: course?.instructorName ?? 'T',
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course?.instructorName ?? 'Giảng viên',
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Giảng viên chuyên nghiệp',
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      AppSpacing.vGap4,
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('4.9', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text('• 12 khóa học • 15k học viên',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        AppSpacing.vGap24,

        const Row(
          children: [
            _InstructorStat(icon: Icons.menu_book_outlined, value: '12', label: 'Khóa học'),
            AppSpacing.hGap16,
            _InstructorStat(icon: Icons.star_rounded, value: '4.8', label: 'Đánh giá'),
            AppSpacing.hGap16,
            _InstructorStat(icon: Icons.people_outline, value: '15k', label: 'Học viên'),
          ],
        ),

        AppSpacing.vGap24,
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InstructorDetailScreen(
                  instructorId: course?.instructorId ?? '',
                  instructorName: course?.instructorName ?? 'Giảng viên',
                  instructorAvatar: course?.instructorAvatar,
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: const Text('Xem trang giảng viên'),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            Text(
              course?.averageRating.toStringAsFixed(1) ?? '0.0',
              style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.hGap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < (course?.averageRating.round() ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    )),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    '${_formatCount(course?.totalRatings ?? 0)} đánh giá',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap32,
        Center(
          child: Text(
            'Chưa có đánh giá nào.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          // Favorite button
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite_outline_rounded, color: cs.onSurfaceVariant),
            ),
          ),
          AppSpacing.hGap12,

          // Download materials button
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('Tải tài liệu khóa học'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  LessonModel? _getNextLesson(CourseDetailSuccess state) {
    for (final section in state.sections) {
      for (final lesson in section.lessons ?? <LessonModel>[]) {
        if (lesson.progress == null || lesson.progress!.status != 'completed') {
          return lesson;
        }
      }
    }
    return null;
  }

  int _getLessonIndex(CourseDetailSuccess state, LessonModel lesson) {
    final allLessons = state.sections
        .expand((s) => s.lessons ?? <LessonModel>[])
        .toList();
    return allLessons.indexWhere((l) => l.id == lesson.id);
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  String _formatDuration(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }
}

// =============================================================================
// Components
// =============================================================================

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: cs.onSurfaceVariant, size: 22),
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            AppSpacing.vGap4,
            Text(
              value,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveItem extends StatelessWidget {
  const _ObjectiveItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - 8) / 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: cs.primary, size: 18),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonPreviewItem extends StatelessWidget {
  const _LessonPreviewItem({
    required this.index,
    required this.lesson,
    required this.onTap,
  });

  final int index;
  final LessonModel lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = lesson.progress?.status == 'completed';
    final isInProgress = lesson.progress?.status == 'in_progress';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isInProgress
                ? cs.primary.withValues(alpha: 0.05)
                : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isInProgress
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Status icon
              LessonStatusIcon(isCompleted: isCompleted, isInProgress: isInProgress),
              AppSpacing.hGap12,

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${lesson.title}',
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${lesson.durationMinutes}:00',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // Status label
              if (isCompleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hoàn thành',
                      style: tt.labelSmall?.copyWith(color: cs.primary),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: cs.primary),
                  ],
                )
              else if (isInProgress)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đang học',
                      style: tt.labelSmall?.copyWith(color: cs.primary),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: cs.primary),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chưa mở khóa',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructorStat extends StatelessWidget {
  const _InstructorStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            AppSpacing.vGap4,
            Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabController, required this.cs});
  final TabController tabController;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: cs.surface,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorWeight: 2,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Nội dung khóa học'),
          Tab(text: 'Giảng viên'),
          Tab(text: 'Đánh giá'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
