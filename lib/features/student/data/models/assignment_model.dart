import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

@freezed
abstract class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'class_name') String? className,
    String? difficulty,
    @JsonKey(name: 'time_limit') int? timeLimit,
    @JsonKey(name: 'memory_limit') int? memoryLimit,
    @Default([]) List<String> languages,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'max_submissions') int? maxSubmissions,
    @JsonKey(name: 'submission_count') @Default(0) int submissionCount,
    @JsonKey(name: 'best_score') double? bestScore,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}

@freezed
abstract class AssignmentSandboxModel with _$AssignmentSandboxModel {
  const factory AssignmentSandboxModel({
    required String id,
    required String title,
    String? description,
    String? difficulty,
    @JsonKey(name: 'time_limit') int? timeLimit,
    @JsonKey(name: 'memory_limit') int? memoryLimit,
    @Default([]) List<String> languages,
    @JsonKey(name: 'starter_code') Map<String, String>? starterCode,
    @JsonKey(name: 'sample_tests') @Default([]) List<SampleTestModel> sampleTests,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'max_submissions') int? maxSubmissions,
    @JsonKey(name: 'submission_count') @Default(0) int submissionCount,
  }) = _AssignmentSandboxModel;

  factory AssignmentSandboxModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentSandboxModelFromJson(json);
}

@freezed
abstract class SampleTestModel with _$SampleTestModel {
  const factory SampleTestModel({
    required String input,
    @JsonKey(name: 'expected_output') required String expectedOutput,
    String? explanation,
  }) = _SampleTestModel;

  factory SampleTestModel.fromJson(Map<String, dynamic> json) =>
      _$SampleTestModelFromJson(json);
}
