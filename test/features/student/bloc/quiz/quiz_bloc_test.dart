import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/features/student/data/models/quiz_question_model.dart';
import 'package:study/features/student/data/models/quiz_submit_result.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/repository/student_repository.dart';

class _StudentRepository extends Mock implements StudentRepository {}

const _questions = [
  QuizQuestionModel(
    id: 'q1',
    answers: [QuizAnswerModel(id: 'a1')],
  ),
  QuizQuestionModel(
    id: 'q2',
    answers: [QuizAnswerModel(id: 'a2')],
  ),
];
const _startedQuiz = (
  attemptId: 'attempt',
  questions: _questions,
  timeLimitMinutes: 10,
);

void main() {
  late _StudentRepository repository;

  setUp(() {
    repository = _StudentRepository();
    SharedPreferences.setMockInitialValues({});
  });

  blocTest<QuizBloc, QuizState>(
    'rejects an empty quiz response',
    build: () {
      when(() => repository.startQuiz('quiz')).thenAnswer(
        (_) async => const Result.success((
          attemptId: 'attempt',
          questions: <QuizQuestionModel>[],
          timeLimitMinutes: 0,
        )),
      );
      return QuizBloc(repository);
    },
    act: (bloc) => bloc.add(const QuizStarted('quiz')),
    expect: () => [const QuizLoading(), const QuizFailure('Không có câu hỏi')],
  );

  blocTest<QuizBloc, QuizState>(
    'maps start failure to a user-visible failure state',
    build: () {
      when(() => repository.startQuiz('quiz')).thenAnswer(
        (_) async =>
            const Result.failure(ServerFailure(message: 'Quiz unavailable')),
      );
      return QuizBloc(repository);
    },
    act: (bloc) => bloc.add(const QuizStarted('quiz')),
    expect: () => [const QuizLoading(), const QuizFailure('Quiz unavailable')],
  );

  blocTest<QuizBloc, QuizState>(
    'ignores answer selections with negative or out-of-range indices',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      bloc
        ..add(const QuizAnswerSelected(-1, 0))
        ..add(const QuizAnswerSelected(2, 0))
        ..add(const QuizAnswerSelected(0, -1))
        ..add(const QuizAnswerSelected(0, 1));
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>().having((state) => state.answers, 'answers', isEmpty),
    ],
  );

  blocTest<QuizBloc, QuizState>(
    'keeps question navigation within both ends of the quiz',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      bloc.add(const QuizPreviousQuestion());
      bloc.add(const QuizNextQuestion());
      await bloc.stream.firstWhere(
        (state) => state is QuizReady && state.currentIndex == 1,
      );
      bloc
        ..add(const QuizNextQuestion())
        ..add(const QuizGoToQuestion(-1))
        ..add(const QuizGoToQuestion(2))
        ..add(const QuizGoToQuestion(0));
      await bloc.stream.firstWhere(
        (state) => state is QuizReady && state.currentIndex == 0,
      );
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>().having(
        (state) => state.currentIndex,
        'initial index',
        0,
      ),
      isA<QuizReady>().having((state) => state.currentIndex, 'next index', 1),
      isA<QuizReady>().having(
        (state) => state.currentIndex,
        'requested index',
        0,
      ),
    ],
  );

  blocTest<QuizBloc, QuizState>(
    'submits selected answers and saves a successful score',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      when(() => repository.submitQuiz('quiz', 'attempt', any())).thenAnswer(
        (_) async => const Result.success(QuizSubmitResult(percentage: 50)),
      );
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      bloc.add(const QuizAnswerSelected(0, 0));
      await bloc.stream.firstWhere(
        (state) => state is QuizReady && state.answers.isNotEmpty,
      );
      bloc.add(const QuizSubmitted());
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>(),
      isA<QuizReady>(),
      const QuizSubmitting(),
      const QuizCompleted(
        correctCount: 1,
        totalCount: 2,
        score: 50,
        timeLimitMinutes: 10,
      ),
    ],
    verify: (_) async {
      final sentAnswers =
          verify(
                () => repository.submitQuiz('quiz', 'attempt', captureAny()),
              ).captured.single
              as List<Map<String, dynamic>>;
      expect(sentAnswers, [
        {
          'question_id': 'q1',
          'selected_answer_ids': ['a1'],
        },
      ]);
      final saved = await QuizResultStorage.getResult('quiz');
      expect(saved?.correctCount, 1);
      expect(saved?.totalCount, 2);
      expect(saved?.score, 50);
    },
  );

  blocTest<QuizBloc, QuizState>(
    'reports submit failures and does not store a result',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      when(() => repository.submitQuiz('quiz', 'attempt', any())).thenAnswer(
        (_) async => const Result.failure(ServerFailure(message: 'Try again')),
      );
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      bloc.add(const QuizSubmitted());
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>(),
      const QuizSubmitting(),
      const QuizFailure('Try again'),
    ],
    verify: (_) async =>
        expect(await QuizResultStorage.hasResult('quiz'), isFalse),
  );
}
