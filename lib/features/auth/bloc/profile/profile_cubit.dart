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

  /// Switch to a different profile/role
  ///
  /// Theo API DOCS:
  /// - POST /auth/switch-role cần role_id, role_type, organization_id (nếu org)
  /// - role_id là system_role_id từ ProfileDto, KHÔNG phải profile.id
  Future<void> switchProfile(ProfileModel profile) async {
    final currentProfiles = _getCurrentProfiles();

    emit(ProfileSwitching(
      profiles: currentProfiles,
      switchingProfileId: profile.id,
    ));

    try {
      // API cần system_role_id, không phải profile.id
      // Nếu không có system_role_id thì không thể switch
      final roleId = profile.systemRoleId;
      if (roleId == null || roleId.isEmpty) {
        emit(ProfileSwitchFailure(
          profiles: currentProfiles,
          message: 'Không thể chuyển vai trò: thiếu thông tin role',
        ));
        return;
      }

      final response = await _authRepository.switchRole(
        roleId: roleId,
        roleType: profile.type,
        organizationId: profile.organizationId,
      );

      emit(ProfileSwitched(
        profiles: currentProfiles,
        newProfile: response.activeProfile ?? profile,
        authResponse: response,
      ));
    } on DioException catch (e) {
      emit(ProfileSwitchFailure(
        profiles: currentProfiles,
        message: AuthErrorHandler.extractMessage(e),
      ));
    } catch (e) {
      emit(ProfileSwitchFailure(
        profiles: currentProfiles,
        message: 'Lỗi: $e',
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
