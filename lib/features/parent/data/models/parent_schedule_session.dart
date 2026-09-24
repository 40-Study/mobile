import 'package:flutter/material.dart';

/// Trạng thái của buổi học đối với Phụ huynh.
enum ParentSessionStatus {
  inProgress,
  upcoming,
  completed,
  cancelled,
  rescheduled,
}

/// Chế độ xem lọc thời gian trên Tab Lịch học.
enum ParentScheduleTab {
  today,
  week,
  month,
}

/// Model cho ca học của con (dùng chung cho cả Home & Schedule).
class ParentScheduleSession {
  const ParentScheduleSession({
    required this.id,
    required this.childId,
    required this.childName,
    required this.childInitial,
    required this.childBadgeColor,
    required this.subjectName,
    required this.lessonTopic,
    required this.startTime,
    required this.endTime,
    required this.instructorName,
    required this.status,
    this.statusNote,
    this.roomOrPlatform,
    this.meetingUrl,
  });

  final String id;
  final String childId;
  final String childName;
  final String childInitial;
  final Color childBadgeColor;
  final String subjectName;
  final String lessonTopic;
  final DateTime startTime;
  final DateTime endTime;
  final String instructorName;
  final ParentSessionStatus status;
  final String? statusNote;
  final String? roomOrPlatform;
  final String? meetingUrl;

  /// Chuỗi hiển thị giờ dạng "09:00 — 10:00"
  String get timeRangeText {
    final startH = startTime.hour.toString().padLeft(2, '0');
    final startM = startTime.minute.toString().padLeft(2, '0');
    final endH = endTime.hour.toString().padLeft(2, '0');
    final endM = endTime.minute.toString().padLeft(2, '0');
    return '$startH:$startM — $endH:$endM';
  }

  /// Label hiển thị cho status badge
  String get statusLabel {
    switch (status) {
      case ParentSessionStatus.inProgress:
        return 'Đang diễn ra';
      case ParentSessionStatus.upcoming:
        return 'Sắp diễn ra';
      case ParentSessionStatus.completed:
        return 'Đã kết thúc';
      case ParentSessionStatus.rescheduled:
        return 'Đã đổi lịch';
      case ParentSessionStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Trạng thái badge có chấm tròn xanh phía trước không
  bool get hasLeadingDot => status == ParentSessionStatus.inProgress;
}
