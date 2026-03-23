import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/profile/profile_state.dart';
import 'package:study/features/auth/data/error_handler.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileInitial());

  final AuthRepository _authRepository;

  Future<void> loadProfiles() async {
    emit(const ProfileLoading());

    try {
      final profiles = await _authRepository.getProfiles();
      emit(ProfileLoaded(profiles: profiles));
    } on DioException catch (e) {
      emit(ProfileFailure(message: AuthErrorHandler.extractMessage(e)));
    }
  }

  Future<void> switchProfile({
    required String profileType,
    required String profileId,
  }) async {
    final currentProfiles = _getCurrentProfiles();

    emit(ProfileSwitching(
      profiles: currentProfiles,
      switchingProfileId: profileId,
    ));

    try {
      final response = await _authRepository.switchProfile(
        profileType: profileType,
        profileId: profileId,
      );
      emit(ProfileSwitched(
        profiles: currentProfiles,
        newProfile: response.activeProfile,
        authResponse: response,
      ));
    } on DioException catch (e) {
      emit(ProfileSwitchFailure(
        profiles: currentProfiles,
        message: AuthErrorHandler.extractMessage(e),
      ));
    }
  }

  List<ProfileModel> _getCurrentProfiles() {
    return switch (state) {
      ProfileLoaded(:final profiles) => profiles,
      ProfileSwitching(:final profiles) => profiles,
      ProfileSwitched(:final profiles) => profiles,
      ProfileSwitchFailure(:final profiles) => profiles,
      ProfileInitial() => [],
      ProfileLoading() => [],
      ProfileFailure() => [],
    };
  }
}
