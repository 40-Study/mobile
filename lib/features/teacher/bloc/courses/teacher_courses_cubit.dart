import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_courses_state.dart';

class TeacherCoursesCubit extends Cubit<TeacherCoursesState> {
  TeacherCoursesCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherCoursesInitial());

  final TeacherRepository _repository;

  Future<void> loadCourses({String? status}) async {
    emit(TeacherCoursesLoading(selectedFilter: status ?? 'all'));

    try {
      final courses = await _repository.getCourses(status: status);
      emit(TeacherCoursesLoaded(
        courses: courses,
        selectedFilter: status ?? 'all',
      ));
    } catch (e) {
      emit(TeacherCoursesFailure(
        message: e.toString(),
        selectedFilter: status ?? 'all',
      ));
    }
  }

  void changeFilter(String filter) {
    loadCourses(status: filter == 'all' ? null : filter);
  }

  Future<void> deleteCourse(String id) async {
    final currentState = state;
    if (currentState is! TeacherCoursesLoaded) return;

    try {
      await _repository.deleteCourse(id);
      final updatedCourses =
          currentState.courses.where((c) => c.id != id).toList();
      emit(currentState.copyWith(courses: updatedCourses));
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}
