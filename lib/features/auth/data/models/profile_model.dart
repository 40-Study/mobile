import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// ProfileDto - theo API DOCS
/// GET /auth/me/profiles returns array of ProfileDto
/// {
///   "id": "uuid",
///   "type": "system|org",
///   "system_role_id": "uuid",
///   "display_name": "string",
///   "role_name": "TEACHER",
///   "status": "active",
///   "created_at": "ISO8601",
///   "organization_id": "uuid|null",
///   "organization_name": "string|null"
/// }
@freezed
abstract class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    @Default('system') String type,
    @JsonKey(name: 'system_role_id') String? systemRoleId,
    @JsonKey(name: 'role_name') @Default('') String roleName,
    @JsonKey(name: 'display_name') String? displayName,
    String? description,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
