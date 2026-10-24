import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/course_card.dart';
import 'package:study/theme/theme.dart';

enum CourseStatusFilter { all, inProgress, completed }

enum CourseSortOption { recent, progressHigh, titleAZ }

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  CourseStatusFilter _statusFilter = CourseStatusFilter.all;
  CourseSortOption _sortOption = CourseSortOption.recent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCourse(BuildContext context, String enrollmentId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              diContainer<CourseDetailBloc>()
                ..add(CourseDetailStarted(enrollmentId, isEnrollment: true)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  List<EnrollmentModel> _filterAndSort(List<EnrollmentModel> list) {
    var result = list;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        final title = (e.course?.title ?? '').toLowerCase();
        final instructor = (e.course?.instructorName ?? '').toLowerCase();
        final category = (e.course?.categoryName ?? '').toLowerCase();
        return title.contains(q) ||
            instructor.contains(q) ||
            category.contains(q);
      }).toList();
    }

    // Status filter
    switch (_statusFilter) {
      case CourseStatusFilter.all:
        break;
      case CourseStatusFilter.inProgress:
        result = result.where((e) => e.progressPercentage < 100).toList();
        break;
      case CourseStatusFilter.completed:
        result = result.where((e) => e.progressPercentage >= 100).toList();
        break;
    }

    // Sort
    switch (_sortOption) {
      case CourseSortOption.recent:
        // Default backend order
        break;
      case CourseSortOption.progressHigh:
        result.sort(
          (a, b) => b.progressPercentage.compareTo(a.progressPercentage),
        );
        break;
      case CourseSortOption.titleAZ:
        result.sort(
          (a, b) => (a.course?.title ?? '').compareTo(b.course?.title ?? ''),
        );
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Khóa học của tôi'), centerTitle: true),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state is LearningInProgress) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state is LearningFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: cs.error,
                    ),
                    AppSpacing.vGap16,
                    Text(state.message, style: tt.bodyMedium),
                    AppSpacing.vGap16,
                    FilledButton(
                      onPressed: () => context.read<LearningBloc>().add(
                        const LearningRefreshed(),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allEnrollments = switch (state) {
            LearningSuccess(:final enrollments) => enrollments,
            _ => <EnrollmentModel>[],
          };

          if (allEnrollments.isEmpty) {
            return _buildZeroEnrollmentState(context, cs, tt);
          }

          final inProgressCount = allEnrollments
              .where((e) => e.progressPercentage < 100)
              .length;
          final completedCount = allEnrollments
              .where((e) => e.progressPercentage >= 100)
              .length;
          final avgProgress = allEnrollments.isEmpty
              ? 0.0
              : allEnrollments.fold<double>(
                      0.0,
                      (sum, e) => sum + e.progressPercentage,
                    ) /
                    allEnrollments.length;

          final displayed = _filterAndSort(allEnrollments);

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<LearningBloc>().add(const LearningRefreshed()),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Progress Overview Card
                        _buildOverviewCard(
                          cs,
                          tt,
                          total: allEnrollments.length,
                          inProgress: inProgressCount,
                          completed: completedCount,
                          avgProgress: avgProgress,
                        ),
                        AppSpacing.vGap16,

                        // Search field
                        _buildSearchBar(cs, tt),
                        AppSpacing.vGap12,

                        // Filter & Sort bar
                        _buildFilterChips(
                          cs,
                          total: allEnrollments.length,
                          inProgress: inProgressCount,
                          completed: completedCount,
                        ),
                        AppSpacing.vGap16,

                        // Courses count & sort label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${displayed.length} khóa học',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PopupMenuButton<CourseSortOption>(
                              initialValue: _sortOption,
                              onSelected: (opt) =>
                                  setState(() => _sortOption = opt),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort_rounded,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    switch (_sortOption) {
                                      CourseSortOption.recent =>
                                        'Mới học gần đây',
                                      CourseSortOption.progressHigh =>
                                        'Tiến độ cao nhất',
                                      CourseSortOption.titleAZ => 'Tên A - Z',
                                    },
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: cs.primary,
                                  ),
                                ],
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: CourseSortOption.recent,
                                  child: Text('Mới học gần đây'),
                                ),
                                const PopupMenuItem(
                                  value: CourseSortOption.progressHigh,
                                  child: Text('Tiến độ cao nhất'),
                                ),
                                const PopupMenuItem(
                                  value: CourseSortOption.titleAZ,
                                  child: Text('Tên A - Z'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.vGap12,
                      ],
                    ),
                  ),
                ),
                if (displayed.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      32,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildEmptyFilterState(cs, tt),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      32,
                    ),
                    sliver: SliverList.separated(
                      itemCount: displayed.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final enrollment = displayed[index];
                        return CourseCard(
                          enrollment: enrollment,
                          onTap: () =>
                              _navigateToCourse(context, enrollment.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    ColorScheme cs,
    TextTheme tt, {
    required int total,
    required int inProgress,
    required int completed,
    required double avgProgress,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, const Color(0xFF2B4491)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              AppSpacing.hGap8,
              Text(
                'TIẾN TRÌNH HỌC TẬP TỔNG QUAN',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${avgProgress.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (avgProgress / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          AppSpacing.vGap16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                label: 'Tổng số',
                value: '$total',
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatChip(
                label: 'Đang học',
                value: '$inProgress',
                color: const Color(0xFF93C5FD),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatChip(
                label: 'Đã hoàn thành',
                value: '$completed',
                color: const Color(0xFF86EFAC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs, TextTheme tt) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: tt.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên khóa học hoặc giảng viên...',
          hintStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
      ),
    );
  }

  Widget _buildFilterChips(
    ColorScheme cs, {
    required int total,
    required int inProgress,
    required int completed,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tất cả ($total)', CourseStatusFilter.all, cs),
          AppSpacing.hGap8,
          _buildFilterChip(
            'Đang học ($inProgress)',
            CourseStatusFilter.inProgress,
            cs,
          ),
          AppSpacing.hGap8,
          _buildFilterChip(
            'Đã hoàn thành ($completed)',
            CourseStatusFilter.completed,
            cs,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    CourseStatusFilter filter,
    ColorScheme cs,
  ) {
    final isSelected = _statusFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = filter),
      selectedColor: cs.primary,
      backgroundColor: cs.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected ? cs.onPrimary : cs.onSurface,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildEmptyFilterState(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          AppSpacing.vGap12,
          Text(
            'Không tìm thấy khóa học phù hợp',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          AppSpacing.vGap4,
          Text(
            'Hãy thử thay đổi từ khóa hoặc bộ lọc trạng thái.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildZeroEnrollmentState(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_outlined, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Chưa có khóa học nào',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.vGap8,
            Text(
              'Bạn chưa đăng ký khóa học nào. Hãy khám phá thư viện khóa học '
              'để bắt đầu hành trình học tập!',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap24,
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Khám phá khóa học'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
