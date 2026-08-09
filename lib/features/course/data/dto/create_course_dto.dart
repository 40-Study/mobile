class CreateCourseDto {
  const CreateCourseDto({
    required this.title,
    this.instructorId,
    this.categoryId,
    this.shortDescription,
    this.description,
    this.thumbnailUrl,
    this.previewVideoUrl,
    this.level,
    this.language,
    this.price,
    this.discountPrice,
    this.discountExpiresAt,
    this.requirements,
    this.objectives,
    this.targetAudience,
    this.isFree,
    this.tagIds,
  });

  final String title;
  final String? instructorId;
  final String? categoryId;
  final String? shortDescription;
  final String? description;
  final String? thumbnailUrl;
  final String? previewVideoUrl;
  final String? level;
  final String? language;
  final double? price;
  final double? discountPrice;
  final DateTime? discountExpiresAt;
  final List<String>? requirements;
  final List<String>? objectives;
  final List<String>? targetAudience;
  final bool? isFree;
  final List<String>? tagIds;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (instructorId != null) 'instructor_id': instructorId,
      if (categoryId != null) 'category_id': categoryId,
      if (shortDescription != null) 'short_description': shortDescription,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (previewVideoUrl != null) 'preview_video_url': previewVideoUrl,
      if (level != null) 'level': level,
      if (language != null) 'language': language,
      if (price != null) 'price': price,
      if (discountPrice != null) 'discount_price': discountPrice,
      if (discountExpiresAt != null)
        'discount_expires_at': discountExpiresAt!.toIso8601String(),
      if (requirements != null) 'requirements': requirements,
      if (objectives != null) 'objectives': objectives,
      if (targetAudience != null) 'target_audience': targetAudience,
      if (isFree != null) 'is_free': isFree,
      if (tagIds != null) 'tag_ids': tagIds,
    };
  }
}
