import 'package:flutter/foundation.dart';

/// Điểm dữ liệu biến thiên độ tập trung theo tuần
@immutable
class FocusTrendDataPoint {
  const FocusTrendDataPoint({
    required this.week,
    required this.score,
    required this.label,
  });

  final int week;
  final double score; // 0.0 -> 100.0
  final String label; // "T1", "T2", ... "T12"
}

/// Model dữ liệu chi tiết cho màn hình Learning Insights
/// (Báo cáo Phân tích Sư phạm).
///
/// Tuân thủ chuẩn sư phạm 3 bước:
/// Observation -> Interpretation -> Action, kèm chỉ số trọng yếu,
/// biểu đồ độ tập trung và điểm mạnh vượt trội.
@immutable
class ParentLearningInsightsModel {
  const ParentLearningInsightsModel({
    required this.childId,
    required this.childName,
    this.childInitials = 'M',
    required this.className,
    this.semester = 'Lớp 10A1 · Học kỳ I 2024–2025',
    this.updateStatus = 'Đang cập nhật tuần 12',
    this.overviewTitle = 'Tổng quan kỳ I (12 tuần)',
    this.weekBadge = 'Tuần 12',
    this.attendanceRatePercent = 92,
    this.attendanceDeltaText = '+4% (23/25 buổi)',
    this.homeworkCompletionPercent = 85,
    this.homeworkDeltaText = 'Đúng hạn (17/20)',
    this.averageGrade = 8.6,
    this.gradeDeltaText = '+0.8 với đầu kỳ',
    this.focusAndInteractionPercent = 88,
    this.focusAndInteractionStatus = 'Rất tích cực',
    this.focusTrendAverageDelta = '+12% trung bình',
    required this.focusTrendPoints,
    required this.focusTrendNote,
    this.improvementFocusBadge = '1 trọng tâm',
    required this.observationContent,
    required this.interpretationContent,
    required this.actionContent,
    this.evidenceActionText =
        'Xem bài tập và bài kiểm tra chi tiết (Evidence) →',
    this.strengthBadge = 'Phát huy tốt',
    required this.strengthTitle,
    required this.strengthContent,
    this.teacherName = 'Cô Lan',
    this.teacherSubject = 'GV Toán',
  });

  final String childId;
  final String childName;
  final String childInitials;
  final String className;
  final String semester;
  final String updateStatus;

  // 1. Chỉ số học tập trọng yếu
  final String overviewTitle;
  final String weekBadge;
  final int attendanceRatePercent;
  final String attendanceDeltaText;
  final int homeworkCompletionPercent;
  final String homeworkDeltaText;
  final double averageGrade;
  final String gradeDeltaText;
  final int focusAndInteractionPercent;
  final String focusAndInteractionStatus;

  // 2. Theo dõi năng lực & độ tập trung
  final String focusTrendAverageDelta;
  final List<FocusTrendDataPoint> focusTrendPoints;
  final String focusTrendNote;

  // 3. Phân tích sư phạm chuyên sâu 3 bước
  final String improvementFocusBadge;
  final String observationContent;
  final String interpretationContent;
  final String actionContent;
  final String evidenceActionText;

  // 4. Năng khiếu vượt trội
  final String strengthBadge;
  final String strengthTitle;
  final String strengthContent;

  // Thông tin liên hệ GV
  final String teacherName;
  final String teacherSubject;
}
