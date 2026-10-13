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
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Câu $questionNumber / $totalQuestions',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: cs.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Text(
            question,
            style: tt.titleMedium?.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              height: 1.45,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
