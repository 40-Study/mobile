import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/student/bloc/profile/profile_event.dart';
import 'package:study/features/student/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._authRepository) : super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileInProgress());

    try {
      final user = await _authRepository.getMe();
      emit(ProfileSuccess(user: user));
    } catch (e) {
      // Fallback to saved user nếu API fail
      final savedUser = await _authRepository.getSavedUser();
      if (savedUser != null) {
        emit(ProfileSuccess(user: savedUser));
      } else {
        emit(ProfileFailure(e.toString()));
      }
    }
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _authRepository.logout();
    emit(const ProfileLoggedOut());
  }
}
