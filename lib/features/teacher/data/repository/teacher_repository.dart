import 'package:study/features/teacher/data/models/models.dart';

/// Repository interface for teacher-related data operations.
abstract class TeacherRepository {
  /// Fetches dashboard statistics.
  Future<TeacherStatsModel> getStats();

  /// Fetches wallet information.
  Future<TeacherWalletModel> getWallet();

  /// Fetches pending assignments to grade.
  Future<List<PendingAssignmentModel>> getPendingAssignments({int limit = 5});

  /// Fetches recent activities.
  Future<List<TeacherActivityModel>> getActivities({int limit = 10});

  /// Fetches recent notifications.
  Future<List<TeacherNotificationModel>> getNotifications({int limit = 5});

  /// Fetches upcoming schedule.
  Future<List<TeacherScheduleModel>> getUpcomingSchedule({int limit = 5});

  /// Fetches all courses/classes for the teacher.
  Future<List<CourseModel>> getCourses({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Creates a new course/class.
  Future<CourseModel> createCourse(Map<String, dynamic> data);

  /// Updates an existing course/class.
  Future<CourseModel> updateCourse(String id, Map<String, dynamic> data);

  /// Deletes a course/class.
  Future<void> deleteCourse(String id);

  /// Fetches students in a class.
  Future<List<StudentModel>> getStudents({
    String? classId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });

  /// Adds a student to a class.
  Future<void> addStudentToClass(String classId, String studentId);

  /// Removes a student from a class.
  Future<void> removeStudentFromClass(String classId, String studentId);

  /// Fetches class schedules.
  Future<List<TeacherScheduleModel>> getClassSchedules(String classId);

  // ==========================================================================
  // CLASSES
  // ==========================================================================

  /// Fetches all classes for the teacher.
  Future<List<ClassModel>> getClasses({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a single class detail.
  Future<ClassModel> getClassDetail(String classId);

  /// Creates a new class.
  Future<ClassModel> createClass(Map<String, dynamic> data);

  /// Updates an existing class.
  Future<ClassModel> updateClass(String classId, Map<String, dynamic> data);

  /// Deletes a class.
  Future<void> deleteClass(String classId);

  // ==========================================================================
  // CLASS TEACHERS
  // ==========================================================================

  /// Fetches teachers in a class.
  Future<List<ClassTeacherModel>> getClassTeachers(String classId);

  /// Adds a teacher to a class.
  Future<void> addTeacherToClass(
    String classId,
    String teacherId, {
    String role = 'assistant',
  });

  /// Removes a teacher from a class.
  Future<void> removeTeacherFromClass(String classId, String teacherId);

  // ==========================================================================
  // CLASS SCHEDULES
  // ==========================================================================

  /// Fetches schedules for a class.
  Future<List<ClassScheduleModel>> getClassScheduleModels(String classId);

  /// Creates a schedule for a class.
  Future<ClassScheduleModel> createClassSchedule(
    String classId,
    Map<String, dynamic> data,
  );

  /// Updates a schedule.
  Future<ClassScheduleModel> updateClassSchedule(
    String classId,
    String scheduleId,
    Map<String, dynamic> data,
  );

  /// Deletes a schedule.
  Future<void> deleteClassSchedule(String classId, String scheduleId);

  // ==========================================================================
  // ATTENDANCES
  // ==========================================================================

  /// Fetches attendance records for a class.
  Future<List<AttendanceModel>> getClassAttendances(
    String classId, {
    String? sessionDate,
    int page = 1,
    int pageSize = 50,
  });

  /// Creates or updates an attendance record.
  Future<AttendanceModel> createAttendance(
    String classId,
    Map<String, dynamic> data,
  );

  /// Batch updates attendance records.
  Future<void> batchUpdateAttendance(
    String classId,
    List<Map<String, dynamic>> attendances,
  );

  // ==========================================================================
  // STUDENT DETAIL
  // ==========================================================================

  /// Fetches detailed student information including parent info and assignments.
  Future<StudentDetailModel> getStudentDetail(String classId, String studentId);
}
