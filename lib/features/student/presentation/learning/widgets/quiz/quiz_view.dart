import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';

import 'quiz_content.dart';
import 'quiz_error_view.dart';

/// Main quiz view, listen state và route to result
class QuizView extends StatelessWidget {
  const QuizView({
    super.key,
    required this.quizId,
    required this.title,
    required this.duration,
  });

  final String quizId;
  final String title;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizCompleted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => QuizResultScreen(
                    title: title,
                    correct: state.correctCount,
                    total: state.totalCount,
                    score: state.score,
                    quizId: quizId,
                    duration: state.timeLimitMinutes,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizFailure) {
              final isMaxAttempts = state.message.contains('hết lượt');
              return QuizErrorView(
                title: title,
                message: state.message,
                isMaxAttempts: isMaxAttempts,
              );
            }

            if (state is QuizReady) {
              return QuizContent(state: state, title: title);
            }

            if (state is QuizSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
