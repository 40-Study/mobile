part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kiểm tra session khi app khởi động.
final class AuthStarted extends AuthEvent {}

/// Đăng nhập thành công (completed=true).
final class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.response);
  final AuthResponse response;

  @override
  List<Object?> get props => [response];
}

/// Đăng xuất.
final class AuthLoggedOut extends AuthEvent {}

/// Session hết hạn (refresh token fail).
final class AuthSessionExpired extends AuthEvent {}
