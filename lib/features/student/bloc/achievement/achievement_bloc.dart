import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc(this._repository) : super(const AchievementInitial()) {
    on<AchievementStarted>(_onStarted);
    on<AchievementTabChanged>(_onTabChanged);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    AchievementStarted event,
    Emitter<AchievementState> emit,
  ) async {
    emit(const AchievementInProgress());

    final (stats, badges) = await (
      _repository.getStats(),
      _repository.getBadges(),
    ).wait;

    if (stats.isFailure) {
      emit(AchievementFailure(stats.errorOrNull?.message ?? 'Loi'));
      return;
    }

    emit(AchievementSuccess(
      stats: stats.valueOrNull ?? const StudentStatsModel(),
      badges: badges.valueOrNull ?? [],
      certificates: [], // TODO: Load from API
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
