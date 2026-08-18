import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_goal_model.freezed.dart';
part 'daily_goal_model.g.dart';

@freezed
abstract class DailyGoalModel with _$DailyGoalModel {
  const factory DailyGoalModel({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    required DateTime date,
    DateTime? completedAt,
  }) = _DailyGoalModel;

  factory DailyGoalModel.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalModelFromJson(json);
}
