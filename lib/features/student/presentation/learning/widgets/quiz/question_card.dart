import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Card hiển thị câu hỏi với Hero Typography và tính năng Cắm cờ xem lại (Flag for Review)
/// Thiết kế không gian mở (Open & Focused Layout) loại bỏ viền đóng hộp
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pill tags: Câu X / Y and Multi-select badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Câu $questionNumber / $totalQuestions',
                          style: tt.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isMultipleChoice) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.checklist_rounded,
                            size: 14,
                            color: Color(0xFF6D28D9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chọn nhiều đáp án',
                            style: tt.labelSmall?.copyWith(
                              color: const Color(0xFF6D28D9),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Flag for review button
              if (onToggleFlag != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleFlag,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFlagged
                            ? const Color(0xFFFEF3C7)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isFlagged
                              ? const Color(0xFFF59E0B)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFlagged
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 16,
                            color: isFlagged
                                ? const Color(0xFFD97706)
                                : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFlagged ? 'Đã đánh dấu' : 'Xem lại',
                            style: tt.labelSmall?.copyWith(
                              color: isFlagged
                                  ? const Color(0xFFB45309)
                                  : cs.onSurfaceVariant,
                              fontWeight: isFlagged
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: cs.primary.withValues(alpha: 0.6),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Hero question typography - open, breathable, bold
          Text(
            question,
            style: tt.titleLarge?.copyWith(
              fontSize: 19.5,
              fontWeight: FontWeight.w800,
              height: 1.42,
              letterSpacing: -0.2,
              color: cs.slate900,
            ),
          ),
          if (isMultipleChoice) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Có thể chọn nhiều hơn một đáp án đúng',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

