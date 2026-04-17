import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationListModel with _$NotificationListModel {
  const factory NotificationListModel({
    @Default([]) List<NotificationItemModel> notifications,
    @Default(0) int total,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
  }) = _NotificationListModel;

  factory NotificationListModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationListModelFromJson(json);
}

@freezed
abstract class NotificationItemModel with _$NotificationItemModel {
  const factory NotificationItemModel({
    required String id,
    required String title,
    String? body,
    String? type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'action_type') String? actionType,
    @JsonKey(name: 'reference_id') String? referenceId,
    Map<String, dynamic>? data,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'read_at') String? readAt,
  }) = _NotificationItemModel;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemModelFromJson(json);
}
