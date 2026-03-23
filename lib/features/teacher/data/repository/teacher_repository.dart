import 'package:study/features/teacher/data/models/models.dart';

/// Repository interface for teacher-related data operations.
abstract class TeacherRepository {
  /// Fetches dashboard statistics.
  Future<TeacherStatsModel> getStats();

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
}
