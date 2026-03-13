part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi email yêu cầu OTP reset mật khẩu.
final class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordSubmitted({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Xác thực OTP + đặt mật khẩu mới.
final class ForgotPasswordOTPSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordOTPSubmitted({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [email, otp, newPassword];
}

/// Gửi lại OTP.
final class ForgotPasswordOTPResent extends ForgotPasswordEvent {
  const ForgotPasswordOTPResent({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}
