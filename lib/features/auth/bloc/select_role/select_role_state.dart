part of 'select_role_cubit.dart';

sealed class SelectRoleState extends Equatable {
  const SelectRoleState();

  @override
  List<Object?> get props => [];
}

final class SelectRoleInitial extends SelectRoleState {
  const SelectRoleInitial();
}

final class SelectRoleLoading extends SelectRoleState {
  const SelectRoleLoading();
}

final class SelectRoleLoaded extends SelectRoleState {
  const SelectRoleLoaded({required this.roles});

  final List<RoleModel> roles;

  @override
  List<Object?> get props => [roles];
}

final class SelectRoleFailure extends SelectRoleState {
  const SelectRoleFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
