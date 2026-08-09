import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/auth/data/models/device_model.dart';
import 'package:study/features/auth/data/models/entry_context_model.dart';
import 'package:study/features/auth/data/models/role_model.dart';
import 'package:study/features/auth/data/models/user_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Response cho API /auth/login
///
/// Case 1 - Single role (completed):
/// {
///   "completed": true,
///   "access_token": "string",
///   "refresh_token": "string",
///   "user": { UserResponseDto },
///   "active_role": { UnifiedRoleDto },
///   "entry_context": { ... },
///   "current_device": { DeviceSessionDto }
/// }
///
/// Case 2 - Multiple roles (needs selection):
/// {
///   "completed": false,
///   "session_token": "string",
///   "roles": [ UnifiedRoleDto[] ],
///   "requires_org_selection": false
/// }
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    /// True nếu login hoàn tất (1 role)
    @Default(false) bool completed,

    /// Session token tạm - dùng khi cần chọn role
    @JsonKey(name: 'session_token') String? sessionToken,

    /// Access token - có khi login thành công
    @JsonKey(name: 'access_token') String? accessToken,

    /// Refresh token
    @JsonKey(name: 'refresh_token') String? refreshToken,

    /// User info - có khi completed=true
    UserModel? user,

    /// Active role sau khi login thành công
    @JsonKey(name: 'active_role') RoleModel? activeRole,

    /// Entry context
    @JsonKey(name: 'entry_context') EntryContextModel? entryContext,

    /// Current device info
    @JsonKey(name: 'current_device') DeviceModel? currentDevice,

    /// Danh sách roles - khi có nhiều roles cần chọn
    @Default([]) List<RoleModel> roles,

    /// True nếu cần chọn organization
    @JsonKey(name: 'requires_org_selection') @Default(false) bool requiresOrgSelection,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
