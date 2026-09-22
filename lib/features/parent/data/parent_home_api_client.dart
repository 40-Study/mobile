import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'parent_home_api_client.g.dart';

/// Retrofit client cho Parent Home Dashboard.
@RestApi()
abstract class ParentHomeApiClient {
  factory ParentHomeApiClient(Dio dio, {String baseUrl}) = _ParentHomeApiClient;

  /// Lấy danh sách con của phụ huynh.
  @GET('/api/me/children')
  Future<HttpResponse<dynamic>> getChildren({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 10,
  });

  /// Tổng quan học tập của 1 con.
  @GET('/api/parent/children/{childId}/overview')
  Future<HttpResponse<dynamic>> getOverview(@Path('childId') String childId);

  /// Lịch học của 1 con.
  @GET('/api/parent/children/{childId}/schedule')
  Future<HttpResponse<dynamic>> getSchedule(@Path('childId') String childId);

  /// Danh sách bài tập của 1 con.
  @GET('/api/parent/children/{childId}/assignments')
  Future<HttpResponse<dynamic>> getAssignments(@Path('childId') String childId);

  /// Điểm số của 1 con.
  @GET('/api/parent/children/{childId}/grades')
  Future<HttpResponse<dynamic>> getGrades(@Path('childId') String childId);
}
