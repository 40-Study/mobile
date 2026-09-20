import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/repository/student_repository.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this._repository) : super(const QuizInitial()) {
    on<QuizStarted>(_onStarted);
    on<QuizAnswerSelected>(_onAnswerSelected);
    on<QuizNextQuestion>(_onNextQuestion);
    on<QuizPreviousQuestion>(_onPreviousQuestion);
    on<QuizGoToQuestion>(_onGoToQuestion);
    on<QuizSubmitted>(_onSubmitted);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    QuizStarted event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());

    final result = await _repository.startQuiz(event.quizId);

    result.when(
      success: (data) {
        if (data.questions.isEmpty) {
          emit(const QuizFailure('Không có câu hỏi'));
          return;
        }
        emit(QuizReady(
          quizId: event.quizId,
          attemptId: data.attemptId,
          questions: data.questions,
          currentIndex: 0,
          answers: const {},
          timeLimitMinutes: data.timeLimitMinutes,
        ));
      },
      failure: (failure) {
        emit(QuizFailure(failure.message ?? 'Đã có lỗi xảy ra'));
      },
    );
  }

  void _onAnswerSelected(
    QuizAnswerSelected event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizReady) return;

    final newAnswers = Map<int, int>.from(current.answers);
    newAnswers[event.questionIndex] = event.answerIndex;

    emit(current.copyWith(answers: newAnswers));
  }

  void _onNextQuestion(
    QuizNextQuestion event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizReady) return;
    if (current.isLastQuestion) return;

    emit(current.copyWith(currentIndex: current.currentIndex + 1));
  }

  void _onPreviousQuestion(
    QuizPreviousQuestion event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizReady) return;
    if (current.isFirstQuestion) return;

    emit(current.copyWith(currentIndex: current.currentIndex - 1));
  }

  void _onGoToQuestion(
    QuizGoToQuestion event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizReady) return;
    if (event.index < 0 || event.index >= current.questions.length) return;

    emit(current.copyWith(currentIndex: event.index));
  }

  Future<void> _onSubmitted(
    QuizSubmitted event,
    Emitter<QuizState> emit,
  ) async {
    final current = state;
    if (current is! QuizReady) return;

    emit(const QuizSubmitting());

    // Convert answers: questionIndex -> answerIndex to [{question_id, selected_answer_ids}]
    final apiAnswers = <Map<String, dynamic>>[];
    for (final entry in current.answers.entries) {
      final questionIndex = entry.key;
      final answerIndex = entry.value;
      final question = current.questions[questionIndex];
      if (answerIndex < question.answers.length) {
        apiAnswers.add({
          'question_id': question.id,
          'selected_answer_ids': [question.answers[answerIndex].id],
        });
      }
    }

    final result = await _repository.submitQuiz(current.quizId, current.attemptId, apiAnswers);

    switch (result) {
      case Success(value: final submitResult):
        // Tính correct count từ percentage (vì backend không gửi is_correct)
        final totalCount = current.questions.length;
        final correctCount = (submitResult.percentage * totalCount / 100).round();

        // Lưu kết quả vào local storage
        await QuizResultStorage.saveResult(
          quizId: current.quizId,
          correctCount: correctCount,
          totalCount: totalCount,
          score: submitResult.percentage,
        );

        emit(QuizCompleted(
          correctCount: correctCount,
          totalCount: totalCount,
          score: submitResult.percentage,
          timeLimitMinutes: current.timeLimitMinutes,
        ));

      case FailureResult(error: final error):
        emit(QuizFailure(error.message ?? 'Không thể nộp bài'));
    }
  }
}
