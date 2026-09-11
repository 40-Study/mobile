import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final _repository = diContainer<StudentRepository>();
  List<EnrollmentModel> _enrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getActiveEnrollments();

    result.when(
      success: (enrollments) {
        setState(() {
          _enrollments = enrollments;
          _isLoading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _error = failure.message ?? 'Không thể tải khóa học';
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          'Khóa học của tôi',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Lỗi',
          message: _error!,
          actionLabel: 'Thử lại',
          onAction: _loadCourses,
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.school_outlined,
          title: 'Chưa có khóa học',
          message: 'Bạn chưa đăng ký khóa học nào.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: CustomScrollView(
        slivers: [
          // Course list
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList.separated(
              itemCount: _enrollments.length,
              separatorBuilder: (_, __) => AppSpacing.vGap12,
              itemBuilder: (context, index) => _CourseCard(
                enrollment: _enrollments[index],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.enrollment});

  final EnrollmentModel enrollment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = enrollment.progressPercentage / 100;
    final isCompleted = enrollment.progressPercentage >= 100;
    final progressColor = isCompleted ? cs.primary : cs.tertiary;

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
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with progress ring
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    children: [
                      // Progress ring background
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 3,
                          backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                          color: cs.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      // Progress ring
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          color: progressColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Thumbnail
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: course?.thumbnailUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: course!.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => _Placeholder(),
                                    errorWidget: (_, __, ___) => _Placeholder(),
                                  )
                                : _Placeholder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.hGap12,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        course?.title ?? 'Khóa học',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      AppSpacing.vGap4,

                      // Instructor
                      if (course?.instructorName != null)
                        Text(
                          course!.instructorName!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      AppSpacing.vGap8,

                      // Stats row
                      Row(
                        children: [
                          // Lessons
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${enrollment.completedLessons}/${enrollment.totalLessons}',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),

                          AppSpacing.hGap12,

                          // Progress badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCompleted)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: progressColor,
                                    ),
                                  ),
                                Text(
                                  isCompleted
                                      ? 'Hoàn thành'
                                      : '${enrollment.progressPercentage.round()}%',
                                  style: tt.labelSmall?.copyWith(
                                    color: progressColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Action
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: cs.primary,
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
    // Pass enrollment.id for enrolled courses
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => CourseDetailBloc(diContainer<StudentRepository>())
            ..add(CourseDetailStarted(enrollment.id, isEnrollment: true)),
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
        child: Icon(Icons.school_rounded, color: cs.outline, size: 20),
      ),
    );
  }
}
