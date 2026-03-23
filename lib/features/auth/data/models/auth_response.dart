import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/auth/data/models/device_model.dart';
import 'package:study/features/auth/data/models/entry_context_model.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/auth/data/models/profile_model.dart';
import 'package:study/features/auth/data/models/role_model.dart';
import 'package:study/features/auth/data/models/user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Response cho login / switch-profile.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    UserModel? user,
    @JsonKey(name: 'active_role') RoleModel? activeRole,
    @JsonKey(name: 'active_org') OrganizationModel? activeOrg,
    @JsonKey(name: 'entry_context') EntryContextModel? entryContext,
    @JsonKey(name: 'current_device') DeviceModel? currentDevice,
    @JsonKey(name: 'active_profile') ProfileModel? activeProfile,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Wrapper response API: message + data.
@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({required String message, T? data}) =
      _ApiResponse<T>;
}

/// Cặp token trả về từ refresh-token.
@freezed
abstract class TokenPair with _$TokenPair {
  const factory TokenPair({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
}

/// Response xác thực OTP đăng ký.
@freezed
abstract class RegisterResponse with _$RegisterResponse {
  const factory RegisterResponse({
    required String id,
    required String email,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'role_id') String? roleId,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}
