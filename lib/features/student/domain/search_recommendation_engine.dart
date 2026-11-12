import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/recommended_course_item.dart';

/// Thuật toán đề xuất khóa học thông minh thu nhỏ (Lightweight Heuristic RecSys)
/// Chạy cục bộ trên thiết bị, kết hợp tín hiệu ngữ cảnh học tập, lịch sử tìm kiếm
/// và độ tín nhiệm cộng đồng.
class SearchRecommendationEngine {
  const SearchRecommendationEngine();

  /// Tính toán và sắp xếp danh sách khóa học đề xuất cá nhân hóa
  List<RecommendedCourseItem> generateRecommendations({
    required List<CourseModel> allCourses,
    required List<EnrollmentModel> activeEnrollments,
    required List<String> recentSearches,
    int limit = 5,
  }) {
    final candidateCourses = allCourses.isNotEmpty
        ? allCourses
        : _curatedFallbackCourses();

    final enrolledCourseIds = activeEnrollments
        .map((e) => e.courseId ?? e.course?.id)
        .whereType<String>()
        .toSet();

    final activeCategories = activeEnrollments
        .map((e) => e.course?.categoryName?.toLowerCase().trim())
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet();

    final activeTitles = activeEnrollments
        .map((e) => e.course?.title.toLowerCase().trim())
        .whereType<String>()
        .toList();

    final normalizedSearches = recentSearches
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    final scoredItems = <RecommendedCourseItem>[];

    for (final course in candidateCourses) {
      final isEnrolled = enrolledCourseIds.contains(course.id);
      final courseTitleLower = course.title.toLowerCase();
      final courseCatLower = (course.categoryName ?? '').toLowerCase();
      final courseInstructorLower = (course.instructorName ?? '').toLowerCase();

      // 1. Learning Track Factor (w1 = 0.35)
      var sLearning = 0.0;
      String? learningReason;
      if (activeCategories.contains(courseCatLower)) {
        sLearning = 1.0;
        learningReason = 'Cùng chuyên ngành bạn đang theo học';
      } else {
        for (final title in activeTitles) {
          if (_hasCommonKeywords(title, courseTitleLower)) {
            sLearning = 0.8;
            learningReason = 'Bổ trợ kỹ năng cho khóa học hiện tại';
            break;
          }
        }
      }

      // 2. Search History Factor (w2 = 0.25)
      var sSearch = 0.0;
      String? searchReason;
      for (final query in normalizedSearches) {
        if (courseTitleLower.contains(query) ||
            courseCatLower.contains(query) ||
            courseInstructorLower.contains(query)) {
          sSearch = 1.0;
          final queryDisplay = recentSearches.firstWhere(
            (s) => s.trim().toLowerCase() == query,
            orElse: () => query,
          );
          searchReason = 'Phù hợp với tìm kiếm "$queryDisplay"';
          break;
        }
      }

      // 3. Quality & Social Proof Factor (w3 = 0.25)
      final rating = course.averageRating > 0 ? course.averageRating : 4.8;
      final students = course.totalStudents > 0 ? course.totalStudents : 320;
      final ratingScore = (rating / 5.0).clamp(0.0, 1.0) * 0.6;
      final studentsScore = (students / 500.0).clamp(0.0, 1.0) * 0.4;
      final sQuality = ratingScore + studentsScore;
      final qualityReason = 'Được đánh giá ${rating.toStringAsFixed(1)}⭐ từ học viên';

      // 4. Trend & Community Momentum (w4 = 0.15)
      final sTrend = (students >= 200 || rating >= 4.8) ? 1.0 : 0.6;
      const trendReason = 'Khóa học xu hướng được quan tâm nhiều';

      // Weighted Total Score
      var totalScore = (0.35 * sLearning) +
          (0.25 * sSearch) +
          (0.25 * sQuality) +
          (0.15 * sTrend);

      if (isEnrolled) {
        totalScore -= 2.0; // Phạt nặng khóa học đã sở hữu để ưu tiên khám phá mới
      }

      // Xác định MatchType và Lý do đề xuất tiêu biểu nhất
      final RecommendationMatchType matchType;
      final String reason;

      if (sSearch >= 0.9 && searchReason != null) {
        matchType = RecommendationMatchType.searchHistory;
        reason = searchReason;
      } else if (sLearning >= 0.8 && learningReason != null) {
        matchType = RecommendationMatchType.learningTrack;
        reason = learningReason;
      } else if (rating >= 4.8) {
        matchType = RecommendationMatchType.topRated;
        reason = qualityReason;
      } else {
        matchType = RecommendationMatchType.trending;
        reason = trendReason;
      }

      scoredItems.add(RecommendedCourseItem(
        course: course,
        reason: reason,
        score: totalScore,
        matchType: matchType,
      ));
    }

    // Lọc các khóa học chưa đăng ký (score > 0)
    var results = scoredItems.where((item) => item.score > 0).toList();
    if (results.isEmpty) {
      results = scoredItems;
    }

    // Sắp xếp giảm dần theo điểm
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).toList();
  }

  bool _hasCommonKeywords(String textA, String textB) {
    final wordsA = textA
        .split(RegExp(r'\s+'))
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.length > 3)
        .toSet();
    final wordsB = textB
        .split(RegExp(r'\s+'))
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.length > 3)
        .toSet();
    return wordsA.intersection(wordsB).isNotEmpty;
  }

  /// Danh sách khóa học chuẩn dự phòng khi offline hoặc API trả về rỗng
  List<CourseModel> _curatedFallbackCourses() {
    return const [
      CourseModel(
        id: 'rec_flutter_arch',
        title: 'Flutter Mobile Architecture & Clean BLoC',
        instructorName: 'Nguyễn Văn A',
        categoryName: 'Lập trình Mobile',
        level: 'Intermediate',
        averageRating: 4.9,
        totalRatings: 184,
        totalStudents: 1250,
        totalLessons: 28,
        price: 0,
        isFree: true,
      ),
      CourseModel(
        id: 'rec_react_next',
        title: 'React 19 & Next.js Server Components',
        instructorName: 'Trần Thị B',
        categoryName: 'Lập trình Web',
        level: 'Advanced',
        averageRating: 4.85,
        totalRatings: 142,
        totalStudents: 890,
        totalLessons: 32,
        price: 0,
        isFree: true,
      ),
      CourseModel(
        id: 'rec_figma_system',
        title: 'Figma Design System & Auto-Layout Master',
        instructorName: 'Lê Hoàng Nam',
        categoryName: 'Thiết kế UI/UX',
        level: 'All Levels',
        averageRating: 4.92,
        totalRatings: 96,
        totalStudents: 640,
        totalLessons: 18,
        price: 0,
        isFree: true,
      ),
      CourseModel(
        id: 'rec_python_ai',
        title: 'Python Thực Chiến: Từ Cơ Bản đến Machine Learning',
        instructorName: 'Đặng Tuấn Anh',
        categoryName: 'Trí Tuệ Nhân Tạo',
        level: 'Beginner',
        averageRating: 4.78,
        totalRatings: 110,
        totalStudents: 1400,
        totalLessons: 36,
        price: 0,
        isFree: true,
      ),
      CourseModel(
        id: 'rec_devops_docker',
        title: 'DevOps & Docker Container cho Developers',
        instructorName: 'Phạm Minh Đức',
        categoryName: 'DevOps & Cloud',
        level: 'Intermediate',
        averageRating: 4.88,
        totalRatings: 75,
        totalStudents: 520,
        totalLessons: 22,
        price: 0,
        isFree: true,
      ),
    ];
  }
}
