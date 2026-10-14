import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class QuestionReviewCard extends StatelessWidget {
  const QuestionReviewCard({
    super.key,
    required this.index,
    required this.question,
    required this.userAnswerIndex,
  });

  final int index;
  final QuizQuestionModel question;
  final int? userAnswerIndex;

  bool get isCorrect =>
      userAnswerIndex != null && userAnswerIndex == question.correctAnswer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final badgeBg = isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final badgeColor = isCorrect ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF059669).withValues(alpha: 0.3)
              : const Color(0xFFDC2626).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Index & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Câu $index',
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Chính xác' : 'Chưa chính xác',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // Question text
          Text(
            question.question,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
              height: 1.4,
            ),
          ),
          AppSpacing.vGap12,

          // Options list
          ...question.answers.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final answer = entry.value;
            final isCorrectOption = optIndex == question.correctAnswer;
            final isUserSelected = optIndex == userAnswerIndex;

            Color optionBg = cs.surfaceContainerHighest.withValues(alpha: 0.4);
            Color optionBorder = cs.outlineVariant.withValues(alpha: 0.3);
            Color textColor = cs.onSurface;
            Widget? trailingWidget;

            if (isCorrectOption) {
              optionBg = const Color(0xFFECFDF5);
              optionBorder = const Color(0xFF059669);
              textColor = const Color(0xFF065F46);
              trailingWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 4),
                  Text(
                    'Đáp án đúng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              );
            } else if (isUserSelected && !isCorrect) {
              optionBg = const Color(0xFFFEF2F2);
              optionBorder = const Color(0xFFDC2626);
              textColor = const Color(0xFF991B1B);
              trailingWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_rounded,
                      size: 16, color: Color(0xFFDC2626)),
                  SizedBox(width: 4),
                  Text(
                    'Bạn đã chọn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              );
            }

            final labelLetter = String.fromCharCode(65 + optIndex); // A, B, C, D

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: optionBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: optionBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCorrectOption
                          ? const Color(0xFF059669)
                          : (isUserSelected
                              ? const Color(0xFFDC2626)
                              : cs.outlineVariant.withValues(alpha: 0.4)),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      labelLetter,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (isCorrectOption || isUserSelected)
                            ? Colors.white
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppSpacing.hGap8,
                  Expanded(
                    child: Text(
                      answer.answerText,
                      style: tt.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: (isCorrectOption || isUserSelected)
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    AppSpacing.hGap8,
                    trailingWidget,
                  ],
                ],
              ),
            );
          }),

          // Explanation callout
          if (question.explanation != null &&
              question.explanation!.trim().isNotEmpty) ...[
            AppSpacing.vGap8,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: cs.primary,
                  ),
                  AppSpacing.hGap8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giải thích kiến thức',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          question.explanation!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.slate800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
