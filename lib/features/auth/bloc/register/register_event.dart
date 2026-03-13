part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi form đăng ký.
final class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
    this.fullName,
    this.roleIds,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String userName;
  final String? fullName;
  final List<String>? roleIds;

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        userName,
        fullName,
        roleIds,
      ];
}

/// Xác thực OTP.
final class RegisterOTPSubmitted extends RegisterEvent {
  const RegisterOTPSubmitted({
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Gửi lại OTP (gọi lại register/request).
final class RegisterOTPResent extends RegisterEvent {
  const RegisterOTPResent({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
    this.fullName,
    this.roleIds,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String userName;
  final String? fullName;
  final List<String>? roleIds;

  @override
  List<Object?> get props => [email];
}
