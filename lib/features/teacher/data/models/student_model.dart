import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

@freezed
abstract class StudentModel with _$StudentModel {
  const factory StudentModel({
    required String id,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'student_code') String? studentCode,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,
    @JsonKey(name: 'enrolled_course') String? enrolledCourse,
    @JsonKey(name: 'progress_percentage') @Default(0) double progress,
    @JsonKey(name: 'last_activity') String? lastActivity,
    @JsonKey(name: 'last_accessed_at') String? lastAccessedAt,
    @JsonKey(name: 'enrolled_at') String? enrolledAt,
    @Default('active') String status,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);
}

extension StudentModelX on StudentModel {
  bool get isCompleted => progress >= 100;
  String get displayCode => studentCode ?? studentId?.substring(0, 8) ?? 'N/A';
  String get displayName => fullName ?? userName ?? 'Unknown';
  String? get displayLastActivity => lastActivity ?? lastAccessedAt;
}
