import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_notification_model.freezed.dart';
part 'teacher_notification_model.g.dart';

enum NotificationType { assignment, finance, system, course }

@freezed
abstract class TeacherNotificationModel with _$TeacherNotificationModel {
  const factory TeacherNotificationModel({
    required String id,
    required String title,
    String? subtitle,
    @JsonKey(name: 'notification_type') @Default('system') String type,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
  }) = _TeacherNotificationModel;

  factory TeacherNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherNotificationModelFromJson(json);
}
