import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'widgets/instructor_avatar_placeholder.dart';

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
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  String _selectedCategory = 'Tất cả';

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
    ),
  ];

  List<String> get _categories {
    final cats = _courses.map((c) => c.category).toSet().toList();
    return ['Tất cả', ...cats];
  }

  List<_InstructorCourseData> get _filteredCourses {
    if (_selectedCategory == 'Tất cả') return _courses;
    return _courses.where((c) => c.category == _selectedCategory).toList();
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
      ),
      body: CustomScrollView(
        slivers: [
          // Instructor mini summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: InstructorAvatarPlaceholder(
                          name: widget.instructorName,
                        ),
                      ),
                    ),
                    AppSpacing.hGap16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.instructorName,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.vGap4,
                          Text(
                            widget.instructorTitle ?? 'Giảng viên cao cấp',
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.vGap4,
                          Text(
                            '${_courses.length} khóa học • 4.8 ⭐ (1.2k đánh giá)',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category filter tabs
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => AppSpacing.hGap8,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: cs.primary,
                    backgroundColor: cs.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: AppSpacing.vGap16),

          // Course list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              32,
            ),
            sliver: SliverList.separated(
              itemCount: _filteredCourses.length,
              separatorBuilder: (_, _) => AppSpacing.vGap12,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return _buildCourseCard(context, course, cs, tt);
              },
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
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () {
            // Navigate to course detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Khóa học: ${course.title}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primary.withValues(alpha: 0.15),
                        cs.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: cs.primary,
                      size: 32,
                    ),
                  ),
                ),
                AppSpacing.hGap16,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge & enrollment
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              course.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (course.isEnrolled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                'Đang học ${(course.progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            )
                          else
                            Text(
                              course.price,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.vGap4,

                      // Title
                      Text(
                        course.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap8,

                      // Metadata row
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${course.rating}',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.slate900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${course.lessonCount} bài  •  ${course.duration}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      if (course.isEnrolled) ...[
                        AppSpacing.vGap8,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: course.progress,
                            minHeight: 4,
                            backgroundColor:
                                cs.outlineVariant.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
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
