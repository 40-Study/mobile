import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
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

    final statusColor = passed ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final statusBg = passed ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

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
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.vGap24,

                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF059669),
                            label: 'Câu đúng',
                            value: '$correct',
                          ),
                        ),
                        AppSpacing.hGap8,
                        Expanded(
                          child: StatCard(
                            icon: Icons.cancel_rounded,
                            iconColor: const Color(0xFFDC2626),
                            label: 'Câu sai',
                            value: '$wrong',
                          ),
                        ),
                        AppSpacing.hGap8,
                        Expanded(
                          child: StatCard(
                            icon: Icons.assignment_rounded,
                            iconColor: cs.primary,
                            label: 'Tổng câu',
                            value: '$total',
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vGap16,

                    // Progress bar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tỷ lệ chính xác',
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '$correct/$total câu ($percent%)',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? (correct / total).clamp(0.0, 1.0) : 0,
                              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                              color: statusColor,
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
                            passed ? 'Đạt yêu cầu (≥70%)' : 'Chưa đạt yêu cầu (cần ≥70%)',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
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
}
