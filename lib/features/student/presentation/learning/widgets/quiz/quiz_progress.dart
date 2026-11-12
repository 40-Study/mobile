import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Progress Bar với question indicators & Clean Seat-Map Style Palette Bottom Sheet
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.slate200.withValues(alpha: 0.8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TIẾN ĐỘ: $answeredCount/$questionsCount CÂU',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                  color: cs.slate500,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _openPalette(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grid_view_rounded,
                          size: 13, color: cs.slate600),
                      const SizedBox(width: 4),
                      Text(
                        'Ma trận',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: questionsCount > 0 ? answeredCount / questionsCount : 0.0,
              backgroundColor: cs.slate200.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper mở ma trận câu hỏi phong cách Clean Seat-Map
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              // Drag Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cs.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title and counts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MA TRẬN CÂU HỎI ($answeredCount/$questionsCount)',
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      fontSize: 13,
                      color: cs.slate900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Minimal Text Legend
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _buildMinimalLegend(
                    cs,
                    tt,
                    dotColor: const Color(0xFF2563EB),
                    label: 'Đang làm',
                  ),
                  _buildMinimalLegend(
                    cs,
                    tt,
                    dotColor: const Color(0xFF10B981),
                    label: 'Đã làm',
                  ),
                  _buildMinimalLegend(
                    cs,
                    tt,
                    dotColor: cs.slate300,
                    label: 'Chưa làm',
                  ),
                  if (flaggedCount > 0)
                    _buildMinimalLegend(
                      cs,
                      tt,
                      dotColor: const Color(0xFFF59E0B),
                      label: 'Đã ghim ($flaggedCount)',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 0.8, color: cs.slate200),
              const SizedBox(height: 14),

              // Grid 5 columns (Clean Seat-Map Style)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: questionsCount,
                    itemBuilder: (context, index) {
                      final isCurrent = index == currentIndex;
                      final ans = answers[index];
                      final isAnswered =
                          ans != null && (ans is! Set || ans.isNotEmpty);
                      final isFlagged = flaggedQuestions.contains(index);

                      final Color tileBg;
                      final Color tileBorder;
                      final Color numColor;

                      if (isCurrent) {
                        tileBg = const Color(0xFF2563EB); // Royal Blue
                        tileBorder = const Color(0xFF1D4ED8);
                        numColor = Colors.white;
                      } else if (isAnswered) {
                        tileBg = Colors.white;
                        tileBorder = cs.slate300;
                        numColor = cs.slate900;
                      } else {
                        tileBg = cs.slate100;
                        tileBorder = cs.slate200;
                        numColor = cs.slate500;
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          onQuestionTap(index);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tileBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tileBorder,
                              width: isCurrent ? 1.5 : 0.8,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: numColor,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),

                              // Indicator Dot cho câu đã làm (ở đáy)
                              if (isAnswered && !isCurrent)
                                Positioned(
                                  bottom: 5,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                              // Flag icon cho câu ghim (ở góc trên)
                              if (isFlagged)
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: Icon(
                                    Icons.bookmark_rounded,
                                    size: 11,
                                    color: isCurrent
                                        ? Colors.white
                                        : const Color(0xFFD97706),
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

              // Bottom Submit CTA
              if (onSubmitQuiz != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onSubmitQuiz();
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 17),
                    label: Text(
                      unansweredCount > 0
                          ? 'Nộp bài (Còn $unansweredCount câu chưa làm)'
                          : 'Nộp bài kiểm tra ngay',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
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

Widget _buildMinimalLegend(
  ColorScheme cs,
  TextTheme tt, {
  required Color dotColor,
  required String label,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.slate500,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
