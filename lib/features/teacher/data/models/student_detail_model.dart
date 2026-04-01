import 'package:equatable/equatable.dart';

class StudentDetailModel extends Equatable {
  const StudentDetailModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.enrolledAt,
    this.progress = 0,
    this.parent,
    this.assignments = const [],
    this.attendanceSummary,
  });

  final String id;
  final String studentCode;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final String? enrolledAt;
  final double progress;
  final ParentModel? parent;
  final List<StudentAssignmentModel> assignments;
  final AttendanceSummaryModel? attendanceSummary;

  @override
  List<Object?> get props => [
        id,
        studentCode,
        fullName,
        avatarUrl,
        email,
        phone,
        dateOfBirth,
        address,
        enrolledAt,
        progress,
        parent,
        assignments,
        attendanceSummary,
      ];

  int get completedAssignments =>
      assignments.where((a) => a.status == AssignmentStatus.completed).length;

  int get incompleteAssignments =>
      assignments.where((a) => a.status == AssignmentStatus.incomplete).length;

  int get lateAssignments =>
      assignments.where((a) => a.status == AssignmentStatus.late).length;
}

class ParentModel extends Equatable {
  const ParentModel({
    required this.id,
    required this.fullName,
    this.relationship,
    this.phone,
    this.email,
    this.address,
  });

  final String id;
  final String fullName;
  final String? relationship;
  final String? phone;
  final String? email;
  final String? address;

  @override
  List<Object?> get props => [id, fullName, relationship, phone, email, address];
}

enum AssignmentStatus {
  incomplete,
  completed,
  late,
}

class StudentAssignmentModel extends Equatable {
  const StudentAssignmentModel({
    required this.id,
    required this.title,
    required this.status,
    this.dueDate,
    this.submittedAt,
    this.score,
    this.maxScore,
    this.feedback,
  });

  final String id;
  final String title;
  final AssignmentStatus status;
  final String? dueDate;
  final String? submittedAt;
  final double? score;
  final double? maxScore;
  final String? feedback;

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        dueDate,
        submittedAt,
        score,
        maxScore,
        feedback,
      ];

  String get scoreDisplay {
    if (score == null || maxScore == null) return '--';
    return '${score!.toInt()}/${maxScore!.toInt()}';
  }

  bool get isPassed => score != null && maxScore != null && score! >= (maxScore! * 0.5);
}

class AttendanceSummaryModel extends Equatable {
  const AttendanceSummaryModel({
    this.totalSessions = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
  });

  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;

  @override
  List<Object?> get props => [
        totalSessions,
        presentCount,
        absentCount,
        lateCount,
        excusedCount,
      ];

  double get attendanceRate {
    if (totalSessions == 0) return 0;
    return (presentCount + lateCount + excusedCount) / totalSessions * 100;
  }
}
