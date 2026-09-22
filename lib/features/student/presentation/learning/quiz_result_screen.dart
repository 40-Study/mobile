import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'quiz_screen.dart';
import 'widgets/quiz/score_circle.dart';
import 'widgets/quiz/stat_card.dart';

/// Result screen sau khi hoàn thành quiz
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.score,
    this.quizId,
    this.duration,
  });

  final String title;
  final int correct;
  final int total;
  final double score;
  final String? quizId;
  final int? duration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = score.round();
    final passed = percent >= 70;
    final wrong = total - correct;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Kết quả bài kiểm tra',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Column(
                  children: [
                    AppSpacing.vGap16,

                    // Score circle
                    ScoreCircle(percent: percent, passed: passed),

                    AppSpacing.vGap24,

                    // Message
                    Text(
                      passed ? 'Xuất sắc!' : 'Cần cố gắng thêm!',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: passed ? cs.primary : cs.error,
                      ),
                    ),
                    AppSpacing.vGap8,
                    Text(
                      passed
                          ? 'Bạn đã hoàn thành tốt bài kiểm tra'
                          : 'Hãy ôn tập và thử lại nhé',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),

                    AppSpacing.vGap32,

                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: cs.primary,
                            label: 'Câu đúng',
                            value: '$correct',
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: StatCard(
                            icon: Icons.cancel_rounded,
                            iconColor: cs.error,
                            label: 'Câu sai',
                            value: '$wrong',
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: StatCard(
                            icon: Icons.quiz_rounded,
                            iconColor: cs.tertiary,
                            label: 'Tổng câu',
                            value: '$total',
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vGap24,

                    // Progress bar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tỷ lệ đúng',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '$correct/$total câu',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: passed ? cs.primary : cs.error,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap12,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? correct / total : 0,
                              backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                              color: passed ? cs.primary : cs.error,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Passing threshold info
                    AppSpacing.vGap16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: (passed ? cs.primary : cs.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            passed
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: passed ? cs.primary : cs.error,
                          ),
                          AppSpacing.hGap8,
                          Text(
                            passed ? 'Đạt yêu cầu (≥70%)' : 'Chưa đạt yêu cầu (cần ≥70%)',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: passed ? cs.primary : cs.error,
                            ),
                          ),
                        ],
                      ),
                    ),

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
                  top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text('Quay lại bài học'),
                    ),
                  ),
                  if (quizId != null) ...[
                    AppSpacing.hGap12,
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuizScreen(
                                quizId: quizId!,
                                title: title,
                                duration: duration ?? 5,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Làm lại'),
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
}
