part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginInProgress extends LoginState {}

/// Đăng nhập thành công (1 role - login hoàn tất).
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.response);
  final AuthResponse response;

  @override
  List<Object?> get props => [response];
}

/// Cần chọn role từ danh sách đã có (2+ roles).
/// roles là UnifiedRoleDto[] từ API
final class LoginNeedsRoleSelection extends LoginState {
  const LoginNeedsRoleSelection({
    required this.sessionToken,
    required this.roles,
    this.requiresOrgSelection = false,
  });
  final String sessionToken;
  final List<RoleModel> roles;
  final bool requiresOrgSelection;

  @override
  List<Object?> get props => [sessionToken, roles, requiresOrgSelection];
}

/// Cần đăng ký role mới (0 roles - sau login không có role nào).
final class LoginNeedsRoleRegistration extends LoginState {
  const LoginNeedsRoleRegistration({
    required this.sessionToken,
    this.user,
  });
  final String sessionToken;
  final UserModel? user;

  @override
  List<Object?> get props => [sessionToken, user];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
