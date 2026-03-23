part of 'teacher_students_cubit.dart';

sealed class TeacherStudentsState extends Equatable {
  const TeacherStudentsState({this.searchQuery = ''});

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

final class TeacherStudentsInitial extends TeacherStudentsState {
  const TeacherStudentsInitial({super.searchQuery});
}

final class TeacherStudentsLoading extends TeacherStudentsState {
  const TeacherStudentsLoading({super.searchQuery});
}

final class TeacherStudentsLoaded extends TeacherStudentsState {
  const TeacherStudentsLoaded({
    required this.students,
    super.searchQuery,
  });

  final List<StudentModel> students;

  int get totalStudents => students.length;

  @override
  List<Object?> get props => [students, searchQuery];
}

final class TeacherStudentsFailure extends TeacherStudentsState {
  const TeacherStudentsFailure({
    required this.message,
    super.searchQuery,
  });

  final String message;

  @override
  List<Object?> get props => [message, searchQuery];
}
