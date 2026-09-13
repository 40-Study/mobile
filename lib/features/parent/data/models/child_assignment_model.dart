import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_assignment_model.freezed.dart';
part 'child_assignment_model.g.dart';

@freezed
abstract class ChildAssignmentModel with _$ChildAssignmentModel {
  const factory ChildAssignmentModel({
    required String id,
    required String title,
    String? courseName,
    DateTime? dueDate,
    @Default('pending') String status, // pending, submitted, graded
    double? score,
  }) = _ChildAssignmentModel;

  factory ChildAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentModelFromJson(json);
}
