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
}
