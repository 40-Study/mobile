import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Card hiển thị câu hỏi
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
  });

  final int questionNumber;
  final int totalQuestions;
  final String question;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Câu $questionNumber',
              style: tt.labelSmall?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          AppSpacing.vGap12,
          Text(
            question,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }
}
