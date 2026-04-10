import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_model.freezed.dart';
part 'portfolio_model.g.dart';

@freezed
abstract class PortfolioModel with _$PortfolioModel {
  const factory PortfolioModel({
    @JsonKey(name: 'child_id') required String childId,
    @JsonKey(name: 'child_name') required String childName,
    @Default([]) List<PortfolioItemModel> items,
    @JsonKey(name: 'total_items') @Default(0) int totalItems,
    @JsonKey(name: 'highlighted_count') @Default(0) int highlightedCount,
  }) = _PortfolioModel;

  factory PortfolioModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioModelFromJson(json);
}

@freezed
abstract class PortfolioItemModel with _$PortfolioItemModel {
  const factory PortfolioItemModel({
    required String id,
    required String title,
    required PortfolioItemType type,
    double? score,
    @JsonKey(name: 'max_score') double? maxScore,
    @JsonKey(name: 'teacher_feedback') String? teacherFeedback,
    @JsonKey(name: 'class_name') String? className,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'attachment_urls') @Default([]) List<String> attachmentUrls,
    @JsonKey(name: 'is_highlighted') @Default(false) bool isHighlighted,
    String? description,
  }) = _PortfolioItemModel;

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemModelFromJson(json);
}

@JsonEnum()
enum PortfolioItemType {
  @JsonValue('assignment')
  assignment,
  @JsonValue('project')
  project,
  @JsonValue('test')
  test,
  @JsonValue('certificate')
  certificate,
  @JsonValue('achievement')
  achievement,
}

extension PortfolioItemTypeExtension on PortfolioItemType {
  String get displayName {
    switch (this) {
      case PortfolioItemType.assignment:
        return 'Bài tập';
      case PortfolioItemType.project:
        return 'Dự án';
      case PortfolioItemType.test:
        return 'Bài kiểm tra';
      case PortfolioItemType.certificate:
        return 'Chứng chỉ';
      case PortfolioItemType.achievement:
        return 'Thành tích';
    }
  }
}
