import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
abstract class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required String type,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'role_name') required String roleName,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'organization_name') String? organizationName,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
