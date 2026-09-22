import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/learning/widgets/exercise/exercise_widgets.dart';

/// Quiz card wrapper cho QuizModel từ API
class QuizCardFromModel extends StatelessWidget {
  const QuizCardFromModel({
    super.key,
    required this.index,
    required this.quiz,
    this.onComplete,
  });

  final int index;
  final QuizModel quiz;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return QuizCard(
      quizId: quiz.id,
      index: index,
      title: quiz.title,
      difficulty: 'Dễ',
      questions: quiz.questionCount ?? 0,
      duration: quiz.timeLimitMinutes ?? 10,
      points: 10,
      onComplete: onComplete,
    );
  }
}
