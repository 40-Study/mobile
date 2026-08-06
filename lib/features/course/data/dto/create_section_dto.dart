class CreateSectionDto {
  const CreateSectionDto({
    required this.title,
    this.description,
    this.displayOrder,
  });

  final String title;
  final String? description;
  final int? displayOrder;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (displayOrder != null) 'display_order': displayOrder,
    };
  }
}
