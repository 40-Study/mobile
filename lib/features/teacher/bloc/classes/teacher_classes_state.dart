part of 'teacher_classes_cubit.dart';

@immutable
sealed class TeacherClassesState extends Equatable {
  const TeacherClassesState({
    this.selectedFilter = 'all',
    this.searchQuery = '',
  });

  final String selectedFilter;
  final String searchQuery;

  @override
  List<Object?> get props => [selectedFilter, searchQuery];
}

final class TeacherClassesInitial extends TeacherClassesState {
  const TeacherClassesInitial({
    super.selectedFilter,
    super.searchQuery,
  });
}

final class TeacherClassesLoading extends TeacherClassesState {
  const TeacherClassesLoading({
    super.selectedFilter,
    super.searchQuery,
  });
}

final class TeacherClassesLoaded extends TeacherClassesState {
  const TeacherClassesLoaded({
    required this.classes,
    super.selectedFilter,
    super.searchQuery,
  });

  final List<ClassModel> classes;

  int get activeCount => classes.where((c) => c.isActive).length;
  int get completedCount => classes.where((c) => c.isCompleted).length;
  int get totalStudents =>
      classes.fold(0, (sum, c) => sum + c.studentCount);

  TeacherClassesLoaded copyWith({
    List<ClassModel>? classes,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return TeacherClassesLoaded(
      classes: classes ?? List.of(this.classes),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [classes, selectedFilter, searchQuery];
}

final class TeacherClassesFailure extends TeacherClassesState {
  const TeacherClassesFailure({
    required this.message,
    super.selectedFilter,
    super.searchQuery,
  });

  final String message;

  @override
  List<Object?> get props => [message, selectedFilter, searchQuery];
}
