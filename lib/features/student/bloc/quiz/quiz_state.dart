import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

final class QuizInitial extends QuizState {
  const QuizInitial();
}

final class QuizLoading extends QuizState {
  const QuizLoading();
}

final class QuizReady extends QuizState {
  const QuizReady({
    required this.quizId,
    required this.attemptId,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.timeLimitMinutes,
  });

  final String quizId;
  final String attemptId;
  final List<QuizQuestionModel> questions;
  final int currentIndex;
  final Map<int, int> answers;
  final int timeLimitMinutes;

  QuizQuestionModel get currentQuestion => questions[currentIndex];
  int? get currentAnswer => answers[currentIndex];
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int get answeredCount => answers.length;
  double get progress => questions.isEmpty ? 0 : answeredCount / questions.length;

  QuizReady copyWith({
    int? currentIndex,
    Map<int, int>? answers,
  }) {
    return QuizReady(
      quizId: quizId,
      attemptId: attemptId,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      timeLimitMinutes: timeLimitMinutes,
    );
  }

  @override
  List<Object?> get props => [quizId, attemptId, questions, currentIndex, answers, timeLimitMinutes];
}

final class QuizSubmitting extends QuizState {
  const QuizSubmitting();
}

final class QuizCompleted extends QuizState {
  const QuizCompleted({
    required this.correctCount,
    required this.totalCount,
    required this.score,
    required this.timeLimitMinutes,
  });

  final int correctCount;
  final int totalCount;
  final double score;
  final int timeLimitMinutes;

  @override
  List<Object?> get props => [correctCount, totalCount, score, timeLimitMinutes];
}

final class QuizFailure extends QuizState {
  const QuizFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
