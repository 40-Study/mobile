import 'package:injectable/injectable.dart';
import 'package:study/features/course/data/course_api_client.dart';
import 'package:study/features/course/data/dto/dto.dart';
import 'package:study/features/course/data/models/models.dart';
import 'package:study/features/course/repository/course_repository.dart';

@LazySingleton(as: CourseRepository)
class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl(this._apiClient);

  final CourseApiClient _apiClient;

  // COURSE

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? level,
    String? search,
    String? sortBy,
    bool? isFree,
  }) async {
    final response = await _apiClient.getCourses(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
      level: level,
      search: search,
      sortBy: sortBy,
      isFree: isFree,
    );
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<CourseModel> getCourseBySlug(String slug) async {
    final response = await _apiClient.getCourseBySlug(slug);
    return CourseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CourseModel> getCourse(String id) async {
    final response = await _apiClient.getCourse(id);
    return CourseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CourseModel> createCourse(CreateCourseDto dto) async {
    final response = await _apiClient.createCourse(dto.toJson());
    return CourseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CourseModel> updateCourse(String id, CreateCourseDto dto) async {
    final response = await _apiClient.updateCourse(id, dto.toJson());
    return CourseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _apiClient.deleteCourse(id);
  }

  // SECTION

  @override
  Future<SectionModel> createSection(
    String courseId,
    CreateSectionDto dto,
  ) async {
    final response = await _apiClient.createSection(courseId, dto.toJson());
    return SectionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<SectionModel>> getSections(String courseId) async {
    final response = await _apiClient.getSections(courseId);
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<SectionModel> getSection(String courseId, String sectionId) async {
    final response = await _apiClient.getSection(courseId, sectionId);
    return SectionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> reorderSections(String courseId, List<String> sectionIds) async {
    await _apiClient.reorderSections(courseId, {'section_ids': sectionIds});
  }

  @override
  Future<SectionModel> updateSection(
    String courseId,
    String sectionId,
    CreateSectionDto dto,
  ) async {
    final response = await _apiClient.updateSection(
      courseId,
      sectionId,
      dto.toJson(),
    );
    return SectionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSection(String courseId, String sectionId) async {
    await _apiClient.deleteSection(courseId, sectionId);
  }

  // LESSON

  @override
  Future<LessonModel> createLesson(
    String sectionId,
    CreateLessonDto dto,
  ) async {
    final response = await _apiClient.createLesson(sectionId, dto.toJson());
    return LessonModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<LessonModel>> getLessons(String sectionId) async {
    final response = await _apiClient.getLessons(sectionId);
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<void> reorderLessons(String sectionId, List<String> lessonIds) async {
    await _apiClient.reorderLessons(sectionId, {'lesson_ids': lessonIds});
  }

  @override
  Future<LessonModel> getLesson(String id) async {
    final response = await _apiClient.getLesson(id);
    return LessonModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<LessonModel> updateLesson(String id, CreateLessonDto dto) async {
    final response = await _apiClient.updateLesson(id, dto.toJson());
    return LessonModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await _apiClient.deleteLesson(id);
  }

  // ENROLLMENT

  @override
  Future<EnrollmentModel> enrollCourse(String courseId) async {
    final response = await _apiClient.enrollCourse(courseId);
    return EnrollmentModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> unenrollCourse(String courseId) async {
    await _apiClient.unenrollCourse(courseId);
  }

  @override
  Future<List<EnrollmentModel>> getCourseEnrollments(
    String courseId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getCourseEnrollments(
      courseId,
      page: page,
      pageSize: pageSize,
    );
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<List<EnrollmentModel>> getMyEnrollments({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    final response = await _apiClient.getMyEnrollments(
      page: page,
      pageSize: pageSize,
      status: status,
    );
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<EnrollmentModel> getEnrollment(String id) async {
    final response = await _apiClient.getEnrollment(id);
    return EnrollmentModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateLessonProgress(
    String lessonId,
    UpdateProgressDto dto,
  ) async {
    await _apiClient.updateLessonProgress(lessonId, dto.toJson());
  }

  // REVIEW

  @override
  Future<List<ReviewModel>> getCourseReviews(
    String courseId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getCourseReviews(
      courseId,
      page: page,
      pageSize: pageSize,
    );
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<ReviewModel> createReview(
    String courseId,
    CreateReviewDto dto,
  ) async {
    final response = await _apiClient.createReview(courseId, dto.toJson());
    return ReviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> updateReview(String id, CreateReviewDto dto) async {
    final response = await _apiClient.updateReview(id, dto.toJson());
    return ReviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReview(String id) async {
    await _apiClient.deleteReview(id);
  }

  @override
  Future<void> reactToReview(String id, String reaction) async {
    await _apiClient.reactToReview(id, {'reaction': reaction});
  }

  @override
  Future<void> removeReviewReaction(String id) async {
    await _apiClient.removeReviewReaction(id);
  }

  // CERTIFICATE

  @override
  Future<CertificateModel> verifyCertificate(String certificateNumber) async {
    final response = await _apiClient.verifyCertificate(certificateNumber);
    return CertificateModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<CertificateModel> issueCertificate(String courseId) async {
    final response = await _apiClient.issueCertificate({'course_id': courseId});
    return CertificateModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<CertificateModel>> getMyCertificates({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getMyCertificates(
      page: page,
      pageSize: pageSize,
    );
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<CertificateModel> getCertificate(String id) async {
    final response = await _apiClient.getCertificate(id);
    return CertificateModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // CATEGORY & TAG

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.getCategories();
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<CategoryModel> getCategory(String id) async {
    final response = await _apiClient.getCategory(id);
    return CategoryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<TagModel>> getTags() async {
    final response = await _apiClient.getTags();
    final data = response.data['data'] as List?;
    return data
            ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<TagModel> getTag(String id) async {
    final response = await _apiClient.getTag(id);
    return TagModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
