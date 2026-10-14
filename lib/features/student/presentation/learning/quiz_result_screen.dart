import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

import 'quiz_screen.dart';
import 'widgets/quiz/question_review_card.dart';
import 'widgets/quiz/score_circle.dart';
import 'widgets/quiz/stat_card.dart';

enum QuizReviewFilter { total, correct, wrong }

/// Result screen sau khi hoàn thành quiz với bộ lọc tương tác câu đúng/sai
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.score,
    this.quizId,
    this.duration,
    this.questions = const [],
    this.userAnswers = const {},
  });

  final String title;
  final int correct;
  final int total;
  final double score;
  final String? quizId;
  final int? duration;
  final List<QuizQuestionModel> questions;
  final Map<int, int> userAnswers;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  QuizReviewFilter _selectedFilter = QuizReviewFilter.total;

  List<MapEntry<int, QuizQuestionModel>> get _filteredQuestions {
    return widget.questions.asMap().entries.where((entry) {
      final index = entry.key;
      final q = entry.value;
      final userAns = widget.userAnswers[index];
      final isCorrect = userAns != null && userAns == q.correctAnswer;

      return switch (_selectedFilter) {
        QuizReviewFilter.total => true,
        QuizReviewFilter.correct => isCorrect,
        QuizReviewFilter.wrong => !isCorrect,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = widget.score.round();
    final passed = percent >= 70;
    final wrong = widget.total - widget.correct;

    final String headline;
    final String subtitle;
    if (percent >= 90) {
      headline = 'Xuất sắc! 🎉';
      subtitle = 'Bạn đã nắm rất vững kiến thức của bài học!';
    } else if (percent >= 70) {
      headline = 'Chúc mừng bạn đã đạt! 👏';
      subtitle = 'Bạn đã hoàn thành tốt bài kiểm tra này.';
    } else if (percent >= 50) {
      headline = 'Cần cố gắng thêm! 💪';
      subtitle = 'Bạn gần đạt rồi, hãy ôn tập lại và thử lại nhé.';
    } else {
      headline = 'Chưa đạt yêu cầu 📚';
      subtitle = 'Hãy xem lại bài giảng và làm lại bài kiểm tra nhé.';
    }

    final statusColor =
        passed ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final statusBg =
        passed ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    final filtered = _filteredQuestions;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Đóng',
                  ),
                  Expanded(
                    child: Text(
                      'Kết quả bài kiểm tra',
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  children: [
                    AppSpacing.vGap16,

                    // Score circle
                    ScoreCircle(percent: percent, passed: passed),

                    AppSpacing.vGap24,

                    // Message
                    Text(
                      headline,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vGap8,
                    Text(
                      subtitle,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Passing threshold info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            passed
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: statusColor,
                          ),
                          AppSpacing.hGap8,
                          Text(
                            passed
                                ? 'Đạt yêu cầu (≥70%)'
                                : 'Chưa đạt yêu cầu (cần ≥70%)',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.vGap24,

                    // Micro-copy guidance
                    if (widget.questions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Chạm vào từng thẻ bên dưới để lọc chi tiết bài làm:',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Interactive Stat cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF059669),
                            label: 'Câu đúng',
                            value: '${widget.correct}',
                            isSelected:
                                _selectedFilter == QuizReviewFilter.correct,
                            onTap: () {
                              setState(() {
                                _selectedFilter = QuizReviewFilter.correct;
                              });
                            },
                          ),
                        ),
                        AppSpacing.hGap8,
                        Expanded(
                          child: StatCard(
                            icon: Icons.cancel_rounded,
                            iconColor: const Color(0xFFDC2626),
                            label: 'Câu sai',
                            value: '$wrong',
                            isSelected:
                                _selectedFilter == QuizReviewFilter.wrong,
                            onTap: () {
                              setState(() {
                                _selectedFilter = QuizReviewFilter.wrong;
                              });
                            },
                          ),
                        ),
                        AppSpacing.hGap8,
                        Expanded(
                          child: StatCard(
                            icon: Icons.assignment_rounded,
                            iconColor: cs.primary,
                            label: 'Tổng câu',
                            value: '${widget.total}',
                            isSelected:
                                _selectedFilter == QuizReviewFilter.total,
                            onTap: () {
                              setState(() {
                                _selectedFilter = QuizReviewFilter.total;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vGap16,

                    // Active filter indicator banner
                    if (widget.questions.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              switch (_selectedFilter) {
                                QuizReviewFilter.total =>
                                  'Đang xem: Tất cả ${widget.total} câu',
                                QuizReviewFilter.correct =>
                                  'Đang xem: ${widget.correct} câu trả lời đúng',
                                QuizReviewFilter.wrong =>
                                  'Đang xem: $wrong câu chưa đúng',
                              },
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedFilter != QuizReviewFilter.total)
                              GestureDetector(
                                onTap: () => setState(() {
                                  _selectedFilter = QuizReviewFilter.total;
                                }),
                                child: Text(
                                  'Xem tất cả',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppSpacing.vGap16,

                      // Question review list or Zero state
                      if (filtered.isEmpty)
                        _buildEmptyReviewState(cs, tt)
                      else
                        ...filtered.map((entry) {
                          final questionIndex = entry.key + 1;
                          final question = entry.value;
                          final userAns = widget.userAnswers[entry.key];
                          return QuestionReviewCard(
                            index: questionIndex,
                            question: question,
                            userAnswerIndex: userAns,
                          );
                        }),
                    ],

                    AppSpacing.vGap32,
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      label: const Text('Quay về bài học'),
                    ),
                  ),
                  if (widget.quizId != null) ...[
                    AppSpacing.hGap12,
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuizScreen(
                                quizId: widget.quizId!,
                                title: widget.title,
                                duration: widget.duration ?? 5,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Làm lại bài kiểm tra'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviewState(ColorScheme cs, TextTheme tt) {
    final isWrongFilter = _selectedFilter == QuizReviewFilter.wrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isWrongFilter
                ? Icons.emoji_events_rounded
                : Icons.auto_awesome_rounded,
            size: 48,
            color: isWrongFilter ? const Color(0xFFF59E0B) : cs.primary,
          ),
          AppSpacing.vGap12,
          Text(
            isWrongFilter
                ? 'Tuyệt vời! Bạn không làm sai câu nào cả! 🎉'
                : 'Chưa có câu trả lời đúng. Hãy ôn bài và thử lại nhé! 💪',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap4,
          Text(
            isWrongFilter
                ? 'Bạn đã đạt điểm số tối đa cho toàn bộ câu hỏi.'
                : 'Xem lại bài giảng để củng cố kiến thức tốt hơn.',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
