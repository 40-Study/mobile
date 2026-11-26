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
    // Backend đọc `pageSize`; 50 đủ cho số con thực tế của 1 phụ huynh
    @Query('pageSize') int pageSize = 50,
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

  // === Family Link Requests ===

  /// Gửi yêu cầu liên kết con.
  @POST('/api/family/link-requests')
  Future<HttpResponse<dynamic>> createLinkRequest(@Body() Map<String, dynamic> body);

  /// Danh sách yêu cầu đã gửi.
  @GET('/api/family/link-requests/sent')
  Future<HttpResponse<dynamic>> getSentLinkRequests();

  /// Hủy yêu cầu liên kết.
  @POST('/api/family/link-requests/{id}/cancel')
  Future<HttpResponse<dynamic>> cancelLinkRequest(@Path('id') String id);

  /// Hủy liên kết con.
  @DELETE('/api/family/children/{id}')
  Future<HttpResponse<dynamic>> unlinkChild(@Path('id') String id);
}
