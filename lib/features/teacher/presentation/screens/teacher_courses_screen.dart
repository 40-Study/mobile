import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/courses/teacher_courses_cubit.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  static const _filters = [
    FilterItem(label: 'Tất cả', value: 'all'),
    FilterItem(label: 'Đang bán', value: 'published'),
    FilterItem(label: 'Bản nháp', value: 'draft'),
    FilterItem(label: 'Lưu trữ', value: 'archived'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<TeacherCoursesCubit>().loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TeacherAppBar(
        title: 'Kho khóa học',
        showSearch: true,
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person, size: 16, color: cs.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản lý khóa học',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocSelector<TeacherCoursesCubit, TeacherCoursesState,
                          int>(
                        selector: (state) {
                          if (state is TeacherCoursesLoaded) {
                            return state.publishedCount;
                          }
                          return 0;
                        },
                        builder: (context, count) {
                          return Text(
                            'Bạn có $count khóa học đang hoạt động.',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    // Navigate to create course
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo mới'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocSelector<TeacherCoursesCubit, TeacherCoursesState,
                String>(
              selector: (state) => state.selectedFilter,
              builder: (context, selectedFilter) {
                return FilterChipBar(
                  filters: _filters,
                  selectedFilter: selectedFilter,
                  onFilterChanged:
                      context.read<TeacherCoursesCubit>().changeFilter,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Courses list
          Expanded(
            child:
                BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
              builder: (context, state) {
                return switch (state) {
                  TeacherCoursesInitial() ||
                  TeacherCoursesLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  TeacherCoursesLoaded(:final courses) =>
                    courses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có khóa học nào',
                                  style: tt.titleMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CourseCard(
                                  course: course,
                                  onTap: () {
                                    // Navigate to course detail
                                  },
                                  onEditTap: () {
                                    // Navigate to edit course
                                  },
                                  onMoreTap: () {
                                    // Show more options
                                  },
                                ),
                              );
                            },
                          ),
                  TeacherCoursesFailure(:final message) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: cs.error,
                          ),
                          const SizedBox(height: 16),
                          Text(message),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context
                                .read<TeacherCoursesCubit>()
                                .loadCourses(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
