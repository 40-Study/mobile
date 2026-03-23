part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi form đăng ký (bước 1).
final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
    required this.roleId,
    this.fullName,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String userName;
  final String roleId;
  final String? fullName;

  @override
  List<Object?> get props => [
    email,
    password,
    confirmPassword,
    userName,
    roleId,
    fullName,
  ];
}

/// Xác thực OTP (bước 2).
final class RegisterOTPSubmitted extends RegisterEvent {
  const RegisterOTPSubmitted({required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Gửi lại OTP.
final class RegisterOTPResent extends RegisterEvent {
  const RegisterOTPResent({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
    required this.roleId,
    this.fullName,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String userName;
  final String roleId;
  final String? fullName;

  @override
  List<Object?> get props => [email];
}
