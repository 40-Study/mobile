part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial
    extends ForgotPasswordState {}

final class ForgotPasswordInProgress
    extends ForgotPasswordState {}

/// OTP đã gửi, chờ user nhập OTP.
final class ForgotPasswordOTPSent
    extends ForgotPasswordState {}

/// OTP đã xác thực, chờ user nhập mật khẩu mới.
final class ForgotPasswordOTPVerifiedState
    extends ForgotPasswordState {
  const ForgotPasswordOTPVerifiedState({
    required this.email,
    required this.otp,
  });
  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Đặt lại mật khẩu thành công.
final class ForgotPasswordSuccess
    extends ForgotPasswordState {}

final class ForgotPasswordFailure
    extends ForgotPasswordState {
  const ForgotPasswordFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
