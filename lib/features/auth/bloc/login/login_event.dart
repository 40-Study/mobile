part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi email + password.
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Chọn role (khi login trả system_roles).
final class LoginRoleSelected extends LoginEvent {
  const LoginRoleSelected({
    required this.sessionToken,
    required this.systemRoleId,
  });

  final String sessionToken;
  final String systemRoleId;

  @override
  List<Object?> get props => [sessionToken, systemRoleId];
}

/// Chọn tổ chức (khi cần chọn org).
final class LoginOrgSelected extends LoginEvent {
  const LoginOrgSelected({
    required this.sessionToken,
    this.organizationId,
  });

  final String sessionToken;
  final String? organizationId;

  @override
  List<Object?> get props => [sessionToken, organizationId];
}
