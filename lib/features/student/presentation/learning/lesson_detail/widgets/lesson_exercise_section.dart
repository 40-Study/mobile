import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/presentation/learning/quiz_screen.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';
import 'package:study/theme/theme.dart';

/// Exercise tab hiển thị bài tập và quiz với giao diện thử thách gamified tinh gọn, hiện đại
class LessonExerciseSection extends StatefulWidget {
  const LessonExerciseSection({
    super.key,
    required this.state,
    required this.onQuizComplete,
  });

  final LessonSuccess state;
  final VoidCallback onQuizComplete;

  @override
  State<LessonExerciseSection> createState() => _LessonExerciseSectionState();
}

class _LessonExerciseSectionState extends State<LessonExerciseSection> {
  Map<String, QuizResultData?> _results = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllResults();
  }

  @override
  void didUpdateWidget(covariant LessonExerciseSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.quizzes != widget.state.quizzes) {
      _loadAllResults();
    }
  }

  Future<void> _loadAllResults() async {
    final quizzes = widget.state.quizzes;
    final map = <String, QuizResultData?>{};
    for (final q in quizzes) {
      map[q.id] = await QuizResultStorage.getResult(q.id);
    }
    if (mounted) {
      setState(() {
        _results = map;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final quizzes = widget.state.quizzes;
    final total = quizzes.length;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final completedCount = _results.values.where((r) => r != null).length;
    final percent = total > 0 ? (completedCount / total * 100).round() : 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Compact Gamified Progress Banner Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3D5FC4),
                  Color(0xFF2E4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D5FC4).withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFDE047),
                      size: 24,
                    ),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completedCount == total && total > 0
                            ? 'Xuất sắc! Đã hoàn thành'
                            : 'Tiến độ làm bài tập',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total == 0
                            ? 'Bài học này không có bài tập bắt buộc'
                            : '$completedCount/$total bài đã nộp • Đạt yêu cầu hoàn thành',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percent / 100,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Exercises List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách bài tập ($total)',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                  fontSize: 14,
                ),
              ),
              const Text(
                'Tối thiểu 70% để đạt',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (quizzes.isEmpty)
            _buildEmptyState(context)
          else
            ...quizzes.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final quiz = entry.value;
              final result = _results[quiz.id];
              return _buildChallengeCard(context, index, quiz, result);
            }),

          // Bottom padding to avoid LessonBottomBar overlay
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    int index,
    QuizModel quiz,
    QuizResultData? result,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDone = result != null;
    final score = result?.score ?? 0;
    final isPassed = score >= 70;

    // Difficulty config
    final difficulty = index == 1 ? 'Dễ' : (index == 2 ? 'Trung bình' : 'Nâng cao');
    final difficultyColor = index == 1
        ? const Color(0xFF10B981)
        : (index == 2 ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? (isPassed
                  ? const Color(0xFF10B981).withValues(alpha: 0.35)
                  : const Color(0xFFEF4444).withValues(alpha: 0.35))
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Lesson Number + Difficulty Badge + Score/Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5FC4).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BÀI ${index.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Color(0xFF3D5FC4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: difficultyColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),

                // Status Badge
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 13,
                          color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${score.round()}% • ${isPassed ? 'Đạt' : 'Chưa đạt'}',
                          style: TextStyle(
                            color: isPassed ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'Chưa làm',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Middle: Quiz Title
            Text(
              quiz.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Bottom Row: Specs Pills & Action CTA
            Row(
              children: [
                // Specs Pills
                _buildSpecPill(Icons.timer_outlined, '${quiz.timeLimitMinutes ?? 10}p'),
                const SizedBox(width: 6),
                _buildSpecPill(Icons.quiz_outlined, '${quiz.questionCount} câu'),
                const SizedBox(width: 6),
                _buildSpecPill(Icons.stars_outlined, '10đ'),

                const Spacer(),

                // Action CTA
                if (isDone) ...[
                  OutlinedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizScreen(
                            quizId: quiz.id,
                            title: quiz.title,
                            duration: quiz.timeLimitMinutes ?? 10,
                          ),
                        ),
                      );
                      await _loadAllResults();
                      widget.onQuizComplete();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Làm lại'),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizResultScreen(
                            title: quiz.title,
                            correct: result.correctCount,
                            total: result.totalCount,
                            score: result.score,
                            quizId: quiz.id,
                            attemptId: result.attemptId,
                            duration: quiz.timeLimitMinutes ?? 10,
                          ),

                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5FC4).withValues(alpha: 0.1),
                      foregroundColor: const Color(0xFF3D5FC4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Xem điểm'),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizScreen(
                            quizId: quiz.id,
                            title: quiz.title,
                            duration: quiz.timeLimitMinutes ?? 10,
                          ),
                        ),
                      );
                      await _loadAllResults();
                      widget.onQuizComplete();
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text('Làm bài'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5FC4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: cs.slate400),
          AppSpacing.vGap16,
          Text(
            'Chưa có bài tập',
            style: tt.titleSmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vGap8,
          Text(
            'Bài học này hiện chưa có bài tập hoặc câu hỏi trắc nghiệm',
            style: tt.bodySmall?.copyWith(color: cs.slate500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
