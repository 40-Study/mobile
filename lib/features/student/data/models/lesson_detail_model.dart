import 'package:flutter/foundation.dart';

@immutable
class LessonDetailModel {
  const LessonDetailModel({
    required this.id,
    required this.title,
    this.chapterTitle,
    this.instructorName,
    this.instructorTitle,
    this.instructorAvatar,
    this.level,
    this.duration,
    this.currentTime,
    this.viewCount = 0,
    this.description,
    this.objectives = const [],
    this.contentSections = const [],
    this.materials = const [],
    this.homework,
    this.quizAttempts = const [],
    this.hasQuiz = false,
  });

  final String id;
  final String title;
  final String? chapterTitle;
  final String? instructorName;
  final String? instructorTitle;
  final String? instructorAvatar;
  final String? level;
  final String? duration;
  final String? currentTime;
  final int viewCount;
  final String? description;
  final List<LessonObjective> objectives;
  final List<LessonContentSection> contentSections;
  final List<LessonMaterial> materials;
  final HomeworkModel? homework;
  final List<QuizAttempt> quizAttempts;
  final bool hasQuiz;
}

@immutable
class LessonObjective {
  const LessonObjective({
    required this.id,
    required this.title,
    this.icon,
  });

  final String id;
  final String title;
  final String? icon;
}

@immutable
class LessonContentSection {
  const LessonContentSection({
    required this.id,
    required this.order,
    required this.title,
    this.subtitle,
  });

  final String id;
  final int order;
  final String title;
  final String? subtitle;
}

enum LessonMaterialType { pdf, zip, image, video, slide }

@immutable
class LessonMaterial {
  const LessonMaterial({
    required this.id,
    required this.title,
    required this.type,
    this.size,
    this.description,
  });

  final String id;
  final String title;
  final LessonMaterialType type;
  final String? size;
  final String? description;
}

@immutable
class HomeworkModel {
  const HomeworkModel({
    required this.id,
    required this.title,
    this.deadline,
    this.description,
    this.requirements = const [],
    this.note,
    this.attachments = const [],
    this.isSubmitted = false,
  });

  final String id;
  final String title;
  final String? deadline;
  final String? description;
  final List<String> requirements;
  final String? note;
  final List<LessonMaterial> attachments;
  final bool isSubmitted;
}

enum QuizStatus { completed, saved }

@immutable
class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.attemptNumber,
    required this.score,
    required this.totalScore,
    this.date,
    this.status = QuizStatus.completed,
  });

  final String id;
  final int attemptNumber;
  final int score;
  final int totalScore;
  final String? date;
  final QuizStatus status;
}
