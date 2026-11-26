import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục xem lại câu hỏi phong cách Biên tập Tạp chí Học thuật (Editorial Question Review Entry)
/// Xóa bỏ hoàn toàn hiện tượng Hộp lồng trong Hộp (Box-in-Box Container Fatigue)
class QuestionReviewCard extends StatelessWidget {
  const QuestionReviewCard({
    super.key,
    required this.index,
    this.reviewItem,
    this.question,
    this.userAnswer,
  });

  final int index;
  final QuizReviewItemModel? reviewItem;
  final QuizQuestionModel? question;
  /// int (1 lựa chọn) hoặc Iterable<int> (nhiều lựa chọn)
  final Object? userAnswer;

  bool get isSkipped {
    if (reviewItem != null) {
      return reviewItem!.isSkipped || reviewItem!.selectedAnswerIds.isEmpty;
    }
    final answer = userAnswer;
    return answer == null || (answer is Iterable && answer.isEmpty);
  }

  bool get isCorrect {
    if (reviewItem != null) {
      return reviewItem!.isCorrect;
    }
    return question?.isAnsweredCorrectly(userAnswer) ?? false;
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
    return question?.correctAnswers.contains(optIndex) ?? false;
  }

  bool _isAnswerSelected(QuizAnswerModel answer, int optIndex) {
    if (reviewItem != null) {
      return reviewItem!.selectedAnswerIds.contains(answer.id);
    }
    final selected = userAnswer;
    if (selected is Iterable) return selected.contains(optIndex);
    return optIndex == selected;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (isCorrect) {
      statusColor = const Color(0xFF059669);
      statusLabel = 'Chính xác';
      statusIcon = Icons.check_circle_rounded;
    } else if (isSkipped) {
      statusColor = cs.slate400;
      statusLabel = 'Chưa làm';
      statusIcon = Icons.remove_circle_outline_rounded;
    } else {
      statusColor = const Color(0xFFDC2626);
      statusLabel = 'Chưa chính xác';
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.slate200.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Câu X + Question Title + Status Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index Display: Câu X kiểu tạp chí
              Text(
                'Câu $index',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                  color: cs.slate500,
                  height: 1.3,
                ),
              ),
              const SizedBox(width: 8),

              // Question Title
              Expanded(
                child: Text(
                  questionTitle,
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    color: cs.slate900,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Minimal Status Tag (Không viền hộp dày)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 15, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isMultipleChoice) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Chọn nhiều',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• Câu hỏi chọn nhiều hơn một đáp án',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: cs.slate500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Options List (Danh sách phẳng sạch sẽ, không hộp lồng hộp)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: answers.asMap().entries.map((entry) {
                final optIndex = entry.key;
                final answer = entry.value;
                final isOptCorrect = _isAnswerCorrect(answer, optIndex);
                final isOptSelected = _isAnswerSelected(answer, optIndex);

                final labelLetter = String.fromCharCode(65 + optIndex); // A, B, C...

                var textColor = cs.slate700;
                var itemBg = Colors.transparent;
                Widget leadIcon;
                Widget? annotation;

                if (isOptCorrect && isOptSelected) {
                  // Bạn đã chọn đúng
                  textColor = const Color(0xFF065F46);
                  itemBg = const Color(0xFFECFDF5).withValues(alpha: 0.8);
                  leadIcon = const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  );
                  annotation = const Text(
                    'Bạn đã chọn đúng',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  );
                } else if (isOptCorrect && !isOptSelected) {
                  // Đáp án đúng (bạn bỏ sót)
                  textColor = const Color(0xFF047857);
                  itemBg = const Color(0xFFF0FDF4).withValues(alpha: 0.6);
                  leadIcon = const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  );
                  annotation = Text(
                    isMultipleChoice
                        ? 'Đáp án đúng (Chưa chọn)'
                        : 'Đáp án đúng',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  );
                } else if (isOptSelected && !isOptCorrect) {
                  // Bạn chọn sai
                  textColor = const Color(0xFF991B1B);
                  itemBg = const Color(0xFFFEF2F2).withValues(alpha: 0.8);
                  leadIcon = const Icon(
                    Icons.cancel_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  );
                  annotation = const Text(
                    '(Bạn đã chọn)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  );
                } else {
                  // Phương án bình thường
                  leadIcon = Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.slate300,
                        width: 1.2,
                      ),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      leadIcon,
                      const SizedBox(width: 8),
                      Text(
                        '$labelLetter.',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          answer.answerText,
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: (isOptCorrect || isOptSelected)
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (annotation != null) ...[
                        const SizedBox(width: 8),
                        annotation,
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Pedagogical Footnote Explanation (Phong cách Notion Callout)
          if (explanationText != null) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(6),
                ),
                border: Border(
                  left: BorderSide(
                    color: Color(0xFF2563EB), // Vạch chỉ thị Academic Blue
                    width: 2.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Giải thích kiến thức',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanationText!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate700,
                      fontSize: 13,
                      height: 1.45,
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
