import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

/// Repository cho Student feature — schedule, assignments, enrollments
abstract class StudentRepository {
  // Schedule
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule();
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(DateTime date);
  Future<ApiResult<Set<DateTime>>> getEventDates(DateTime month);

  // Assignments
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments();

  // Enrollments
  Future<ApiResult<List<EnrollmentModel>>> getActiveEnrollments();
  Future<ApiResult<EnrollmentModel?>> getContinueLearning();
  Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId);
  Future<void> setLastAccessedCourse(String enrollmentId);

  // Lesson
  Future<ApiResult<LessonModel>> getLessonDetail(String lessonId);
  /// Returns true if course is completed after this lesson
  Future<ApiResult<bool>> markLessonComplete(
    String lessonId, {
    List<List<int>>? playedRanges,
    int? durationSeconds,
  });

  // Notifications
  Future<ApiResult<List<NotificationModel>>> getNotifications();
  Future<ApiResult<int>> getUnreadNotificationCount();
  Future<ApiResult<void>> markNotificationRead(String id);
  Future<ApiResult<void>> markAllNotificationsRead();

  // Achievements
  Future<ApiResult<List<BadgeModel>>> getBadges();
  Future<ApiResult<List<CertificateModel>>> getCertificates();
  Future<ApiResult<StudentStatsModel>> getStats();

  // Quiz
  Future<ApiResult<List<QuizQuestionModel>>> getQuizQuestions(String quizId);
  Future<ApiResult<List<QuizModel>>> getQuizzesByLesson(String lessonId);
  Future<ApiResult<({String attemptId, List<QuizQuestionModel> questions, int timeLimitMinutes})>> startQuiz(String quizId);
  Future<ApiResult<QuizSubmitResult>> submitQuiz(
    String quizId,
    String attemptId,
    List<Map<String, dynamic>> answers,
  );

  // Search
  Future<ApiResult<List<CourseModel>>> searchCourses(String query);

  // Courses
  Future<ApiResult<List<CourseModel>>> getAllCourses({int page = 1});
  Future<ApiResult<CourseModel>> getCourseById(String courseId);

  // Contributions (activity grid)
  Future<ApiResult<List<ContributionModel>>> getContributions(String userId);

  // Class
  Future<ApiResult<String?>> getCourseIdFromClass(String classId);
}
