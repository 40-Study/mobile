import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/course_model.dart';

/// Loại tiêu chí đề xuất (Match Type)
enum RecommendationMatchType {
  learningTrack,
  searchHistory,
  topRated,
  trending,
}

/// Model đóng gói khóa học kèm thông tin giải thích lý do đề xuất
class RecommendedCourseItem extends Equatable {
  const RecommendedCourseItem({
    required this.course,
    required this.reason,
    required this.score,
    required this.matchType,
  });

  final CourseModel course;
  final String reason;
  final double score;
  final RecommendationMatchType matchType;

  @override
  List<Object?> get props => [course, reason, score, matchType];
}
