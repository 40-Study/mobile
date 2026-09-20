import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/data/models/bookmark_model.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/features/student/presentation/learning/instructor_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/section/section_widgets.dart';
import 'package:study/features/student/presentation/learning/widgets/thumbnail_placeholder.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/student/repository/student_repository.dart';
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
  bool _isBookmarked = false;

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

  Future<void> _checkBookmarkStatus(String courseId) async {
    final bookmarks = await diContainer<BookmarkStorage>().getAll();
    final exists = bookmarks.any((b) => b.itemId == courseId);
    if (mounted && exists != _isBookmarked) {
      setState(() => _isBookmarked = exists);
    }
  }

  void _navigateToLesson(
    BuildContext context,
    LessonModel lesson,
    List<LessonModel> allLessons,
    List<SectionModel> sections,
  ) async {
    final index = allLessons.indexWhere((l) => l.id == lesson.id);

    // Check bài trước đã hoàn thành chưa
    if (index > 0) {
      final prevLesson = allLessons[index - 1];
      final prevCompleted = prevLesson.progress?.status == 'completed';
      if (!prevCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn cần hoàn thành bài học trước để mở khoá bài này'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    // Find section and lesson index within section
    final sectionIndex = sections.indexWhere(
      (s) => s.lessons?.any((l) => l.id == lesson.id) ?? false,
    );
    final sectionNumber = sectionIndex >= 0 ? sectionIndex + 1 : 1;
    final lessonInSection = sectionIndex >= 0
        ? (sections[sectionIndex].lessons?.indexWhere((l) => l.id == lesson.id) ?? 0) + 1
        : 1;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonBloc(diContainer<StudentRepository>())
            ..add(LessonStarted(lesson.id)),
          child: LessonDetailScreen(
            currentIndex: index >= 0 ? index : 0,
            totalLessons: allLessons.length,
            sectionNumber: sectionNumber,
            lessonInSection: lessonInSection,
            onNavigate: (direction) {
              final newIndex = (index >= 0 ? index : 0) + direction;
              if (newIndex >= 0 && newIndex < allLessons.length) {
                Navigator.of(context).pop();
                _navigateToLesson(
                  context,
                  allLessons[newIndex],
                  allLessons,
                  sections,
                );
              }
            },
          ),
        ),
      ),
    );
    // Refresh enrollment data sau khi quay lại
    if (context.mounted) {
      context.read<CourseDetailBloc>().add(const CourseDetailRefreshed());
    }
  }

  Future<void> _navigateToCertificate(
    BuildContext context,
    String enrollmentId,
  ) async {
    final bloc = context.read<CourseDetailBloc>();
    final courseId = (bloc.state as CourseDetailSuccess?)?.course?.id;
    if (courseId == null) return;

    final studentRepo = diContainer<StudentRepository>();
    final result = await studentRepo.getCertificates();

    if (!context.mounted) return;

    result.when(
      success: (certs) async {
        var cert = certs.where((c) => c.courseId == courseId).firstOrNull;

        // Nếu chưa có chứng chỉ, cấp mới
        if (cert == null) {
          try {
            final courseRepo = diContainer<CourseRepository>();
            cert = await courseRepo.issueCertificate(courseId, enrollmentId);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi cấp chứng chỉ: $e'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CertificateDetailScreen(certificate: cert!),
            ),
          );
        }
      },
      failure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${f.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
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
          child: _buildAppBar(context, state),
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

  Widget _buildAppBar(BuildContext context, CourseDetailSuccess state) {
    // Check bookmark status khi build
    if (state.course != null) {
      _checkBookmarkStatus(state.course!.id);
    }

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
          _SoftIconButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            iconColor: _isBookmarked ? AchievementColors.orange : null,
            onTap: () => _toggleBookmark(context, state),
          ),
          AppSpacing.hGap8,
          _SoftIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Future<void> _toggleBookmark(BuildContext context, CourseDetailSuccess state) async {
    final course = state.course;
    if (course == null) return;

    final storage = diContainer<BookmarkStorage>();
    final bookmarkId = 'course_${course.id}';

    if (_isBookmarked) {
      await storage.remove(bookmarkId);
      setState(() => _isBookmarked = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã bỏ lưu khóa học'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final bookmark = BookmarkModel(
        id: bookmarkId,
        itemId: course.id,
        type: BookmarkType.course,
        title: course.title,
        thumbnail: course.thumbnailUrl,
        subtitle: course.instructorName,
        savedAt: DateTime.now(),
      );
      await storage.save(bookmark);
      setState(() => _isBookmarked = true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu khóa học'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildHeroSection(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;
    final enrollment = state.enrollment;
    final isCompleted = enrollment.progressPercentage >= 100;
    final isActive = enrollment.progressPercentage > 0;

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
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : isActive
                            ? cs.primary.withValues(alpha: 0.1)
                            : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    isCompleted
                        ? 'Hoàn thành'
                        : isActive
                            ? 'Đang học'
                            : 'Chưa bắt đầu',
                    style: tt.labelSmall?.copyWith(
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? cs.primary
                              : cs.onSurfaceVariant,
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
    final course = state.course;
    // Check enrolled: có enrollment ID thực (không rỗng) = đã enroll
    final isEnrolled = enrollment.id.isNotEmpty &&
        enrollment.status != 'preview';

    debugPrint('Enrollment id: ${enrollment.id}, status: ${enrollment.status}, isEnrolled: $isEnrolled');

    // Non-enrolled: show enroll card
    if (!isEnrolled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.isFree == true ? 'Miễn phí' : '${course?.price.toStringAsFixed(0) ?? 0}đ',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${course?.totalLessons ?? 0} bài học • ${course?.totalDurationMins ?? 0} phút',
                      style: tt.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đăng ký đang phát triển')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: const Text('Đăng ký ngay'),
              ),
            ],
          ),
        ),
      );
    }

    // Enrolled: show progress or certificate button
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);
    final nextLesson = _getNextLesson(state);
    final isCompleted = enrollment.progressPercentage >= 100;

    // Completed: just show certificate button
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: FilledButton(
          onPressed: () => _navigateToCertificate(context, enrollment.id),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_rounded, size: 18),
              SizedBox(width: 4),
              Text('Xem chứng chỉ'),
            ],
          ),
        ),
      );
    }

    // In progress: show card with progress
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text('Tiến độ', style: tt.labelMedium),
                      ),
                      const SizedBox(width: 4),
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
            FilledButton(
              onPressed: () {
                if (nextLesson != null) {
                  final allLessons = state.sections
                      .expand((s) => s.lessons ?? <LessonModel>[])
                      .toList();
                  _navigateToLesson(context, nextLesson, allLessons, state.sections);
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 18),
                  SizedBox(width: 4),
                  Text('Tiếp tục học'),
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatCard(
                icon: Icons.play_circle_outline,
                value: '${course?.totalLessons ?? 0}',
                label: 'Bài học',
              ),
              AppSpacing.hGap8,
              _StatCard(
                icon: Icons.access_time_rounded,
                value: _formatDuration(course?.totalDurationMins ?? 0),
                label: 'Thời lượng',
              ),
              AppSpacing.hGap8,
              _StatCard(
                icon: Icons.signal_cellular_alt_rounded,
                value: course?.level ?? 'Cơ bản',
                label: 'Cấp độ',
              ),
              AppSpacing.hGap8,
              const _StatCard(
                icon: Icons.workspace_premium_outlined,
                value: 'Có',
                label: 'Chứng chỉ',
              ),
            ],
          ),
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
        ...() {
          final allLessons = state.sections
              .expand((s) => s.lessons ?? <LessonModel>[])
              .toList();
          return allLessons.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final isLocked = index > 0 &&
                allLessons[index - 1].progress?.status != 'completed';
            return _LessonPreviewItem(
              index: index,
              lesson: lesson,
              isLocked: isLocked,
              onTap: () => _navigateToLesson(context, lesson, allLessons, state.sections),
            );
          });
        }(),

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
        ...() {
          int globalIndex = 0;
          return state.sections.asMap().entries.map((entry) {
            final sectionIndex = entry.key;
            final section = entry.value;
            final startIndex = globalIndex;
            globalIndex += section.lessons?.length ?? 0;
            return SectionCard(
              sectionIndex: sectionIndex,
              section: section,
              isExpanded: state.expandedSections.contains(section.id),
              allLessons: allLessons,
              globalStartIndex: startIndex,
              onToggle: () {
                context.read<CourseDetailBloc>().add(
                  CourseDetailSectionToggled(section.id),
                );
              },
              onLessonTap: (lesson) => _navigateToLesson(context, lesson, allLessons, state.sections),
            );
          });
        }(),

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
  const _SoftIconButton({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

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
        icon: Icon(icon, color: iconColor ?? cs.onSurfaceVariant, size: 22),
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
    this.isLocked = false,
  });

  final int index;
  final LessonModel lesson;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = lesson.progress?.status == 'completed';
    final isInProgress = lesson.progress?.status == 'in_progress';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: isLocked ? null : onTap,
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
              LessonStatusIcon(isCompleted: isCompleted, isInProgress: isInProgress, isLocked: isLocked),
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
