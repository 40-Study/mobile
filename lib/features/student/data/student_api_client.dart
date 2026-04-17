import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'student_api_client.g.dart';

@RestApi()
abstract class StudentApiClient {
  factory StudentApiClient(Dio dio, {String baseUrl}) = _StudentApiClient;

  // ==========================================================================
  // CLASSES (filtered by student)
  // ==========================================================================

  /// Lay danh sach lop hoc cua hoc sinh.
  @GET('/api/classes')
  Future<HttpResponse<dynamic>> getClasses({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('student_id') String? studentId,
    @Query('status') String? status,
  });

  /// Lay chi tiet lop hoc.
  @GET('/api/classes/{id}')
  Future<HttpResponse<dynamic>> getClass(@Path('id') String id);

  /// Lay lich hoc cua lop.
  @GET('/api/classes/{classId}/schedules')
  Future<HttpResponse<dynamic>> getClassSchedules(
    @Path('classId') String classId,
  );

  // ==========================================================================
  // ENROLLMENTS
  // ==========================================================================

  /// Lay danh sach khoa hoc da dang ky.
  @GET('/api/enrollments')
  Future<HttpResponse<dynamic>> getEnrollments({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
  });

  /// Lay chi tiet enrollment.
  @GET('/api/enrollments/{id}')
  Future<HttpResponse<dynamic>> getEnrollment(@Path('id') String id);

  /// Dang ky khoa hoc moi.
  @POST('/api/courses/{courseId}/enroll')
  Future<HttpResponse<dynamic>> enrollCourse(@Path('courseId') String courseId);

  // ==========================================================================
  // LESSON PROGRESS
  // ==========================================================================

  /// Cap nhat tien do bai hoc.
  @PUT('/api/lessons/{lessonId}/progress')
  Future<HttpResponse<dynamic>> updateLessonProgress(
    @Path('lessonId') String lessonId,
    @Body() Map<String, dynamic> body,
  );

  /// Lay tien do bai hoc.
  @GET('/api/lessons/{lessonId}/progress')
  Future<HttpResponse<dynamic>> getLessonProgress(@Path('lessonId') String lessonId);

  // ==========================================================================
  // LIVESTREAM
  // ==========================================================================

  /// Lay danh sach livestream sap toi.
  @GET('/api/livestream')
  Future<HttpResponse<dynamic>> getUpcomingLivestreams({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
  });

  /// Lay chi tiet livestream.
  @GET('/api/livestream/{id}')
  Future<HttpResponse<dynamic>> getLivestream(@Path('id') String id);

  // ==========================================================================
  // COURSES (for discovery)
  // ==========================================================================

  /// Lay danh sach khoa hoc (kham pha).
  @GET('/api/courses')
  Future<HttpResponse<dynamic>> getCourses({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('category') String? category,
    @Query('search') String? search,
  });

  /// Lay chi tiet khoa hoc.
  @GET('/api/courses/{id}')
  Future<HttpResponse<dynamic>> getCourse(@Path('id') String id);

  /// Lay chi tiet khoa hoc day du (bao gom chapters, documents, discussions).
  @GET('/api/courses/{id}/detail')
  Future<HttpResponse<dynamic>> getCourseDetail(@Path('id') String id);

  /// Lay chi tiet bai hoc.
  @GET('/api/lessons/{id}')
  Future<HttpResponse<dynamic>> getLessonDetail(@Path('id') String id);

  // ==========================================================================
  // UNENROLL
  // ==========================================================================

  /// Huy dang ky khoa hoc.
  @DELETE('/api/courses/{courseId}/enroll')
  Future<HttpResponse<dynamic>> unenrollCourse(@Path('courseId') String courseId);

  // ==========================================================================
  // CART
  // ==========================================================================

  /// Lay gio hang.
  @GET('/api/cart')
  Future<HttpResponse<dynamic>> getCart();

  /// Them khoa hoc vao gio hang.
  @POST('/api/cart')
  Future<HttpResponse<dynamic>> addToCart(@Body() Map<String, dynamic> body);

  /// Xoa khoa hoc khoi gio hang.
  @DELETE('/api/cart')
  Future<HttpResponse<dynamic>> removeFromCart(@Body() Map<String, dynamic> body);

  /// Xoa toan bo gio hang.
  @DELETE('/api/cart/clear')
  Future<HttpResponse<dynamic>> clearCart();

  /// Kiem tra khoa hoc trong gio hang.
  @GET('/api/cart/check/{courseId}')
  Future<HttpResponse<dynamic>> checkCourseInCart(@Path('courseId') String courseId);

  // ==========================================================================
  // ORDERS
  // ==========================================================================

  /// Tao don hang.
  @POST('/api/orders')
  Future<HttpResponse<dynamic>> createOrder(@Body() Map<String, dynamic> body);

  /// Lay danh sach don hang.
  @GET('/api/orders')
  Future<HttpResponse<dynamic>> getOrders({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
  });

  /// Lay chi tiet don hang.
  @GET('/api/orders/{id}')
  Future<HttpResponse<dynamic>> getOrder(@Path('id') String id);

  /// Lay trang thai thanh toan.
  @GET('/api/orders/{id}/payment-status')
  Future<HttpResponse<dynamic>> getPaymentStatus(@Path('id') String orderId);

  // ==========================================================================
  // ASSIGNMENTS
  // ==========================================================================

  /// Lay danh sach bai tap.
  @GET('/api/assignments')
  Future<HttpResponse<dynamic>> getAssignments({
    @Query('session_id') String? sessionId,
    @Query('class_id') String? classId,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay chi tiet bai tap.
  @GET('/api/assignments/{id}')
  Future<HttpResponse<dynamic>> getAssignment(@Path('id') String id);

  /// Lay sandbox bai tap (cho hoc sinh).
  @GET('/api/assignments/{id}/sandbox')
  Future<HttpResponse<dynamic>> getAssignmentSandbox(@Path('id') String id);

  // ==========================================================================
  // SUBMISSIONS
  // ==========================================================================

  /// Nop bai.
  @POST('/api/submissions')
  Future<HttpResponse<dynamic>> submitAssignment(@Body() Map<String, dynamic> body);

  /// Chay code (kiem tra voi sample tests).
  @POST('/api/submissions/run')
  Future<HttpResponse<dynamic>> runCode(@Body() Map<String, dynamic> body);

  /// Chay code voi custom input.
  @POST('/api/submissions/run-custom')
  Future<HttpResponse<dynamic>> runCodeCustom(@Body() Map<String, dynamic> body);

  /// Lay chi tiet submission.
  @GET('/api/submissions/{id}')
  Future<HttpResponse<dynamic>> getSubmission(@Path('id') String id);

  /// Lay danh sach submissions cua bai tap.
  @GET('/api/submissions')
  Future<HttpResponse<dynamic>> getSubmissions({
    @Query('assignment_id') String? assignmentId,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

  /// Lay danh sach thong bao.
  @GET('/api/notifications')
  Future<HttpResponse<dynamic>> getNotifications({
    @Query('is_read') bool? isRead,
    @Query('type') String? type,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay so thong bao chua doc.
  @GET('/api/notifications/unread-count')
  Future<HttpResponse<dynamic>> getUnreadNotificationCount();

  /// Danh dau da doc.
  @PATCH('/api/notifications/{id}/read')
  Future<HttpResponse<dynamic>> markNotificationAsRead(@Path('id') String id);

  /// Danh dau tat ca da doc.
  @PATCH('/api/notifications/read-all')
  Future<HttpResponse<dynamic>> markAllNotificationsAsRead();

  /// Xoa thong bao.
  @DELETE('/api/notifications/{id}')
  Future<HttpResponse<dynamic>> deleteNotification(@Path('id') String id);

  // ==========================================================================
  // GAMIFICATION - ACHIEVEMENTS
  // ==========================================================================

  /// Lay danh sach thanh tuu.
  @GET('/api/achievements')
  Future<HttpResponse<dynamic>> getAchievements();

  /// Lay thanh tuu cua toi.
  @GET('/api/achievements/me')
  Future<HttpResponse<dynamic>> getMyAchievements();

  // ==========================================================================
  // GAMIFICATION - LEADERBOARD
  // ==========================================================================

  /// Lay bang xep hang.
  @GET('/api/leaderboard')
  Future<HttpResponse<dynamic>> getLeaderboard({
    @Query('period_type') String periodType = 'weekly',
    @Query('limit') int limit = 50,
  });

  /// Lay thu hang cua toi.
  @GET('/api/leaderboard/me')
  Future<HttpResponse<dynamic>> getMyRank();

  // ==========================================================================
  // USER STATS
  // ==========================================================================

  /// Lay profile cong khai cua user.
  @GET('/api/users/{id}/public-profile')
  Future<HttpResponse<dynamic>> getUserPublicProfile(@Path('id') String userId);

  // ==========================================================================
  // VOUCHERS
  // ==========================================================================

  /// Lay danh sach voucher cong khai.
  @GET('/api/vouchers/public')
  Future<HttpResponse<dynamic>> getPublicVouchers();

  /// Lay voucher theo code.
  @GET('/api/vouchers/code/{code}')
  Future<HttpResponse<dynamic>> getVoucherByCode(@Path('code') String code);

  /// Luu voucher.
  @POST('/api/vouchers/{id}/save')
  Future<HttpResponse<dynamic>> saveVoucher(@Path('id') String id);

  /// Bo luu voucher.
  @DELETE('/api/vouchers/{id}/save')
  Future<HttpResponse<dynamic>> unsaveVoucher(@Path('id') String id);

  /// Lay voucher da luu.
  @GET('/api/vouchers/me')
  Future<HttpResponse<dynamic>> getMySavedVouchers();

  // ==========================================================================
  // DISCUSSIONS
  // ==========================================================================

  /// Lay danh sach bai viet.
  @GET('/api/discussions')
  Future<HttpResponse<dynamic>> getDiscussions({
    @Query('category') String? category,
    @Query('keyword') String? keyword,
    @Query('sort') String? sort,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay chi tiet bai viet.
  @GET('/api/discussions/{slug}')
  Future<HttpResponse<dynamic>> getDiscussion(@Path('slug') String slug);

  /// Tao bai viet.
  @POST('/api/discussions')
  Future<HttpResponse<dynamic>> createDiscussion(@Body() Map<String, dynamic> body);

  /// Binh luan.
  @POST('/api/discussions/{slug}/comments')
  Future<HttpResponse<dynamic>> addComment(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );

  /// Vote bai viet.
  @POST('/api/discussions/{id}/vote')
  Future<HttpResponse<dynamic>> voteDiscussion(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Bo vote.
  @DELETE('/api/discussions/{id}/vote')
  Future<HttpResponse<dynamic>> removeVote(@Path('id') String id);

  // ==========================================================================
  // TRENDING & FEATURED
  // ==========================================================================

  /// Lay khoa hoc xu huong.
  @GET('/api/courses/trending')
  Future<HttpResponse<dynamic>> getTrendingCourses({
    @Query('limit') int limit = 10,
  });

  /// Lay bai viet noi bat.
  @GET('/api/discussions/featured')
  Future<HttpResponse<dynamic>> getFeaturedDiscussions({
    @Query('limit') int limit = 5,
  });

  // ==========================================================================
  // COMPETITIONS
  // ==========================================================================

  /// Lay danh sach cuoc thi.
  @GET('/api/competitions')
  Future<HttpResponse<dynamic>> getCompetitions({
    @Query('status') String? status,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay chi tiet cuoc thi.
  @GET('/api/competitions/{id}')
  Future<HttpResponse<dynamic>> getCompetition(@Path('id') String id);

  /// Tham gia cuoc thi.
  @POST('/api/competitions/{id}/join')
  Future<HttpResponse<dynamic>> joinCompetition(@Path('id') String id);

  // ==========================================================================
  // PENDING ASSIGNMENTS
  // ==========================================================================

  /// Lay bai tap can lam (chua nop hoac chua hoan thanh).
  @GET('/api/assignments/pending')
  Future<HttpResponse<dynamic>> getPendingAssignments({
    @Query('limit') int limit = 10,
  });

  // ==========================================================================
  // SCHEDULES
  // ==========================================================================

  /// Lay lich hoc tuan nay.
  @GET('/api/schedules/week')
  Future<HttpResponse<dynamic>> getWeekSchedules();

  /// Lay lich hoc thang nay.
  @GET('/api/schedules/month')
  Future<HttpResponse<dynamic>> getMonthSchedules({
    @Query('month') int? month,
    @Query('year') int? year,
  });
}
