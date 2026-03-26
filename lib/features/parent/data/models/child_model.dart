import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
abstract class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String id,
    required String name,
    String? grade,
    String? school,
    @JsonKey(name: 'attendance_rate') @Default(0.0) double attendanceRate,
    @JsonKey(name: 'average_score') @Default(0.0) double averageScore,
    @JsonKey(name: 'class_count') @Default(0) int classCount,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'user_id') String? userId,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}

extension ChildModelX on ChildModel {
  String get displayGrade => grade ?? 'Chưa xác định';
  String get displaySchool => school ?? 'Chưa xác định';
  String get attendancePercentage => '${(attendanceRate * 100).toStringAsFixed(0)}%';
  String get averageScoreDisplay => averageScore.toStringAsFixed(1);
}
