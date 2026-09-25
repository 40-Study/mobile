import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/course_detail/course_detail_widgets.dart';
import 'package:study/di/di_container.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'widgets/widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.lessonUnlockError),
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
          create: (_) => diContainer<LessonBloc>()
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

  void _requestCertificate(BuildContext context, String enrollmentId) {
    context.read<CourseDetailBloc>().add(
      CourseDetailCertificateRequested(enrollmentId),
    );
  }

  void _toggleBookmark(BuildContext context) {
    context.read<CourseDetailBloc>().add(const CourseDetailBookmarkToggled());
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CourseDetailBloc, CourseDetailState>(
        listenWhen: (prev, curr) {
          if (prev is! CourseDetailSuccess || curr is! CourseDetailSuccess) return false;
          // Listen khi bookmark hoặc certificate thay đổi
          return prev.isBookmarked != curr.isBookmarked ||
              (prev.certificate == null && curr.certificate != null);
        },
        listener: (context, state) {
          if (state is! CourseDetailSuccess) return;

          // Navigate khi có certificate mới
          final cert = state.certificate;
          if (cert != null) {
            Navigator.push(
              context,
              MaterialPageRoute<Widget>(
                builder: (_) => CertificateDetailScreen(certificate: cert),
              ),
            );
          }
        },
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
              Text(AppLocalizations.of(context)!.courseLoadError, style: tt.titleMedium),
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
                label: Text(AppLocalizations.of(context)!.tryAgainButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailSuccess state) {
    final cs = Theme.of(context).colorScheme;

    final allLessons = state.sections
        .expand((s) => s.lessons ?? <LessonModel>[])
        .toList();
    final nextLesson = _getNextLesson(state);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: CourseDetailHeader(
            isBookmarked: state.isBookmarked,
            onBack: () => Navigator.of(context).pop(),
            onBookmark: () => _toggleBookmark(context),
            onShare: () {},
          ),
        ),
        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: CourseHero(state: state)),
              SliverToBoxAdapter(
                child: CourseProgressCard(
                  state: state,
                  onContinue: () {
                    if (nextLesson != null) {
                      _navigateToLesson(context, nextLesson, allLessons, state.sections);
                    }
                  },
                  onViewCertificate: () => _requestCertificate(context, state.enrollment.id),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: CourseDetailTabBarDelegate(tabController: _tabController, cs: cs),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                CourseOverviewTab(
                  state: state,
                  onViewAllContent: () => _tabController.animateTo(1),
                  onLessonTap: (lesson) => _navigateToLesson(context, lesson, allLessons, state.sections),
                ),
                CourseContentTab(
                  state: state,
                  onLessonTap: (lesson) => _navigateToLesson(context, lesson, allLessons, state.sections),
                ),
                CourseInstructorTab(state: state),
                CourseReviewsTab(state: state),
              ],
            ),
          ),
        ),
        const CourseEnrollmentBar(),
      ],
    );
  }
}
