import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

// Backend notification_type values
enum NotificationType {
  @JsonValue('course')
  course,
  @JsonValue('assignment')
  assignment,
  @JsonValue('livestream')
  livestream,
  @JsonValue('system')
  system,
  @JsonValue('achievement')
  achievement,
  @JsonValue('reminder')
  reminder,
  @JsonValue('payment')
  payment,
  @JsonValue('enrollment')
  enrollment,
  unknown, // Fallback cho type mới từ backend
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    @JsonKey(name: 'content') required String body, // Backend gửi content
    @JsonKey(name: 'notification_type', unknownEnumValue: NotificationType.unknown)
    required NotificationType type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'reference_type') String? referenceType, // Thay action_url
    @JsonKey(name: 'reference_id') String? referenceId,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
