import 'package:equatable/equatable.dart';

sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

final class QuizStarted extends QuizEvent {
  const QuizStarted(this.quizId);

  final String quizId;

  @override
  List<Object?> get props => [quizId];
}

final class QuizAnswerSelected extends QuizEvent {
  const QuizAnswerSelected(this.questionIndex, this.answerIndex);

  final int questionIndex;
  final int answerIndex;

  @override
  List<Object?> get props => [questionIndex, answerIndex];
}

final class QuizNextQuestion extends QuizEvent {
  const QuizNextQuestion();
}

final class QuizPreviousQuestion extends QuizEvent {
  const QuizPreviousQuestion();
}

final class QuizGoToQuestion extends QuizEvent {
  const QuizGoToQuestion(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class QuizSubmitted extends QuizEvent {
  const QuizSubmitted();
}
