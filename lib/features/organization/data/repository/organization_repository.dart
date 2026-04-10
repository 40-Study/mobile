import 'package:study/features/organization/data/models/models.dart';

/// Repository interface for organization owner data operations.
abstract class OrganizationRepository {
  // ==========================================================================
  // DASHBOARD
  // ==========================================================================

  /// Fetches organization statistics.
  Future<OrgStatsModel> getStats();

  /// Fetches recent activities.
  Future<List<OrgActivityModel>> getActivities({int limit = 10});

  // ==========================================================================
  // TEACHERS
  // ==========================================================================

  /// Fetches all teachers in the organization.
  Future<List<OrgTeacherModel>> getTeachers({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a single teacher detail.
  Future<OrgTeacherModel> getTeacherDetail(String teacherId);

  /// Invites a new teacher to the organization.
  Future<void> inviteTeacher(String email);

  /// Updates teacher status (active/inactive).
  Future<void> updateTeacherStatus(String teacherId, String status);

  /// Removes a teacher from the organization.
  Future<void> removeTeacher(String teacherId);

  // ==========================================================================
  // STUDENTS
  // ==========================================================================

  /// Fetches all students in the organization.
  Future<List<OrgStudentModel>> getStudents({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a single student detail.
  Future<OrgStudentModel> getStudentDetail(String studentId);

  // ==========================================================================
  // FINANCE & CASH FLOW ANALYTICS
  // ==========================================================================

  /// Fetches finance overview.
  Future<OrgFinanceModel> getFinanceOverview();

  /// Fetches transaction history.
  Future<List<OrgTransactionModel>> getTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Requests a payout.
  Future<void> requestPayout(double amount);

  /// Fetches revenue breakdown by course (top performing courses).
  Future<List<CourseRevenueModel>> getCourseRevenue({int limit = 10});

  /// Fetches revenue breakdown by teacher.
  Future<List<TeacherRevenueModel>> getTeacherRevenue({int limit = 10});

  /// Fetches finance alerts (warnings about low revenue, high expense, etc.)
  Future<List<FinanceAlertModel>> getFinanceAlerts();

  // ==========================================================================
  // COURSES (ORG_OWNER có thể tạo/sửa khóa học theo API DOCS)
  // ==========================================================================

  /// Fetches all courses in the organization.
  Future<List<OrgCourseModel>> getCourses({
    String? status,
    String? instructorId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a single course detail.
  Future<OrgCourseModel> getCourseDetail(String courseId);

  /// Creates a new course.
  Future<OrgCourseModel> createCourse({
    required String title,
    required String instructorId,
    String? categoryId,
    String? shortDescription,
    String? price,
    String? level,
  });

  /// Updates a course.
  Future<OrgCourseModel> updateCourse(String courseId, Map<String, dynamic> data);

  /// Publishes a course.
  Future<void> publishCourse(String courseId);

  /// Archives a course.
  Future<void> archiveCourse(String courseId);

  // ==========================================================================
  // CLASSES (ORG_OWNER có thể tạo lớp học theo API DOCS)
  // ==========================================================================

  /// Fetches all classes in the organization.
  Future<List<OrgClassModel>> getClasses({
    String? status,
    String? teacherId,
    int page = 1,
    int pageSize = 20,
  });

  /// Creates a new class.
  Future<OrgClassModel> createClass({
    required String name,
    required String teacherId,
    String? courseId,
    String? description,
    int? maxStudents,
    String? schedule,
  });

  // ==========================================================================
  // LIVESTREAM (ORG_OWNER có thể host livestream theo API DOCS)
  // ==========================================================================

  /// Fetches livestream sessions.
  Future<List<OrgLivestreamModel>> getLivestreams({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Schedules a new livestream.
  Future<OrgLivestreamModel> scheduleLivestream({
    required String title,
    required String classId,
    required String scheduledAt,
    String? description,
  });
}
