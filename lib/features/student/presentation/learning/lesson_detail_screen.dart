import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/presentation/learning/quiz_screen.dart';
import 'package:study/theme/theme.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    this.currentIndex = 0,
    this.totalLessons = 1,
    this.onNavigate,
  });

  final int currentIndex;
  final int totalLessons;
  final void Function(int direction)? onNavigate;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<LessonBloc, LessonState>(
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
              child: const Text('Quay lại'),
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
    final lesson = state.lesson;

    return Column(
      children: [
        // App Bar
        _buildAppBar(context, lesson),

        // Video Player
        _VideoPlayer(hasVideo: state.videoUrl != null),

        // Tabs
        _buildTabs(context),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContentTab(context, state),
              _buildDocumentsTab(context),
              _buildExerciseTab(context),
              _buildNotesTab(context),
            ],
          ),
        ),

        // Bottom Bar
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
                'Bài ${widget.currentIndex + 1}. ${lesson.title}',
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
          Tab(icon: Icon(Icons.menu_book_outlined, size: 20), text: 'Nội dung'),
          Tab(icon: Icon(Icons.description_outlined, size: 20), text: 'Tài liệu'),
          Tab(icon: Icon(Icons.edit_outlined, size: 20), text: 'Bài tập'),
          Tab(icon: Icon(Icons.sticky_note_2_outlined, size: 20), text: 'Ghi chú'),
        ],
      ),
    );
  }

  Widget _buildContentTab(BuildContext context, LessonSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lesson = state.lesson;
    final contents = lesson.contents ?? [];
    final progress = lesson.progress?.progressPercentage ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info card
          _SessionInfoCard(
            sessionNumber: 1,
            sessionTitle: lesson.title,
            progress: progress,
            currentTime: '${(lesson.durationMinutes * progress / 100).toStringAsFixed(0)}:00',
            totalTime: '${lesson.durationMinutes}:00',
          ),
          AppSpacing.vGap16,

          // Content list title
          Text(
            'Nội dung bài học',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap12,

          // Content items
          ...contents.asMap().entries.map((entry) {
            final index = entry.key;
            final content = entry.value;
            final isCompleted = index == 0;
            final isCurrent = index == 1;
            final isLocked = index > 2;

            return _LessonContentItem(
              index: index,
              content: content,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
            );
          }),

          AppSpacing.vGap24,
        ],
      ),
    );
  }

  Widget _buildEmptyTab(BuildContext context, IconData icon, String title, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, size: 32, color: cs.onSurfaceVariant),
          ),
          AppSpacing.vGap16,
          Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          AppSpacing.vGap4,
          Text(message, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
                      Text(
                        'Tải tất cả tài liệu',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '4 tệp • 12.5 MB',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Tải về'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // Slide section
          _DocumentSection(
            icon: Icons.slideshow_outlined,
            title: 'Slide bài giảng',
            children: [
              _DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Giới thiệu Python',
                subtitle: 'PDF • 2.3 MB • 15 trang',
                isDownloaded: true,
              ),
              _DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Cài đặt môi trường',
                subtitle: 'PDF • 1.8 MB • 12 trang',
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Code examples section
          _DocumentSection(
            icon: Icons.code_rounded,
            title: 'Mã nguồn mẫu',
            children: [
              _DocumentCard(
                icon: Icons.folder_zip_outlined,
                iconColor: Colors.amber.shade700,
                title: 'source_code_lesson1.zip',
                subtitle: 'ZIP • 156 KB • 5 files',
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Additional resources section
          _DocumentSection(
            icon: Icons.library_books_outlined,
            title: 'Tài liệu tham khảo',
            children: [
              _DocumentCard(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'Python Cheat Sheet',
                subtitle: 'PDF • 890 KB • 4 trang',
              ),
              _DocumentCard(
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

  Widget _buildExerciseTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress card
          _ExerciseProgressCard(completed: 2, total: 5, percent: 40),
          AppSpacing.vGap24,

          // Bài tập code section
          _ExerciseSection(
            icon: Icons.code_rounded,
            title: 'Bài tập code',
            subtitle: 'Thực hành viết và chạy code trên trình duyệt',
            children: [
              _CodeExerciseCard(
                index: 1,
                title: 'In dòng chữ đầu tiên',
                difficulty: 'Dễ',
                description: 'Viết chương trình in ra dòng chữ "Xin chào, Python!"',
                duration: 10,
                points: 10,
                completionRate: 80,
              ),
            ],
            infoText: 'Bài tập code chỉ có thể thực hiện trên website để đảm bảo trải nghiệm tốt nhất.',
          ),
          AppSpacing.vGap24,

          // Quiz section
          _ExerciseSection(
            icon: Icons.quiz_outlined,
            title: 'Quiz',
            subtitle: 'Trả lời câu hỏi trắc nghiệm',
            children: [
              _QuizCard(
                index: 2,
                title: 'Kiểm tra kiến thức',
                difficulty: 'Dễ',
                questions: 5,
                duration: 5,
                points: 10,
              ),
              _QuizCard(
                index: 3,
                title: 'Biến và kiểu dữ liệu',
                difficulty: 'Trung bình',
                difficultyColor: Colors.orange,
                questions: 8,
                duration: 8,
                points: 20,
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Bài tập tự luận section
          _ExerciseSection(
            icon: Icons.edit_outlined,
            title: 'Bài tập tự luận',
            subtitle: 'Trả lời câu hỏi ngắn hoặc giải thích',
            children: [
              _EssayCard(
                index: 4,
                title: 'Giải thích ngắn',
                difficulty: 'Dễ',
                description: 'Giải thích sự khác nhau giữa biến và hằng.',
                points: 10,
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Thử thách thêm section
          _ExerciseSection(
            icon: Icons.star_outline_rounded,
            title: 'Thử thách thêm',
            titleSuffix: '(Không bắt buộc)',
            subtitle: 'Bài tập nâng cao để luyện kỹ năng',
            children: [
              _ChallengeCard(
                index: 5,
                title: 'Tính tổng các số',
                difficulty: 'Trung bình',
                difficultyColor: Colors.orange,
                description: 'Viết chương trình tính tổng của n số tự nhiên đầu tiên.',
                duration: 20,
                points: 20,
              ),
            ],
          ),
          AppSpacing.vGap32,
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
              Text('Ghi chú của bạn', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
                  hintText: 'Viết ghi chú...',
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
    final lesson = state.lesson;
    final contents = lesson.contents ?? [];
    final currentIdx = contents.length > 1 ? 1 : 0;
    final currentContent = contents.isNotEmpty ? contents[currentIdx] : null;

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
          // Bài trước
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
                          Text(
                            'Bài trước',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            hasPrev ? 'Giới thiệu khóa học' : '--',
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

          // Progress indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.currentIndex + 1}/${widget.totalLessons}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
              ),
              Text('Bài học', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          AppSpacing.hGap12,

          // Tiếp tục học
          Expanded(
            child: FilledButton(
              onPressed: () {},
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
                        Text('Tiếp tục học', style: tt.labelMedium?.copyWith(color: cs.onPrimary)),
                        if (currentContent != null)
                          Text(
                            '${currentIdx + 1}. ${currentContent.title}',
                            style: tt.labelSmall?.copyWith(color: cs.onPrimary.withValues(alpha: 0.8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: cs.onPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Components
// =============================================================================

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer({required this.hasVideo});
  final bool hasVideo;

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  // Sample video để test
  static const _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController == null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(_sampleVideoUrl));
      _videoController = controller;

      await controller.initialize();

      if (!mounted) return;

      final primary = Theme.of(context).colorScheme.primary;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: primary,
          handleColor: primary,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(
          color: const Color(0xFF1a1a2e),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (ctx, errorMessage) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              AppSpacing.vGap8,
              Text('Không thể tải video\n$errorMessage',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e, st) {
      debugPrint('Video init error: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: const Color(0xFF1a1a2e),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                AppSpacing.vGap8,
                Text('Lỗi: $_error', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: const Color(0xFF1a1a2e),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}

class _SessionInfoCard extends StatelessWidget {
  const _SessionInfoCard({
    required this.sessionNumber,
    required this.sessionTitle,
    required this.progress,
    required this.currentTime,
    required this.totalTime,
  });

  final int sessionNumber;
  final String sessionTitle;
  final double progress;
  final String currentTime;
  final String totalTime;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Buổi $sessionNumber',
                style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('Tiến độ bài học', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              AppSpacing.hGap4,
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: tt.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          AppSpacing.vGap4,
          Row(
            children: [
              Expanded(
                child: Text(
                  sessionTitle,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$currentTime / $totalTime',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          AppSpacing.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonContentItem extends StatefulWidget {
  const _LessonContentItem({
    required this.index,
    required this.content,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocked = false,
  });

  final int index;
  final LessonContentModel content;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  State<_LessonContentItem> createState() => _LessonContentItemState();
}

class _LessonContentItemState extends State<_LessonContentItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isCurrent;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final durationMins = (widget.content.duration / 60).ceil();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Column(
            children: [
              _StatusIcon(
                isCompleted: widget.isCompleted,
                isCurrent: widget.isCurrent,
                isLocked: widget.isLocked,
              ),
              if (!widget.isLocked)
                Container(
                  width: 2,
                  height: _isExpanded ? 100 : 40,
                  color: widget.isCompleted ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          ),
          AppSpacing.hGap12,

          // Content
          Expanded(
            child: InkWell(
              onTap: widget.isLocked ? null : () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: widget.isCurrent
                      ? cs.primary.withValues(alpha: 0.05)
                      : cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: widget.isCurrent
                        ? cs.primary.withValues(alpha: 0.3)
                        : cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Type icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.isCurrent
                                ? cs.primary.withValues(alpha: 0.1)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Icon(
                            _getTypeIcon(widget.content.type),
                            size: 18,
                            color: widget.isCurrent ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.hGap12,

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.index + 1}. ${widget.content.title}',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: widget.isLocked ? cs.onSurfaceVariant : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_getTypeLabel(widget.content.type)} • ${durationMins > 0 ? '$durationMins:00' : '0:30'}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        _StatusBadge(
                          isCompleted: widget.isCompleted,
                          isCurrent: widget.isCurrent,
                          isLocked: widget.isLocked,
                        ),
                        AppSpacing.hGap4,
                        Icon(
                          _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // Expanded sub-contents
                    if (_isExpanded && !widget.isLocked) ...[
                      AppSpacing.vGap12,
                      _SubContentItem(number: '${widget.index + 1}.1', title: 'Dễ học, dễ đọc', duration: '01:20', isCompleted: true),
                      _SubContentItem(number: '${widget.index + 1}.2', title: 'Đa nền tảng', duration: '01:35', isCompleted: true),
                      _SubContentItem(number: '${widget.index + 1}.3', title: 'Thư viện phong phú', duration: '01:40', progress: 50),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) => switch (type) {
    'video' => Icons.play_circle_outline_rounded,
    'article' => Icons.description_outlined,
    'exercise' => Icons.help_outline_rounded,
    _ => Icons.play_circle_outline_rounded,
  };

  String _getTypeLabel(String type) => switch (type) {
    'video' => 'Video',
    'article' => 'Tài liệu',
    'exercise' => 'Quiz',
    _ => 'Video',
  };
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
  });

  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 14, color: cs.onPrimary),
      );
    }

    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          ),
        ),
      );
    }

    if (isLocked) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_outline_rounded, size: 12, color: cs.onSurfaceVariant),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: cs.surface,
        shape: BoxShape.circle,
        border: Border.all(color: cs.outlineVariant),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
  });

  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Đã xem', style: tt.labelSmall?.copyWith(color: cs.primary)),
          AppSpacing.hGap4,
          Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
        ],
      );
    }

    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text('Đang xem', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w500)),
      );
    }

    if (isLocked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Khóa', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          AppSpacing.hGap4,
          Icon(Icons.lock_outline_rounded, size: 14, color: cs.onSurfaceVariant),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text('Chưa học', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
    );
  }
}

class _SubContentItem extends StatelessWidget {
  const _SubContentItem({
    required this.number,
    required this.title,
    required this.duration,
    this.isCompleted = false,
    this.progress,
  });

  final String number;
  final String title;
  final String duration;
  final bool isCompleted;
  final int? progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number $title',
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(duration, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_circle_rounded, size: 18, color: cs.primary)
          else if (progress != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    value: progress! / 100,
                    strokeWidth: 2,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                AppSpacing.hGap4,
                Text('$progress%', style: tt.labelSmall?.copyWith(color: cs.primary)),
              ],
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Exercise Tab Components
// =============================================================================

class _ExerciseProgressCard extends StatelessWidget {
  const _ExerciseProgressCard({
    required this.completed,
    required this.total,
    required this.percent,
  });

  final int completed;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
            child: Icon(Icons.emoji_events_outlined, color: cs.primary, size: 28),
          ),
          AppSpacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thành bài tập để nắm vững kiến thức',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.vGap4,
                Text(
                  'Bạn cần đạt ít nhất 70% để hoàn thành bài học',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.hGap12,
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: cs.primary,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                    Text(
                      '$completed/$total bài',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
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
}

class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.titleSuffix,
    this.infoText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? titleSuffix;
  final String? infoText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            AppSpacing.hGap8,
            Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (titleSuffix != null) ...[
              AppSpacing.hGap4,
              Text(titleSuffix!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
        AppSpacing.vGap4,
        Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        AppSpacing.vGap12,
        ...children,
        if (infoText != null) ...[
          AppSpacing.vGap12,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: cs.onSurfaceVariant),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    infoText!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CodeExerciseCard extends StatelessWidget {
  const _CodeExerciseCard({
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.duration,
    required this.points,
    required this.completionRate,
  });

  final int index;
  final String title;
  final String difficulty;
  final String description;
  final int duration;
  final int points;
  final int completionRate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.code_rounded, color: cs.primary, size: 24),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$index. $title',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        AppSpacing.hGap8,
                        _DifficultyBadge(text: difficulty),
                      ],
                    ),
                    AppSpacing.vGap4,
                    Text(
                      description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.vGap8,
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$duration phút', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        AppSpacing.hGap12,
                        Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        AppSpacing.hGap12,
                        Icon(Icons.check_circle_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$completionRate% hoàn thành', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Làm bài trên web'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.index,
    required this.title,
    required this.difficulty,
    required this.questions,
    required this.duration,
    required this.points,
    this.difficultyColor,
  });

  final int index;
  final String title;
  final String difficulty;
  final Color? difficultyColor;
  final int questions;
  final int duration;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.help_outline_rounded, color: cs.primary, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    _DifficultyBadge(text: difficulty, color: difficultyColor),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  '$questions câu hỏi • $duration phút • $points điểm',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    quizId: 'quiz-$index',
                    title: title,
                    totalQuestions: questions,
                    duration: duration,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Làm bài'),
          ),
        ],
      ),
    );
  }
}

class _EssayCard extends StatelessWidget {
  const _EssayCard({
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.points,
  });

  final int index;
  final String title;
  final String difficulty;
  final String description;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.assignment_outlined, color: cs.primary, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    _DifficultyBadge(text: difficulty),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('Không giới hạn', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap12,
                    Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.duration,
    required this.points,
    this.difficultyColor,
  });

  final int index;
  final String title;
  final String difficulty;
  final Color? difficultyColor;
  final String description;
  final int duration;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.emoji_events_rounded, color: Colors.amber.shade700, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    _DifficultyBadge(text: difficulty, color: difficultyColor),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$duration phút', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap12,
                    Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Làm bài'),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badgeColor = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: tt.labelSmall?.copyWith(color: badgeColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =============================================================================
// Documents Tab Components
// =============================================================================

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            AppSpacing.hGap8,
            Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        AppSpacing.vGap12,
        ...children,
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isDownloaded = false,
    this.isLink = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDownloaded;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          if (isDownloaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                  AppSpacing.hGap4,
                  Text(
                    'Đã tải',
                    style: tt.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          else if (isLink)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Mở'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            )
          else
            IconButton.outlined(
              onPressed: () {},
              icon: Icon(Icons.download_rounded, size: 20, color: cs.primary),
              style: IconButton.styleFrom(
                side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
