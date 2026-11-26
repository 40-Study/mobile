import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

class _StudentRepository extends Mock implements StudentRepository {}

// UUID để không rơi vào nhánh mock khi preview bật
const _lessonId = '7f1c2a9e-0000-4000-8000-000000000001';
const _lesson = LessonModel(id: _lessonId, title: 'Bài 1');

void main() {
  group('LessonBloc', () {
    late _StudentRepository repo;

    setUp(() {
      repo = _StudentRepository();
      when(() => repo.getQuizzesByLesson(_lessonId)).thenAnswer(
        (_) async => const Result.success(<QuizModel>[]),
      );
    });

    blocTest<LessonBloc, LessonState>(
      'should emit LessonFailure when getLessonDetail fails',
      build: () {
        when(() => repo.getLessonDetail(_lessonId)).thenAnswer(
          (_) async => const Result.failure(ServerFailure(message: 'boom')),
        );
        return LessonBloc(repo);
      },
      act: (b) => b.add(const LessonStarted(_lessonId)),
      expect: () => [const LessonInProgress(), const LessonFailure('boom')],
    );

    blocTest<LessonBloc, LessonState>(
      'should keep isCompleted false and set completionError when markLessonComplete fails',
      build: () {
        when(() => repo.getLessonDetail(_lessonId)).thenAnswer(
          (_) async => const Result.success(_lesson),
        );
        when(
          () => repo.markLessonComplete(
            _lessonId,
            playedRanges: any(named: 'playedRanges'),
            durationSeconds: any(named: 'durationSeconds'),
          ),
        ).thenAnswer(
          (_) async => const Result.failure(ServerFailure(message: 'denied')),
        );
        return LessonBloc(repo);
      },
      act: (b) async {
        b.add(const LessonStarted(_lessonId));
        await Future<void>.delayed(Duration.zero);
        b.add(const LessonCompleted());
      },
      expect: () => [
        const LessonInProgress(),
        const LessonSuccess(lesson: _lesson),
        const LessonSuccess(lesson: _lesson, completionError: 'denied'),
      ],
    );

    blocTest<LessonBloc, LessonState>(
      'should set isCompleted true when markLessonComplete succeeds',
      build: () {
        when(() => repo.getLessonDetail(_lessonId)).thenAnswer(
          (_) async => const Result.success(_lesson),
        );
        when(
          () => repo.markLessonComplete(
            _lessonId,
            playedRanges: any(named: 'playedRanges'),
            durationSeconds: any(named: 'durationSeconds'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            (lessonCompleted: true, courseCompleted: false),
          ),
        );
        return LessonBloc(repo);
      },
      act: (b) async {
        b.add(const LessonStarted(_lessonId));
        await Future<void>.delayed(Duration.zero);
        b.add(const LessonCompleted());
      },
      skip: 2,
      expect: () => [const LessonSuccess(lesson: _lesson, isCompleted: true)],
    );

    blocTest<LessonBloc, LessonState>(
      'should keep isCompleted false when server has not completed the lesson',
      build: () {
        when(() => repo.getLessonDetail(_lessonId)).thenAnswer(
          (_) async => const Result.success(_lesson),
        );
        when(
          () => repo.markLessonComplete(
            _lessonId,
            playedRanges: any(named: 'playedRanges'),
            durationSeconds: any(named: 'durationSeconds'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            (lessonCompleted: false, courseCompleted: false),
          ),
        );
        return LessonBloc(repo);
      },
      act: (b) async {
        b.add(const LessonStarted(_lessonId));
        await Future<void>.delayed(Duration.zero);
        b.add(const LessonCompleted());
      },
      skip: 2,
      // Equatable: state mới bằng state cũ nên không emit
      expect: () => <LessonState>[],
    );
  });
}
