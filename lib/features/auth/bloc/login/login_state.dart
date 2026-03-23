part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginInProgress extends LoginState {}

/// Đăng nhập thành công.
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.response);
  final AuthResponse response;

  @override
  List<Object?> get props => [response];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
