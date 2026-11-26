import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class _StudentRepository extends Mock implements StudentRepository {}

class _CourseRepository extends Mock implements CourseRepository {}

class _BookmarkStorage extends Mock implements BookmarkStorage {}

// UUID để không rơi vào nhánh mock khi preview bật
const _id = '7f1c2a9e-0000-4000-8000-000000000002';

void main() {
  group('CourseDetailBloc', () {
    late _StudentRepository repo;

    setUp(() => repo = _StudentRepository());

    CourseDetailBloc build() =>
        CourseDetailBloc(repo, _CourseRepository(), _BookmarkStorage());

    blocTest<CourseDetailBloc, CourseDetailState>(
      'should emit CourseDetailFailure when getCourseById fails',
      build: () {
        when(() => repo.getCourseById(_id)).thenAnswer(
          (_) async => const Result.failure(ServerFailure(message: 'boom')),
        );
        return build();
      },
      act: (b) => b.add(const CourseDetailStarted(_id, isEnrollment: false)),
      expect: () => [
        const CourseDetailInProgress(),
        const CourseDetailFailure('boom'),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'should emit CourseDetailFailure when getCourseDetail fails',
      build: () {
        when(() => repo.getCourseDetail(_id)).thenAnswer(
          (_) async => const Result.failure(ServerFailure(message: 'boom')),
        );
        return build();
      },
      act: (b) => b.add(const CourseDetailStarted(_id)),
      expect: () => [
        const CourseDetailInProgress(),
        const CourseDetailFailure('boom'),
      ],
    );

    // Chỉ chạy với --dart-define=ENV=prod: id mock không được trả mock data
    if (const String.fromEnvironment('ENV') == 'prod') {
      blocTest<CourseDetailBloc, CourseDetailState>(
      'should not return mock data for mock id when preview disabled',
      build: () {
        when(() => repo.getCourseById('course_1')).thenAnswer(
          (_) async => const Result.failure(ServerFailure(message: 'boom')),
        );
        return build();
      },
      act: (b) =>
          b.add(const CourseDetailStarted('course_1', isEnrollment: false)),
      expect: () => [
        const CourseDetailInProgress(),
        const CourseDetailFailure('boom'),
      ],
    );
    }
  });
}
