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
      // Session cũ có thể thiếu profile → thử resolve lại thay vì kẹt màn lỗi
      final profile =
          await _authRepository.getSavedProfile() ??
          await _resolveProfile(
            user,
            await _authRepository.getSavedRole(),
            // Không saveSession ở đây vì nó ghi đè activeOrg đã lưu
            persist: false,
          );
      emit(AuthAuthenticated(user: user, activeProfile: profile));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    final user = event.response.user;
    if (user == null) {
      // Token có thể đã được lưu → xoá để không kẹt session nửa vời
      AppLogger.auth('Login response has no user, clearing session');
      await _authRepository.clearSession();
      emit(AuthUnauthenticated());
      return;
    }

    final activeProfile =
        event.response.activeProfile ??
        await _resolveProfile(user, event.response.activeRole);

    emit(AuthAuthenticated(user: user, activeProfile: activeProfile));
  }

  // Fetch profiles, chọn theo activeRole hoặc profile duy nhất; không đoán khi không khớp
  Future<ProfileModel?> _resolveProfile(
    UserModel user,
    RoleModel? activeRole, {
    bool persist = true,
  }) async {
    try {
      final profiles = await _authRepository.getProfiles();
      AppLogger.auth('Fetched ${profiles.length} profiles');

      final ProfileModel? profile;
      if (activeRole != null) {
        profile = profiles
            .where(
              (p) =>
                  p.systemRoleId == activeRole.id ||
                  p.roleName.toUpperCase() == activeRole.name.toUpperCase(),
            )
            .firstOrNull;
      } else {
        profile = profiles.length == 1 ? profiles.single : null;
      }

      if (profile != null && persist) {
        AppLogger.auth('Selected profile: ${profile.roleName}');
        await _authRepository.saveSession(
          AuthResponse(user: user, activeProfile: profile, activeRole: activeRole),
        );
      }
      return profile;
    } catch (e) {
      AppLogger.w('Error fetching profiles', e);
      return null;
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
