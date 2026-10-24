import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/repository/student_repository.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this._repository) : super(const QuizInitial()) {
    on<QuizStarted>(_onStarted);
    on<QuizAnswerSelected>(_onAnswerSelected);
    on<QuizNextQuestion>(_onNextQuestion);
    on<QuizPreviousQuestion>(_onPreviousQuestion);
    on<QuizGoToQuestion>(_onGoToQuestion);
    on<QuizQuestionFlagToggled>(_onQuestionFlagToggled);
    on<QuizSubmitted>(_onSubmitted);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizLoading());

    final result = await _repository.startQuiz(event.quizId);

    result.when(
      success: (data) {
        if (data.questions.isEmpty) {
          emit(const QuizFailure('Không có câu hỏi'));
          return;
        }
        emit(
          QuizReady(
            quizId: event.quizId,
            attemptId: data.attemptId,
            questions: data.questions,
            currentIndex: 0,
            answers: const {},
            timeLimitMinutes: data.timeLimitMinutes,
          ),
        );
      },
      failure: (failure) {
        emit(QuizFailure(failure.message ?? 'Đã có lỗi xảy ra'));
      },
    );
  }

  void _onAnswerSelected(QuizAnswerSelected event, Emitter<QuizState> emit) {
    final current = state;
    if (current is! QuizReady) return;
    if (event.questionIndex < 0 ||
        event.questionIndex >= current.questions.length) {
      return;
    }
    final question = current.questions[event.questionIndex];
    if (event.answerIndex < 0 ||
        event.answerIndex >= question.answers.length) {
      return;
    }

    final newAnswers = Map<int, Set<int>>.from(
      current.answers.map((k, v) => MapEntry(k, Set<int>.from(v))),
    );

    final currentSet = newAnswers[event.questionIndex] ?? <int>{};
    if (question.isMultipleChoice) {
      // Toggle for multiple choice
      if (currentSet.contains(event.answerIndex)) {
        currentSet.remove(event.answerIndex);
      } else {
        currentSet.add(event.answerIndex);
      }
      if (currentSet.isEmpty) {
        newAnswers.remove(event.questionIndex);
      } else {
        newAnswers[event.questionIndex] = currentSet;
      }
    } else {
      // Single choice / true_false: replace with single answer
      newAnswers[event.questionIndex] = {event.answerIndex};
    }

    emit(current.copyWith(answers: newAnswers));
  }

  void _onNextQuestion(QuizNextQuestion event, Emitter<QuizState> emit) {
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

  void _onGoToQuestion(QuizGoToQuestion event, Emitter<QuizState> emit) {
    final current = state;
    if (current is! QuizReady) return;
    if (event.index < 0 || event.index >= current.questions.length) return;

    emit(current.copyWith(currentIndex: event.index));
  }

  void _onQuestionFlagToggled(
    QuizQuestionFlagToggled event,
    Emitter<QuizState> emit,
  ) {
    final current = state;
    if (current is! QuizReady) return;
    if (event.questionIndex < 0 ||
        event.questionIndex >= current.questions.length) {
      return;
    }

    final newFlags = Set<int>.from(current.flaggedQuestions);
    if (newFlags.contains(event.questionIndex)) {
      newFlags.remove(event.questionIndex);
    } else {
      newFlags.add(event.questionIndex);
    }

    emit(current.copyWith(flaggedQuestions: newFlags));
  }

  Future<void> _onSubmitted(
    QuizSubmitted event,
    Emitter<QuizState> emit,
  ) async {
    final current = state;
    if (current is! QuizReady) return;

    emit(const QuizSubmitting());

    // Convert answers: questionIndex -> Set<answerIndex> to [{question_id, selected_answer_ids}]
    final apiAnswers = <Map<String, dynamic>>[];
    for (final entry in current.answers.entries) {
      final questionIndex = entry.key;
      final selectedIndices = entry.value;
      if (selectedIndices.isEmpty) continue;
      final question = current.questions[questionIndex];
      final selectedIds = <String>[];
      for (final idx in selectedIndices) {
        if (idx < question.answers.length) {
          selectedIds.add(question.answers[idx].id);
        }
      }
      if (selectedIds.isNotEmpty) {
        apiAnswers.add({
          'question_id': question.id,
          'selected_answer_ids': selectedIds,
        });
      }
    }

    final result = await _repository.submitQuiz(
      current.quizId,
      current.attemptId,
      apiAnswers,
    );

    switch (result) {
      case Success(value: final submitResult):
        List<QuizReviewItemModel> reviewItems = const [];
        try {
          final reviewResult = await _repository.getQuizAttemptReview(
            current.quizId,
            current.attemptId,
            current.questions,
          );
          if (reviewResult case Success(value: final items)) {
            reviewItems = items;
          }
        } catch (_) {
          // Fallback if review endpoint fails or is unmocked in tests
        }

        final int totalCount;
        final int correctCount;
        if (reviewItems.isNotEmpty) {
          totalCount = reviewItems.length;
          correctCount = reviewItems.where((e) => e.isCorrect).length;
        } else {
          totalCount = current.questions.length;
          correctCount =
              (submitResult.percentage * totalCount / 100).round();
        }

        // Lưu kết quả vào local storage kèm attemptId
        await QuizResultStorage.saveResult(
          quizId: current.quizId,
          attemptId: current.attemptId,
          correctCount: correctCount,
          totalCount: totalCount,
          score: submitResult.percentage,
        );

        emit(
          QuizCompleted(
            correctCount: correctCount,
            totalCount: totalCount,
            score: submitResult.percentage,
            timeLimitMinutes: current.timeLimitMinutes,
            questions: current.questions,
            userAnswers: current.answers,
            reviewItems: reviewItems,
          ),
        );

      case FailureResult(error: final error):
        emit(QuizFailure(error.message ?? 'Không thể nộp bài'));
    }
  }
}

