import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_link_model.freezed.dart';
part 'family_link_model.g.dart';

/// Thông tin rút gọn của user trong yêu cầu liên kết
@freezed
abstract class LinkUserModel with _$LinkUserModel {
  const factory LinkUserModel({
    required String id,
    @Default('') String username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('') String email,
  }) = _LinkUserModel;

  factory LinkUserModel.fromJson(Map<String, dynamic> json) =>
      _$LinkUserModelFromJson(json);
}

/// Yêu cầu liên kết từ phụ huynh (student side)
@freezed
abstract class ParentLinkRequestModel with _$ParentLinkRequestModel {
  const factory ParentLinkRequestModel({
    required String id,
    @Default('pending') String status,
    @Default('parent') String relationship,
    String? message,
    @JsonKey(name: 'student_email') @Default('') String studentEmail,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'responded_at') String? respondedAt,
    LinkUserModel? parent,
    LinkUserModel? student,
  }) = _ParentLinkRequestModel;

  factory ParentLinkRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ParentLinkRequestModelFromJson(json);
}

/// Phụ huynh đã liên kết với học sinh
@freezed
abstract class LinkedParentModel with _$LinkedParentModel {
  const factory LinkedParentModel({
    required String id,
    @Default('') String username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('') String email,
    @Default('parent') String relationship,
    @JsonKey(name: 'linked_at') String? linkedAt,
  }) = _LinkedParentModel;

  factory LinkedParentModel.fromJson(Map<String, dynamic> json) =>
      _$LinkedParentModelFromJson(json);
}
