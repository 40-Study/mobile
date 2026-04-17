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
      final activeRole = event.response.activeRole;

      // If no activeProfile in response, try to fetch from profiles API
      if (activeProfile == null) {
        try {
          final profiles = await _authRepository.getProfiles();
          // ignore: avoid_print
          print('📋 Fetched ${profiles.length} profiles after login');
          for (final p in profiles) {
            // ignore: avoid_print
            print('📋 Profile: ${p.roleName} - ${p.type} - systemRoleId: ${p.systemRoleId}');
          }

          if (profiles.isNotEmpty) {
            // Tìm profile khớp với activeRole (nếu có)
            if (activeRole != null) {
              // ignore: avoid_print
              print('📋 Looking for profile matching activeRole: ${activeRole.name} (id: ${activeRole.id})');
              activeProfile = profiles.firstWhere(
                (p) => p.systemRoleId == activeRole.id ||
                       p.roleName.toUpperCase() == activeRole.name.toUpperCase(),
                orElse: () => profiles.first,
              );
            } else {
              activeProfile = profiles.first;
            }
            // ignore: avoid_print
            print('📋 Selected profile: ${activeProfile.roleName}');
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
          // ignore: avoid_print
          print('📋 Error fetching profiles: $e');
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
      final newState = AuthAuthenticated(
        user: user,
        activeProfile: event.response.activeProfile,
      );
      // ignore: avoid_print
      print('🔐 AuthBloc: Emitting new state...');
      // ignore: avoid_print
      print('🔐 AuthBloc: roleName = ${newState.roleName}');
      // ignore: avoid_print
      print('🔐 AuthBloc: isOrganizationOwner = ${newState.isOrganizationOwner}');
      // ignore: avoid_print
      print('🔐 AuthBloc: isTeacher = ${newState.isTeacher}');
      emit(newState);
      // ignore: avoid_print
      print('🔐 AuthBloc: State emitted successfully');
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
