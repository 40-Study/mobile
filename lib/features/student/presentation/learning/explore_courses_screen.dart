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
import 'package:study/widgets/async_list_scaffold.dart';

class ExploreCoursesScreen extends StatelessWidget {
  const ExploreCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningBloc, LearningState>(
      builder: (context, state) {
        final courses = switch (state) {
          LearningSuccess(:final recommendedCourses) => recommendedCourses,
          _ => <CourseModel>[],
        };
        final isLoading = state is LearningInProgress;
        final error = state is LearningFailure ? state.message : null;

        return AsyncListScaffold<CourseModel>(
          title: 'Khám phá khóa học',
          items: courses,
          isLoading: isLoading,
          error: error,
          onRefresh: () async =>
              context.read<LearningBloc>().add(const LearningRefreshed()),
          emptyIcon: Icons.school_outlined,
          emptyTitle: 'Chưa có khóa học',
          emptyMessage: 'Hiện chưa có khóa học nào được đề xuất.',
          itemBuilder: (context, course) => _ExploreCourseCard(course: course),
        );
      },
    );
  }
}

class _ExploreCourseCard extends StatelessWidget {
  const _ExploreCourseCard({required this.course});

  final CourseModel course;

  static String _formatPrice(double price) {
    final intVal = price.toInt();
    final s = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
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
          onTap: () => _navigateToCourse(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: 88,
                    height: 88,
                    color: cs.primaryContainer,
                    child: course.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _Placeholder(),
                            errorWidget: (_, __, ___) => _Placeholder(),
                          )
                        : _Placeholder(),
                  ),
                ),
                AppSpacing.hGap16,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap4,

                      // Instructor
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInstructorInitial(course.instructorName),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cs.blue600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              course.instructorName ?? 'Giảng viên',
                              style: tt.bodySmall?.copyWith(
                                color: cs.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap8,

                      // Tags & Price Row
                      Row(
                        children: [
                          if (course.level != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Text(
                                course.level!,
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (course.totalLessons > 0) ...[
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 13,
                              color: cs.slate400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${course.totalLessons} bài',
                              style: tt.labelSmall?.copyWith(
                                color: cs.slate500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (course.isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
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
                          else if (course.price > 0)
                            Text(
                              _formatPrice(course.price),
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right_rounded, color: cs.slate400, size: 20),
              ],
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
          create: (_) => diContainer<CourseDetailBloc>()
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
