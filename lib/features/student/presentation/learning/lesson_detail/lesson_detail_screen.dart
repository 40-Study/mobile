import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/presentation/learning/lesson_detail/widgets/widgets.dart';
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

  void _markComplete(
    BuildContext context,
    String lessonId, {
    List<List<int>>? playedRanges,
    int? durationSeconds,
  }) {
    // Bloc handles repo call, state update triggers dialog via BlocConsumer listener
    context.read<LessonBloc>().add(LessonCompleted(
      playedRanges: playedRanges,
      durationSeconds: durationSeconds,
    ));
  }

  void _showCourseCompletedDialog() {
    showDialog<void>(
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

  Future<int> _countCompletedQuizzes(List<QuizModel> quizzes) async {
    var count = 0;
    for (final quiz in quizzes) {
      if (await QuizResultStorage.hasResult(quiz.id)) count++;
    }
    return count;
  }

  Future<void> _checkAllQuizzesComplete(BuildContext context, String lessonId, List<QuizModel> quizzes) async {
    if (quizzes.isEmpty) return;
    final completed = await _countCompletedQuizzes(quizzes);
    if (completed >= quizzes.length) _markComplete(context, lessonId);
  }

  Future<void> _onNextPressed(BuildContext context, LessonSuccess state, bool hasNext) async {
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

    _markComplete(context, state.lesson.id);
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // AppBar
        SafeArea(
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
                    'Bai ${widget.currentIndex + 1}. ${state.lesson.title}',
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
        ),

        // Video player
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: LessonVideoPlayer(
            videoUrl: state.videoUrl,
            onProgressThreshold: (ranges, duration) {
              _videoWatched = true;
              _markComplete(context, state.lesson.id, playedRanges: ranges, durationSeconds: duration);
            },
          ),
        ),

        // Tabs
        Container(
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
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              LessonContentSection(
                state: state,
                sectionNumber: widget.sectionNumber,
                lessonInSection: widget.lessonInSection,
              ),
              const LessonDocumentsSection(),
              LessonExerciseSection(
                state: state,
                onQuizComplete: () => _checkAllQuizzesComplete(context, state.lesson.id, state.quizzes),
              ),
              const LessonNotesSection(),
            ],
          ),
        ),

        // Bottom bar
        LessonBottomBar(
          currentIndex: widget.currentIndex,
          totalLessons: widget.totalLessons,
          onPrevious: () => widget.onNavigate?.call(-1),
          onNext: () => _onNextPressed(context, state, widget.currentIndex < widget.totalLessons - 1),
        ),
      ],
    );
  }
}
