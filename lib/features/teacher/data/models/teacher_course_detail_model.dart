import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/class_model.dart';

@immutable
class TeacherCourseDetailModel {
  const TeacherCourseDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.badge,
    this.status = 'draft',
    this.categoryName,
    this.price = 0,
    this.originalPrice,
    this.discountPercent = 0,
    this.isOnSale = false,
    this.studentCount = 0,
    this.classCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.progressPercent = 0,
    this.totalLessons = 0,
    this.publishedLessons = 0,
    this.totalRevenue = 0,
    this.monthlyRevenue = 0,
    this.learningOutcomes = const [],
    this.chapters = const [],
    this.classes = const [],
    this.recentReviews = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String? badge;
  final String status;
  final String? categoryName;
  final double price;
  final double? originalPrice;
  final int discountPercent;
  final bool isOnSale;
  final int studentCount;
  final int classCount;
  final double rating;
  final int reviewCount;
  final int progressPercent;
  final int totalLessons;
  final int publishedLessons;
  final double totalRevenue;
  final double monthlyRevenue;
  final List<String> learningOutcomes;
  final List<TeacherChapterModel> chapters;
  final List<ClassModel> classes;
  final List<CourseReviewModel> recentReviews;
  final String? createdAt;
  final String? updatedAt;

  bool get isPublished => status.toLowerCase() == 'published';
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isArchived => status.toLowerCase() == 'archived';

  String get statusLabel => switch (status.toLowerCase()) {
        'published' => 'Xuất bản',
        'draft' => 'Bản nháp',
        'archived' => 'Lưu trữ',
        _ => 'Bản nháp',
      };
}

@immutable
class TeacherChapterModel {
  const TeacherChapterModel({
    required this.id,
    required this.title,
    this.order = 0,
    this.totalLessons = 0,
    this.publishedLessons = 0,
    this.lessons = const [],
  });

  final String id;
  final String title;
  final int order;
  final int totalLessons;
  final int publishedLessons;
  final List<TeacherLessonModel> lessons;

  bool get isAllPublished =>
      totalLessons > 0 && publishedLessons >= totalLessons;
}

enum TeacherLessonStatus { published, draft, processing }

@immutable
class TeacherLessonModel {
  const TeacherLessonModel({
    required this.id,
    required this.title,
    this.duration,
    this.status = TeacherLessonStatus.draft,
    this.order = 0,
    this.type = 'video',
    this.viewCount = 0,
  });

  final String id;
  final String title;
  final String? duration;
  final TeacherLessonStatus status;
  final int order;
  final String type;
  final int viewCount;

  bool get isPublished => status == TeacherLessonStatus.published;
}

@immutable
class CourseReviewModel {
  const CourseReviewModel({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String studentName;
  final String? studentAvatar;
  final int rating;
  final String? comment;
  final String? createdAt;
}
