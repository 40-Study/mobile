part of 'achievement_cubit.dart';

@immutable
sealed class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

final class AchievementInitial extends AchievementState {
  const AchievementInitial();
}

final class AchievementLoading extends AchievementState {
  const AchievementLoading();
}

final class AchievementLoaded extends AchievementState {
  const AchievementLoaded({
    required this.allAchievements,
    required this.myAchievements,
    required this.unlockedCount,
    required this.totalCount,
  });

  final List<AchievementModel> allAchievements;
  final List<AchievementModel> myAchievements;
  final int unlockedCount;
  final int totalCount;

  @override
  List<Object?> get props => [
        allAchievements,
        myAchievements,
        unlockedCount,
        totalCount,
      ];
}

final class AchievementFailure extends AchievementState {
  const AchievementFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
