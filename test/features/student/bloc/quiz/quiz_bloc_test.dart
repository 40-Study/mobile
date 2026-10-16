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
import 'package:study/features/student/data/models/quiz_review_item_model.dart';
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
        questions: _questions,
        userAnswers: {
          0: {0},
        },
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
      expect(saved?.attemptId, 'attempt');
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

  blocTest<QuizBloc, QuizState>(
    'toggles question flag status correctly',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      bloc.add(const QuizQuestionFlagToggled(0));
      await bloc.stream.firstWhere(
        (state) => state is QuizReady && state.isQuestionFlagged(0),
      );
      bloc.add(const QuizQuestionFlagToggled(0));
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>().having((s) => s.flaggedQuestions, 'initial', isEmpty),
      isA<QuizReady>().having((s) => s.flaggedQuestions, 'flagged', contains(0)),
      isA<QuizReady>().having((s) => s.flaggedQuestions, 'unflagged', isEmpty),
    ],
  );

  blocTest<QuizBloc, QuizState>(
    'submits and fetches review items accurately from server',
    build: () {
      when(
        () => repository.startQuiz('quiz'),
      ).thenAnswer((_) async => const Result.success(_startedQuiz));
      when(() => repository.submitQuiz('quiz', 'attempt', any())).thenAnswer(
        (_) async => const Result.success(QuizSubmitResult(percentage: 50)),
      );
      when(() => repository.getQuizAttemptReview('quiz', 'attempt', any()))
          .thenAnswer(
        (_) async => const Result.success([
          QuizReviewItemModel(
            index: 1,
            questionId: 'q1',
            questionText: 'Q1',
            answers: [QuizAnswerModel(id: 'a1', answerText: 'Ans 1')],
            selectedAnswerIds: ['a1'],
            correctAnswerIds: ['a1'],
            isCorrect: true,
            isSkipped: false,
            pointsEarned: 1.0,
            explanation: 'Correct explanation',
          ),
          QuizReviewItemModel(
            index: 2,
            questionId: 'q2',
            questionText: 'Q2',
            answers: [QuizAnswerModel(id: 'a2', answerText: 'Ans 2')],
            selectedAnswerIds: [],
            correctAnswerIds: ['a2'],
            isCorrect: false,
            isSkipped: true,
            pointsEarned: 0.0,
            explanation: 'Review explanation',
          ),
        ]),
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
      isA<QuizCompleted>()
          .having((s) => s.correctCount, 'correctCount', 1)
          .having((s) => s.totalCount, 'totalCount', 2)
          .having((s) => s.reviewItems.length, 'reviewItems length', 2)
          .having((s) => s.reviewItems.first.isCorrect, 'first isCorrect', isTrue)
          .having((s) => s.reviewItems.last.isCorrect, 'second isCorrect', isFalse),
    ],
  );

  blocTest<QuizBloc, QuizState>(
    'toggles multiple choice answers and submits all selected ids',
    build: () {
      const multiChoiceQuiz = (
        attemptId: 'attempt_multi',
        questions: [
          QuizQuestionModel(
            id: 'q_multi',
            question: 'Select multiple git commands',
            questionType: 'multiple_choice',
            answers: [
              QuizAnswerModel(id: 'a1', answerText: 'git push'),
              QuizAnswerModel(id: 'a2', answerText: 'git commit'),
              QuizAnswerModel(id: 'a3', answerText: 'git push origin main'),
            ],
          ),
        ],
        timeLimitMinutes: 10,
      );
      when(() => repository.startQuiz('quiz_multi'))
          .thenAnswer((_) async => const Result.success(multiChoiceQuiz));
      when(() => repository.submitQuiz('quiz_multi', 'attempt_multi', any()))
          .thenAnswer(
        (_) async => const Result.success(QuizSubmitResult(percentage: 100)),
      );
      return QuizBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const QuizStarted('quiz_multi'));
      await bloc.stream.firstWhere((state) => state is QuizReady);
      // Select option 0
      bloc.add(const QuizAnswerSelected(0, 0));
      await bloc.stream.firstWhere(
        (s) => s is QuizReady && s.answers[0]?.contains(0) == true,
      );
      // Select option 2
      bloc.add(const QuizAnswerSelected(0, 2));
      await bloc.stream.firstWhere(
        (s) => s is QuizReady && s.answers[0]?.contains(2) == true,
      );
      // Submit
      bloc.add(const QuizSubmitted());
    },
    expect: () => [
      const QuizLoading(),
      isA<QuizReady>(),
      isA<QuizReady>().having((s) => s.answers[0], 'has option 0', {0}),
      isA<QuizReady>().having((s) => s.answers[0], 'has options 0 and 2', {0, 2}),
      const QuizSubmitting(),
      isA<QuizCompleted>().having(
        (s) => s.userAnswers[0],
        'userAnswers contains 0 and 2',
        {0, 2},
      ),
    ],
    verify: (_) async {
      final sentAnswers = verify(
        () => repository.submitQuiz('quiz_multi', 'attempt_multi', captureAny()),
      ).captured.single as List<Map<String, dynamic>>;
      expect(sentAnswers, [
        {
          'question_id': 'q_multi',
          'selected_answer_ids': ['a1', 'a3'],
        },
      ]);
    },
  );
}

