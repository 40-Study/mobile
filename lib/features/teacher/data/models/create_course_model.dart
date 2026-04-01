import 'package:equatable/equatable.dart';

class CreateCourseModel extends Equatable {
  const CreateCourseModel({
    this.name = '',
    this.teachingFormat = TeachingFormat.hybrid,
    this.categoryId,
    this.level = CourseLevel.all,
    this.shortDescription = '',
    this.thumbnailUrl,
    this.fullDescription = '',
    this.price = 0,
    this.discountPrice,
    this.isFree = false,
  });

  final String name;
  final TeachingFormat teachingFormat;
  final String? categoryId;
  final CourseLevel level;
  final String shortDescription;
  final String? thumbnailUrl;
  final String fullDescription;
  final double price;
  final double? discountPrice;
  final bool isFree;

  CreateCourseModel copyWith({
    String? name,
    TeachingFormat? teachingFormat,
    String? categoryId,
    CourseLevel? level,
    String? shortDescription,
    String? thumbnailUrl,
    String? fullDescription,
    double? price,
    double? discountPrice,
    bool? isFree,
  }) {
    return CreateCourseModel(
      name: name ?? this.name,
      teachingFormat: teachingFormat ?? this.teachingFormat,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fullDescription: fullDescription ?? this.fullDescription,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      isFree: isFree ?? this.isFree,
    );
  }

  @override
  List<Object?> get props => [
        name,
        teachingFormat,
        categoryId,
        level,
        shortDescription,
        thumbnailUrl,
        fullDescription,
        price,
        discountPrice,
        isFree,
      ];
}

enum TeachingFormat {
  video,
  livestream,
  hybrid,
}

extension TeachingFormatX on TeachingFormat {
  String get label {
    return switch (this) {
      TeachingFormat.video => 'Video Quay Sẵn',
      TeachingFormat.livestream => 'Livestream',
      TeachingFormat.hybrid => 'Hybrid (Kết hợp)',
    };
  }

  String get description {
    return switch (this) {
      TeachingFormat.video => 'Học qua video bài giảng',
      TeachingFormat.livestream => 'Học trực tiếp qua Zoom/Meet',
      TeachingFormat.hybrid => 'Video & Buổi học trực tiếp',
    };
  }
}

enum CourseLevel {
  all,
  beginner,
  intermediate,
  advanced,
}

extension CourseLevelX on CourseLevel {
  String get label {
    return switch (this) {
      CourseLevel.all => 'Tất cả trình độ',
      CourseLevel.beginner => 'Người mới bắt đầu',
      CourseLevel.intermediate => 'Trung cấp',
      CourseLevel.advanced => 'Nâng cao',
    };
  }
}

class CourseCategoryModel extends Equatable {
  const CourseCategoryModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
