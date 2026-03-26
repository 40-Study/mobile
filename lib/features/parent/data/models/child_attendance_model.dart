import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_attendance_model.freezed.dart';
part 'child_attendance_model.g.dart';

enum AttendanceStatus { present, absent, late, excused }

@freezed
abstract class ChildAttendanceModel with _$ChildAttendanceModel {
  const factory ChildAttendanceModel({
    required String id,
    required String date,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'class_name') String? className,
    @Default('present') String status,
    String? note,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ChildAttendanceModel;

  factory ChildAttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$ChildAttendanceModelFromJson(json);
}

extension ChildAttendanceModelX on ChildAttendanceModel {
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
        return AttendanceStatus.present;
    }
  }

  String get statusDisplay {
    switch (attendanceStatus) {
      case AttendanceStatus.present:
        return 'Co mat';
      case AttendanceStatus.absent:
        return 'Vang';
      case AttendanceStatus.late:
        return 'Muon';
      case AttendanceStatus.excused:
        return 'Co phep';
    }
  }

  String get statusDisplayVietnamese {
    switch (attendanceStatus) {
      case AttendanceStatus.present:
        return 'Co mat';
      case AttendanceStatus.absent:
        return 'Vang';
      case AttendanceStatus.late:
        return 'Muon';
      case AttendanceStatus.excused:
        return 'Co phep';
    }
  }
}
