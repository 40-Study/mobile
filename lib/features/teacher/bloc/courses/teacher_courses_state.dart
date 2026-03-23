part of 'teacher_courses_cubit.dart';

sealed class TeacherCoursesState extends Equatable {
  const TeacherCoursesState({this.selectedFilter = 'all'});

  final String selectedFilter;

  @override
  List<Object?> get props => [selectedFilter];
}

final class TeacherCoursesInitial extends TeacherCoursesState {
  const TeacherCoursesInitial({super.selectedFilter});
}

final class TeacherCoursesLoading extends TeacherCoursesState {
  const TeacherCoursesLoading({super.selectedFilter});
}

final class TeacherCoursesLoaded extends TeacherCoursesState {
  const TeacherCoursesLoaded({
    required this.courses,
    super.selectedFilter,
  });

  final List<CourseModel> courses;

  int get publishedCount =>
      courses.where((c) => c.status == 'published').length;

  TeacherCoursesLoaded copyWith({
    List<CourseModel>? courses,
    String? selectedFilter,
  }) {
    return TeacherCoursesLoaded(
      courses: courses ?? this.courses,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [courses, selectedFilter];
}

final class TeacherCoursesFailure extends TeacherCoursesState {
  const TeacherCoursesFailure({
    required this.message,
    super.selectedFilter,
  });

  final String message;

  @override
  List<Object?> get props => [message, selectedFilter];
}
