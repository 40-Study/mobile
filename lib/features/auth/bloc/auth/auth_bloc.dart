import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/core/logger/app_logger.dart';
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
      final activeRole = event.response.activeRole;

      // If no activeProfile in response, try to fetch from profiles API
      if (activeProfile == null) {
        try {
          final profiles = await _authRepository.getProfiles();
          AppLogger.auth('Fetched ${profiles.length} profiles after login');
          for (final p in profiles) {
            AppLogger.auth(
              'Profile: ${p.roleName} - ${p.type} - '
              'systemRoleId: ${p.systemRoleId}',
            );
          }

          if (profiles.isNotEmpty) {
            // Tìm profile khớp với activeRole (nếu có)
            if (activeRole != null) {
              AppLogger.auth(
                'Looking for profile matching activeRole: '
                '${activeRole.name} (id: ${activeRole.id})',
              );
              activeProfile = profiles.firstWhere(
                (p) =>
                    p.systemRoleId == activeRole.id ||
                    p.roleName.toUpperCase() == activeRole.name.toUpperCase(),
                orElse: () => profiles.first,
              );
            } else {
              activeProfile = profiles.first;
            }
            AppLogger.auth('Selected profile: ${activeProfile.roleName}');
            // Save the profile to storage
            await _authRepository.saveSession(
              AuthResponse(
                user: event.response.user,
                activeProfile: activeProfile,
                activeRole: activeRole,
              ),
            );
          }
        } catch (e) {
          AppLogger.w('Error fetching profiles after login', e);
        }
      }

      emit(
        AuthAuthenticated(
          user: event.response.user!,
          activeProfile: activeProfile,
        ),
      );
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      // Nếu API lỗi, vẫn clear session local
      await _authRepository.clearSession();
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onProfileSwitched(
    AuthProfileSwitched event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('ProfileSwitched event received');
    AppLogger.auth('response.user = ${event.response.user}');
    AppLogger.auth('activeProfile = ${event.response.activeProfile?.toJson()}');

    final currentState = state;
    final user =
        event.response.user ??
        (currentState is AuthAuthenticated ? currentState.user : null);

    if (user != null) {
      final newState = AuthAuthenticated(
        user: user,
        activeProfile: event.response.activeProfile,
      );
      AppLogger.auth('Emitting new state...');
      AppLogger.auth('roleName = ${newState.roleName}');
      AppLogger.auth('isOrganizationOwner = ${newState.isOrganizationOwner}');
      AppLogger.auth('isTeacher = ${newState.isTeacher}');
      emit(newState);
      AppLogger.auth('State emitted successfully');
    } else {
      AppLogger.auth('Cannot emit - no user available');
    }
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearSession();
    emit(AuthUnauthenticated());
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(
        AuthAuthenticated(
          user: event.user,
          activeProfile: currentState.activeProfile,
        ),
      );
    }
  }
}
