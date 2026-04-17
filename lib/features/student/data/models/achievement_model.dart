import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
abstract class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    String? category,
    @JsonKey(name: 'points_reward') @Default(0) int pointsReward,
    @JsonKey(name: 'requirement_type') String? requirementType,
    @JsonKey(name: 'requirement_value') int? requirementValue,
    @JsonKey(name: 'is_unlocked') @Default(false) bool isUnlocked,
    @JsonKey(name: 'unlocked_at') String? unlockedAt,
    double? progress,
    @JsonKey(name: 'current_value') int? currentValue,
    String? rarity,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}
