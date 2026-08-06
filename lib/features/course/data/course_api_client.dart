import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'course_api_client.g.dart';

@RestApi()
abstract class CourseApiClient {
  factory CourseApiClient(Dio dio, {String baseUrl}) = _CourseApiClient;

  // COURSE

  /// Lấy danh sách khóa học (public)
  @GET('/api/courses')
  Future<HttpResponse<dynamic>> getCourses({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('category_id') String? categoryId,
    @Query('level') String? level,
    @Query('search') String? search,
    @Query('sort_by') String? sortBy,
    @Query('is_free') bool? isFree,
  });

  /// Lấy khóa học theo slug (public)
  @GET('/api/courses/slug/{slug}')
  Future<HttpResponse<dynamic>> getCourseBySlug(@Path('slug') String slug);

  /// Lấy chi tiết khóa học
  @GET('/api/courses/{id}')
  Future<HttpResponse<dynamic>> getCourse(@Path('id') String id);

  /// Tạo khóa học mới
  @POST('/api/courses')
  Future<HttpResponse<dynamic>> createCourse(@Body() Map<String, dynamic> body);

  /// Cập nhật khóa học
  @PUT('/api/courses/{id}')
  Future<HttpResponse<dynamic>> updateCourse(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa khóa học
  @DELETE('/api/courses/{id}')
  Future<HttpResponse<dynamic>> deleteCourse(@Path('id') String id);

  // SECTION

  /// Tạo section mới
  @POST('/api/courses/{courseId}/sections')
  Future<HttpResponse<dynamic>> createSection(
    @Path('courseId') String courseId,
    @Body() Map<String, dynamic> body,
  );

  /// Lấy tất cả sections của khóa học
  @GET('/api/courses/{courseId}/sections')
  Future<HttpResponse<dynamic>> getSections(@Path('courseId') String courseId);

  /// Lấy chi tiết section
  @GET('/api/courses/{courseId}/sections/{id}')
  Future<HttpResponse<dynamic>> getSection(
    @Path('courseId') String courseId,
    @Path('id') String sectionId,
  );

  /// Sắp xếp lại sections
  @PUT('/api/courses/{courseId}/sections/reorder')
  Future<HttpResponse<dynamic>> reorderSections(
    @Path('courseId') String courseId,
    @Body() Map<String, dynamic> body,
  );

  /// Cập nhật section
  @PUT('/api/courses/{courseId}/sections/{id}')
  Future<HttpResponse<dynamic>> updateSection(
    @Path('courseId') String courseId,
    @Path('id') String sectionId,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa section
  @DELETE('/api/courses/{courseId}/sections/{id}')
  Future<HttpResponse<dynamic>> deleteSection(
    @Path('courseId') String courseId,
    @Path('id') String sectionId,
  );

  // LESSON

  /// Tạo lesson mới
  @POST('/api/sections/{sectionId}/lessons')
  Future<HttpResponse<dynamic>> createLesson(
    @Path('sectionId') String sectionId,
    @Body() Map<String, dynamic> body,
  );

  /// Lấy tất cả lessons của section
  @GET('/api/sections/{sectionId}/lessons')
  Future<HttpResponse<dynamic>> getLessons(@Path('sectionId') String sectionId);

  /// Sắp xếp lại lessons
  @PUT('/api/sections/{sectionId}/lessons/reorder')
  Future<HttpResponse<dynamic>> reorderLessons(
    @Path('sectionId') String sectionId,
    @Body() Map<String, dynamic> body,
  );

  /// Lấy chi tiết lesson
  @GET('/api/lessons/{id}')
  Future<HttpResponse<dynamic>> getLesson(@Path('id') String id);

  /// Cập nhật lesson
  @PUT('/api/lessons/{id}')
  Future<HttpResponse<dynamic>> updateLesson(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa lesson
  @DELETE('/api/lessons/{id}')
  Future<HttpResponse<dynamic>> deleteLesson(@Path('id') String id);

  // LESSON CONTENT

  /// Tạo nội dung lesson
  @POST('/api/lessons/{lessonId}/contents')
  Future<HttpResponse<dynamic>> createLessonContent(
    @Path('lessonId') String lessonId,
    @Body() Map<String, dynamic> body,
  );

  /// Lấy nội dung lesson
  @GET('/api/lessons/{lessonId}/contents')
  Future<HttpResponse<dynamic>> getLessonContents(
    @Path('lessonId') String lessonId,
  );

  /// Sắp xếp lại nội dung
  @PUT('/api/lessons/{lessonId}/contents/reorder')
  Future<HttpResponse<dynamic>> reorderLessonContents(
    @Path('lessonId') String lessonId,
    @Body() Map<String, dynamic> body,
  );

  /// Cập nhật nội dung
  @PUT('/api/lessons/{lessonId}/contents/{id}')
  Future<HttpResponse<dynamic>> updateLessonContent(
    @Path('lessonId') String lessonId,
    @Path('id') String contentId,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa nội dung
  @DELETE('/api/lessons/{lessonId}/contents/{id}')
  Future<HttpResponse<dynamic>> deleteLessonContent(
    @Path('lessonId') String lessonId,
    @Path('id') String contentId,
  );

  // ENROLLMENT

  /// Ghi danh khóa học
  @POST('/api/courses/{courseId}/enroll')
  Future<HttpResponse<dynamic>> enrollCourse(@Path('courseId') String courseId);

  /// Hủy ghi danh
  @DELETE('/api/courses/{courseId}/enroll')
  Future<HttpResponse<dynamic>> unenrollCourse(
    @Path('courseId') String courseId,
  );

  /// Lấy danh sách ghi danh của khóa học
  @GET('/api/courses/{courseId}/enrollments')
  Future<HttpResponse<dynamic>> getCourseEnrollments(
    @Path('courseId') String courseId, {
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lấy khóa học đã ghi danh của user
  @GET('/api/enrollments')
  Future<HttpResponse<dynamic>> getMyEnrollments({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
    @Query('status') String? status,
  });

  /// Lấy chi tiết ghi danh
  @GET('/api/enrollments/{id}')
  Future<HttpResponse<dynamic>> getEnrollment(@Path('id') String id);

  /// Cập nhật tiến độ lesson
  @PUT('/api/lessons/{lessonId}/progress')
  Future<HttpResponse<dynamic>> updateLessonProgress(
    @Path('lessonId') String lessonId,
    @Body() Map<String, dynamic> body,
  );

  // REVIEW

  /// Lấy reviews của khóa học (public)
  @GET('/api/courses/{courseId}/reviews')
  Future<HttpResponse<dynamic>> getCourseReviews(
    @Path('courseId') String courseId, {
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Tạo review mới
  @POST('/api/courses/{courseId}/reviews')
  Future<HttpResponse<dynamic>> createReview(
    @Path('courseId') String courseId,
    @Body() Map<String, dynamic> body,
  );

  /// Cập nhật review
  @PUT('/api/reviews/{id}')
  Future<HttpResponse<dynamic>> updateReview(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa review
  @DELETE('/api/reviews/{id}')
  Future<HttpResponse<dynamic>> deleteReview(@Path('id') String id);

  /// React to review
  @POST('/api/reviews/{id}/reaction')
  Future<HttpResponse<dynamic>> reactToReview(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa reaction
  @DELETE('/api/reviews/{id}/reaction')
  Future<HttpResponse<dynamic>> removeReviewReaction(@Path('id') String id);

  // CERTIFICATE

  /// Xác minh chứng chỉ (public)
  @GET('/api/certificates/verify/{number}')
  Future<HttpResponse<dynamic>> verifyCertificate(
    @Path('number') String certificateNumber,
  );

  /// Cấp chứng chỉ
  @POST('/api/certificates')
  Future<HttpResponse<dynamic>> issueCertificate(
    @Body() Map<String, dynamic> body,
  );

  /// Lấy chứng chỉ của user
  @GET('/api/certificates')
  Future<HttpResponse<dynamic>> getMyCertificates({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  /// Lấy chi tiết chứng chỉ
  @GET('/api/certificates/{id}')
  Future<HttpResponse<dynamic>> getCertificate(@Path('id') String id);

  // CATEGORY & TAG

  /// Lấy tất cả categories (public)
  @GET('/api/categories')
  Future<HttpResponse<dynamic>> getCategories();

  /// Lấy chi tiết category
  @GET('/api/categories/{id}')
  Future<HttpResponse<dynamic>> getCategory(@Path('id') String id);

  /// Tạo category mới
  @POST('/api/categories')
  Future<HttpResponse<dynamic>> createCategory(
    @Body() Map<String, dynamic> body,
  );

  /// Cập nhật category
  @PUT('/api/categories/{id}')
  Future<HttpResponse<dynamic>> updateCategory(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa category
  @DELETE('/api/categories/{id}')
  Future<HttpResponse<dynamic>> deleteCategory(@Path('id') String id);

  /// Lấy tất cả tags (public)
  @GET('/api/tags')
  Future<HttpResponse<dynamic>> getTags();

  /// Lấy chi tiết tag
  @GET('/api/tags/{id}')
  Future<HttpResponse<dynamic>> getTag(@Path('id') String id);

  /// Tạo tag mới
  @POST('/api/tags')
  Future<HttpResponse<dynamic>> createTag(@Body() Map<String, dynamic> body);

  /// Cập nhật tag
  @PUT('/api/tags/{id}')
  Future<HttpResponse<dynamic>> updateTag(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Xóa tag
  @DELETE('/api/tags/{id}')
  Future<HttpResponse<dynamic>> deleteTag(@Path('id') String id);
}
