/// Loại cảnh báo "Cần xử lý".
enum ParentAlertType { overdue, scheduleChange }

/// Model cho mục Cần xử lý (bài tập quá hạn / đổi lịch học).
class ParentAlertItem {
  const ParentAlertItem({
    required this.type,
    required this.childName,
    required this.subjectName,
    required this.detail,
    required this.metaText,
    required this.tagLabel,
  });

  final ParentAlertType type;
  final String childName;
  final String subjectName;

  /// Mô tả chính, ví dụ: "1 bài tập trắc nghiệm đã quá hạn nộp".
  final String detail;

  /// Text phụ, ví dụ: "Hạn chót: 23:59 hôm qua".
  final String metaText;

  /// Tag pill, ví dụ: "Quá hạn" / "Thay đổi".
  final String tagLabel;
}
