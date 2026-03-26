import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_teacher_model.freezed.dart';
part 'class_teacher_model.g.dart';

enum TeacherRole { owner, assistant }

@freezed
abstract class ClassTeacherModel with _$ClassTeacherModel {
  const factory ClassTeacherModel({
    required String id,
    @JsonKey(name: 'teacher_id') String? teacherId,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,
    String? phone,
    @Default('assistant') String role,
    @JsonKey(name: 'assigned_at') String? assignedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ClassTeacherModel;

  factory ClassTeacherModel.fromJson(Map<String, dynamic> json) =>
      _$ClassTeacherModelFromJson(json);
}

extension ClassTeacherModelX on ClassTeacherModel {
  /// Get display name.
  String get displayName => fullName ?? 'Giao vien';

  /// Get teacher role enum.
  TeacherRole get teacherRole {
    switch (role.toLowerCase()) {
      case 'owner':
        return TeacherRole.owner;
      case 'assistant':
      default:
        return TeacherRole.assistant;
    }
  }

  bool get isOwner => teacherRole == TeacherRole.owner;
  bool get isAssistant => teacherRole == TeacherRole.assistant;

  /// Get role display name in Vietnamese.
  String get roleDisplayName {
    switch (teacherRole) {
      case TeacherRole.owner:
        return 'Giao vien chinh';
      case TeacherRole.assistant:
        return 'Tro giang';
    }
  }
}
