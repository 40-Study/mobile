import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';

/// Hình thức buổi học trong lịch "Hôm nay / Tiếp theo".
enum ParentScheduleMode { online, offline }

/// Model cho mục buổi học hôm nay.
class ParentScheduleItem {
  const ParentScheduleItem({
    required this.startTime,
    required this.childName,
    required this.subjectName,
    required this.locationOrLink,
    required this.teacherOrRoom,
    required this.mode,
    required this.statusLabel,
    this.durationMinutes,
    this.lessonTopic,
    this.endTime,
    this.childInitial,
    this.childBadgeColor,
    this.status = ParentSessionStatus.upcoming,
    this.id,
    this.childId,
  });

  final String? id;
  final String? childId;

  /// Giờ bắt đầu dạng "14:00".
  final String startTime;

  /// Giờ kết thúc dạng "15:30" (nếu có).
  final String? endTime;

  final String childName;
  final String? childInitial;
  final Color? childBadgeColor;
  final String subjectName;

  /// Tên chuyên đề/bài học cụ thể.
  final String? lessonTopic;

  /// Online: link học (VD "Trực tuyến trên Google Meet").
  /// Offline: địa điểm (VD "Cơ sở Phan Xích Long").
  final String locationOrLink;

  /// Online: tên giáo viên. Offline: phòng học.
  final String teacherOrRoom;
  final ParentScheduleMode mode;

  /// "Sắp bắt đầu" / "Trực tiếp" / "Đang diễn ra".
  final String statusLabel;

  /// Enum trạng thái chuẩn hóa.
  final ParentSessionStatus status;

  /// Thời lượng tính theo phút (VD 60, 90).
  final int? durationMinutes;

  /// Chuyển đổi sang ParentScheduleSession để dùng chung card hiển thị
  ParentScheduleSession toSession() {
    final now = DateTime.now();
    final startParts = startTime.split(':');
    final startH = int.tryParse(startParts.first) ?? 9;
    final startM =
        int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;
    final startDt = DateTime(now.year, now.month, now.day, startH, startM);

    final duration =
        durationMinutes ?? (mode == ParentScheduleMode.online ? 60 : 90);
    final endDt = endTime != null && endTime!.contains(':')
        ? () {
            final endParts = endTime!.split(':');
            return DateTime(
              now.year,
              now.month,
              now.day,
              int.tryParse(endParts.first) ?? startH + 1,
              int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? startM,
            );
          }()
        : startDt.add(Duration(minutes: duration));

    final initial = childInitial ??
        (childName.isNotEmpty ? childName[0].toUpperCase() : 'C');
    final badgeColor = childBadgeColor ??
        (childName == 'Minh'
            ? const Color(0xFFDBEAFE)
            : const Color(0xFFFCE7F3));

    return ParentScheduleSession(
      id: id ?? '${childName}_$startTime',
      childId: childId ?? childName,
      childName: childName,
      childInitial: initial,
      childBadgeColor: badgeColor,
      subjectName: subjectName,
      lessonTopic: lessonTopic ?? 'Chuyên đề: $subjectName',
      startTime: startDt,
      endTime: endDt,
      instructorName: teacherOrRoom.contains('·')
          ? teacherOrRoom.split('·').last.trim()
          : teacherOrRoom,
      status: status,
      roomOrPlatform: locationOrLink,
    );
  }
}
