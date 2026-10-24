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
    this.flaggedQuestions = const {},
  });

  final String quizId;
  final String attemptId;
  final List<QuizQuestionModel> questions;
  final int currentIndex;
  final Map<int, Set<int>> answers;
  final int timeLimitMinutes;
  final Set<int> flaggedQuestions;

  QuizQuestionModel get currentQuestion => questions[currentIndex];
  Set<int> get currentAnswers => answers[currentIndex] ?? const {};
  int? get currentAnswer => currentAnswers.firstOrNull;
  bool isAnswerSelected(int questionIndex, int answerIndex) =>
      answers[questionIndex]?.contains(answerIndex) ?? false;
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int get answeredCount => answers.values.where((s) => s.isNotEmpty).length;
  double get progress => questions.isEmpty ? 0 : answeredCount / questions.length;
  bool isQuestionFlagged(int index) => flaggedQuestions.contains(index);

  QuizReady copyWith({
    int? currentIndex,
    Map<int, Set<int>>? answers,
    Set<int>? flaggedQuestions,
  }) {
    return QuizReady(
      quizId: quizId,
      attemptId: attemptId,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      timeLimitMinutes: timeLimitMinutes,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
    );
  }

  @override
  List<Object?> get props => [
        quizId,
        attemptId,
        questions,
        currentIndex,
        answers,
        timeLimitMinutes,
        flaggedQuestions,
      ];
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
    this.questions = const [],
    this.userAnswers = const {},
    this.reviewItems = const [],
  });

  final int correctCount;
  final int totalCount;
  final double score;
  final int timeLimitMinutes;
  final List<QuizQuestionModel> questions;
  final Map<int, Set<int>> userAnswers;
  final List<QuizReviewItemModel> reviewItems;

  @override
  List<Object?> get props => [
        correctCount,
        totalCount,
        score,
        timeLimitMinutes,
        questions,
        userAnswers,
        reviewItems,
      ];
}


final class QuizFailure extends QuizState {
  const QuizFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
