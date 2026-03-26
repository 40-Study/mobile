import 'package:flutter/foundation.dart';

@immutable
class CourseDetailModel {
  const CourseDetailModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.badge,
    this.instructorName,
    this.instructorAvatar,
    this.instructorTitle,
    this.instructorBio,
    this.instructorStudentCount = 0,
    this.instructorRating = 0,
    this.instructorReviewCount = 0,
    this.description,
    this.progress = 0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.learningOutcomes = const [],
    this.chapters = const [],
    this.documents = const [],
    this.discussions = const [],
    this.totalStudents = 0,
  });

  final String id;
  final String title;
  final String? thumbnail;
  final String? badge;
  final String? instructorName;
  final String? instructorAvatar;
  final String? instructorTitle;
  final String? instructorBio;
  final int instructorStudentCount;
  final double instructorRating;
  final int instructorReviewCount;
  final String? description;
  final int progress;
  final int totalLessons;
  final int completedLessons;
  final List<String> learningOutcomes;
  final List<ChapterModel> chapters;
  final List<DocumentModel> documents;
  final List<DiscussionModel> discussions;
  final int totalStudents;

  LessonModel? get currentLesson {
    for (final chapter in chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.status == LessonStatus.inProgress) return lesson;
      }
    }
    for (final chapter in chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.status == LessonStatus.locked) return lesson;
      }
    }
    return null;
  }
}

enum LessonStatus { completed, inProgress, locked }

@immutable
class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.title,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.status,
    this.lessons = const [],
  });

  final String id;
  final String title;
  final int totalLessons;
  final int completedLessons;
  final String? status;
  final List<LessonModel> lessons;

  bool get isAllCompleted =>
      totalLessons > 0 && completedLessons >= totalLessons;
}

@immutable
class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    this.duration,
    this.status = LessonStatus.locked,
    this.currentTime,
    this.totalTime,
  });

  final String id;
  final String title;
  final String? duration;
  final LessonStatus status;
  final String? currentTime;
  final String? totalTime;
}

enum DocumentType { pdf, pptx, video, zip, epub }

@immutable
class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    this.size,
    this.updatedAt,
    this.isGift = false,
  });

  final String id;
  final String title;
  final DocumentType type;
  final String? size;
  final String? updatedAt;
  final bool isGift;
}

@immutable
class DiscussionModel {
  const DiscussionModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    this.role = DiscussionRole.student,
    required this.content,
    this.timeAgo,
    this.likes = 0,
    this.replyCount = 0,
    this.replies = const [],
  });

  final String id;
  final String authorName;
  final String? authorAvatar;
  final DiscussionRole role;
  final String content;
  final String? timeAgo;
  final int likes;
  final int replyCount;
  final List<DiscussionModel> replies;
}

enum DiscussionRole { student, instructor }
