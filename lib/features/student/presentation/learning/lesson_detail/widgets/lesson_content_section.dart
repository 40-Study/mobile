import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/lesson_content_item.dart';
import 'package:study/theme/theme.dart';

/// Content tab hiển thị nội dung bài học, mục tiêu và lộ trình chi tiết
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final lesson = state.lesson;
    final contents = lesson.contents ?? [];
    final totalSeconds = contents.fold<int>(0, (sum, c) => sum + c.duration);
    final isDone = state.isCompleted;
    final progressVal = isDone ? 1.0 : 0.65;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Tiến trình bài học
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : cs.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Buổi $sectionNumber • Bài $lessonInSection',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF059669).withValues(alpha: 0.1)
                            : cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded,
                            size: 13,
                            color: isDone ? const Color(0xFF059669) : cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDone ? 'Đã hoàn thành' : 'Đang học',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDone ? const Color(0xFF059669) : cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap12,
                Text(
                  lesson.title,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vGap8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ bài học: ${(progressVal * 100).round()}%',
                      style: tt.bodySmall?.copyWith(color: cs.slate500),
                    ),
                    Text(
                      '${_formatTime((totalSeconds * progressVal).round())} / ${_formatTime(totalSeconds)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 7,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? const Color(0xFF059669) : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Mục tiêu bài học (Key Takeaways)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.amber.shade800,
                        size: 18,
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      'Mục tiêu bài học (Key Takeaways)',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap12,
                _buildTakeawayItem(
                  context,
                  'Hiểu rõ cấu trúc và phương pháp tiếp cận các thành phần cốt lõi.',
                ),
                AppSpacing.vGap8,
                _buildTakeawayItem(
                  context,
                  'Thực hành viết mã và ứng dụng trực tiếp vào dự án thực chiến.',
                ),
                AppSpacing.vGap8,
                _buildTakeawayItem(
                  context,
                  'Làm bài trắc nghiệm củng cố kiến thức và khắc sâu kỹ năng chuyên môn.',
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          // 3. Lộ trình bài học (Timeline Sub-lessons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lộ trình chi tiết',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                ),
              ),
              Text(
                '${contents.length} phần học',
                style: tt.bodySmall?.copyWith(color: cs.slate500),
              ),
            ],
          ),
          AppSpacing.vGap12,
          if (contents.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              child: Text(
                'Chưa có danh sách bài học con',
                style: tt.bodySmall?.copyWith(color: cs.slate500),
              ),
            )
          else
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

  Widget _buildTakeawayItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_outline_rounded, size: 15, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
