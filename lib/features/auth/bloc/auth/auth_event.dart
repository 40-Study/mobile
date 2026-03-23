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

/// Chuyển đổi profile thành công.
final class AuthProfileSwitched extends AuthEvent {
  const AuthProfileSwitched(this.response);
  final AuthResponse response;

  @override
  List<Object?> get props => [response];
}

/// Session hết hạn (refresh token fail).
final class AuthSessionExpired extends AuthEvent {}

/// User cập nhật thông tin.
final class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.user);
  final UserModel user;

  @override
  List<Object?> get props => [user];
}
