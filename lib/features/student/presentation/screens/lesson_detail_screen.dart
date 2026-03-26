import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/widgets/lesson_detail/lesson_detail_widgets.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.initialTab = 0,
  });

  final String lessonId;
  final String lessonTitle;
  final int initialTab;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LessonDetailCubit>().load();
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
          'Course Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<LessonDetailCubit, LessonDetailState>(
        builder: (context, state) {
          return switch (state) {
            LessonDetailInitial() ||
            LessonDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            LessonDetailLoaded(:final detail) =>
              _LessonBody(
                detail: detail,
                initialTab: widget.initialTab,
              ),
            LessonDetailFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: AppIconSize.hero, color: cs.error),
                    SizedBox(height: AppSpacing.lg),
                    Text(message),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _LessonBody extends StatefulWidget {
  const _LessonBody({required this.detail, this.initialTab = 0});
  final LessonDetailModel detail;
  final int initialTab;

  @override
  State<_LessonBody> createState() => _LessonBodyState();
}

class _LessonBodyState extends State<_LessonBody> {
  late final PageController _pageCtrl;
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _pageCtrl = PageController(initialPage: widget.initialTab);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentTab = index);
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;

    return Column(
      children: [
        VideoHero(detail: d),
        LessonInfoBar(detail: d),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentTab = i),
            children: [
              LessonOverviewTab(detail: d),
              LessonMaterialsTab(detail: d),
              LessonHomeworkTab(detail: d),
              LessonQuizTab(detail: d),
            ],
          ),
        ),
        LessonBottomTabBar(
          currentIndex: _currentTab,
          onTap: _onTabSelected,
          hasQuiz: d.hasQuiz,
          quizCount: d.quizAttempts.length,
        ),
      ],
    );
  }
}
