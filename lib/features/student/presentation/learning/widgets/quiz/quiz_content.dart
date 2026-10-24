import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/theme/theme.dart';

import 'answer_option.dart';
import 'question_card.dart';
import 'quiz_bottom_bar.dart';
import 'quiz_header.dart';
import 'quiz_progress.dart';

/// Main content khi quiz đang active
/// Thiết kế mở thoáng đãng, Slim Progress Bar ở Header, loại bỏ Container Fatigue
class QuizContent extends StatefulWidget {
  const QuizContent({
    super.key,
    required this.state,
    required this.title,
  });

  final QuizReady state;
  final String title;

  @override
  State<QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.state.currentIndex);
  }

  @override
  void didUpdateWidget(covariant QuizContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.currentIndex != oldWidget.state.currentIndex) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.state.currentIndex) {
        _pageController.animateToPage(
          widget.state.currentIndex,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Column(
      children: [
        // Slim Header: Title, counter, countdown timer, palette button, and 4px slim progress bar
        QuizHeader(
          title: widget.title,
          duration: state.timeLimitMinutes,
          totalQuestions: state.questions.length,
          currentIndex: state.currentIndex,
          answeredCount: state.answers.length,
          onOpenPalette: () => showQuestionPaletteBottomSheet(
            context: context,
            questionsCount: state.questions.length,
            currentIndex: state.currentIndex,
            answers: state.answers,
            flaggedQuestions: state.flaggedQuestions,
            onQuestionTap: (index) =>
                context.read<QuizBloc>().add(QuizGoToQuestion(index)),
            onSubmitQuiz: () =>
                context.read<QuizBloc>().add(const QuizSubmitted()),
          ),
          onTimeUp: () => context.read<QuizBloc>().add(const QuizSubmitted()),
        ),

        // Open focused question body with native PageView swipe gestures
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: state.questions.length,
            onPageChanged: (pageIndex) {
              if (pageIndex != state.currentIndex) {
                context.read<QuizBloc>().add(QuizGoToQuestion(pageIndex));
              }
            },
            itemBuilder: (context, qIndex) {
              final question = state.questions[qIndex];
              final selectedAnswerIndices =
                  state.answers[qIndex] ?? const <int>{};
              final isFlagged = state.isQuestionFlagged(qIndex);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  16,
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Open Hero Question (no bulky card box)
                    QuestionCard(
                      questionNumber: qIndex + 1,
                      totalQuestions: state.questions.length,
                      question: question.question,
                      isFlagged: isFlagged,
                      isMultipleChoice: question.isMultipleChoice,
                      onToggleFlag: () => context
                          .read<QuizBloc>()
                          .add(QuizQuestionFlagToggled(qIndex)),
                    ),
                    const SizedBox(height: 28),

                    // Tactile Answer Options
                    ...question.options.asMap().entries.map((entry) {
                      final optIndex = entry.key;
                      final option = entry.value;
                      final isSelected = selectedAnswerIndices.contains(optIndex);

                      return AnswerOption(
                        index: optIndex,
                        text: option,
                        isSelected: isSelected,
                        isMultipleChoice: question.isMultipleChoice,
                        onTap: () => context.read<QuizBloc>().add(
                              QuizAnswerSelected(qIndex, optIndex),
                            ),
                      );
                    }),
                  ],
                ),
              );
            },

          ),
        ),

        // Bottom Navigation Bar
        QuizBottomBar(state: state),
      ],
    );
  }
}
