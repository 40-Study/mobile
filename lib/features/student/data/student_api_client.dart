import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'student_api_client.g.dart';

@RestApi()
abstract class StudentApiClient {
  factory StudentApiClient(Dio dio, {String baseUrl}) = _StudentApiClient;

  // Schedule - need classId from enrollment
  @GET('/api/classes/{classId}/schedules/')
  Future<HttpResponse<dynamic>> getSchedules(
    @Path('classId') String classId, {
    @Query('date') String? date,
  });

  // Notifications
  @GET('/api/notifications/')
  Future<HttpResponse<dynamic>> getNotifications({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  @GET('/api/notifications/unread-count')
  Future<HttpResponse<dynamic>> getUnreadCount();

  @PATCH('/api/notifications/read-all')
  Future<HttpResponse<dynamic>> markAllRead();

  @PATCH('/api/notifications/{id}/read')
  Future<HttpResponse<dynamic>> markRead(@Path('id') String id);

  // Achievements
  @GET('/api/achievements/me')
  Future<HttpResponse<dynamic>> getMyAchievements();

  // Quiz
  @GET('/api/quizzes/{quizId}/questions')
  Future<HttpResponse<dynamic>> getQuizQuestions(@Path('quizId') String quizId);

  @POST('/api/quizzes/{quizId}/start')
  Future<HttpResponse<dynamic>> startQuiz(@Path('quizId') String quizId);

  @POST('/api/quizzes/{quizId}/submit')
  Future<HttpResponse<dynamic>> submitQuiz(
    @Path('quizId') String quizId,
    @Body() Map<String, dynamic> answers,
  );

  // Search courses
  @GET('/api/courses')
  Future<HttpResponse<dynamic>> searchCourses({
    @Query('search') String? query,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  // Calendar events
  @GET('/api/me/events/')
  Future<HttpResponse<dynamic>> getMyEvents({
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });
}
