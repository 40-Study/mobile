import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'student_courses_state.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  StudentCoursesCubit({required StudentRepository repository})
      : _repository = repository,
        super(const StudentCoursesInitial());

  final StudentRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  Future<void> loadCourses({String? filter}) async {
    emit(const StudentCoursesLoading());
    _currentPage = 1;

    try {
      final status = filter == 'all' ? null : filter;
      final enrollments = await _repository.getEnrollments(
        status: status,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(StudentCoursesLoaded(
        enrollments: _sorted(enrollments),
        selectedFilter: filter ?? 'all',
        hasMore: enrollments.length >= _pageSize,
      ));
    } catch (e) {
      emit(StudentCoursesFailure(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! StudentCoursesLoaded || !currentState.hasMore) return;

    _currentPage++;

    try {
      final status =
          currentState.selectedFilter == 'all' ? null : currentState.selectedFilter;
      final newEnrollments = await _repository.getEnrollments(
        status: status,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(currentState.copyWith(
        enrollments: [...currentState.enrollments, ...newEnrollments],
        hasMore: newEnrollments.length >= _pageSize,
      ));
    } catch (e) {
      _currentPage--;
      // Keep current state on load more failure
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    final filter = currentState is StudentCoursesLoaded
        ? currentState.selectedFilter
        : 'all';
    await loadCourses(filter: filter);
  }

  Future<void> changeFilter(String filter) async {
    await loadCourses(filter: filter);
  }

  /// active → pending → completed
  List<EnrollmentModel> _sorted(List<EnrollmentModel> list) {
    const order = {'active': 0, 'pending': 1, 'paused': 2, 'completed': 3, 'dropped': 4};
    return List.of(list)
      ..sort((a, b) =>
          (order[a.status] ?? 5).compareTo(order[b.status] ?? 5));
  }

  Future<void> continueLearning(String enrollmentId) async {
    // Navigate to lesson player
    // This would typically trigger navigation via BlocListener
  }
}
