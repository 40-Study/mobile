import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
abstract class LocationModel with _$LocationModel {
  const factory LocationModel({
    required double latitude,
    required double longitude,
    String? cityName,
    @JsonKey(name: 'cached_at') int? cachedAt,
  }) = _LocationModel;

  const LocationModel._();

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  /// Default location: Hanoi
  factory LocationModel.hanoi() => LocationModel(
        latitude: 21.0285,
        longitude: 105.8542,
        cityName: 'Hanoi',
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );

  bool get isCacheValid {
    if (cachedAt == null) return false;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedAt!);
    return DateTime.now().difference(cachedTime).inMinutes < 15;
  }
}
