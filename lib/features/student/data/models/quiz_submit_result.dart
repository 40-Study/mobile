import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_submit_result.freezed.dart';
part 'quiz_submit_result.g.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

@freezed
abstract class QuizSubmitResult with _$QuizSubmitResult {
  const factory QuizSubmitResult({
    @Default('') String id,
    @JsonKey(fromJson: _parseDouble) @Default(0) double score,
    @JsonKey(name: 'total_points', fromJson: _parseDouble)
    @Default(0)
    double totalPoints,
    @JsonKey(fromJson: _parseDouble) @Default(0) double percentage,
    @JsonKey(name: 'is_passed') @Default(false) bool isPassed,
    @JsonKey(name: 'time_spent_seconds') @Default(0) int timeSpentSeconds,
  }) = _QuizSubmitResult;

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) =>
      _$QuizSubmitResultFromJson(json);
}
