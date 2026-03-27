import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/lesson_detail_model.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  group('LessonDetailCubit', () {
    late StudentRepository repository;

    const testLessonId = 'lesson-1';

    setUp(() {
      repository = MockStudentRepository();
    });

    LessonDetailCubit buildCubit() {
      return LessonDetailCubit(
        repository: repository,
        lessonId: testLessonId,
      );
    }

    test('initial state should be LessonDetailInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, equals(const LessonDetailInitial()));
    });

    group('load', () {
      const mockLessonDetail = LessonDetailModel(
        id: testLessonId,
        title: 'Introduction to Flutter',
        chapterTitle: 'Chapter 1: Getting Started',
        instructorName: 'John Doe',
        instructorTitle: 'Senior Flutter Developer',
        level: 'BEGINNER',
        duration: '25:00',
        currentTime: '10:30',
        viewCount: 1500,
        description: 'Learn the basics of Flutter development.',
        objectives: [
          LessonObjective(
            id: 'obj1',
            title: 'Understand Flutter basics',
            icon: 'cloud',
          ),
        ],
        contentSections: [
          LessonContentSection(
            id: 'cs1',
            order: 1,
            title: 'What is Flutter?',
            subtitle: 'An overview of the framework.',
          ),
        ],
        materials: [
          LessonMaterial(
            id: 'mat1',
            title: 'Slide_01.pdf',
            type: LessonMaterialType.pdf,
            size: '2.4 MB',
          ),
        ],
        hasQuiz: true,
        quizAttempts: [
          QuizAttempt(
            id: 'qa1',
            attemptNumber: 1,
            score: 8,
            totalScore: 10,
            date: '2024-01-01',
            status: QuizStatus.completed,
          ),
        ],
      );

      blocTest<LessonDetailCubit, LessonDetailState>(
        'should emit [Loading, Loaded] when load succeeds',
        setUp: () {
          when(() => repository.getLessonDetail(testLessonId))
              .thenAnswer((_) async => mockLessonDetail);
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          const LessonDetailLoading(),
          isA<LessonDetailLoaded>()
              .having((s) => s.detail.id, 'detail.id', testLessonId)
              .having((s) => s.detail.title, 'detail.title', 'Introduction to Flutter')
              .having((s) => s.detail.hasQuiz, 'detail.hasQuiz', true),
        ],
        verify: (_) {
          verify(() => repository.getLessonDetail(testLessonId)).called(1);
        },
      );

      blocTest<LessonDetailCubit, LessonDetailState>(
        'should emit [Loading, Failure] when load fails',
        setUp: () {
          when(() => repository.getLessonDetail(testLessonId))
              .thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          const LessonDetailLoading(),
          isA<LessonDetailFailure>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });

    group('refresh', () {
      const mockLessonDetail = LessonDetailModel(
        id: testLessonId,
        title: 'Introduction to Flutter',
        hasQuiz: false,
      );

      blocTest<LessonDetailCubit, LessonDetailState>(
        'should call load when refresh is called',
        setUp: () {
          when(() => repository.getLessonDetail(testLessonId))
              .thenAnswer((_) async => mockLessonDetail);
        },
        build: buildCubit,
        act: (cubit) => cubit.refresh(),
        verify: (_) {
          verify(() => repository.getLessonDetail(testLessonId)).called(1);
        },
      );
    });
  });
}
