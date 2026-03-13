import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository)
      : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  // ignore: unused_field
  final AuthRepository _authRepository;

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Bật lại khi test API
    // final loggedIn =
    //     await _authRepository.isLoggedIn();
    // if (!loggedIn) {
    //   emit(AuthUnauthenticated());
    //   return;
    // }
    // final user =
    //     await _authRepository.getSavedUser();
    // if (user != null) {
    //   emit(AuthAuthenticated(user: user));
    // } else {
    //   emit(AuthUnauthenticated());
    // }

    emit(AuthUnauthenticated());
  }

  Future<void> _onLoggedIn(
    AuthLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Bật lại khi test API
    // if (event.response.user != null) {
    //   emit(AuthAuthenticated(
    //     user: event.response.user!,
    //   ));
    // }

    final user = event.response.user ??
        const UserModel(
          id: 'mock-user',
          username: 'testuser',
          email: 'test@example.com',
        );
    emit(AuthAuthenticated(user: user));
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Bật lại khi test API
    // await _authRepository.logout();

    emit(AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Bật lại khi test API
    // await _authRepository.clearSession();

    emit(AuthUnauthenticated());
  }
}
