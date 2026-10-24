import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Progress bar với question indicators và hỗ trợ mở Ma trận câu hỏi (Question Palette)
class QuizProgress extends StatelessWidget {
  const QuizProgress({
    super.key,
    required this.questionsCount,
    required this.currentIndex,
    required this.answers,
    required this.onQuestionTap,
    this.flaggedQuestions = const {},
    this.onSubmitQuiz,
  });

  final int questionsCount;
  final int currentIndex;
  final Map<int, dynamic> answers;
  final void Function(int index) onQuestionTap;
  final Set<int> flaggedQuestions;
  final VoidCallback? onSubmitQuiz;

  void _openPalette(BuildContext context) {
    showQuestionPaletteBottomSheet(
      context: context,
      questionsCount: questionsCount,
      currentIndex: currentIndex,
      answers: answers,
      flaggedQuestions: flaggedQuestions,
      onQuestionTap: onQuestionTap,
      onSubmitQuiz: onSubmitQuiz,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final answeredCount = answers.values
        .where((v) => v is Set ? v.isNotEmpty : v != null)
        .length;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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

              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${(questionsCount > 0 ? answeredCount / questionsCount * 100 : 0).round()}%',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              AppSpacing.hGap8,

              // Palette grid button
              InkWell(
                onTap: () => _openPalette(context),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grid_view_rounded,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        'Tất cả',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: questionsCount > 0 ? answeredCount / questionsCount : 0.0,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              minHeight: 4,
            ),
          ),
          AppSpacing.vGap12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(questionsCount, (index) {
                final ans = answers[index];
                final isAnswered = ans != null && (ans is! Set || ans.isNotEmpty);
                final isCurrent = index == currentIndex;
                final isFlagged = flaggedQuestions.contains(index);


                return Padding(
                  padding:
                      EdgeInsets.only(right: index < questionsCount - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onQuestionTap(index),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
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
                                      : (isFlagged
                                          ? const Color(0xFFF59E0B)
                                          : cs.outlineVariant),
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
                        if (isFlagged)
                          const Positioned(
                            top: -2,
                            right: -2,
                            child: Icon(
                              Icons.bookmark_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                      ],
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

/// Helper mở ma trận câu hỏi (Question Palette)
void showQuestionPaletteBottomSheet({
  required BuildContext context,
  required int questionsCount,
  required int currentIndex,
  required Map<int, dynamic> answers,
  required Set<int> flaggedQuestions,
  required void Function(int index) onQuestionTap,
  VoidCallback? onSubmitQuiz,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final tt = Theme.of(ctx).textTheme;
      final answeredCount = answers.values
          .where((v) => v is Set ? v.isNotEmpty : v != null)
          .length;
      final flaggedCount = flaggedQuestions.length;
      final unansweredCount = questionsCount - answeredCount;


      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title and counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ma trận câu hỏi ($answeredCount/$questionsCount)',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegend(cs, tt,
                      color: cs.primary, label: 'Đang làm', isCircle: true),
                  _buildLegend(cs, tt,
                      color: const Color(0xFF059669), label: 'Đã làm'),
                  _buildLegend(cs, tt,
                      color: cs.surfaceContainerHighest, label: 'Chưa làm'),
                  if (flaggedCount > 0)
                    _buildLegend(cs, tt,
                        color: const Color(0xFFF59E0B),
                        label: 'Xem lại ($flaggedCount)'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Grid 5 columns
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.42,
                ),
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: questionsCount,
                    itemBuilder: (context, index) {
                      final isCurrent = index == currentIndex;
                      final ans = answers[index];
                      final isAnswered =
                          ans != null && (ans is! Set || ans.isNotEmpty);
                      final isFlagged = flaggedQuestions.contains(index);


                      return InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          onQuestionTap(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? cs.primary.withValues(alpha: 0.15)
                                : isAnswered
                                    ? const Color(0xFFECFDF5)
                                    : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? cs.primary
                                  : isAnswered
                                      ? const Color(0xFF059669)
                                      : (isFlagged
                                          ? const Color(0xFFF59E0B)
                                          : cs.outlineVariant
                                              .withValues(alpha: 0.4)),
                              width: isCurrent ? 2.0 : 1.2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? cs.primary
                                      : isAnswered
                                          ? const Color(0xFF065F46)
                                          : cs.onSurface,
                                ),
                              ),
                              if (isFlagged)
                                const Positioned(
                                  top: 3,
                                  right: 3,
                                  child: Icon(
                                    Icons.bookmark_rounded,
                                    size: 13,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Bottom submit confirmation button if available
              if (onSubmitQuiz != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onSubmitQuiz();
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(
                      unansweredCount > 0
                          ? 'Nộp bài (Còn $unansweredCount câu chưa chọn)'
                          : 'Nộp bài kiểm tra',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildLegend(
  ColorScheme cs,
  TextTheme tt, {
  required Color color,
  required String label,
  bool isCircle = false,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isCircle ? 6 : 3),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    ],
  );
}
