import 'package:study/features/course/data/dto/dto.dart';
import 'package:study/features/course/data/models/models.dart';

abstract class CourseRepository {
  // COURSE

  Future<List<CourseModel>> getCourses({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? level,
    String? search,
    String? sortBy,
    bool? isFree,
  });

  Future<CourseModel> getCourseBySlug(String slug);

  Future<CourseModel> getCourse(String id);

  Future<CourseModel> createCourse(CreateCourseDto dto);

  Future<CourseModel> updateCourse(String id, CreateCourseDto dto);

  Future<void> deleteCourse(String id);

  // SECTION

  Future<SectionModel> createSection(String courseId, CreateSectionDto dto);

  Future<List<SectionModel>> getSections(String courseId);

  Future<SectionModel> getSection(String courseId, String sectionId);

  Future<void> reorderSections(String courseId, List<String> sectionIds);

  Future<SectionModel> updateSection(
    String courseId,
    String sectionId,
    CreateSectionDto dto,
  );

  Future<void> deleteSection(String courseId, String sectionId);

  // LESSON

  Future<LessonModel> createLesson(String sectionId, CreateLessonDto dto);

  Future<List<LessonModel>> getLessons(String sectionId);

  Future<void> reorderLessons(String sectionId, List<String> lessonIds);

  Future<LessonModel> getLesson(String id);

  Future<LessonModel> updateLesson(String id, CreateLessonDto dto);

  Future<void> deleteLesson(String id);

  // ENROLLMENT

  Future<EnrollmentModel> enrollCourse(String courseId);

  Future<void> unenrollCourse(String courseId);

  Future<List<EnrollmentModel>> getCourseEnrollments(
    String courseId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<List<EnrollmentModel>> getMyEnrollments({
    int page = 1,
    int pageSize = 20,
    String? status,
  });

  Future<EnrollmentModel> getEnrollment(String id);

  Future<void> updateLessonProgress(String lessonId, UpdateProgressDto dto);

  // REVIEW

  Future<List<ReviewModel>> getCourseReviews(
    String courseId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<ReviewModel> createReview(String courseId, CreateReviewDto dto);

  Future<ReviewModel> updateReview(String id, CreateReviewDto dto);

  Future<void> deleteReview(String id);

  Future<void> reactToReview(String id, String reaction);

  Future<void> removeReviewReaction(String id);

  // CERTIFICATE

  Future<CertificateModel> verifyCertificate(String certificateNumber);

  Future<CertificateModel> issueCertificate(String courseId);

  Future<List<CertificateModel>> getMyCertificates({
    int page = 1,
    int pageSize = 20,
  });

  Future<CertificateModel> getCertificate(String id);

  // CATEGORY & TAG

  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> getCategory(String id);

  Future<List<TagModel>> getTags();

  Future<TagModel> getTag(String id);
}
