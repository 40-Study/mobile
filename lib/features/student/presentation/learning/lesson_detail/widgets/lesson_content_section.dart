import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/lesson_content_item.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/session_info_card.dart';
import 'package:study/theme/theme.dart';

/// Content tab hiển thị nội dung bài học
class LessonContentSection extends StatelessWidget {
  const LessonContentSection({
    super.key,
    required this.state,
    required this.sectionNumber,
    required this.lessonInSection,
  });

  final LessonSuccess state;
  final int sectionNumber;
  final int lessonInSection;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lesson = state.lesson;
    final contents = lesson.contents ?? [];
    final totalSeconds = contents.fold<int>(0, (sum, c) => sum + c.duration);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionInfoCard(
            sessionNumber: sectionNumber,
            lessonInSection: lessonInSection,
            sessionTitle: lesson.title,
            progress: state.isCompleted ? 100 : 0,
            currentTime: state.isCompleted ? _formatTime(totalSeconds) : '0:00',
            totalTime: _formatTime(totalSeconds),
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
