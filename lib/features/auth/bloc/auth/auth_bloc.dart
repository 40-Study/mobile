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
      final profile = await _authRepository.getSavedProfile();
      emit(AuthAuthenticated(user: user, activeProfile: profile));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    if (event.response.user != null) {
      var activeProfile = event.response.activeProfile;

      // If no activeProfile in response, try to fetch from profiles API
      if (activeProfile == null) {
        try {
          final profiles = await _authRepository.getProfiles();
          // ignore: avoid_print
          print('📋 Fetched ${profiles.length} profiles after login');
          for (final p in profiles) {
            // ignore: avoid_print
            print('📋 Profile: ${p.roleName} - ${p.type}');
          }
          if (profiles.isNotEmpty) {
            activeProfile = profiles.first;
            // ignore: avoid_print
            print('📋 Using first profile: ${activeProfile.roleName}');
            // Save the profile to storage
            await _authRepository.saveSession(
              AuthResponse(
                user: event.response.user,
                activeProfile: activeProfile,
              ),
            );
          }
        } catch (_) {
          // Ignore error, continue without profile
        }
      }

      emit(AuthAuthenticated(
        user: event.response.user!,
        activeProfile: activeProfile,
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
    // ignore: avoid_print
    print('🔐 AuthBloc: ProfileSwitched event received');
    // ignore: avoid_print
    print('🔐 AuthBloc: response.user = ${event.response.user}');
    // ignore: avoid_print
    print('🔐 AuthBloc: activeProfile = ${event.response.activeProfile?.toJson()}');

    final currentState = state;
    final user = event.response.user ??
        (currentState is AuthAuthenticated ? currentState.user : null);

    if (user != null) {
      emit(AuthAuthenticated(
        user: user,
        activeProfile: event.response.activeProfile,
      ));
      // ignore: avoid_print
      print('🔐 AuthBloc: Emitted AuthAuthenticated with role: ${event.response.activeProfile?.roleName}');
    } else {
      // ignore: avoid_print
      print('🔐 AuthBloc: Cannot emit - no user available');
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
