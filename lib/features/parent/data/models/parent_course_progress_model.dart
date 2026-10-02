import 'package:flutter/material.dart';

/// Thẻ tổng quan chỉ số tiến độ học tập của con
@immutable
class ParentProgressOverviewModel {
  const ParentProgressOverviewModel({
    required this.activeCourseCount,
    required this.studyingCourseCount,
    required this.completedCourseCount,
    required this.averageProgressPercent,
    this.progressStatusText = 'Đúng lộ trình đề ra',
  });

  final int activeCourseCount; // 3 khóa
  final int studyingCourseCount; // 2 đang học
  final int completedCourseCount; // 1 hoàn thành
  final double averageProgressPercent; // 0.65 -> 65%
  final String progressStatusText; // "Đúng lộ trình đề ra"
}

/// Thẻ tiến độ của một khóa học cụ thể
@immutable
class ParentCourseProgressItem {
  const ParentCourseProgressItem({
    required this.courseId,
    required this.courseName,
    required this.subjectCode,
    required this.subjectColor,
    required this.subjectBgColor,
    required this.teacherName,
    required this.locationText,
    required this.statusLabel,
    required this.statusTextColor,
    required this.statusBgColor,
    required this.completedSessions,
    required this.totalSessions,
    required this.progressPercent,
    required this.progressColor,
    required this.remainingSessionsText,
    this.progressNote,
    this.warningNote,
    this.certificateText,
    this.isCompleted = false,
  });

  final String courseId;
  final String courseName;
  final String subjectCode; // "Σ", "文A", "STEM"
  final Color subjectColor;
  final Color subjectBgColor;
  final String teacherName;
  final String locationText; // "Phòng 302", "Trực tuyến Zoom", "Lab STEM A2"
  final String statusLabel; // "Đang học", "Xong"
  final Color statusTextColor;
  final Color statusBgColor;

  final int completedSessions; // 8
  final int totalSessions; // 12
  final double progressPercent; // 0.67
  final Color progressColor;
  final String remainingSessionsText; // "Còn 4 buổi"

  final String? progressNote; // "Đúng tiến độ · Buổi tiếp theo thứ 2 (18:00)"
  final String? warningNote; // "Cần chú ý bài tập viết luận"
  final String? certificateText; // "Đã hoàn thành · Đạt chứng nhận Xuất sắc"
  final bool isCompleted;
}

/// Ghi chú từ Giáo viên chủ nhiệm ở đáy trang
@immutable
class TeacherHomeroomNote {
  const TeacherHomeroomNote({
    this.title = 'Ghi chú từ Giáo viên chủ nhiệm',
    required this.content,
  });

  final String title;
  final String content;
}

/// Toàn bộ dữ liệu của màn hình Tiến độ học tập
@immutable
class ParentProgressScreenData {
  const ParentProgressScreenData({
    required this.overview,
    required this.courses,
    required this.homeroomNote,
  });

  final ParentProgressOverviewModel overview;
  final List<ParentCourseProgressItem> courses;
  final TeacherHomeroomNote homeroomNote;
}
