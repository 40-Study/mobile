import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/presentation/learning/widgets/exercise/exercise_widgets.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/lesson_detail_widgets.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_video_player.dart';
import 'package:study/theme/theme.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    this.currentIndex = 0,
    this.totalLessons = 1,
    this.sectionNumber = 1,
    this.lessonInSection = 1,
    this.onNavigate,
  });

  final int currentIndex;
  final int totalLessons;
  final int sectionNumber;
  final int lessonInSection;
  final void Function(int direction)? onNavigate;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _videoWatched = false;

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

  Future<void> _markComplete(
    String lessonId, {
    List<List<int>>? playedRanges,
    int? durationSeconds,
  }) async {
    final result = await diContainer<StudentRepository>().markLessonComplete(
      lessonId,
      playedRanges: playedRanges,
      durationSeconds: durationSeconds,
    );
    result.when(
      success: (courseCompleted) {
        if (courseCompleted && mounted) _showCourseCompletedDialog();
      },
      failure: (_) {},
    );
  }

  void _showCourseCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Chuc mung!'),
        content: const Text('Ban da hoan thanh khoa hoc!\n\nChung chi cua ban da san sang.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Dong'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              // TODO: Navigate to certificate screen
            },
            child: const Text('Xem chung chi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<LessonBloc, LessonState>(
        listenWhen: (prev, curr) =>
            curr is LessonSuccess &&
            curr.courseCompleted &&
            (prev is! LessonSuccess || !prev.courseCompleted),
        listener: (context, state) => _showCourseCompletedDialog(),
        builder: (context, state) {
          return switch (state) {
            LessonInitial() || LessonInProgress() => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            LessonFailure(:final message) => _buildError(context, message),
            LessonSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Spacer(),
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            AppSpacing.vGap16,
            Text(message, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            AppSpacing.vGap24,
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lai'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LessonSuccess state) {
    return Column(
      children: [
        _buildAppBar(context, state.lesson),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: LessonVideoPlayer(
            videoUrl: state.videoUrl,
            onProgressThreshold: (ranges, duration) {
              _videoWatched = true;
              _markComplete(state.lesson.id, playedRanges: ranges, durationSeconds: duration);
            },
          ),
        ),
        _buildTabs(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContentTab(context, state),
              _buildDocumentsTab(context),
              _buildExerciseTab(context, state),
              _buildNotesTab(context),
            ],
          ),
        ),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, LessonModel lesson) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Bai ${widget.currentIndex + 1}. ${lesson.title}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark_outline_rounded, color: cs.onSurfaceVariant),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorWeight: 3,
        labelStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: tt.labelMedium,
        tabs: const [
          Tab(icon: Icon(Icons.menu_book_outlined, size: 20), text: 'Noi dung'),
          Tab(icon: Icon(Icons.description_outlined, size: 20), text: 'Tai lieu'),
          Tab(icon: Icon(Icons.edit_outlined, size: 20), text: 'Bai tap'),
          Tab(icon: Icon(Icons.sticky_note_2_outlined, size: 20), text: 'Ghi chu'),
        ],
      ),
    );
  }

  Widget _buildContentTab(BuildContext context, LessonSuccess state) {
    final tt = Theme.of(context).textTheme;
    final lesson = state.lesson;
    final contents = lesson.contents ?? [];
    final totalSeconds = contents.fold<int>(0, (sum, c) => sum + c.duration);

    String formatTime(int seconds) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionInfoCard(
            sessionNumber: widget.sectionNumber,
            lessonInSection: widget.lessonInSection,
            sessionTitle: lesson.title,
            progress: state.isCompleted ? 100 : 0,
            currentTime: state.isCompleted ? formatTime(totalSeconds) : '0:00',
            totalTime: formatTime(totalSeconds),
          ),
          AppSpacing.vGap16,
          Text('Noi dung bai hoc', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap12,
          ...contents.asMap().entries.map((entry) {
            final index = entry.key;
            final content = entry.value;
            return LessonContentItem(
              index: index,
              content: content,
              isCompleted: index == 0,
              isCurrent: index == 1,
              isLocked: index > 2,
            );
          }),
          AppSpacing.vGap24,
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Download all button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.folder_zip_outlined, color: cs.primary, size: 24),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tai tat ca tai lieu',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('4 tep • 12.5 MB',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Tai ve'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          const DocumentSection(
            icon: Icons.slideshow_outlined,
            title: 'Slide bai giang',
            children: [
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Gioi thieu Python',
                subtitle: 'PDF • 2.3 MB • 15 trang',
                isDownloaded: true,
              ),
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Cai dat moi truong',
                subtitle: 'PDF • 1.8 MB • 12 trang',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.code_rounded,
            title: 'Ma nguon mau',
            children: [
              DocumentCard(
                icon: Icons.folder_zip_outlined,
                iconColor: Colors.amber.shade700,
                title: 'source_code_lesson1.zip',
                subtitle: 'ZIP • 156 KB • 5 files',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.library_books_outlined,
            title: 'Tai lieu tham khao',
            children: [
              const DocumentCard(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'Python Cheat Sheet',
                subtitle: 'PDF • 890 KB • 4 trang',
              ),
              DocumentCard(
                icon: Icons.link_rounded,
                iconColor: cs.primary,
                title: 'Python Official Documentation',
                subtitle: 'Link • python.org',
                isLink: true,
              ),
            ],
          ),
          AppSpacing.vGap32,
        ],
      ),
    );
  }

  Widget _buildExerciseTab(BuildContext context, LessonSuccess state) {
    final quizzes = state.quizzes;
    final total = quizzes.length;

    if (total == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseProgressCard(completed: 0, total: 0, percent: 100),
            AppSpacing.vGap24,
            _buildEmptyExercises(context),
            AppSpacing.vGap32,
          ],
        ),
      );
    }

    return FutureBuilder<int>(
      future: _countCompletedQuizzes(quizzes),
      builder: (context, snapshot) {
        final completed = snapshot.data ?? 0;
        final percent = (completed / total * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExerciseProgressCard(completed: completed, total: total, percent: percent),
              AppSpacing.vGap24,
              if (quizzes.isNotEmpty)
                ExerciseSection(
                  icon: Icons.quiz_outlined,
                  title: 'Quiz',
                  subtitle: 'Tra loi cau hoi trac nghiem',
                  children: quizzes.asMap().entries.map((entry) {
                    return QuizCardFromModel(
                      index: entry.key + 1,
                      quiz: entry.value,
                      onComplete: () => _checkAllQuizzesComplete(state.lesson.id, quizzes),
                    );
                  }).toList(),
                ),
              if (quizzes.isEmpty) _buildEmptyExercises(context),
              AppSpacing.vGap32,
            ],
          ),
        );
      },
    );
  }

  Future<int> _countCompletedQuizzes(List<QuizModel> quizzes) async {
    var count = 0;
    for (final quiz in quizzes) {
      if (await QuizResultStorage.hasResult(quiz.id)) count++;
    }
    return count;
  }

  Future<void> _checkAllQuizzesComplete(String lessonId, List<QuizModel> quizzes) async {
    if (quizzes.isEmpty) return;
    final completed = await _countCompletedQuizzes(quizzes);
    if (completed >= quizzes.length) _markComplete(lessonId);
  }

  Future<void> _onNextPressed(LessonSuccess state, bool hasNext) async {
    if (!_videoWatched && state.videoUrl != null) {
      final confirm = await _showSkipVideoDialog();
      if (confirm != true) return;
    }

    final quizzes = state.quizzes;
    if (quizzes.isNotEmpty) {
      final completed = await _countCompletedQuizzes(quizzes);
      if (completed < quizzes.length) {
        final confirm = await _showSkipQuizDialog(quizzes.length - completed);
        if (confirm != true) return;
      }
    }

    await _markComplete(state.lesson.id);
    if (hasNext) widget.onNavigate?.call(1);
  }

  Future<bool?> _showSkipVideoDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chua xem het video'),
        content: const Text('Ban chua xem du 80% video bai hoc.\n\nBan co chac muon qua bai tiep theo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, false);
              _tabController.animateTo(0);
            },
            child: const Text('Xem tiep'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bo qua')),
        ],
      ),
    );
  }

  Future<bool?> _showSkipQuizDialog(int remaining) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chua hoan thanh bai tap'),
        content: Text('Ban con $remaining bai tap chua lam.\n\nBan co chac muon qua bai tiep theo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, false);
              _tabController.animateTo(2);
            },
            child: const Text('Lam bai tap'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bo qua')),
        ],
      ),
    );
  }

  Widget _buildEmptyExercises(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          AppSpacing.vGap16,
          Text('Chua co bai tap', style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
          AppSpacing.vGap8,
          Text(
            'Bai hoc nay chua co bai tap hoac quiz',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 20, color: cs.primary),
              AppSpacing.hGap8,
              Text('Ghi chu cua ban', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          AppSpacing.vGap12,
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(
                  hintText: 'Viet ghi chu...',
                  hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
                style: tt.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, LessonSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasPrev = widget.currentIndex > 0;
    final hasNext = widget.currentIndex < widget.totalLessons - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          // Prev button
          Expanded(
            child: InkWell(
              onTap: hasPrev ? () => widget.onNavigate?.call(-1) : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left_rounded, size: 20, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bai truoc', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                          Text(
                            hasPrev ? 'Gioi thieu khoa hoc' : '--',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.hGap12,

          // Progress
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.currentIndex + 1}/${widget.totalLessons}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
              ),
              Text('Bai hoc', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          AppSpacing.hGap12,

          // Next button
          Expanded(
            child: FilledButton(
              onPressed: () => _onNextPressed(state, hasNext),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasNext ? 'Bai tiep theo' : 'Hoan thanh',
                          style: tt.labelMedium?.copyWith(color: cs.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    hasNext ? Icons.chevron_right_rounded : Icons.check_rounded,
                    size: 20,
                    color: cs.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
