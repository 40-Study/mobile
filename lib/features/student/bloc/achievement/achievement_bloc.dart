import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc(this._repository, this._authRepository)
      : super(const AchievementInitial()) {
    on<AchievementStarted>(_onStarted);
    on<AchievementTabChanged>(_onTabChanged);
  }

  final StudentRepository _repository;
  final AuthRepository _authRepository;

  Future<void> _onStarted(
    AchievementStarted event,
    Emitter<AchievementState> emit,
  ) async {
    emit(const AchievementInProgress());

    // Get userId for contributions
    final user = await _authRepository.getSavedUser();
    final userId = user?.id;

    final (stats, badges, certificates) = await (
      _repository.getStats(),
      _repository.getBadges(),
      _repository.getCertificates(),
    ).wait;

    if (stats.isFailure) {
      emit(AchievementFailure(stats.errorOrNull?.message ?? 'Loi'));
      return;
    }

    // Fetch contributions if userId available
    final contributions = userId != null
        ? (await _repository.getContributions(userId)).valueOrNull ?? []
        : <ContributionModel>[];

    emit(AchievementSuccess(
      stats: stats.valueOrNull ?? const StudentStatsModel(),
      badges: badges.valueOrNull ?? [],
      certificates: certificates.valueOrNull ?? [],
      contributions: contributions,
    ));
  }

  void _onTabChanged(
    AchievementTabChanged event,
    Emitter<AchievementState> emit,
  ) {
    final currentState = state;
    if (currentState is AchievementSuccess) {
      emit(currentState.copyWith(selectedTab: event.tab));
    }
  }
}
