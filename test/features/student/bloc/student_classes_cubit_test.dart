import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/student/bloc/student_classes/student_classes_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  group('StudentClassesCubit', () {
    late StudentRepository repository;

    setUp(() {
      repository = MockStudentRepository();
    });

    StudentClassesCubit buildCubit() {
      return StudentClassesCubit(repository: repository);
    }

    test('initial state should be StudentClassesInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, equals(const StudentClassesInitial()));
    });

    group('loadClasses', () {
      final mockClasses = [
        const StudentClassModel(
          id: '1',
          name: 'Math 101',
          teacherName: 'Mr. Smith',
          scheduleText: 'Mon, Wed, Fri - 09:00',
          attendanceRate: 95.0,
          averageScore: 8.5,
          studentCount: 25,
          maxStudents: 30,
          status: 'active',
        ),
        const StudentClassModel(
          id: '2',
          name: 'English 101',
          teacherName: 'Ms. Johnson',
          scheduleText: 'Tue, Thu - 14:00',
          attendanceRate: 90.0,
          averageScore: 8.0,
          studentCount: 20,
          maxStudents: 25,
          status: 'active',
        ),
      ];

      blocTest<StudentClassesCubit, StudentClassesState>(
        'should emit [Loading, Loaded] when loadClasses succeeds',
        setUp: () {
          when(() => repository.getClasses(
                status: any(named: 'status'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => mockClasses);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadClasses(),
        expect: () => [
          const StudentClassesLoading(),
          isA<StudentClassesLoaded>()
              .having((s) => s.classes.length, 'classes.length', 2)
              .having((s) => s.selectedFilter, 'selectedFilter', 'all')
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<StudentClassesCubit, StudentClassesState>(
        'should emit [Loading, Loaded] with filter when filter is specified',
        setUp: () {
          when(() => repository.getClasses(
                status: 'active',
                page: 1,
                pageSize: 20,
              )).thenAnswer((_) async => mockClasses);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadClasses(filter: 'active'),
        expect: () => [
          const StudentClassesLoading(),
          isA<StudentClassesLoaded>()
              .having((s) => s.selectedFilter, 'selectedFilter', 'active'),
        ],
      );

      blocTest<StudentClassesCubit, StudentClassesState>(
        'should emit [Loading, Failure] when loadClasses fails',
        setUp: () {
          when(() => repository.getClasses(
                status: any(named: 'status'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadClasses(),
        expect: () => [
          const StudentClassesLoading(),
          isA<StudentClassesFailure>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });

    group('loadMore', () {
      final moreClasses = [
        const StudentClassModel(
          id: '3',
          name: 'Physics 101',
          teacherName: 'Dr. Brown',
          scheduleText: 'Sat - 10:00',
          attendanceRate: 85.0,
          averageScore: 7.5,
          studentCount: 15,
          maxStudents: 20,
          status: 'active',
        ),
      ];

      blocTest<StudentClassesCubit, StudentClassesState>(
        'should append new classes when loadMore succeeds',
        setUp: () {
          when(() => repository.getClasses(
                status: any(named: 'status'),
                page: 2,
                pageSize: 20,
              )).thenAnswer((_) async => moreClasses);
        },
        build: buildCubit,
        seed: () => const StudentClassesLoaded(
          classes: [
            StudentClassModel(
              id: '1',
              name: 'Math 101',
              teacherName: 'Mr. Smith',
              status: 'active',
            ),
          ],
          hasMore: true,
          selectedFilter: 'all',
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [
          isA<StudentClassesLoaded>()
              .having((s) => s.classes.length, 'classes.length', 2)
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<StudentClassesCubit, StudentClassesState>(
        'should not load more when hasMore is false',
        build: buildCubit,
        seed: () => const StudentClassesLoaded(
          classes: [],
          hasMore: false,
          selectedFilter: 'all',
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
      );
    });

    group('changeFilter', () {
      blocTest<StudentClassesCubit, StudentClassesState>(
        'should reload classes with new filter',
        setUp: () {
          when(() => repository.getClasses(
                status: 'completed',
                page: 1,
                pageSize: 20,
              )).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.changeFilter('completed'),
        expect: () => [
          const StudentClassesLoading(),
          isA<StudentClassesLoaded>()
              .having((s) => s.selectedFilter, 'selectedFilter', 'completed'),
        ],
      );
    });
  });
}
