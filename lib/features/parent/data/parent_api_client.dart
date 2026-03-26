import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'parent_api_client.g.dart';

@RestApi()
abstract class ParentApiClient {
  factory ParentApiClient(Dio dio, {String baseUrl}) = _ParentApiClient;

  // ==========================================================================
  // CHILDREN
  // ==========================================================================

  /// Lay danh sach con cua phu huynh.
  @GET('/api/me/children')
  Future<HttpResponse<dynamic>> getChildren();

  // ==========================================================================
  // CLASSES (for child)
  // ==========================================================================

  /// Lay danh sach lop hoc cua con (filter by student_id).
  @GET('/api/classes')
  Future<HttpResponse<dynamic>> getClasses({
    @Query('student_id') String? studentId,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay chi tiet lop hoc.
  @GET('/api/classes/{id}')
  Future<HttpResponse<dynamic>> getClass(@Path('id') String id);

  // ==========================================================================
  // ATTENDANCES (for child)
  // ==========================================================================

  /// Lay lich su diem danh cua con trong lop.
  @GET('/api/classes/{classId}/attendances')
  Future<HttpResponse<dynamic>> getClassAttendances(
    @Path('classId') String classId, {
    @Query('student_id') String? studentId,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  // ==========================================================================
  // ENROLLMENTS (for child's online courses)
  // ==========================================================================

  /// Lay danh sach khoa hoc online cua con (filter by user_id).
  @GET('/api/enrollments')
  Future<HttpResponse<dynamic>> getEnrollments({
    @Query('user_id') String? userId,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lay chi tiet enrollment.
  @GET('/api/enrollments/{id}')
  Future<HttpResponse<dynamic>> getEnrollment(@Path('id') String id);
}
