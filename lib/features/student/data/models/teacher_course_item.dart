import 'package:flutter/foundation.dart';

@immutable
class TeacherCourseItem {
  const TeacherCourseItem({
    required this.id,
    required this.title,
    this.thumbnail,
    this.duration,
    this.price,
    this.rating = 0.0,
  });

  final String id;
  final String title;
  final String? thumbnail;
  final String? duration;
  final String? price;
  final double rating;
}
