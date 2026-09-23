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
  });

  /// Giờ bắt đầu dạng "14:00".
  final String startTime;
  final String childName;
  final String subjectName;

  /// Online: link học (VD "Trực tuyến trên Google Meet").
  /// Offline: địa điểm (VD "Cơ sở Phan Xích Long").
  final String locationOrLink;

  /// Online: tên giáo viên. Offline: phòng học.
  final String teacherOrRoom;
  final ParentScheduleMode mode;

  /// "Sắp bắt đầu" / "Trực tiếp".
  final String statusLabel;

  /// Thời lượng tính theo phút (VD 60, 90).
  final int? durationMinutes;
}
