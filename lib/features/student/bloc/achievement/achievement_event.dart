import 'package:equatable/equatable.dart';

enum AchievementTab { badges, certificates, stats }

sealed class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

final class AchievementStarted extends AchievementEvent {
  const AchievementStarted();
}

final class AchievementTabChanged extends AchievementEvent {
  const AchievementTabChanged(this.tab);

  final AchievementTab tab;

  @override
  List<Object?> get props => [tab];
}
