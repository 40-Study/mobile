import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'parent_api_client.g.dart';

@RestApi()
abstract class ParentApiClient {
  factory ParentApiClient(Dio dio, {String baseUrl}) = _ParentApiClient;

  @GET('/api/me/children')
  Future<HttpResponse<dynamic>> getChildren();

  @GET('/api/parent/children/{id}/overview')
  Future<HttpResponse<dynamic>> getChildOverview(@Path('id') String childId);

  @GET('/api/parent/children/{id}/courses')
  Future<HttpResponse<dynamic>> getChildCourses(@Path('id') String childId);

  @GET('/api/parent/children/{id}/schedule')
  Future<HttpResponse<dynamic>> getChildSchedule(@Path('id') String childId);

  @GET('/api/parent/children/{id}/assignments')
  Future<HttpResponse<dynamic>> getChildAssignments(@Path('id') String childId);

  @GET('/api/parent/alerts')
  Future<HttpResponse<dynamic>> getAlerts();
}
