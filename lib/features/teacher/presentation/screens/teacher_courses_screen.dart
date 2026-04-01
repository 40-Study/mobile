import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/classes/teacher_class_detail_cubit.dart';
import 'package:study/features/teacher/bloc/classes/teacher_classes_cubit.dart';
import 'package:study/features/teacher/bloc/courses/teacher_course_detail_cubit.dart';
import 'package:study/features/teacher/bloc/courses/teacher_courses_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';
import 'package:study/features/teacher/presentation/screens/create_course_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_class_detail_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_course_detail_screen.dart';
import 'package:study/features/weather/presentation/widgets/weather_content_overlay.dart';
import 'package:study/theme/app_colors.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  int _selectedTab = 0; // 0 = Khóa học, 1 = Lớp học

  @override
  void initState() {
    super.initState();
    context.read<TeacherCoursesCubit>().loadCourses();
    context.read<TeacherClassesCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _selectedTab == 0
            ? _buildCoursesTab(context)
            : _buildClassesTab(context),
      ),
      floatingActionButton: _selectedTab == 0 ? _buildFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCoursesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildTitle(context),
        _buildTabSwitcher(context),
        const SizedBox(height: AppSpacing.md),
        _buildFilterChips(context),
        const SizedBox(height: AppSpacing.xs),
        _buildSortRow(context),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: _buildCoursesList(context)),
      ],
    );
  }

  Widget _buildClassesTab(BuildContext context) {
    return BlocBuilder<TeacherClassesCubit, TeacherClassesState>(
      builder: (context, state) {
        return switch (state) {
          TeacherClassesInitial() ||
          TeacherClassesLoading() =>
            const Center(child: CircularProgressIndicator()),
          TeacherClassesLoaded() => RefreshIndicator(
              onRefresh: context.read<TeacherClassesCubit>().refresh,
              child: _ClassesTabContent(
                state: state,
                onTabChanged: () => setState(() => _selectedTab = 0),
                selectedTab: _selectedTab,
                onSelectTab: (tab) => setState(() => _selectedTab = tab),
              ),
            ),
          TeacherClassesFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<TeacherClassesCubit>().loadClasses(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
        };
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textColor = context.weatherTextColor;
    final secondaryColor = context.weatherTextColorSecondary;
    final iconBgColor = context.weatherIconBackgroundColor;

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Quản lý Giáo dục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBgColor,
            child: Icon(Icons.person, color: secondaryColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final textColor = context.weatherTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Text(
        'Khóa học của tôi',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
      ),
    );
  }

  Widget _buildTabSwitcher(BuildContext context) {
    final isDark = context.isWeatherBackgroundDark;

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabButton(
              label: 'Khóa học',
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            _TabButton(
              label: 'Lớp học',
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.isWeatherBackgroundDark;

    return SizedBox(
      height: 40,
      child: BlocSelector<TeacherCoursesCubit, TeacherCoursesState,
          CourseFilter>(
        selector: (state) => state.selectedFilter,
        builder: (context, selectedFilter) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenMargin,
            ),
            itemCount: CourseFilter.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final filter = CourseFilter.values[index];
              final isSelected = filter == selectedFilter;

              return GestureDetector(
                onTap: () =>
                    context.read<TeacherCoursesCubit>().changeFilter(filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : cs.outlineVariant,
                          ),
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected
                          ? cs.onPrimary
                          : isDark
                              ? Colors.white
                              : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSortRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.isWeatherBackgroundDark;
    final textColor = context.weatherTextColorSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Sắp xếp:',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          BlocSelector<TeacherCoursesCubit, TeacherCoursesState, CourseSortBy>(
            selector: (state) => state.sortBy,
            builder: (context, sortBy) {
              return PopupMenuButton<CourseSortBy>(
                initialValue: sortBy,
                onSelected: context.read<TeacherCoursesCubit>().changeSortBy,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sortBy.label,
                        style: TextStyle(
                          color: isDark ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => CourseSortBy.values
                    .map((sort) => PopupMenuItem(
                          value: sort,
                          child: Row(
                            children: [
                              if (sort == sortBy)
                                Icon(Icons.check, size: 18, color: cs.primary)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(sort.label),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context) {
    return BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
      builder: (context, state) {
        return switch (state) {
          TeacherCoursesInitial() ||
          TeacherCoursesLoading() =>
            const Center(child: CircularProgressIndicator()),
          TeacherCoursesLoaded(:final courses) => courses.isEmpty
              ? _EmptyState(filter: state.selectedFilter)
              : RefreshIndicator(
                  onRefresh: context.read<TeacherCoursesCubit>().refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.screenMargin,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _CourseCard(course: courses[index]),
                    ),
                  ),
                ),
          TeacherCoursesFailure(:final message) => _ErrorState(
              message: message,
              onRetry: context.read<TeacherCoursesCubit>().loadCourses,
            ),
        };
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CreateCourseScreen(),
          ),
        );
      },
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      child: const Icon(Icons.add),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
    final isDark = context.isWeatherBackgroundDark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? cs.onPrimary
                : isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseModel course;

  void _navigateToCourseDetail(BuildContext context) {
    final repository = context.read<TeacherRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TeacherCourseDetailCubit(
            repository: repository,
            courseId: course.id,
          ),
          child: TeacherCourseDetailScreen(
            courseId: course.id,
            courseTitle: course.displayTitle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _navigateToCourseDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: cs.shadowCard,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with status badge
          _buildThumbnail(context, cs),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  course.displayTitle,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                // Stats row
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.video_library_outlined,
                      value: '${course.classCount} Lớp học',
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    _StatItem(
                      icon: Icons.people_outline,
                      value: '${course.studentCount} Học viên',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Progress bar
                _buildProgressBar(context, cs),
                const SizedBox(height: AppSpacing.sm),
                // Status and price row
                _buildStatusPriceRow(context, cs, tt),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, ColorScheme cs) {
    return Stack(
      children: [
        // Thumbnail image
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            image: course.displayThumbnail != null
                ? DecorationImage(
                    image: NetworkImage(course.displayThumbnail!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: course.displayThumbnail == null
              ? Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: cs.primary.withValues(alpha: 0.5),
                  ),
                )
              : null,
        ),
        // Status badge
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: _StatusBadge(
            status: course.status,
            isOnSale: course.isOnSale,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, ColorScheme cs) {
    final progress = course.progressPercent / 100.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress >= 1.0 ? cs.primary : cs.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildStatusPriceRow(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final statusText = _getProgressStatusText();
    final statusColor = _getProgressStatusColor(cs);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          statusText,
          style: tt.labelMedium?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        if (course.price > 0)
          Text(
            _formatPrice(course.price),
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          )
        else
          Text(
            '--',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  String _getProgressStatusText() {
    if (course.progressPercent >= 100) {
      return 'HOÀN TẤT 100%';
    } else if (course.progressPercent > 0) {
      return 'HOÀN TẤT ${course.progressPercent}%';
    } else {
      return 'ĐANG BIÊN SOẠN';
    }
  }

  Color _getProgressStatusColor(ColorScheme cs) {
    if (course.progressPercent >= 100) {
      return cs.primary;
    } else if (course.progressPercent > 0) {
      return cs.primary;
    } else {
      return cs.onSurfaceVariant;
    }
  }

  String _formatPrice(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(0)}M';
    }
    return '\$${NumberFormat('#,##0.00', 'en_US').format(amount)}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isOnSale,
  });

  final String status;
  final bool isOnSale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (label, bgColor, textColor) = _getStatusStyle(cs);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, Color) _getStatusStyle(ColorScheme cs) {
    if (isOnSale || status.toLowerCase() == 'on_sale') {
      return ('Đang bán', cs.primary, cs.onPrimary);
    }

    return switch (status.toLowerCase()) {
      'published' || 'active' => ('Xuất bản', Colors.green, Colors.white),
      'draft' => ('Bản nháp', cs.surfaceContainerHighest, cs.onSurface),
      'archived' => ('Lưu trữ', cs.surfaceContainerHighest, cs.onSurfaceVariant),
      _ => ('Bản nháp', cs.surfaceContainerHighest, cs.onSurface),
    };
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final CourseFilter filter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final message = switch (filter) {
      CourseFilter.all => 'Chưa có khóa học nào',
      CourseFilter.published => 'Chưa có khóa học xuất bản',
      CourseFilter.onSale => 'Chưa có khóa học đang bán',
      CourseFilter.draft => 'Không có bản nháp',
      CourseFilter.archived => 'Không có khóa học lưu trữ',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: AppSpacing.lg),
          Text(message),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CLASSES TAB CONTENT
// =============================================================================

class _ClassesTabContent extends StatelessWidget {
  const _ClassesTabContent({
    required this.state,
    required this.onTabChanged,
    required this.selectedTab,
    required this.onSelectTab,
  });

  final TeacherClassesLoaded state;
  final VoidCallback onTabChanged;
  final int selectedTab;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final textColor = context.weatherTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _ClassesHeader(textColor: textColor),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Text(
            'Lớp học của tôi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
          ),
        ),

        // Tab switcher
        _ClassesTabSwitcher(
          selectedTab: selectedTab,
          onSelectTab: onSelectTab,
        ),
        const SizedBox(height: AppSpacing.md),

        // Filter chips
        const _ClassesFilterChips(),
        const SizedBox(height: AppSpacing.xs),

        // Sort row
        const _ClassesSortRow(),
        const SizedBox(height: AppSpacing.sm),

        // Classes list
        Expanded(child: _ClassesList(classes: state.classes)),
      ],
    );
  }
}

class _ClassesFilterChips extends StatelessWidget {
  const _ClassesFilterChips();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.isWeatherBackgroundDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course filter dropdown + Day filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: BlocBuilder<TeacherClassesCubit, TeacherClassesState>(
            builder: (context, state) {
              final availableCourses = state.availableCourses;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  // Course filter dropdown
                  _FilterDropdown<String?>(
                    value: state.courseFilter,
                    icon: Icons.school_outlined,
                    hint: 'Khóa học',
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tất cả khóa học'),
                      ),
                      ...availableCourses.map((course) => DropdownMenuItem<String?>(
                            value: course,
                            child: Text(
                              course,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (value) =>
                        context.read<TeacherClassesCubit>().changeCourseFilter(value),
                    isDark: isDark,
                    cs: cs,
                  ),
                  // Day filter dropdown
                  _FilterDropdown<DayFilter>(
                    value: state.dayFilter,
                    icon: Icons.calendar_today_outlined,
                    hint: 'Ngày học',
                    items: DayFilter.values
                        .map((day) => DropdownMenuItem<DayFilter>(
                              value: day,
                              child: Text(day.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<TeacherClassesCubit>().changeDayFilter(value);
                      }
                    },
                    isDark: isDark,
                    cs: cs,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Status filter chips
        SizedBox(
          height: 40,
          child: BlocSelector<TeacherClassesCubit, TeacherClassesState,
              ClassStatusFilter>(
            selector: (state) => state.statusFilter,
            builder: (context, statusFilter) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenMargin,
                ),
                itemCount: ClassStatusFilter.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final filter = ClassStatusFilter.values[index];
                  final isSelected = filter == statusFilter;

                  return GestureDetector(
                    onTap: () => context
                        .read<TeacherClassesCubit>()
                        .changeStatusFilter(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : cs.outlineVariant,
                              ),
                      ),
                      child: Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected
                              ? cs.onPrimary
                              : isDark
                                  ? Colors.white
                                  : cs.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.icon,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.isDark,
    required this.cs,
  });

  final T value;
  final IconData icon;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : cs.outlineVariant,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white : cs.onSurface,
          ),
          items: items,
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? Colors.white : cs.onSurface,
            fontSize: 13,
          ),
          dropdownColor: cs.surface,
        ),
      ),
    );
  }
}

class _ClassesSortRow extends StatelessWidget {
  const _ClassesSortRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.isWeatherBackgroundDark;
    final textColor = context.weatherTextColorSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Sắp xếp:',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          BlocSelector<TeacherClassesCubit, TeacherClassesState, ClassSortBy>(
            selector: (state) => state.sortBy,
            builder: (context, sortBy) {
              return PopupMenuButton<ClassSortBy>(
                initialValue: sortBy,
                onSelected: context.read<TeacherClassesCubit>().changeSortBy,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sortBy.label,
                        style: TextStyle(
                          color: isDark ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => ClassSortBy.values
                    .map((sort) => PopupMenuItem(
                          value: sort,
                          child: Row(
                            children: [
                              if (sort == sortBy)
                                Icon(Icons.check, size: 18, color: cs.primary)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(sort.label),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ClassesList extends StatelessWidget {
  const _ClassesList({required this.classes});

  final List<ClassModel> classes;

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const _ClassesEmptyState();
    }

    return RefreshIndicator(
      onRefresh: context.read<TeacherClassesCubit>().refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenMargin,
          vertical: AppSpacing.sm,
        ),
        itemCount: classes.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _ClassCard(classModel: classes[index]),
        ),
      ),
    );
  }
}

class _ClassesEmptyState extends StatelessWidget {
  const _ClassesEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chưa có lớp học nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classModel});

  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: cs.shadowCard,
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => TeacherClassDetailCubit(
                repository: context.read<TeacherRepository>(),
              ),
              child: TeacherClassDetailScreen(classId: classModel.id),
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      classModel.isOnline
                          ? Icons.videocam_outlined
                          : Icons.school_outlined,
                      color: cs.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.displayName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (classModel.courseName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            classModel.courseName!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _ClassStatusBadge(status: classModel.classStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats row
              Row(
                children: [
                  _ClassInfoChip(
                    icon: Icons.people_outline,
                    label: '${classModel.studentCount}/${classModel.maxStudents} Học viên',
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  if (classModel.nextScheduleTime != null)
                    _ClassInfoChip(
                      icon: Icons.schedule,
                      label: classModel.nextScheduleTime!,
                    ),
                ],
              ),

              // Progress bar
              if (classModel.maxStudents > 0) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: classModel.fillPercentage / 100,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      classModel.isFull ? cs.error : cs.primary,
                    ),
                  ),
                ),
              ],

              // Location
              if (classModel.nextScheduleRoom != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      classModel.nextScheduleRoom!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassStatusBadge extends StatelessWidget {
  const _ClassStatusBadge({required this.status});

  final ClassStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (label, bgColor, textColor) = switch (status) {
      ClassStatus.active => ('Đang học', Colors.green.withValues(alpha: 0.1), Colors.green),
      ClassStatus.completed => ('Hoàn thành', cs.primary.withValues(alpha: 0.1), cs.primary),
      ClassStatus.inactive => ('Tạm dừng', cs.secondary.withValues(alpha: 0.1), cs.secondary),
      ClassStatus.cancelled => ('Đã hủy', cs.error.withValues(alpha: 0.1), cs.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ClassInfoChip extends StatelessWidget {
  const _ClassInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ClassesHeader extends StatelessWidget {
  const _ClassesHeader({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final iconBgColor = context.weatherIconBackgroundColor;
    final secondaryColor = context.weatherTextColorSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: iconBgColor,
            child: Icon(Icons.person, color: secondaryColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Quản lý Giáo dục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_outlined, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassesTabSwitcher extends StatelessWidget {
  const _ClassesTabSwitcher({
    required this.selectedTab,
    required this.onSelectTab,
  });

  final int selectedTab;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isWeatherBackgroundDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClassesTabButton(
              label: 'Khóa học',
              isSelected: selectedTab == 0,
              onTap: () => onSelectTab(0),
            ),
            _ClassesTabButton(
              label: 'Lớp học',
              isSelected: selectedTab == 1,
              onTap: () => onSelectTab(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassesTabButton extends StatelessWidget {
  const _ClassesTabButton({
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
    final isDark = context.isWeatherBackgroundDark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? cs.onPrimary
                : isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
