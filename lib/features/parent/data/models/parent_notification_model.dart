import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_notification_model.freezed.dart';
part 'parent_notification_model.g.dart';

@JsonEnum()
enum NotificationType {
  @JsonValue('attendance')
  attendance,
  @JsonValue('assignment')
  assignment,
  @JsonValue('finance')
  finance,
  @JsonValue('performance')
  performance,
  @JsonValue('live_class')
  liveClass,
  @JsonValue('general')
  general,
}

@freezed
abstract class ParentNotificationModel with _$ParentNotificationModel {
  const factory ParentNotificationModel({
    required String id,
    required String title,
    String? subtitle,
    @Default(NotificationType.general) NotificationType type,
    @JsonKey(name: 'child_id') String? childId,
    @JsonKey(name: 'child_name') String? childName,
    @JsonKey(name: 'created_at') String? createdAt,
    @Default(false) bool isRead,
  }) = _ParentNotificationModel;

  factory ParentNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$ParentNotificationModelFromJson(json);
}
