part of 'org_students_cubit.dart';

@immutable
sealed class OrgStudentsState extends Equatable {
  const OrgStudentsState();

  @override
  List<Object?> get props => [];
}

final class OrgStudentsInitial extends OrgStudentsState {
  const OrgStudentsInitial();
}

final class OrgStudentsLoading extends OrgStudentsState {
  const OrgStudentsLoading();
}

final class OrgStudentsLoaded extends OrgStudentsState {
  const OrgStudentsLoaded({
    required this.students,
    this.currentFilter,
    this.searchQuery,
  });

  final List<OrgStudentModel> students;
  final String? currentFilter;
  final String? searchQuery;

  @override
  List<Object?> get props => [students, currentFilter, searchQuery];
}

final class OrgStudentsFailure extends OrgStudentsState {
  const OrgStudentsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
