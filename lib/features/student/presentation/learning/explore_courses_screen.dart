import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/theme/theme.dart';

enum ExploreSortOption {
  popular('Phổ biến nhất'),
  newest('Mới nhất'),
  rating('Đánh giá cao'),
  priceLow('Giá: Thấp đến Cao'),
  priceHigh('Giá: Cao đến Thấp');

  const ExploreSortOption(this.label);
  final String label;
}

enum PriceFilterOption {
  all('Tất cả'),
  free('🎁 Miễn phí'),
  paid('💳 Có phí');

  const PriceFilterOption(this.label);
  final String label;
}

class ExploreCoursesScreen extends StatefulWidget {
  const ExploreCoursesScreen({super.key});

  @override
  State<ExploreCoursesScreen> createState() => _ExploreCoursesScreenState();
}

class _ExploreCoursesScreenState extends State<ExploreCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  PriceFilterOption _priceFilter = PriceFilterOption.all;
  ExploreSortOption _sortOption = ExploreSortOption.popular;
  final Set<String> _bookmarkedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'Tất cả';
      _priceFilter = PriceFilterOption.all;
      _sortOption = ExploreSortOption.popular;
    });
  }

  List<CourseModel> _filterAndSortCourses(List<CourseModel> courses) {
    var result = List<CourseModel>.from(courses);

    // 1. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((c) {
        final title = c.title.toLowerCase();
        final instructor = (c.instructorName ?? '').toLowerCase();
        final category = (c.categoryName ?? '').toLowerCase();
        final desc = (c.shortDescription ?? '').toLowerCase();
        return title.contains(q) ||
            instructor.contains(q) ||
            category.contains(q) ||
            desc.contains(q);
      }).toList();
    }

    // 2. Category Filter
    if (_selectedCategory != 'Tất cả') {
      result = result.where((c) {
        return c.categoryName == _selectedCategory;
      }).toList();
    }

    // 3. Price Filter
    switch (_priceFilter) {
      case PriceFilterOption.all:
        break;
      case PriceFilterOption.free:
        result = result.where((c) => c.isFree || c.price == 0).toList();
        break;
      case PriceFilterOption.paid:
        result = result.where((c) => !c.isFree && c.price > 0).toList();
        break;
    }

    // 4. Sorting
    switch (_sortOption) {
      case ExploreSortOption.popular:
        result.sort((a, b) {
          final cmp = b.totalStudents.compareTo(a.totalStudents);
          if (cmp != 0) return cmp;
          return b.averageRating.compareTo(a.averageRating);
        });
        break;
      case ExploreSortOption.newest:
        result.sort((a, b) {
          final da = a.createdAt ?? DateTime(2000);
          final db = b.createdAt ?? DateTime(2000);
          return db.compareTo(da);
        });
        break;
      case ExploreSortOption.rating:
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case ExploreSortOption.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ExploreSortOption.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return result;
  }

  List<String> _extractCategories(List<CourseModel> courses) {
    final set = <String>{};
    for (final c in courses) {
      if (c.categoryName != null && c.categoryName!.trim().isNotEmpty) {
        set.add(c.categoryName!.trim());
      }
    }
    final sorted = set.toList()..sort();
    return ['Tất cả', ...sorted];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Khám phá khóa học',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: cs.surface,
      ),
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
                padding: const EdgeInsets.all(AppSpacing.xl),
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
                      child: Icon(
                        Icons.sync_problem_rounded,
                        color: cs.error,
                        size: 28,
                      ),
                    ),
                    AppSpacing.vGap16,
                    Text(
                      'Không thể tải danh sách khóa học',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.message,
                      style: tt.bodySmall?.copyWith(color: cs.slate500),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vGap16,
                    FilledButton(
                      onPressed: () => context.read<LearningBloc>().add(
                        const LearningRefreshed(),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3D5FC4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allCourses = switch (state) {
            LearningSuccess(:final recommendedCourses) => recommendedCourses,
            _ => <CourseModel>[],
          };

          final categories = _extractCategories(allCourses);
          final displayedCourses = _filterAndSortCourses(allCourses);

          // Find spotlight course when not searching
          final spotlightCourse =
              (_searchQuery.isEmpty &&
                  _selectedCategory == 'Tất cả' &&
                  allCourses.isNotEmpty)
              ? allCourses.first
              : null;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<LearningBloc>().add(const LearningRefreshed()),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Search Bar
                        _buildSearchBar(cs, tt),
                        const SizedBox(height: 12),

                        // 2. Category Chips Bar
                        _buildCategoryChips(categories, cs),
                        const SizedBox(height: 12),

                        // 3. Quick Price Filters & Sort Bar
                        _buildFilterAndSortBar(cs, tt, displayedCourses.length),
                        const SizedBox(height: 14),

                        // 4. Spotlight Banner
                        if (spotlightCourse != null &&
                            _priceFilter == PriceFilterOption.all) ...[
                          _buildSpotlightBanner(
                            context,
                            spotlightCourse,
                            cs,
                            tt,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
                  ),
                ),
                if (displayedCourses.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverToBoxAdapter(child: _buildEmptyState(cs, tt)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList.separated(
                      itemCount: displayedCourses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = displayedCourses[index];
                        return _ExploreCourseCard(
                          course: course,
                          isBookmarked: _bookmarkedIds.contains(course.id),
                          onBookmarkToggle: () {
                            setState(() {
                              if (_bookmarkedIds.contains(course.id)) {
                                _bookmarkedIds.remove(course.id);
                              } else {
                                _bookmarkedIds.add(course.id);
                              }
                            });
                          },
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

  Widget _buildSearchBar(ColorScheme cs, TextTheme tt) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(fontSize: 13.5, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm khóa học, giảng viên, kỹ năng...',
          hintStyle: TextStyle(fontSize: 13, color: cs.slate400),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF3D5FC4),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories, ColorScheme cs) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6.5,
              ),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outlineVariant.withValues(alpha: 0.8),
                  width: 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterAndSortBar(ColorScheme cs, TextTheme tt, int count) {
    return Row(
      children: [
        // Price Filter Chips
        ...PriceFilterOption.values.map((opt) {
          final isSelected = opt == _priceFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => setState(() => _priceFilter = opt),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected
                        ? cs.primary
                        : cs.outlineVariant.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),

        // Sort Menu
        PopupMenuButton<ExploreSortOption>(
          initialValue: _sortOption,
          onSelected: (val) => setState(() => _sortOption = val),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _sortOption.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
          itemBuilder: (context) {
            return ExploreSortOption.values.map((opt) {
              return PopupMenuItem<ExploreSortOption>(
                value: opt,
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: opt == _sortOption
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: opt == _sortOption
                        ? cs.primary
                        : cs.onSurface,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildSpotlightBanner(
    BuildContext context,
    CourseModel course,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3D5FC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D5FC4).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCourse(context, course),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'KHÓA HỌC NỔI BẬT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFDE047),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            course.averageRating > 0
                                ? course.averageRating.toStringAsFixed(1)
                                : '4.9',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '${course.totalLessons} bài học',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: Colors.white12,
                    child: course.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 200,
                            memCacheHeight: 200,
                            errorWidget: (_, _, _) => _Placeholder(),
                          )
                        : _Placeholder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: Color(0xFF3D5FC4),
            ),
          ),
          AppSpacing.vGap16,
          Text(
            'Không tìm thấy khóa học phù hợp',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thử tìm với từ khóa khác hoặc xóa bớt các bộ lọc hiện tại.',
            style: tt.bodySmall?.copyWith(color: cs.slate500),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap16,
          InkWell(
            onTap: _clearFilters,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: Color(0xFF3D5FC4),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Đặt lại bộ lọc',
                    style: TextStyle(
                      color: Color(0xFF3D5FC4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCourse(BuildContext context, CourseModel course) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              diContainer<CourseDetailBloc>()
                ..add(CourseDetailStarted(course.id, isEnrollment: false)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }
}

class _ExploreCourseCard extends StatelessWidget {
  const _ExploreCourseCard({
    required this.course,
    this.isBookmarked = false,
    this.onBookmarkToggle,
  });

  final CourseModel course;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;

  static String _formatPrice(double price) {
    final intVal = price.toInt();
    final s = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return '${buffer.toString()}đ';
  }

  static String _getInstructorInitial(String? name) {
    if (name == null || name.trim().isEmpty) return 'T';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.last.isNotEmpty ? words.last[0].toUpperCase() : 'T';
  }

  String _formatLevel(String? level) {
    if (level == null) return 'Mọi trình độ';
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung cấp';
      case 'advanced':
        return 'Nâng cao';
      default:
        return level;
    }
  }

  Color _levelColor(String? level) {
    if (level == null) return const Color(0xFF3D5FC4);
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF059669);
      case 'intermediate':
        return const Color(0xFF2563EB);
      case 'advanced':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF3D5FC4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final levelText = _formatLevel(course.level);
    final levelColor = _levelColor(course.level);
    final rating = course.averageRating > 0 ? course.averageRating : 4.8;
    final ratingsCount = course.totalRatings > 0 ? course.totalRatings : 120;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _navigateToCourse(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thumbnail with overlay tag
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 92,
                          height: 92,
                          color: cs.primaryContainer,
                          child: course.thumbnailUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: course.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                  placeholder: (_, _) => _Placeholder(),
                                  errorWidget: (_, _, _) => _Placeholder(),
                                )
                              : _Placeholder(),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            levelText,
                            style: TextStyle(
                              color: levelColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // 2. Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.slate900,
                            fontSize: 14,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Instructor
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _getInstructorInitial(course.instructorName),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                course.instructorName ?? 'Giảng viên',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.slate500,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Rating & Lesson Specs
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              ' ($ratingsCount)',
                              style: TextStyle(
                                fontSize: 10,
                                color: cs.slate400,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: TextStyle(color: cs.outlineVariant),
                            ),
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 13,
                              color: cs.slate400,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${course.totalLessons} bài',
                              style: TextStyle(
                                color: cs.slate500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Price and Free badge
                        Row(
                          children: [
                            if (course.isFree || course.price == 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: const Text(
                                  'Miễn phí',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              Text(
                                _formatPrice(course.price),
                                style: const TextStyle(
                                  color: Color(0xFF3D5FC4),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            const Spacer(),
                            InkWell(
                              onTap: onBookmarkToggle,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: isBookmarked
                                      ? const Color(0xFF3D5FC4)
                                      : const Color(0xFF94A3B8),
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
        ),
      ),
    );
  }

  void _navigateToCourse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              diContainer<CourseDetailBloc>()
                ..add(CourseDetailStarted(course.id, isEnrollment: false)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.school_rounded, color: cs.outline, size: 24),
      ),
    );
  }
}
