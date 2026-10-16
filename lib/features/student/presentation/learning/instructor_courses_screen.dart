import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'widgets/category_tabs_header_delegate.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    this.instructorTitle,
  });

  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String? instructorTitle;

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCourseData {
  const _InstructorCourseData({
    required this.id,
    required this.title,
    required this.category,
    required this.lessonCount,
    required this.duration,
    required this.rating,
    required this.studentCount,
    this.progress = 0,
    this.isEnrolled = false,
    this.price = 'Miễn phí',
    this.level = 'Cơ bản',
  });

  final String id;
  final String title;
  final String category;
  final int lessonCount;
  final String duration;
  final double rating;
  final int studentCount;
  final double progress;
  final bool isEnrolled;
  final String price;
  final String level;
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  late final PageController _pageController;
  late final List<GlobalKey> _chipKeys;
  int _selectedCategoryIndex = 0;

  late final List<_InstructorCourseData> _courses = [
    const _InstructorCourseData(
      id: 'course_1',
      title: 'UI/UX Design Fundamentals',
      category: 'UI/UX Design',
      lessonCount: 12,
      duration: '6h 40m',
      rating: 4.9,
      studentCount: 1250,
      progress: 0.65,
      isEnrolled: true,
      level: 'Cơ bản',
    ),
    const _InstructorCourseData(
      id: 'course_2',
      title: 'Product Design Masterclass',
      category: 'Product Design',
      lessonCount: 18,
      duration: '8h 20m',
      rating: 4.8,
      studentCount: 940,
      progress: 0.40,
      isEnrolled: true,
      level: 'Nâng cao',
    ),
    const _InstructorCourseData(
      id: 'course_3',
      title: 'Design Thinking for UX',
      category: 'UI/UX Design',
      lessonCount: 10,
      duration: '4h 15m',
      rating: 4.7,
      studentCount: 680,
      progress: 0.20,
      isEnrolled: false,
      price: '499.000 đ',
      level: 'Thực chiến',
    ),
    const _InstructorCourseData(
      id: 'course_4',
      title: 'User Research Methods',
      category: 'User Research',
      lessonCount: 14,
      duration: '5h 30m',
      rating: 4.8,
      studentCount: 520,
      progress: 0,
      isEnrolled: false,
      price: '599.000 đ',
      level: 'Chuyên sâu',
    ),
    const _InstructorCourseData(
      id: 'course_5',
      title: 'Design System & Component Library',
      category: 'Product Design',
      lessonCount: 16,
      duration: '7h 10m',
      rating: 4.9,
      studentCount: 810,
      progress: 0,
      isEnrolled: false,
      price: '699.000 đ',
      level: 'Nâng cao',
    ),
  ];

  late final List<String> _categories = [
    'Tất cả',
    ..._courses.map((c) => c.category).toSet(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _chipKeys = List.generate(_categories.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryTapped(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    _scrollToSelectedChip(index);
  }

  void _onPageChanged(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _scrollToSelectedChip(index);
  }

  void _scrollToSelectedChip(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _chipKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Color _getCategoryPastelColor(String category) {
    switch (category) {
      case 'UI/UX Design':
        return const Color(0xFFEEF2FF); // Indigo pastel
      case 'Product Design':
        return const Color(0xFFF0FDF4); // Emerald pastel
      case 'User Research':
        return const Color(0xFFFAF5FF); // Lavender pastel
      default:
        return const Color(0xFFFFFBEB); // Amber pastel
    }
  }

  Color _getCategoryBorderColor(String category) {
    switch (category) {
      case 'UI/UX Design':
        return const Color(0xFFE0E7FF);
      case 'Product Design':
        return const Color(0xFFDCFCE7);
      case 'User Research':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getCategoryThemeColor(String category) {
    switch (category) {
      case 'UI/UX Design':
        return const Color(0xFF4F46E5);
      case 'Product Design':
        return const Color(0xFF059669);
      case 'User Research':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFFD97706);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'UI/UX Design':
        return Icons.palette_outlined;
      case 'Product Design':
        return Icons.layers_outlined;
      case 'User Research':
        return Icons.psychology_outlined;
      default:
        return Icons.auto_awesome_mosaic_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Khóa học của giảng viên'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Sticky Category Filter Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryTabsHeaderDelegate(
              height: 52,
              child: _buildCategoryTabs(cs),
            ),
          ),
        ],
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final courses = cat == 'Tất cả'
                ? _courses
                : _courses.where((c) => c.category == cat).toList();
            return _buildTabCourseList(context, cat, courses, cs, tt);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ColorScheme cs) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 7,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => AppSpacing.hGap8,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          final count = cat == 'Tất cả'
              ? _courses.length
              : _courses.where((c) => c.category == cat).length;

          return KeyedSubtree(
            key: _chipKeys[index],
            child: ChoiceChip(
              label: Text('$cat ($count)'),
              selected: isSelected,
              onSelected: (_) => _onCategoryTapped(index),
              selectedColor: cs.primary,
              backgroundColor: cs.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: isSelected
                      ? cs.primary
                      : cs.outlineVariant.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabCourseList(
    BuildContext context,
    String category,
    List<_InstructorCourseData> courses,
    ColorScheme cs,
    TextTheme tt,
  ) {
    if (courses.isEmpty) {
      return _buildEmptyState(category, cs, tt);
    }

    return ListView.separated(
      key: PageStorageKey<String>('instructor_courses_$category'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        32,
      ),
      itemCount: courses.length,
      separatorBuilder: (_, _) => AppSpacing.vGap12,
      itemBuilder: (context, index) {
        return _buildCourseCard(context, courses[index], cs, tt);
      },
    );
  }

  Widget _buildEmptyState(String category, ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 36,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vGap16,
            Text(
              'Chưa có khóa học nào',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            AppSpacing.vGap8,
            Text(
              'Giảng viên hiện chưa mở khóa học thuộc chuyên mục $category.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseThumbnail(
    _InstructorCourseData course,
    ColorScheme cs,
  ) {
    final pastelColor = _getCategoryPastelColor(course.category);
    final borderColor = _getCategoryBorderColor(course.category);
    final themeColor = _getCategoryThemeColor(course.category);
    final iconData = _getCategoryIcon(course.category);

    return Container(
      width: 86,
      height: 94,
      decoration: BoxDecoration(
        color: pastelColor,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                iconData,
                color: themeColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.8),
                width: 0.6,
              ),
            ),
            child: Text(
              course.level,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: themeColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    _InstructorCourseData course,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final themeColor = _getCategoryThemeColor(course.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.45),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Khóa học: ${course.title}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thematic Pastel Squircle Thumbnail
                _buildCourseThumbnail(course, cs),
                AppSpacing.hGap16,

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Status / Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryPastelColor(course.category),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: _getCategoryBorderColor(course.category),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              course.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (course.isEnrolled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                  width: 0.6,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Đang học '
                                    '${(course.progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              course.price,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.vGap8,

                      // Title
                      Text(
                        course.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                          fontSize: 14,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap8,

                      // Metadata row: Star rating + Lesson count + Duration
                      Row(
                        children: [
                          const Icon(
                             Icons.star_rounded,
                             size: 16,
                             color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${course.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${course.studentCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: cs.outlineVariant),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.lessonCount} bài',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(color: cs.outlineVariant),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            course.duration,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Enrolled Progress Bar
                      if (course.isEnrolled) ...[
                        AppSpacing.vGap8,
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: course.progress,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${((course.progress) * course.lessonCount).round()}/${course.lessonCount} bài',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
