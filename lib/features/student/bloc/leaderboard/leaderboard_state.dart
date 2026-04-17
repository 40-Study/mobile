part of 'leaderboard_cubit.dart';

@immutable
sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({
    required this.leaderboard,
    required this.myRank,
    required this.selectedPeriod,
  });

  final LeaderboardModel leaderboard;
  final LeaderboardEntryModel myRank;
  final String selectedPeriod;

  @override
  List<Object?> get props => [leaderboard, myRank, selectedPeriod];
}

final class LeaderboardFailure extends LeaderboardState {
  const LeaderboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
