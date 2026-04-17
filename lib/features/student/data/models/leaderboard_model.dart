import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

@freezed
abstract class LeaderboardModel with _$LeaderboardModel {
  const factory LeaderboardModel({
    @JsonKey(name: 'period_type') String? periodType,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @Default([]) List<LeaderboardEntryModel> entries,
    @JsonKey(name: 'my_rank') LeaderboardEntryModel? myRank,
    @JsonKey(name: 'total_participants') @Default(0) int totalParticipants,
  }) = _LeaderboardModel;

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardModelFromJson(json);
}

@freezed
abstract class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default(0) int rank,
    @Default(0) int points,
    @JsonKey(name: 'courses_completed') @Default(0) int coursesCompleted,
    @JsonKey(name: 'lessons_completed') @Default(0) int lessonsCompleted,
    @JsonKey(name: 'assignments_completed') @Default(0) int assignmentsCompleted,
    @JsonKey(name: 'streak_days') @Default(0) int streakDays,
    @JsonKey(name: 'rank_change') int? rankChange,
  }) = _LeaderboardEntryModel;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);
}
