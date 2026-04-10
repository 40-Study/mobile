part of 'org_teachers_cubit.dart';

@immutable
sealed class OrgTeachersState extends Equatable {
  const OrgTeachersState();

  @override
  List<Object?> get props => [];
}

final class OrgTeachersInitial extends OrgTeachersState {
  const OrgTeachersInitial();
}

final class OrgTeachersLoading extends OrgTeachersState {
  const OrgTeachersLoading();
}

final class OrgTeachersLoaded extends OrgTeachersState {
  const OrgTeachersLoaded({
    required this.teachers,
    this.currentFilter,
    this.searchQuery,
  });

  final List<OrgTeacherModel> teachers;
  final String? currentFilter;
  final String? searchQuery;

  @override
  List<Object?> get props => [teachers, currentFilter, searchQuery];
}

final class OrgTeachersFailure extends OrgTeachersState {
  const OrgTeachersFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
