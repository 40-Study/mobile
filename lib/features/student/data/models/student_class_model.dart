import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_class_model.freezed.dart';
part 'student_class_model.g.dart';

@freezed
abstract class StudentClassModel with _$StudentClassModel {
  const factory StudentClassModel({
    required String id,
    String? name,
    String? description,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'teacher_avatar') String? teacherAvatar,
    @JsonKey(name: 'schedule_text') String? scheduleText,
    @JsonKey(name: 'attendance_rate') @Default(0) double attendanceRate,
    @JsonKey(name: 'average_score') @Default(0) double averageScore,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'max_students') @Default(0) int maxStudents,
    @Default('active') String status,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
  }) = _StudentClassModel;

  factory StudentClassModel.fromJson(Map<String, dynamic> json) =>
      _$StudentClassModelFromJson(json);
}

extension StudentClassModelX on StudentClassModel {
  String get displayName => name ?? 'Chua dat ten';

  String get attendanceText => '${attendanceRate.toStringAsFixed(0)}%';

  String get scoreText => averageScore > 0 ? averageScore.toStringAsFixed(1) : '-';

  bool get isActive => status.toLowerCase() == 'active';
}
