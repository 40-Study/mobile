import 'package:equatable/equatable.dart';

/// Dữ liệu tổng hợp hiển thị trên các thẻ của Trung tâm Học tập (Learning Root Hub)
class ParentLearningHubData extends Equatable {
  const ParentLearningHubData({
    required this.childId,
    required this.childName,
    this.className,
    this.newInsightsCount = 0,
    this.activeClassCount = 0,
    this.activeClassNames = const [],
    this.pendingHomeworkCount = 0,
    this.overdueHomeworkCount = 0,
    this.courseProgressPercent = 0.0,
    this.recommendedTopic,
  });

  /// ID của học sinh
  final String childId;

  /// Tên học sinh (VD: "Minh", "Lan")
  final String childName;

  /// Tên lớp chính quy (VD: "10A1", "7B")
  final String? className;

  /// Số lượng nhận xét / phân tích mới trong tuần này (VD: 2)
  final int newInsightsCount;

  /// Số lớp học đang tham gia (VD: 3)
  final int activeClassCount;

  /// Danh sách tên các lớp đang học (VD: ["Toán nâng cao", "Tiếng Anh", "Vật Lý"])
  final List<String> activeClassNames;

  /// Số bài tập về nhà cần chú ý nộp đúng hạn (VD: 2)
  final int pendingHomeworkCount;

  /// Số bài tập về nhà sắp quá hạn hoặc đã quá hạn cần nhắc nhở gấp (VD: 1)
  final int overdueHomeworkCount;

  /// Tiến độ hoàn thành khối lượng học phần tổng thể (0.0 -> 1.0, VD: 0.68 tương ứng 68%)
  final double courseProgressPercent;

  /// Tên chuyên đề hoặc nội dung được AI và giáo viên gợi ý bổ trợ (VD: "Chuyên đề bổ trợ hình học không gian")
  final String? recommendedTopic;

  ParentLearningHubData copyWith({
    String? childId,
    String? childName,
    String? className,
    int? newInsightsCount,
    int? activeClassCount,
    List<String>? activeClassNames,
    int? pendingHomeworkCount,
    int? overdueHomeworkCount,
    double? courseProgressPercent,
    String? recommendedTopic,
  }) {
    return ParentLearningHubData(
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      className: className ?? this.className,
      newInsightsCount: newInsightsCount ?? this.newInsightsCount,
      activeClassCount: activeClassCount ?? this.activeClassCount,
      activeClassNames: activeClassNames ?? this.activeClassNames,
      pendingHomeworkCount: pendingHomeworkCount ?? this.pendingHomeworkCount,
      overdueHomeworkCount: overdueHomeworkCount ?? this.overdueHomeworkCount,
      courseProgressPercent:
          courseProgressPercent ?? this.courseProgressPercent,
      recommendedTopic: recommendedTopic ?? this.recommendedTopic,
    );
  }

  @override
  List<Object?> get props => [
        childId,
        childName,
        className,
        newInsightsCount,
        activeClassCount,
        activeClassNames,
        pendingHomeworkCount,
        overdueHomeworkCount,
        courseProgressPercent,
        recommendedTopic,
      ];
}
