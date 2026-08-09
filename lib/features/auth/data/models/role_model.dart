import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_model.freezed.dart';
part 'role_model.g.dart';

/// Helper để đọc 'role_name' hoặc 'name' từ JSON
/// - GET /auth/system-roles returns 'name'
/// - UnifiedRoleDto (login, my-roles) returns 'role_name'
Object? _readRoleName(Map<dynamic, dynamic> json, String key) {
  return json['role_name'] ?? json['name'];
}

/// Role Model - dùng cho cả system_roles và UnifiedRoleDto
///
/// GET /auth/system-roles returns:
/// { "id", "name", "description" }
///
/// UnifiedRoleDto (login, my-roles, active_role):
/// { "id", "type", "role_name", "organization_id", "organization_name", "display_name" }
@freezed
abstract class RoleModel with _$RoleModel {
  const factory RoleModel({
    required String id,
    /// 'name' from system-roles or 'role_name' from UnifiedRoleDto
    @JsonKey(readValue: _readRoleName) required String name,
    /// 'system' or 'organization'
    String? type,
    @JsonKey(name: 'display_name') String? displayName,
    String? description,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
  }) = _RoleModel;

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
}
