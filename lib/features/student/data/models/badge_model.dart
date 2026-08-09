import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

@freezed
abstract class BadgeModel with _$BadgeModel {
  const factory BadgeModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'is_earned') @Default(false) bool isEarned,
    @JsonKey(name: 'earned_at') DateTime? earnedAt,
    String? category,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);
}
