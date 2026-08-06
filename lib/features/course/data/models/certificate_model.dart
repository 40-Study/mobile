import 'package:freezed_annotation/freezed_annotation.dart';

part 'certificate_model.freezed.dart';
part 'certificate_model.g.dart';

@freezed
abstract class CertificateModel with _$CertificateModel {
  const factory CertificateModel({
    required String id,
    @JsonKey(name: 'certificate_number') String? certificateNumber,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'course_title') String? courseTitle,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @JsonKey(name: 'issue_date') DateTime? issueDate,
    @JsonKey(name: 'expiry_date') DateTime? expiryDate,
    @JsonKey(name: 'certificate_url') String? certificateUrl,
    @JsonKey(name: 'is_valid') @Default(true) bool isValid,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _CertificateModel;

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateModelFromJson(json);
}
