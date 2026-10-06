import 'package:equatable/equatable.dart';

/// Phân loại insight học tập định kỳ trong Family Insights Inbox
enum FamilyInsightCategory {
  /// Tiến bộ vượt bậc (Xanh lá - Growth / Achievement)
  breakthrough,

  /// Cần chú ý (Vàng/Cam - Warning / Need Support)
  attention,

  /// Khen thưởng / Thói quen tự học (Xanh dương - Discipline / Habit)
  reward,
}

/// Dữ liệu số liệu định lượng (Quantitative Evidence)
class InsightMetric extends Equatable {
  const InsightMetric({
    required this.label,
    required this.value,
    this.delta,
    this.isPositive = true,
  });

  final String label;
  final String value;
  final String? delta;
  final bool isPositive;

  @override
  List<Object?> get props => [label, value, delta, isPositive];
}

/// Dữ liệu chuỗi ngày học tập chuyên cần (Streak)
class InsightStreakInfo extends Equatable {
  const InsightStreakInfo({
    required this.currentDays,
    required this.activeDayLabels,
  });

  final int currentDays;
  final List<String> activeDayLabels;

  @override
  List<Object?> get props => [currentDays, activeDayLabels];
}

/// Model cho một thông báo phân tích trong Family Insights Inbox
class FamilyInsightItem extends Equatable {
  const FamilyInsightItem({
    required this.id,
    required this.childId,
    required this.childName,
    required this.className,
    required this.subjectOrSkill,
    required this.category,
    required this.timeAgoText,
    required this.title,
    required this.description,
    this.highlightText,
    this.metrics = const [],
    this.teacherQuote,
    this.streakInfo,
    this.hasEncouraged = false,
    this.actionLabel,
    this.actionRoute,
    this.isRead = false,
  });

  final String id;
  final String childId;
  final String childName;
  final String className;
  final String subjectOrSkill;
  final FamilyInsightCategory category;
  final String timeAgoText;
  final String title;
  final String description;
  final String? highlightText;

  // Dữ liệu cho các khối đặc thù:
  final List<InsightMetric> metrics;
  final String? teacherQuote;
  final InsightStreakInfo? streakInfo;
  final bool hasEncouraged;

  // Điều hướng:
  final String? actionLabel;
  final String? actionRoute;
  final bool isRead;

  FamilyInsightItem copyWith({
    bool? hasEncouraged,
    bool? isRead,
  }) {
    return FamilyInsightItem(
      id: id,
      childId: childId,
      childName: childName,
      className: className,
      subjectOrSkill: subjectOrSkill,
      category: category,
      timeAgoText: timeAgoText,
      title: title,
      description: description,
      highlightText: highlightText,
      metrics: metrics,
      teacherQuote: teacherQuote,
      streakInfo: streakInfo,
      hasEncouraged: hasEncouraged ?? this.hasEncouraged,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        childId,
        childName,
        className,
        subjectOrSkill,
        category,
        timeAgoText,
        title,
        description,
        highlightText,
        metrics,
        teacherQuote,
        streakInfo,
        hasEncouraged,
        actionLabel,
        actionRoute,
        isRead,
      ];
}
