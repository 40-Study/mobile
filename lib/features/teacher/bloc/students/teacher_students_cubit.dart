import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_students_state.dart';

class TeacherStudentsCubit extends Cubit<TeacherStudentsState> {
  TeacherStudentsCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherStudentsInitial());

  final TeacherRepository _repository;

  Future<void> loadStudents({String? searchQuery}) async {
    emit(TeacherStudentsLoading(searchQuery: searchQuery ?? ''));

    try {
      final students = await _repository.getStudents(searchQuery: searchQuery);
      emit(TeacherStudentsLoaded(
        students: students,
        searchQuery: searchQuery ?? '',
      ));
    } catch (e) {
      emit(TeacherStudentsFailure(
        message: e.toString(),
        searchQuery: searchQuery ?? '',
      ));
    }
  }

  void search(String query) {
    loadStudents(searchQuery: query);
  }

  Future<void> refresh() async {
    final currentSearch =
        state is TeacherStudentsLoaded
            ? (state as TeacherStudentsLoaded).searchQuery
            : '';
    await loadStudents(searchQuery: currentSearch);
  }
}
