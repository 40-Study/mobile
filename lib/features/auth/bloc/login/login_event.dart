part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi email + password để đăng nhập.
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Chọn role sau khi login có 2+ roles.
final class LoginRoleSelected extends LoginEvent {
  const LoginRoleSelected({
    required this.sessionToken,
    required this.roleId,
    required this.roleType,
    this.organizationId,
  });

  final String sessionToken;
  final String roleId;
  final String roleType;
  final String? organizationId;

  @override
  List<Object?> get props => [sessionToken, roleId, roleType, organizationId];
}
