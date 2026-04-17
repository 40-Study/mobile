import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'achievement_state.dart';

class AchievementCubit extends Cubit<AchievementState> {
  AchievementCubit({required StudentRepository repository})
      : _repository = repository,
        super(const AchievementInitial());

  final StudentRepository _repository;

  Future<void> loadAchievements() async {
    emit(const AchievementLoading());

    try {
      final results = await Future.wait([
        _repository.getAchievements(),
        _repository.getMyAchievements(),
      ]);

      final allAchievements = results[0] as List<AchievementModel>;
      final myAchievements = results[1] as List<AchievementModel>;

      emit(AchievementLoaded(
        allAchievements: allAchievements,
        myAchievements: myAchievements,
        unlockedCount: myAchievements.length,
        totalCount: allAchievements.length,
      ));
    } catch (e) {
      debugPrint('loadAchievements error: $e');
      emit(AchievementFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadAchievements();
  }
}
