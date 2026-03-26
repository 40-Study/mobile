import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

enum AttendanceStatus { present, absent, late, excused }

@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    required String id,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'student_id') String? studentId,
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'student_code') String? studentCode,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'schedule_id') String? scheduleId,
    @JsonKey(name: 'session_date') String? sessionDate,
    @Default('absent') String status,
    String? note,
    @JsonKey(name: 'checked_at') String? checkedAt,
    @JsonKey(name: 'checked_by') String? checkedBy,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}

extension AttendanceModelX on AttendanceModel {
  /// Get display name.
  String get displayName => studentName ?? 'Hoc vien';

  /// Get display code.
  String get displayCode => studentCode ?? studentId?.substring(0, 8) ?? 'N/A';

  /// Get attendance status enum.
  AttendanceStatus get attendanceStatus {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.absent;
    }
  }

  bool get isPresent => attendanceStatus == AttendanceStatus.present;
  bool get isAbsent => attendanceStatus == AttendanceStatus.absent;
  bool get isLate => attendanceStatus == AttendanceStatus.late;
  bool get isExcused => attendanceStatus == AttendanceStatus.excused;

  /// Get status display name in Vietnamese.
  String get statusDisplayName {
    switch (attendanceStatus) {
      case AttendanceStatus.present:
        return 'Co mat';
      case AttendanceStatus.absent:
        return 'Vang mat';
      case AttendanceStatus.late:
        return 'Di muon';
      case AttendanceStatus.excused:
        return 'Co phep';
    }
  }

  /// Get status color hint.
  String get statusColorHint {
    switch (attendanceStatus) {
      case AttendanceStatus.present:
        return 'green';
      case AttendanceStatus.absent:
        return 'red';
      case AttendanceStatus.late:
        return 'orange';
      case AttendanceStatus.excused:
        return 'blue';
    }
  }
}
