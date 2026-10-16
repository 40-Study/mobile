import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class QuestionReviewCard extends StatelessWidget {
  const QuestionReviewCard({
    super.key,
    required this.index,
    this.reviewItem,
    this.question,
    this.userAnswerIndex,
  });

  final int index;
  final QuizReviewItemModel? reviewItem;
  final QuizQuestionModel? question;
  final int? userAnswerIndex;

  bool get isSkipped {
    if (reviewItem != null) {
      return reviewItem!.isSkipped || reviewItem!.selectedAnswerIds.isEmpty;
    }
    return userAnswerIndex == null;
  }

  bool get isCorrect {
    if (reviewItem != null) {
      return reviewItem!.isCorrect;
    }
    return userAnswerIndex != null &&
        question != null &&
        userAnswerIndex == question!.correctAnswer;
  }

  String get questionTitle =>
      reviewItem?.questionText ?? question?.question ?? '';

  List<QuizAnswerModel> get answers =>
      reviewItem?.answers ?? question?.answers ?? const [];

  bool get isMultipleChoice {
    if (reviewItem != null) {
      return reviewItem!.correctAnswerIds.length > 1;
    }
    return question?.isMultipleChoice ?? false;
  }

  String? get explanationText {
    final exp = reviewItem?.explanation ?? question?.explanation;
    if (exp != null && exp.trim().isNotEmpty) {
      return exp.trim();
    }
    return null;
  }

  bool _isAnswerCorrect(QuizAnswerModel answer, int optIndex) {
    if (reviewItem != null) {
      return reviewItem!.correctAnswerIds.contains(answer.id);
    }
    return question != null && optIndex == question!.correctAnswer;
  }

  bool _isAnswerSelected(QuizAnswerModel answer, int optIndex) {
    if (reviewItem != null) {
      return reviewItem!.selectedAnswerIds.contains(answer.id);
    }
    return optIndex == userAnswerIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Color badgeBg;
    final Color badgeColor;
    final IconData badgeIcon;
    final String badgeLabel;

    if (isCorrect) {
      badgeBg = const Color(0xFFECFDF5);
      badgeColor = const Color(0xFF059669);
      badgeIcon = Icons.check_circle_rounded;
      badgeLabel = 'Chính xác';
    } else if (isSkipped) {
      badgeBg = const Color(0xFFF3F4F6);
      badgeColor = const Color(0xFF6B7280);
      badgeIcon = Icons.help_outline_rounded;
      badgeLabel = 'Chưa làm';
    } else {
      badgeBg = const Color(0xFFFEF2F2);
      badgeColor = const Color(0xFFDC2626);
      badgeIcon = Icons.cancel_rounded;
      badgeLabel = 'Chưa chính xác';
    }

    final borderColor = isCorrect
        ? const Color(0xFF059669).withValues(alpha: 0.3)
        : isSkipped
            ? cs.outlineVariant.withValues(alpha: 0.35)
            : const Color(0xFFDC2626).withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: 1.2),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  if (isMultipleChoice) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Chọn nhiều',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
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
            questionTitle,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
              height: 1.4,
            ),
          ),
          AppSpacing.vGap12,

          // Options list
          ...answers.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final answer = entry.value;
            final isCorrectOption = _isAnswerCorrect(answer, optIndex);
            final isUserSelected = _isAnswerSelected(answer, optIndex);

            Color optionBg = cs.surfaceContainerHighest.withValues(alpha: 0.4);
            Color optionBorder = cs.outlineVariant.withValues(alpha: 0.3);
            Color textColor = cs.onSurface;
            Widget? trailingWidget;

            if (isCorrectOption && isUserSelected) {
              optionBg = const Color(0xFFECFDF5);
              optionBorder = const Color(0xFF059669);
              textColor = const Color(0xFF065F46);
              trailingWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Bạn đã chọn đúng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              );
            } else if (isCorrectOption && !isUserSelected) {
              optionBg = const Color(0xFFF0FDF4);
              optionBorder = const Color(0xFF10B981).withValues(alpha: 0.6);
              textColor = const Color(0xFF047857);
              trailingWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMultipleChoice
                        ? 'Đáp án đúng (Chưa chọn)'
                        : 'Đáp án đúng',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              );
            } else if (isUserSelected && !isCorrectOption) {
              optionBg = const Color(0xFFFEF2F2);
              optionBorder = const Color(0xFFDC2626);
              textColor = const Color(0xFF991B1B);
              trailingWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Bạn đã chọn (Sai)',
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

          // Pedagogical Explanation Box
          if (explanationText != null) ...[
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
                          explanationText!,
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
