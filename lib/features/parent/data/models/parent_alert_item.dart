/// 4 Mức độ ưu tiên của cảnh báo "Cần xử lý" theo Spec (Dòng 311 của
/// deliverable.md):
/// (1) Khẩn cấp/thay đổi bất thường (lớp đổi giờ/hủy trong ngày, bài quá hạn)
/// (2) Đến hạn trong hôm nay
/// (3) Sự kiện tiếp theo
/// (4) Tổng quan không cần hành động
enum ParentAlertTier {
  /// Tier 1: Khẩn cấp / Thay đổi bất thường
  emergency,

  /// Tier 2: Đến hạn trong hôm nay
  dueToday,

  /// Tier 3: Sự kiện tiếp theo
  nextEvent,

  /// Tier 4: Tổng quan / Thông tin chung
  generalInfo,
}

/// Loại cảnh báo "Cần xử lý".
enum ParentAlertType {
  overdue,
  scheduleChange,
  dueToday,
  upcomingExam,
  announcement,
}

/// Model cho mục Cần xử lý (bài tập quá hạn / đổi lịch học / thông báo quan trọng).
class ParentAlertItem {
  const ParentAlertItem({
    required this.type,
    required this.childName,
    required this.subjectName,
    required this.detail,
    required this.metaText,
    required this.tagLabel,
    this.tier = ParentAlertTier.emergency,
    this.childId,
    this.targetId,
    this.timestamp,
  });

  final ParentAlertTier tier;
  final ParentAlertType type;
  final String? childId;
  final String? targetId;
  final String childName;
  final String subjectName;

  /// Mô tả chính, ví dụ: "1 bài tập trắc nghiệm đã quá hạn nộp".
  final String detail;

  /// Text phụ, ví dụ: "Hạn chót: 23:59 hôm qua".
  final String metaText;

  /// Tag pill, ví dụ: "Quá hạn" / "Thay đổi" / "Hôm nay" / "Sắp tới".
  final String tagLabel;

  /// Thời gian ghi nhận hoặc hạn chót để sắp xếp thứ cấp trong cùng 1 tier.
  final DateTime? timestamp;
}
