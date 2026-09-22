import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/theme/theme.dart';

import 'quiz_header.dart';
import 'quiz_progress.dart';
import 'question_card.dart';
import 'answer_option.dart';
import 'quiz_bottom_bar.dart';

/// Main content khi quiz đang active
class QuizContent extends StatelessWidget {
  const QuizContent({
    super.key,
    required this.state,
    required this.title,
  });

  final QuizReady state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;

    return Column(
      children: [
        QuizHeader(
          title: title,
          duration: state.timeLimitMinutes,
          totalQuestions: state.questions.length,
          onTimeUp: () => context.read<QuizBloc>().add(const QuizSubmitted()),
        ),
        QuizProgress(
          questionsCount: state.questions.length,
          currentIndex: state.currentIndex,
          answers: state.answers,
          onQuestionTap: (index) => context.read<QuizBloc>().add(QuizGoToQuestion(index)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionCard(
                  questionNumber: state.currentIndex + 1,
                  totalQuestions: state.questions.length,
                  question: question.question,
                ),
                AppSpacing.vGap24,
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = state.currentAnswer == index;

                  return AnswerOption(
                    index: index,
                    text: option,
                    isSelected: isSelected,
                    onTap: () => context.read<QuizBloc>().add(
                          QuizAnswerSelected(state.currentIndex, index),
                        ),
                  );
                }),
              ],
            ),
          ),
        ),
        QuizBottomBar(state: state),
      ],
    );
  }
}
