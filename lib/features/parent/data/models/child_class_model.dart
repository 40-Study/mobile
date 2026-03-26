import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_class_model.freezed.dart';
part 'child_class_model.g.dart';

@freezed
abstract class ChildClassModel with _$ChildClassModel {
  const factory ChildClassModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'max_students') @Default(0) int maxStudents,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @Default('active') String status,
  }) = _ChildClassModel;

  factory ChildClassModel.fromJson(Map<String, dynamic> json) =>
      _$ChildClassModelFromJson(json);
}
