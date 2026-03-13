import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/auth/data/models/device_model.dart';
import 'package:study/features/auth/data/models/entry_context_model.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/auth/data/models/role_model.dart';
import 'package:study/features/auth/data/models/user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Response chung cho login / select-profile / select-org.
/// [completed] = true -> có token, vào app.
/// [completed] = false -> cần chọn role hoặc org tiếp.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool completed,
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    UserModel? user,
    @JsonKey(name: 'active_role') RoleModel? activeRole,
    @JsonKey(name: 'active_org') OrganizationModel? activeOrg,
    @JsonKey(name: 'entry_context') EntryContextModel? entryContext,
    @JsonKey(name: 'current_device') DeviceModel? currentDevice,
    @JsonKey(name: 'session_token') String? sessionToken,
    @JsonKey(name: 'system_roles') List<RoleModel>? systemRoles,
    @JsonKey(name: 'requires_org_selection')
    @Default(false)
    bool requiresOrgSelection,
    List<OrganizationModel>? organizations,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Wrapper response API: message + data.
@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required String message,
    T? data,
  }) = _ApiResponse<T>;
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
    @JsonKey(name: 'role_ids') List<String>? roleIds,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}
