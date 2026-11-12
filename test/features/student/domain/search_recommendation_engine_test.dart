import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/recommended_course_item.dart';
import 'package:study/features/student/domain/search_recommendation_engine.dart';

void main() {
  group('SearchRecommendationEngine', () {
    const engine = SearchRecommendationEngine();

    test('generates curated fallback recommendations when allCourses is empty', () {
      final results = engine.generateRecommendations(
        allCourses: const [],
        activeEnrollments: const [],
        recentSearches: const [],
      );

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(5));
      expect(results.first.course.title, isNotEmpty);
      expect(results.first.reason, isNotEmpty);
    });

    test('prioritizes courses matching recent search history', () {
      const courseA = CourseModel(
        id: 'c1',
        title: 'Lập trình Flutter cơ bản',
        categoryName: 'Mobile',
        totalStudents: 100,
        averageRating: 4.5,
      );
      const courseB = CourseModel(
        id: 'c2',
        title: 'Thiết kế đồ họa Photoshop',
        categoryName: 'Design',
        totalStudents: 100,
        averageRating: 4.5,
      );

      final results = engine.generateRecommendations(
        allCourses: const [courseA, courseB],
        activeEnrollments: const [],
        recentSearches: const ['Flutter'],
      );

      expect(results.first.course.id, equals('c1'));
      expect(results.first.matchType, equals(RecommendationMatchType.searchHistory));
      expect(results.first.reason, contains('Flutter'));
    });

    test('prioritizes courses in the same category as active enrollments', () {
      const activeEnrollment = EnrollmentModel(
        id: 'e1',
        courseId: 'c_existing',
        course: CourseModel(
          id: 'c_existing',
          title: 'Nhập môn Lập trình Web',
          categoryName: 'Web Development',
        ),
      );

      const courseSameCat = CourseModel(
        id: 'c_web2',
        title: 'React & Next.js chuyên sâu',
        categoryName: 'Web Development',
        totalStudents: 150,
        averageRating: 4.7,
      );

      const courseOtherCat = CourseModel(
        id: 'c_finance',
        title: 'Kế toán doanh nghiệp',
        categoryName: 'Finance',
        totalStudents: 150,
        averageRating: 4.7,
      );

      final results = engine.generateRecommendations(
        allCourses: const [courseOtherCat, courseSameCat],
        activeEnrollments: const [activeEnrollment],
        recentSearches: const [],
      );

      expect(results.first.course.id, equals('c_web2'));
      expect(results.first.matchType, equals(RecommendationMatchType.learningTrack));
    });
  });
}
