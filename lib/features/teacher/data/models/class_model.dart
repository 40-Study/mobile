import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

enum ClassStatus { active, inactive, completed, cancelled }

@freezed
abstract class ClassModel with _$ClassModel {
  const factory ClassModel({
    required String id,
    String? name,
    String? description,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'max_students') @Default(30) int maxStudents,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'teacher_count') @Default(0) int teacherCount,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @Default('active') String status,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    // Schedule info for next class
    @JsonKey(name: 'next_schedule_date') String? nextScheduleDate,
    @JsonKey(name: 'next_schedule_time') String? nextScheduleTime,
    @JsonKey(name: 'next_schedule_room') String? nextScheduleRoom,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);
}

extension ClassModelX on ClassModel {
  /// Get display name.
  String get displayName => name ?? 'Lop hoc chua dat ten';

  /// Get class status enum.
  ClassStatus get classStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return ClassStatus.active;
      case 'inactive':
        return ClassStatus.inactive;
      case 'completed':
        return ClassStatus.completed;
      case 'cancelled':
        return ClassStatus.cancelled;
      default:
        return ClassStatus.active;
    }
  }

  bool get isActive => classStatus == ClassStatus.active;
  bool get isCompleted => classStatus == ClassStatus.completed;
  bool get isFull => studentCount >= maxStudents;

  /// Get available slots.
  int get availableSlots => maxStudents - studentCount;

  /// Get fill percentage.
  double get fillPercentage =>
      maxStudents > 0 ? (studentCount / maxStudents) * 100 : 0;

  /// Get formatted date range.
  String get dateRange {
    if (startDate == null && endDate == null) return 'Chua xac dinh';
    if (startDate != null && endDate != null) {
      return '$startDate - $endDate';
    }
    return startDate ?? endDate ?? '';
  }
}
