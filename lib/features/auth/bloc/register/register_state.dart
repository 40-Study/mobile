part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterInProgress extends RegisterState {}

final class RegisterRolesLoaded extends RegisterState {
  const RegisterRolesLoaded(this.roles);
  final List<RoleModel> roles;

  @override
  List<Object?> get props => [roles];
}

final class RegisterRolesFailure extends RegisterState {
  const RegisterRolesFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// OTP đã gửi, chờ user nhập.
final class RegisterOTPSent extends RegisterState {}

/// Đăng ký thành công.
final class RegisterSuccess extends RegisterState {}

final class RegisterFailure extends RegisterState {
  const RegisterFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
