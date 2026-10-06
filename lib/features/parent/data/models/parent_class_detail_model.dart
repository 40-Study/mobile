import 'package:equatable/equatable.dart';

enum ClassLessonStatus {
  /// Buổi vừa hoàn thành hôm nay (dot xanh lá nổi bật, có nút Xem bài học)
  completedToday,

  /// Buổi đã học trước đây (dot xám đặc, có điểm quiz / video xem lại)
  completed,

  /// Buổi sắp diễn ra (dot viền rỗng)
  upcoming,
}

/// Dữ liệu từng buổi học trên Timeline lộ trình lớp học
class ClassLessonItem extends Equatable {
  const ClassLessonItem({
    required this.sessionNumber,
    required this.title,
    required this.timeSubtitle,
    this.quizScoreText,
    this.hasVideoRecording = false,
    this.noteText,
    required this.status,
    required this.statusLabel,
    this.canViewLesson = false,
  });

  final int sessionNumber;
  final String title;
  final String timeSubtitle;
  final String? quizScoreText;
  final bool hasVideoRecording;
  final String? noteText;
  final ClassLessonStatus status;
  final String statusLabel;
  final bool canViewLesson;

  @override
  List<Object?> get props => [
        sessionNumber,
        title,
        timeSubtitle,
        quizScoreText,
        hasVideoRecording,
        noteText,
        status,
        statusLabel,
        canViewLesson,
      ];
}

/// Dữ liệu chi tiết một Lớp học của con dành cho Phụ huynh
class ParentClassDetailModel extends Equatable {
  const ParentClassDetailModel({
    required this.classId,
    required this.className,
    required this.childName,
    required this.childId,
    required this.semester,
    required this.teacherName,
    required this.teacherTitle,
    required this.teacherInitials,
    required this.scheduleFixed,
    required this.roomOrPlatform,
    required this.completedSessions,
    required this.totalSessions,
    required this.attendanceRatePercent,
    required this.averageGrade,
    required this.lessons,
  });

  final String classId;
  final String className;
  final String childName;
  final String childId;
  final String semester;
  final String teacherName;
  final String teacherTitle;
  final String teacherInitials;
  final String scheduleFixed;
  final String roomOrPlatform;
  final int completedSessions;
  final int totalSessions;
  final int attendanceRatePercent;
  final double averageGrade;
  final List<ClassLessonItem> lessons;

  double get progressPercent =>
      totalSessions > 0 ? completedSessions / totalSessions : 0.0;

  @override
  List<Object?> get props => [
        classId,
        className,
        childName,
        childId,
        semester,
        teacherName,
        teacherTitle,
        teacherInitials,
        scheduleFixed,
        roomOrPlatform,
        completedSessions,
        totalSessions,
        attendanceRatePercent,
        averageGrade,
        lessons,
      ];
}
