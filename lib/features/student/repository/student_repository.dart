import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

/// Repository cho Student feature — schedule, assignments, enrollments
abstract class StudentRepository {
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule();
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(DateTime date);
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments();
  Future<ApiResult<List<EnrollmentModel>>> getActiveEnrollments();
  Future<ApiResult<EnrollmentModel?>> getContinueLearning();

  // Course detail
  Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId);

  // Lesson
  Future<ApiResult<LessonModel>> getLessonDetail(String lessonId);
  Future<ApiResult<void>> markLessonComplete(String lessonId);

  // Achievement
  Future<ApiResult<List<BadgeModel>>> getBadges();
  Future<ApiResult<StudentStatsModel>> getStats();
}
