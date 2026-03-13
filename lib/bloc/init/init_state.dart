part of 'init_bloc.dart';

sealed class InitState extends Equatable {
  const InitState();

  @override
  List<Object> get props => [];
}

final class InitInitial extends InitState {}

final class InitOpenOnboarding extends InitState {}

final class InitOpenApp extends InitState {}

/// Chưa đăng nhập -> chuyển sang màn login.
final class InitOpenLogin extends InitState {}
