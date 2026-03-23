part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterInProgress extends RegisterState {}

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
