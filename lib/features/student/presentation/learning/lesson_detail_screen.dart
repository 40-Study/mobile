import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_content_tabs.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_nav_bar.dart';
import 'package:study/theme/theme.dart';

class LessonDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          return switch (state) {
            LessonInitial() || LessonInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LessonSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lesson = state.lesson;

    return Column(
      children: [
        // Video player area
        Container(
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Video placeholder
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: state.videoUrl != null
                        ? Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_off,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                AppSpacing.vGap8,
                                Text(
                                  'Không có video',
                                  style: tt.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content area
        Expanded(
          child: Column(
            children: [
              // Lesson info + tabs
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (lesson.durationMinutes > 0) ...[
                      AppSpacing.vGap4,
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: cs.outline),
                          AppSpacing.hGap4,
                          Text(
                            '${lesson.durationMinutes} phút',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    AppSpacing.vGap16,
                    LessonContentTabs(
                      selectedTab: state.selectedTab,
                      onTabChanged: (tab) {
                        context.read<LessonBloc>().add(
                          LessonContentTabChanged(tab),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: _buildTabContent(context, state),
                ),
              ),
            ],
          ),
        ),

        // Bottom nav bar
        LessonNavBar(
          currentIndex: currentIndex,
          totalLessons: totalLessons,
          isCompleted: state.isCompleted,
          onPrev: currentIndex > 0 ? () => onNavigate?.call(-1) : null,
          onNext: currentIndex < totalLessons - 1
              ? () => onNavigate?.call(1)
              : null,
          onComplete: () {
            context.read<LessonBloc>().add(const LessonCompleted());
          },
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, LessonSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return switch (state.selectedTab) {
      LessonContentTab.video => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vGap8,
          Text(
            state.lesson.description ?? 'Không có mô tả',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          AppSpacing.vGap24,
        ],
      ),
      LessonContentTab.documents => _buildEmptyTab(
        context,
        Icons.description_outlined,
        'Chưa có tài liệu',
      ),
      LessonContentTab.quiz => _buildEmptyTab(
        context,
        Icons.quiz_outlined,
        'Chưa có bài tập',
      ),
      LessonContentTab.notes => _buildEmptyTab(
        context,
        Icons.edit_note,
        'Chưa có ghi chú',
      ),
    };
  }

  Widget _buildEmptyTab(BuildContext context, IconData icon, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(icon, size: 48, color: cs.onSurfaceVariant),
            AppSpacing.vGap12,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
