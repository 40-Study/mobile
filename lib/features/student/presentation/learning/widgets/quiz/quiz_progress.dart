import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Progress bar với question indicators
class QuizProgress extends StatelessWidget {
  const QuizProgress({
    super.key,
    required this.questionsCount,
    required this.currentIndex,
    required this.answers,
    required this.onQuestionTap,
  });

  final int questionsCount;
  final int currentIndex;
  final Map<int, int> answers;
  final void Function(int index) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final answeredCount = answers.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Icon(Icons.fact_check_outlined, size: 18, color: cs.primary),
              AppSpacing.hGap8,
              Text(
                'Tiến độ: $answeredCount/$questionsCount câu',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${(answeredCount / questionsCount * 100).round()}%',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(questionsCount, (index) {
                final isAnswered = answers.containsKey(index);
                final isCurrent = index == currentIndex;

                return Padding(
                  padding: EdgeInsets.only(right: index < questionsCount - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onQuestionTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primary
                            : isAnswered
                                ? cs.primary.withValues(alpha: 0.12)
                                : cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? cs.primary
                              : isAnswered
                                  ? cs.primary
                                  : cs.outlineVariant,
                          width: isCurrent ? 2 : 1.5,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isAnswered && !isCurrent
                          ? Icon(Icons.check, size: 18, color: cs.primary)
                          : Text(
                              '${index + 1}',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? cs.onPrimary
                                    : isAnswered
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
