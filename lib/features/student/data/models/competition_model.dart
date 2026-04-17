import 'package:freezed_annotation/freezed_annotation.dart';

part 'competition_model.freezed.dart';
part 'competition_model.g.dart';

enum CompetitionStatus { upcoming, ongoing, ended }

@freezed
abstract class CompetitionModel with _$CompetitionModel {
  const factory CompetitionModel({
    required String id,
    required String title,
    String? description,
    String? thumbnail,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    String? status,
    @JsonKey(name: 'participant_count') @Default(0) int participantCount,
    @JsonKey(name: 'max_participants') int? maxParticipants,
    @JsonKey(name: 'prize_pool') String? prizePool,
    @Default([]) List<String> prizes,
    String? difficulty,
    @JsonKey(name: 'is_joined') @Default(false) bool isJoined,
    @JsonKey(name: 'my_rank') int? myRank,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _CompetitionModel;

  factory CompetitionModel.fromJson(Map<String, dynamic> json) =>
      _$CompetitionModelFromJson(json);
}

extension CompetitionModelX on CompetitionModel {
  CompetitionStatus get statusEnum {
    final now = DateTime.now();
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);

    if (start != null && now.isBefore(start)) {
      return CompetitionStatus.upcoming;
    }
    if (end != null && now.isAfter(end)) {
      return CompetitionStatus.ended;
    }
    return CompetitionStatus.ongoing;
  }

  bool get isUpcoming => statusEnum == CompetitionStatus.upcoming;
  bool get isOngoing => statusEnum == CompetitionStatus.ongoing;
  bool get isEnded => statusEnum == CompetitionStatus.ended;

  String get participantDisplay {
    if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}K';
    }
    return '$participantCount';
  }

  int? get daysUntilStart {
    final start = DateTime.tryParse(startDate);
    if (start == null) return null;
    return start.difference(DateTime.now()).inDays;
  }

  int? get daysUntilEnd {
    final end = DateTime.tryParse(endDate);
    if (end == null) return null;
    return end.difference(DateTime.now()).inDays;
  }

  String get timeDisplay {
    if (isUpcoming) {
      final days = daysUntilStart;
      if (days != null && days > 0) return 'Bat dau sau $days ngay';
      return 'Sap bat dau';
    }
    if (isOngoing) {
      final days = daysUntilEnd;
      if (days != null && days > 0) return 'Con $days ngay';
      return 'Sap ket thuc';
    }
    return 'Da ket thuc';
  }
}
