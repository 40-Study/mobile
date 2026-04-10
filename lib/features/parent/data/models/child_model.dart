import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

/// Child model theo API DOCS - GET /me/children
/// Response: { children: [ChildDto], total, page, page_size }
@freezed
abstract class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String id,
    // API fields
    String? username,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('parent') String relationship, // parent|guardian|grandparent
    // Extended fields for app functionality
    required String name, // Display name (fullName or username)
    String? grade,
    String? school,
    @JsonKey(name: 'attendance_rate') @Default(0.0) double attendanceRate,
    @JsonKey(name: 'average_score') @Default(0.0) double averageScore,
    @JsonKey(name: 'class_count') @Default(0) int classCount,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'user_id') String? userId,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}

extension ChildModelX on ChildModel {
  /// Display name - prefer fullName, fallback to name or username
  String get displayName => fullName ?? name;

  String get displayGrade => grade ?? 'Chưa xác định';
  String get displaySchool => school ?? 'Chưa xác định';
  String get attendancePercentage => '${(attendanceRate * 100).toStringAsFixed(0)}%';
  String get averageScoreDisplay => averageScore.toStringAsFixed(1);

  /// Relationship display in Vietnamese
  String get relationshipDisplay {
    switch (relationship) {
      case 'guardian':
        return 'Người giám hộ';
      case 'grandparent':
        return 'Ông bà';
      default:
        return 'Phụ huynh';
    }
  }
}
