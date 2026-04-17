import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit({required StudentRepository repository})
      : _repository = repository,
        super(const LeaderboardInitial());

  final StudentRepository _repository;

  Future<void> loadLeaderboard({String periodType = 'weekly'}) async {
    emit(const LeaderboardLoading());

    try {
      final results = await Future.wait([
        _repository.getLeaderboard(periodType: periodType),
        _repository.getMyRank(),
      ]);

      final leaderboard = results[0] as LeaderboardModel;
      final myRank = results[1] as LeaderboardEntryModel;

      emit(LeaderboardLoaded(
        leaderboard: leaderboard,
        myRank: myRank,
        selectedPeriod: periodType,
      ));
    } catch (e) {
      debugPrint('loadLeaderboard error: $e');
      emit(LeaderboardFailure(message: e.toString()));
    }
  }

  Future<void> changePeriod(String periodType) async {
    await loadLeaderboard(periodType: periodType);
  }

  Future<void> refresh() async {
    final currentState = state;
    final period = currentState is LeaderboardLoaded
        ? currentState.selectedPeriod
        : 'weekly';
    await loadLeaderboard(periodType: period);
  }
}
