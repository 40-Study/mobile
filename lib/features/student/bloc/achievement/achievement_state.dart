import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/models.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

final class AchievementInitial extends AchievementState {
  const AchievementInitial();
}

final class AchievementInProgress extends AchievementState {
  const AchievementInProgress();
}

final class AchievementSuccess extends AchievementState {
  const AchievementSuccess({
    required this.stats,
    this.badges = const [],
    this.certificates = const [],
    this.contributions = const [],
    this.selectedTab = AchievementTab.badges,
  });

  final StudentStatsModel stats;
  final List<BadgeModel> badges;
  final List<CertificateModel> certificates;
  final List<ContributionModel> contributions;
  final AchievementTab selectedTab;

  List<BadgeModel> get earnedBadges => badges.where((b) => b.isEarned).toList();
  List<BadgeModel> get lockedBadges => badges.where((b) => !b.isEarned).toList();

  @override
  List<Object?> get props => [stats, badges, certificates, contributions, selectedTab];

  AchievementSuccess copyWith({
    StudentStatsModel? stats,
    List<BadgeModel>? badges,
    List<CertificateModel>? certificates,
    List<ContributionModel>? contributions,
    AchievementTab? selectedTab,
  }) {
    return AchievementSuccess(
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
      certificates: certificates ?? this.certificates,
      contributions: contributions ?? this.contributions,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

final class AchievementFailure extends AchievementState {
  const AchievementFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
