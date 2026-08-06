class CreateReviewDto {
  const CreateReviewDto({
    required this.rating,
    this.comment,
  });

  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (comment != null) 'comment': comment,
    };
  }
}
