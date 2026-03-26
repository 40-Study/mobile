part of 'student_classes_cubit.dart';

@immutable
sealed class StudentClassesState extends Equatable {
  const StudentClassesState();

  @override
  List<Object?> get props => [];
}

final class StudentClassesInitial extends StudentClassesState {
  const StudentClassesInitial();
}

final class StudentClassesLoading extends StudentClassesState {
  const StudentClassesLoading();
}

final class StudentClassesLoaded extends StudentClassesState {
  const StudentClassesLoaded({
    required this.classes,
    this.selectedFilter = 'all',
    this.hasMore = false,
  });

  final List<StudentClassModel> classes;
  final String selectedFilter;
  final bool hasMore;

  StudentClassesLoaded copyWith({
    List<StudentClassModel>? classes,
    String? selectedFilter,
    bool? hasMore,
  }) {
    return StudentClassesLoaded(
      classes: classes ?? this.classes,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [classes, selectedFilter, hasMore];
}

final class StudentClassesFailure extends StudentClassesState {
  const StudentClassesFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
