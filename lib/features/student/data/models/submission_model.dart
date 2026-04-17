import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_model.freezed.dart';
part 'submission_model.g.dart';

@freezed
abstract class SubmissionModel with _$SubmissionModel {
  const factory SubmissionModel({
    required String id,
    @JsonKey(name: 'assignment_id') required String assignmentId,
    @JsonKey(name: 'user_id') String? userId,
    required String language,
    String? code,
    String? status,
    double? score,
    @JsonKey(name: 'execution_time') int? executionTime,
    @JsonKey(name: 'memory_used') int? memoryUsed,
    @JsonKey(name: 'test_results') @Default([]) List<TestResultModel> testResults,
    @JsonKey(name: 'passed_tests') @Default(0) int passedTests,
    @JsonKey(name: 'total_tests') @Default(0) int totalTests,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _SubmissionModel;

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionModelFromJson(json);
}

@freezed
abstract class TestResultModel with _$TestResultModel {
  const factory TestResultModel({
    @JsonKey(name: 'test_case') int? testCase,
    String? status,
    @JsonKey(name: 'execution_time') int? executionTime,
    @JsonKey(name: 'memory_used') int? memoryUsed,
    String? input,
    @JsonKey(name: 'expected_output') String? expectedOutput,
    @JsonKey(name: 'actual_output') String? actualOutput,
    String? error,
  }) = _TestResultModel;

  factory TestResultModel.fromJson(Map<String, dynamic> json) =>
      _$TestResultModelFromJson(json);
}

@freezed
abstract class RunCodeResultModel with _$RunCodeResultModel {
  const factory RunCodeResultModel({
    String? status,
    @JsonKey(name: 'execution_time') int? executionTime,
    @JsonKey(name: 'memory_used') int? memoryUsed,
    @JsonKey(name: 'test_results') @Default([]) List<TestResultModel> testResults,
    @JsonKey(name: 'passed_tests') @Default(0) int passedTests,
    @JsonKey(name: 'total_tests') @Default(0) int totalTests,
    String? output,
    String? error,
  }) = _RunCodeResultModel;

  factory RunCodeResultModel.fromJson(Map<String, dynamic> json) =>
      _$RunCodeResultModelFromJson(json);
}
