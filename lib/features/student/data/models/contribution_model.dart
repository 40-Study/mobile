import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_model.freezed.dart';
part 'contribution_model.g.dart';

@freezed
abstract class ContributionModel with _$ContributionModel {
  const factory ContributionModel({
    required String date,
    @Default(0) int count,
  }) = _ContributionModel;

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);
}
