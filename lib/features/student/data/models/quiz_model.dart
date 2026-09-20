import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/core/utils/json_converters.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
abstract class QuizModel with _$QuizModel {
  const factory QuizModel({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'lesson_id') String? lessonId,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'time_limit_minutes') int? timeLimitMinutes,
    @JsonKey(name: 'pass_percentage') @StringToDoubleConverter() double? passPercentage,
    @JsonKey(name: 'question_count') @Default(0) int questionCount,
    @JsonKey(name: 'trigger_type') @Default('manual') String triggerType,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}
