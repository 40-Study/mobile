import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/teacher/bloc/courses/teacher_courses_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

class MockTeacherRepository extends Mock implements TeacherRepository {}

void main() {
  group('TeacherCoursesCubit', () {
    late TeacherRepository repository;
    late TeacherCoursesCubit cubit;

    final mockCourses = [
      const CourseModel(
        id: '1',
        name: 'Flutter Course',
        status: 'published',
        studentCount: 100,
        classCount: 5,
        rating: 4.5,
        price: 500000,
      ),
      const CourseModel(
        id: '2',
        name: 'Dart Course',
        status: 'draft',
        studentCount: 50,
        classCount: 10,
        rating: 4.0,
        price: 300000,
      ),
      const CourseModel(
        id: '3',
        name: 'React Course',
        status: 'archived',
        studentCount: 200,
        classCount: 3,
        rating: 4.8,
        price: 600000,
      ),
    ];

    setUp(() {
      repository = MockTeacherRepository();
      cubit = TeacherCoursesCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be TeacherCoursesInitial', () {
      expect(cubit.state, const TeacherCoursesInitial());
    });

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'loadCourses should emit [Loading, Loaded] when successful',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        const TeacherCoursesLoading(),
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 3)
            .having((s) => s.selectedFilter, 'filter', CourseFilter.all)
            .having((s) => s.sortBy, 'sortBy', CourseSortBy.newest),
      ],
      verify: (_) {
        verify(() => repository.getCourses()).called(1);
      },
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'loadCourses should emit [Loading, Failure] when repository throws',
      setUp: () {
        when(() => repository.getCourses())
            .thenThrow(Exception('Failed to load courses'));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        const TeacherCoursesLoading(),
        isA<TeacherCoursesFailure>()
            .having((s) => s.message, 'message', contains('Failed')),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeFilter should filter published courses',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeFilter(CourseFilter.published);
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 1)
            .having(
              (s) => s.courses.first.id,
              'first course id',
              '1',
            )
            .having(
              (s) => s.selectedFilter,
              'filter',
              CourseFilter.published,
            ),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeFilter should filter draft courses',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeFilter(CourseFilter.draft);
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 1)
            .having((s) => s.courses.first.id, 'first course id', '2')
            .having((s) => s.selectedFilter, 'filter', CourseFilter.draft),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeFilter should not emit when filter is unchanged',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeFilter(CourseFilter.all);
      },
      skip: 2,
      expect: () => <TeacherCoursesState>[],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeSortBy should sort by most students',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeSortBy(CourseSortBy.mostStudents);
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.first.id, 'first course id', '3')
            .having((s) => s.sortBy, 'sortBy', CourseSortBy.mostStudents),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeSortBy should sort by highest rating',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeSortBy(CourseSortBy.highestRating);
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.first.id, 'first course id', '3')
            .having((s) => s.sortBy, 'sortBy', CourseSortBy.highestRating),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeSortBy should sort by most classes',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeSortBy(CourseSortBy.mostClasses);
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.first.id, 'first course id', '2')
            .having((s) => s.sortBy, 'sortBy', CourseSortBy.mostClasses),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'changeSortBy should sort by highest revenue',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.changeSortBy(CourseSortBy.highestRevenue);
      },
      skip: 2,
      expect: () => [
        // React: 200 * 600000 = 120M (highest)
        // Flutter: 100 * 500000 = 50M
        // Dart: 50 * 300000 = 15M
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.first.id, 'first course id', '3')
            .having((s) => s.sortBy, 'sortBy', CourseSortBy.highestRevenue),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'search should filter courses by name',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.search('Flutter');
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 1)
            .having((s) => s.courses.first.name, 'course name', 'Flutter Course')
            .having((s) => s.searchQuery, 'searchQuery', 'Flutter'),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'search should be case insensitive',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        cubit.search('flutter');
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 1)
            .having((s) => s.courses.first.name, 'course name', 'Flutter Course'),
      ],
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'deleteCourse should remove course and re-emit filtered list',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
        when(() => repository.deleteCourse('1'))
            .thenAnswer((_) async {});
      },
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadCourses();
        await cubit.deleteCourse('1');
      },
      skip: 2,
      expect: () => [
        isA<TeacherCoursesLoaded>()
            .having((s) => s.courses.length, 'courses length', 2)
            .having(
              (s) => s.courses.any((c) => c.id == '1'),
              'contains deleted course',
              false,
            ),
      ],
      verify: (_) {
        verify(() => repository.deleteCourse('1')).called(1);
      },
    );

    blocTest<TeacherCoursesCubit, TeacherCoursesState>(
      'refresh should reload courses',
      setUp: () {
        when(() => repository.getCourses())
            .thenAnswer((_) async => mockCourses);
      },
      build: () => cubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const TeacherCoursesLoading(),
        isA<TeacherCoursesLoaded>(),
      ],
    );
  });
}
