/// Model phân tích học tập cho Learning Analytics card.
class ParentAnalyticsData {
  const ParentAnalyticsData({
    required this.childName,
    required this.className,
    required this.reportLabel,
    required this.subjectName,
    required this.progressPercent,
    required this.averageScore,
    required this.weeklyTrend,
    required this.insightText,
    this.insightHighlight,
  });

  final String childName;
  final String className;

  /// Ví dụ: "Báo cáo tuần 4 • Môn Ngữ Văn".
  final String reportLabel;
  final String subjectName;

  /// Tỷ lệ tiến bộ, ví dụ 15 => hiển thị "+15%".
  final int progressPercent;

  /// Điểm trung bình, ví dụ 8.4.
  final double averageScore;

  /// 4 mức cột cho mini chart (0.0 - 1.0).
  final List<double> weeklyTrend;

  /// Nội dung AI insight.
  final String insightText;

  /// Phần text được highlight đậm trong insight.
  final String? insightHighlight;
}
