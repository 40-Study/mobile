import 'package:flutter/material.dart';

/// Trạng thái của bài tập về nhà
enum ParentHomeworkStatus {
  urgent, // Cần nộp gấp trong ngày
  inProgress, // Đang làm
  submitted, // Đã nộp, chờ chấm
  graded, // Đã nộp và đã chấm điểm
  overdue, // Quá hạn nộp
}

/// Item bài tập về nhà hiển thị trong danh sách
@immutable
class ParentHomeworkItem {
  const ParentHomeworkItem({
    required this.id,
    required this.title,
    required this.subjectCode,
    required this.subjectName,
    required this.teacherName,
    required this.dueTagLabel,
    required this.dueTagTextColor,
    required this.dueTagBgColor,
    required this.timeRemainingText,
    required this.status,
    this.scoreText,
    this.gradeLabel,
    this.isUrgent = false,
  });

  final String id;
  final String title;
  final String subjectCode; // "Σ", "En", "Sc"
  final String subjectName; // "TOÁN NÂNG CAO 10"
  final String teacherName;
  final String dueTagLabel;
  final Color dueTagTextColor;
  final Color dueTagBgColor;
  final String timeRemainingText;
  final ParentHomeworkStatus status;
  final String? scoreText;
  final String? gradeLabel;
  final bool isUrgent;
}

/// Dòng bài tập đã được chấm hiển thị trong khối kết quả tuần gần nhất
@immutable
class RecentGradedItem {
  const RecentGradedItem({
    required this.id,
    required this.title,
    required this.gradedDateText,
    required this.score,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String id;
  final String title;
  final String gradedDateText;
  final double score;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
}

/// Báo cáo tóm tắt kết quả bài tập đã chấm tuần gần nhất (Empty State)
@immutable
class ParentGradedSummaryModel {
  const ParentGradedSummaryModel({
    required this.submissionRatio,
    required this.assessmentLabel,
    this.ratingBadge = 'Xuất sắc',
    required this.averageScore,
    this.maxScore = 10.0,
    required this.recentGradedItems,
  });

  final String submissionRatio; // "3/3 bài nộp"
  final String assessmentLabel; // "Tất cả đều đạt loại Giỏi"
  final String ratingBadge; // "Xuất sắc"
  final double averageScore; // 8.8
  final double maxScore; // 10.0
  final List<RecentGradedItem> recentGradedItems;
}

/// Chi tiết bài tập về nhà dành cho phụ huynh (View-only)
@immutable
class ParentHomeworkDetailModel {
  const ParentHomeworkDetailModel({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.teacherName,
    required this.dueDateText,
    required this.timeRemainingText,
    required this.status,
    required this.statusLabel,
    required this.description,
    this.attachments = const [],
    this.studentSubmissionNote,
    this.submittedFiles = const [],
    this.submittedAtText,
    this.teacherFeedback,
    this.score,
    this.maxScore = 10.0,
  });

  final String id;
  final String title;
  final String subjectName;
  final String teacherName;
  final String dueDateText;
  final String timeRemainingText;
  final ParentHomeworkStatus status;
  final String statusLabel;
  final String description;
  final List<String> attachments;

  // Dữ liệu bài làm của học sinh
  final String? studentSubmissionNote;
  final List<String> submittedFiles;
  final String? submittedAtText;

  // Lời phê và điểm của giáo viên
  final String? teacherFeedback;
  final double? score;
  final double maxScore;
}
