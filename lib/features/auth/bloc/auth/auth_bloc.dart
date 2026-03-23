import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthProfileSwitched>(_onProfileSwitched);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (!loggedIn) {
      emit(AuthUnauthenticated());
      return;
    }
    final user = await _authRepository.getSavedUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    if (event.response.user != null) {
      emit(AuthAuthenticated(
        user: event.response.user!,
        activeProfile: event.response.activeProfile,
      ));
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onProfileSwitched(
    AuthProfileSwitched event,
    Emitter<AuthState> emit,
  ) async {
    if (event.response.user != null) {
      emit(AuthAuthenticated(
        user: event.response.user!,
        activeProfile: event.response.activeProfile,
      ));
    }
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearSession();
    emit(AuthUnauthenticated());
  }

  void _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthAuthenticated(
        user: event.user,
        activeProfile: currentState.activeProfile,
      ));
    }
  }
}
