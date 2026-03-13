import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_context_model.freezed.dart';
part 'entry_context_model.g.dart';

@freezed
abstract class EntryContextModel with _$EntryContextModel {
  const factory EntryContextModel({
    @JsonKey(name: 'primary_role') required String primaryRole,
    @JsonKey(name: 'requires_setup') @Default(false) bool requiresSetup,
    @JsonKey(name: 'setup_endpoint') @Default('') String setupEndpoint,
  }) = _EntryContextModel;

  factory EntryContextModel.fromJson(Map<String, dynamic> json) =>
      _$EntryContextModelFromJson(json);
}
