import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/data/models/course_detail_model.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  group('CourseDetailCubit', () {
    late StudentRepository repository;

    const testEnrollmentId = 'enrollment-1';
    const testCourseId = 'course-1';

    setUp(() {
      repository = MockStudentRepository();
    });

    CourseDetailCubit buildCubit() {
      return CourseDetailCubit(
        repository: repository,
        enrollmentId: testEnrollmentId,
        courseId: testCourseId,
      );
    }

    test('initial state should be CourseDetailInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, equals(const CourseDetailInitial()));
    });

    group('load', () {
      final mockCourseDetail = CourseDetailModel(
        id: testCourseId,
        title: 'Flutter Development',
        progress: 65,
        totalLessons: 20,
        completedLessons: 13,
        instructorName: 'John Doe',
        chapters: const [
          ChapterModel(
            id: 'ch1',
            title: 'Getting Started',
            totalLessons: 4,
            completedLessons: 4,
            status: 'completed',
          ),
        ],
      );

      blocTest<CourseDetailCubit, CourseDetailState>(
        'should emit [Loading, Loaded] when load succeeds',
        setUp: () {
          when(() => repository.getCourseDetail(
                enrollmentId: testEnrollmentId,
                courseId: testCourseId,
              )).thenAnswer((_) async => mockCourseDetail);
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          const CourseDetailLoading(),
          isA<CourseDetailLoaded>()
              .having((s) => s.detail.id, 'detail.id', testCourseId)
              .having((s) => s.detail.title, 'detail.title', 'Flutter Development')
              .having((s) => s.detail.progress, 'detail.progress', 65),
        ],
        verify: (_) {
          verify(() => repository.getCourseDetail(
                enrollmentId: testEnrollmentId,
                courseId: testCourseId,
              )).called(1);
        },
      );

      blocTest<CourseDetailCubit, CourseDetailState>(
        'should emit [Loading, Failure] when load fails',
        setUp: () {
          when(() => repository.getCourseDetail(
                enrollmentId: testEnrollmentId,
                courseId: testCourseId,
              )).thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          const CourseDetailLoading(),
          isA<CourseDetailFailure>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });

    group('refresh', () {
      final mockCourseDetail = CourseDetailModel(
        id: testCourseId,
        title: 'Flutter Development',
        progress: 70,
        totalLessons: 20,
        completedLessons: 14,
      );

      blocTest<CourseDetailCubit, CourseDetailState>(
        'should call load when refresh is called',
        setUp: () {
          when(() => repository.getCourseDetail(
                enrollmentId: testEnrollmentId,
                courseId: testCourseId,
              )).thenAnswer((_) async => mockCourseDetail);
        },
        build: buildCubit,
        act: (cubit) => cubit.refresh(),
        verify: (_) {
          verify(() => repository.getCourseDetail(
                enrollmentId: testEnrollmentId,
                courseId: testCourseId,
              )).called(1);
        },
      );
    });
  });
}
