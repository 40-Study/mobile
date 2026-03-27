import 'package:study/features/student/data/models/course_detail_model.dart';
import 'package:study/features/student/data/models/lesson_detail_model.dart';
import 'package:study/features/student/data/models/models.dart';

/// Repository interface for student-related data operations.
abstract class StudentRepository {
  /// Fetches dashboard statistics for student.
  Future<StudentStatsModel> getStats();

  /// Fetches today's schedule (classes and livestreams).
  Future<List<StudentScheduleModel>> getTodaySchedule();

  /// Fetches enrollments (courses being learned).
  Future<List<EnrollmentModel>> getEnrollments({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches enrollment detail.
  Future<EnrollmentModel> getEnrollmentDetail(String id);

  /// Fetches classes the student is enrolled in.
  Future<List<StudentClassModel>> getClasses({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches class detail.
  Future<StudentClassModel> getClassDetail(String id);

  /// Fetches upcoming livestreams.
  Future<List<StudentScheduleModel>> getUpcomingLivestreams({int limit = 5});

  /// Updates lesson progress.
  Future<void> updateLessonProgress(String lessonId, int progress);

  /// Enrolls in a new course.
  Future<EnrollmentModel> enrollCourse(String courseId);

  /// Fetches course detail by enrollment and course IDs.
  Future<CourseDetailModel> getCourseDetail({
    required String enrollmentId,
    required String courseId,
  });

  /// Fetches lesson detail by lesson ID.
  Future<LessonDetailModel> getLessonDetail(String lessonId);
}
