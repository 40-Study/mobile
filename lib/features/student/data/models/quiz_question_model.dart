import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_question_model.freezed.dart';
part 'quiz_question_model.g.dart';

@freezed
abstract class QuizAnswerModel with _$QuizAnswerModel {
  const factory QuizAnswerModel({
    @Default('') String id,
    @JsonKey(name: 'answer_text') @Default('') String answerText,
    @JsonKey(name: 'is_correct') @Default(false) bool isCorrect,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
  }) = _QuizAnswerModel;

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerModelFromJson(json);
}

@freezed
abstract class QuizQuestionModel with _$QuizQuestionModel {
  const QuizQuestionModel._();

  const factory QuizQuestionModel({
    @Default('') String id,
    @JsonKey(name: 'question_text') @Default('') String question,
    @JsonKey(name: 'question_type') @Default('single_choice') String questionType,
    String? explanation,
    @Default([]) List<QuizAnswerModel> answers,
  }) = _QuizQuestionModel;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);

  /// Lấy list options text cho UI
  List<String> get options => answers.map((a) => a.answerText).toList();

  /// Lấy index đáp án đúng
  int get correctAnswer => answers.indexWhere((a) => a.isCorrect);
}
