import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'teacher_api_client.g.dart';

@RestApi()
abstract class TeacherApiClient {
  factory TeacherApiClient(Dio dio, {String baseUrl}) = _TeacherApiClient;

  // ==========================================================================
  // COURSES
  // ==========================================================================

  /// Lấy danh sách courses.
  @GET('/api/courses')
  Future<HttpResponse<dynamic>> getCourses({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  /// Lấy chi tiết course.
  @GET('/api/courses/{id}')
  Future<HttpResponse<dynamic>> getCourse(@Path('id') String id);

  /// Tạo course mới.
  @POST('/api/courses')
  Future<HttpResponse<dynamic>> createCourse(@Body() Map<String, dynamic> body);

  /// Cập nhật course.
  @PUT('/api/courses/{id}')
  Future<HttpResponse<dynamic>> updateCourse(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa course.
  @DELETE('/api/courses/{id}')
  Future<HttpResponse<dynamic>> deleteCourse(@Path('id') String id);

  // ==========================================================================
  // CLASSES
  // ==========================================================================

  /// Lấy danh sách classes.
  @GET('/api/classes')
  Future<HttpResponse<dynamic>> getClasses({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
  });

  /// Lấy chi tiết class.
  @GET('/api/classes/{id}')
  Future<HttpResponse<dynamic>> getClass(@Path('id') String id);

  /// Tạo class mới.
  @POST('/api/classes')
  Future<HttpResponse<dynamic>> createClass(@Body() Map<String, dynamic> body);

  /// Cập nhật class.
  @PUT('/api/classes/{id}')
  Future<HttpResponse<dynamic>> updateClass(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa class.
  @DELETE('/api/classes/{id}')
  Future<HttpResponse<dynamic>> deleteClass(@Path('id') String id);

  // ==========================================================================
  // CLASS STUDENTS
  // ==========================================================================

  /// Lấy danh sách học sinh trong class.
  @GET('/api/classes/{classId}/students')
  Future<HttpResponse<dynamic>> getClassStudents(
    @Path('classId') String classId, {
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('search') String? search,
  });

  /// Thêm học sinh vào class.
  @POST('/api/classes/{classId}/students')
  Future<HttpResponse<dynamic>> addStudentToClass(
    @Path('classId') String classId,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa học sinh khỏi class.
  @DELETE('/api/classes/{classId}/students/{studentId}')
  Future<HttpResponse<dynamic>> removeStudentFromClass(
    @Path('classId') String classId,
    @Path('studentId') String studentId,
  );

  // ==========================================================================
  // CLASS SCHEDULES
  // ==========================================================================

  /// Lấy lịch học của class.
  @GET('/api/classes/{classId}/schedules')
  Future<HttpResponse<dynamic>> getClassSchedules(
    @Path('classId') String classId,
  );

  /// Tạo lịch học.
  @POST('/api/classes/{classId}/schedules')
  Future<HttpResponse<dynamic>> createSchedule(
    @Path('classId') String classId,
    @Body() Map<String, dynamic> body,
  );

  // ==========================================================================
  // ENROLLMENTS (for student progress)
  // ==========================================================================

  /// Lấy danh sách enrollments.
  @GET('/api/enrollments')
  Future<HttpResponse<dynamic>> getEnrollments({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Chi tiết enrollment.
  @GET('/api/enrollments/{id}')
  Future<HttpResponse<dynamic>> getEnrollment(@Path('id') String id);

  // ==========================================================================
  // TEACHERS
  // ==========================================================================

  /// Lấy danh sách teachers.
  @GET('/api/teachers')
  Future<HttpResponse<dynamic>> getTeachers({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('search') String? search,
  });

  /// Lấy chi tiết teacher.
  @GET('/api/teachers/{id}')
  Future<HttpResponse<dynamic>> getTeacher(@Path('id') String id);
}
