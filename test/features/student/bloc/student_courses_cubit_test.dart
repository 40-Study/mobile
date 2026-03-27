import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/student/bloc/student_courses/student_courses_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  group('StudentCoursesCubit', () {
    late StudentRepository repository;

    setUp(() {
      repository = MockStudentRepository();
    });

    StudentCoursesCubit buildCubit() {
      return StudentCoursesCubit(repository: repository);
    }

    test('initial state should be StudentCoursesInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, equals(const StudentCoursesInitial()));
    });

    group('loadCourses', () {
      final mockEnrollments = [
        const EnrollmentModel(
          id: '1',
          courseId: 'c1',
          courseName: 'Flutter Development',
          progress: 50,
          status: 'active',
        ),
        const EnrollmentModel(
          id: '2',
          courseId: 'c2',
          courseName: 'React Native',
          progress: 100,
          status: 'completed',
        ),
      ];

      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should emit [Loading, Loaded] when loadCourses succeeds',
        setUp: () {
          when(() => repository.getEnrollments(
                status: any(named: 'status'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => mockEnrollments);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadCourses(),
        expect: () => [
          const StudentCoursesLoading(),
          isA<StudentCoursesLoaded>()
              .having((s) => s.enrollments.length, 'enrollments.length', 2)
              .having((s) => s.selectedFilter, 'selectedFilter', 'all')
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should emit [Loading, Loaded] with filter when filter is specified',
        setUp: () {
          when(() => repository.getEnrollments(
                status: 'active',
                page: 1,
                pageSize: 20,
              )).thenAnswer((_) async => [mockEnrollments.first]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadCourses(filter: 'active'),
        expect: () => [
          const StudentCoursesLoading(),
          isA<StudentCoursesLoaded>()
              .having((s) => s.enrollments.length, 'enrollments.length', 1)
              .having((s) => s.selectedFilter, 'selectedFilter', 'active'),
        ],
      );

      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should emit [Loading, Failure] when loadCourses fails',
        setUp: () {
          when(() => repository.getEnrollments(
                status: any(named: 'status'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadCourses(),
        expect: () => [
          const StudentCoursesLoading(),
          isA<StudentCoursesFailure>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });

    group('loadMore', () {
      final initialEnrollments = [
        const EnrollmentModel(
          id: '1',
          courseId: 'c1',
          courseName: 'Flutter',
          progress: 50,
          status: 'active',
        ),
      ];

      final moreEnrollments = [
        const EnrollmentModel(
          id: '2',
          courseId: 'c2',
          courseName: 'React',
          progress: 30,
          status: 'active',
        ),
      ];

      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should append new enrollments when loadMore succeeds',
        setUp: () {
          when(() => repository.getEnrollments(
                status: any(named: 'status'),
                page: 1,
                pageSize: 20,
              )).thenAnswer((_) async => List.generate(
                20,
                (i) => EnrollmentModel(
                  id: '$i',
                  courseId: 'c$i',
                  courseName: 'Course $i',
                  progress: 50,
                  status: 'active',
                ),
              ));
          when(() => repository.getEnrollments(
                status: any(named: 'status'),
                page: 2,
                pageSize: 20,
              )).thenAnswer((_) async => moreEnrollments);
        },
        build: buildCubit,
        seed: () => StudentCoursesLoaded(
          enrollments: initialEnrollments,
          hasMore: true,
          selectedFilter: 'all',
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [
          isA<StudentCoursesLoaded>()
              .having((s) => s.enrollments.length, 'enrollments.length', 2)
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should not load more when hasMore is false',
        build: buildCubit,
        seed: () => const StudentCoursesLoaded(
          enrollments: [],
          hasMore: false,
          selectedFilter: 'all',
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
      );
    });

    group('changeFilter', () {
      blocTest<StudentCoursesCubit, StudentCoursesState>(
        'should reload courses with new filter',
        setUp: () {
          when(() => repository.getEnrollments(
                status: 'completed',
                page: 1,
                pageSize: 20,
              )).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.changeFilter('completed'),
        expect: () => [
          const StudentCoursesLoading(),
          isA<StudentCoursesLoaded>()
              .having((s) => s.selectedFilter, 'selectedFilter', 'completed'),
        ],
      );
    });
  });
}
