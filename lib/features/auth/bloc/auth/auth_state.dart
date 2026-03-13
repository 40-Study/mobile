part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {}
