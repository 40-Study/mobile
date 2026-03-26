import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/widgets/course_detail/course_detail_widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.enrollmentId,
    required this.courseId,
    required this.courseTitle,
  });

  final String enrollmentId;
  final String courseId;
  final String courseTitle;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.courseTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: cs.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CourseDetailCubit, CourseDetailState>(
        builder: (context, state) {
          return switch (state) {
            CourseDetailInitial() ||
            CourseDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            CourseDetailLoaded(:final detail) =>
              _CourseDetailBody(detail: detail),
            CourseDetailFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: AppIconSize.hero, color: cs.error),
                    SizedBox(height: AppSpacing.lg),
                    Text(message),
                    SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () =>
                          context.read<CourseDetailCubit>().load(),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _CourseDetailBody extends StatefulWidget {
  const _CourseDetailBody({required this.detail});
  final CourseDetailModel detail;

  @override
  State<_CourseDetailBody> createState() => _CourseDetailBodyState();
}

class _CourseDetailBodyState extends State<_CourseDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = ['Tong quan', 'Noi dung', 'Tai lieu', 'Thao luan'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _navigateToCurrentLesson() {
    final lesson = widget.detail.currentLesson;
    if (lesson == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonDetailCubit(lessonId: lesson.id),
          child: LessonDetailScreen(
            lessonId: lesson.id,
            lessonTitle: lesson.title,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: CourseHeroHeader(
            detail: d,
            onContinue: _navigateToCurrentLesson,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: CourseTabBarDelegate(
            tabCtrl: _tabCtrl,
            tabs: _tabs,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          CourseOverviewTab(detail: d),
          CourseContentTab(detail: d),
          CourseDocumentsTab(detail: d),
          CourseDiscussionTab(detail: d),
        ],
      ),
    );
  }
}
