class CreateLessonDto {
  const CreateLessonDto({
    required this.title,
    this.description,
    this.displayOrder,
    this.durationMinutes,
    this.isPreview,
    this.isMandatory,
  });

  final String title;
  final String? description;
  final int? displayOrder;
  final int? durationMinutes;
  final bool? isPreview;
  final bool? isMandatory;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (displayOrder != null) 'display_order': displayOrder,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (isPreview != null) 'is_preview': isPreview,
      if (isMandatory != null) 'is_mandatory': isMandatory,
    };
  }
}
