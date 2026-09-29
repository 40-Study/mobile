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
          onRefresh: () async => context.read<LearningBloc>().add(const LearningRefreshed()),
          emptyIcon: Icons.school_outlined,
          emptyTitle: 'Chưa có khóa học',
          emptyMessage: 'Hiện chưa có khóa học nào.',
          itemBuilder: (context, course) => _CourseCard(course: course),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCourse(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: 100,
                    height: 70,
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

                AppSpacing.hGap12,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGap4,
                      if (course.instructorName != null)
                        Text(
                          course.instructorName!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      AppSpacing.vGap8,
                      Row(
                        children: [
                          if (course.level != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderXs,
                              ),
                              child: Text(
                                course.level!,
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            AppSpacing.hGap8,
                          ],
                          if (course.totalLessons > 0) ...[
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.totalLessons} bài',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            AppSpacing.hGap8,
                          ],
                          const Spacer(),
                          if (course.isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Text(
                                'Miễn phí',
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (course.price > 0)
                            Text(
                              '${course.price.toStringAsFixed(0)}đ',
                              style: tt.labelMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
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
