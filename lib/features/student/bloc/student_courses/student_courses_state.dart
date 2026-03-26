part of 'student_courses_cubit.dart';

@immutable
sealed class StudentCoursesState extends Equatable {
  const StudentCoursesState();

  @override
  List<Object?> get props => [];
}

final class StudentCoursesInitial extends StudentCoursesState {
  const StudentCoursesInitial();
}

final class StudentCoursesLoading extends StudentCoursesState {
  const StudentCoursesLoading();
}

final class StudentCoursesLoaded extends StudentCoursesState {
  const StudentCoursesLoaded({
    required this.enrollments,
    this.selectedFilter = 'all',
    this.hasMore = false,
  });

  final List<EnrollmentModel> enrollments;
  final String selectedFilter;
  final bool hasMore;

  StudentCoursesLoaded copyWith({
    List<EnrollmentModel>? enrollments,
    String? selectedFilter,
    bool? hasMore,
  }) {
    return StudentCoursesLoaded(
      enrollments: enrollments ?? this.enrollments,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [enrollments, selectedFilter, hasMore];
}

final class StudentCoursesFailure extends StudentCoursesState {
  const StudentCoursesFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
