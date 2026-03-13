part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginInProgress extends LoginState {}

/// Đăng nhập xong (completed=true).
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.response);
  final AuthResponse response;

  @override
  List<Object?> get props => [response];
}

/// Cần chọn role.
final class LoginNeedRole extends LoginState {
  const LoginNeedRole({
    required this.sessionToken,
    required this.roles,
  });

  final String sessionToken;
  final List<RoleModel> roles;

  @override
  List<Object?> get props => [sessionToken, roles];
}

/// Cần chọn tổ chức.
final class LoginNeedOrg extends LoginState {
  const LoginNeedOrg({
    required this.sessionToken,
    required this.organizations,
    this.activeRole,
  });

  final String sessionToken;
  final List<OrganizationModel> organizations;
  final RoleModel? activeRole;

  @override
  List<Object?> get props => [
        sessionToken,
        organizations,
        activeRole,
      ];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
