import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/theme/theme.dart';

/// Card hiển thị câu hỏi với Hero Typography và Minimalist Meta Strip
/// Loại bỏ hoàn toàn Pill Overdose (viên nhộng lơ lửng) và viền hộp thô
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
    this.isFlagged = false,
    this.isMultipleChoice = false,
    this.onToggleFlag,
  });

  final int questionNumber;
  final int totalQuestions;
  final String question;
  final bool isFlagged;
  final bool isMultipleChoice;
  final VoidCallback? onToggleFlag;

  void _handleToggleFlag() {
    HapticFeedback.selectionClick();
    onToggleFlag?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimalist Meta Strip
          Row(
            children: [
              // 1. Text Tracking Chữ hoa: Câu X / Y
              Text(
                'Câu $questionNumber / $totalQuestions',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: cs.slate500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),

              // 2. Micro-badge "Chọn nhiều đáp án" (Indigo Slate thanh nhã)
              if (isMultipleChoice) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF), // Indigo 50
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE).withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.checklist_rounded,
                        size: 13,
                        color: Color(0xFF4F46E5), // Indigo 600
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Chọn nhiều đáp án',
                        style: tt.labelSmall?.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // 3. Squircle Bookmark Button
              if (onToggleFlag != null)
                InkWell(
                  onTap: _handleToggleFlag,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFlagged
                          ? const Color(0xFFFFFBEB) // Amber 50
                          : cs.slate100.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFlagged
                            ? const Color(0xFFFDE68A)
                            : Colors.transparent,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFlagged
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 15,
                          color: isFlagged
                              ? const Color(0xFFD97706)
                              : cs.slate400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFlagged ? 'Đã ghim' : 'Xem lại',
                          style: tt.labelSmall?.copyWith(
                            color: isFlagged
                                ? const Color(0xFFB45309)
                                : cs.slate500,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Hero Question Typography (Open, Breathable, Bold)
          Text(
            question,
            style: tt.titleLarge?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.45,
              letterSpacing: -0.2,
              color: cs.slate900,
            ),
          ),

          if (isMultipleChoice) ...[
            const SizedBox(height: 6),
            Text(
              'Có thể chọn nhiều hơn một đáp án đúng',
              style: tt.bodySmall?.copyWith(
                color: cs.slate400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
