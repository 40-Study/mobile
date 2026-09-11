import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_alert_model.freezed.dart';
part 'parent_alert_model.g.dart';

enum AlertSeverity { critical, warning, info }
enum AlertType { missedClass, lowScore, courseExpiring, completed }

@freezed
abstract class ParentAlertModel with _$ParentAlertModel {
  const factory ParentAlertModel({
    required String id,
    required AlertType type,
    required AlertSeverity severity,
    required String childId,
    required String childName,
    required String message,
    String? relatedId,
    required DateTime createdAt,
  }) = _ParentAlertModel;

  factory ParentAlertModel.fromJson(Map<String, dynamic> json) =>
      _$ParentAlertModelFromJson(json);
}
