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

  /// Unenrolls from a course.
  Future<void> unenrollCourse(String courseId);

  /// Fetches course detail by enrollment and course IDs.
  Future<CourseDetailModel> getCourseDetail({
    required String enrollmentId,
    required String courseId,
  });

  /// Fetches lesson detail by lesson ID.
  Future<LessonDetailModel> getLessonDetail(String lessonId);

  // ==========================================================================
  // CART
  // ==========================================================================

  /// Fetches cart items.
  Future<CartModel> getCart();

  /// Adds course to cart.
  Future<void> addToCart(String courseId);

  /// Removes courses from cart.
  Future<void> removeFromCart(List<String> courseIds);

  /// Clears cart.
  Future<void> clearCart();

  /// Checks if course is in cart.
  Future<bool> isCourseInCart(String courseId);

  // ==========================================================================
  // ORDERS
  // ==========================================================================

  /// Creates an order.
  Future<OrderModel> createOrder({
    required String source,
    required List<String> courseIds,
    String? couponCode,
  });

  /// Fetches orders.
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches order detail.
  Future<OrderModel> getOrderDetail(String id);

  // ==========================================================================
  // ASSIGNMENTS
  // ==========================================================================

  /// Fetches assignments.
  Future<List<AssignmentModel>> getAssignments({
    String? sessionId,
    String? classId,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches assignment detail.
  Future<AssignmentModel> getAssignmentDetail(String id);

  /// Fetches assignment sandbox (for students).
  Future<AssignmentSandboxModel> getAssignmentSandbox(String id);

  // ==========================================================================
  // SUBMISSIONS
  // ==========================================================================

  /// Submits assignment.
  Future<SubmissionModel> submitAssignment({
    required String assignmentId,
    required String language,
    required String code,
  });

  /// Runs code against sample tests.
  Future<RunCodeResultModel> runCode({
    required String assignmentId,
    required String language,
    required String code,
  });

  /// Fetches submission detail.
  Future<SubmissionModel> getSubmissionDetail(String id);

  /// Fetches submissions for an assignment.
  Future<List<SubmissionModel>> getSubmissions({
    String? assignmentId,
    int page = 1,
    int pageSize = 20,
  });

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

  /// Fetches notifications.
  Future<NotificationListModel> getNotifications({
    bool? isRead,
    String? type,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches unread notification count.
  Future<int> getUnreadNotificationCount();

  /// Marks notification as read.
  Future<void> markNotificationAsRead(String id);

  /// Marks all notifications as read.
  Future<void> markAllNotificationsAsRead();

  /// Deletes notification.
  Future<void> deleteNotification(String id);

  // ==========================================================================
  // GAMIFICATION
  // ==========================================================================

  /// Fetches all achievements.
  Future<List<AchievementModel>> getAchievements();

  /// Fetches my achievements.
  Future<List<AchievementModel>> getMyAchievements();

  /// Fetches leaderboard.
  Future<LeaderboardModel> getLeaderboard({
    String periodType = 'weekly',
    int limit = 50,
  });

  /// Fetches my rank.
  Future<LeaderboardEntryModel> getMyRank();

  // ==========================================================================
  // VOUCHERS
  // ==========================================================================

  /// Fetches public vouchers.
  Future<List<VoucherModel>> getPublicVouchers();

  /// Fetches voucher by code.
  Future<VoucherModel> getVoucherByCode(String code);

  /// Saves voucher.
  Future<void> saveVoucher(String id);

  /// Unsaves voucher.
  Future<void> unsaveVoucher(String id);

  /// Fetches my saved vouchers.
  Future<List<VoucherModel>> getMySavedVouchers();

  // ==========================================================================
  // DISCUSSIONS / FORUM
  // ==========================================================================

  /// Fetches discussions.
  Future<List<ForumPostModel>> getDiscussions({
    String? category,
    String? sort,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches discussion detail by slug.
  Future<ForumPostModel> getDiscussion(String slug);

  /// Creates a discussion.
  Future<ForumPostModel> createDiscussion({
    required String title,
    required String content,
    required String category,
  });

  /// Votes on a discussion.
  Future<void> voteDiscussion(String discussionId, VoteType voteType);

  /// Removes vote from discussion.
  Future<void> removeVote(String discussionId);

  /// Adds comment to discussion.
  Future<void> addComment(String slug, String content, {String? parentId});

  // ==========================================================================
  // LIVESTREAMS
  // ==========================================================================

  /// Fetches livestreams.
  Future<List<LivestreamModel>> getLivestreams({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches livestream detail.
  Future<LivestreamModel> getLivestream(String id);

  // ==========================================================================
  // COURSES (Discovery)
  // ==========================================================================

  /// Fetches trending courses.
  Future<List<CourseModel>> getTrendingCourses({int limit = 10});

  /// Fetches all courses for discovery.
  Future<List<CourseModel>> getCourses({
    String? category,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  // ==========================================================================
  // COMPETITIONS
  // ==========================================================================

  /// Fetches competitions.
  Future<List<CompetitionModel>> getCompetitions({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches competition detail.
  Future<CompetitionModel> getCompetitionDetail(String id);

  /// Joins a competition.
  Future<void> joinCompetition(String id);

  // ==========================================================================
  // FEATURED CONTENT
  // ==========================================================================

  /// Fetches featured discussions/posts.
  Future<List<ForumPostModel>> getFeaturedDiscussions({int limit = 5});

  /// Fetches pending assignments (not submitted or incomplete).
  Future<List<AssignmentModel>> getPendingAssignments({int limit = 10});

  // ==========================================================================
  // SCHEDULES
  // ==========================================================================

  /// Fetches week schedules.
  Future<List<StudentScheduleModel>> getWeekSchedules();

  /// Fetches month schedules.
  Future<List<StudentScheduleModel>> getMonthSchedules({int? month, int? year});
}
