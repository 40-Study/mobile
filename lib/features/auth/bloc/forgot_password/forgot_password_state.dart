part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordInProgress extends ForgotPasswordState {}

/// OTP đã gửi, chờ user nhập OTP + mật khẩu mới.
final class ForgotPasswordOTPSent extends ForgotPasswordState {}

/// Đặt lại mật khẩu thành công.
final class ForgotPasswordSuccess extends ForgotPasswordState {}

final class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
