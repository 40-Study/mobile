import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_model.freezed.dart';
part 'bookmark_model.g.dart';

enum BookmarkType { course, lesson, document }

@freezed
abstract class BookmarkModel with _$BookmarkModel {
  const factory BookmarkModel({
    required String id,
    required String itemId,
    required BookmarkType type,
    required String title,
    String? thumbnail,
    String? subtitle,
    @JsonKey(name: 'saved_at') required DateTime savedAt,
  }) = _BookmarkModel;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);
}
