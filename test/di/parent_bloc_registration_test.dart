import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/di/di_initializer.config.dart';
import 'package:study/features/parent/bloc/home/parent_home_bloc.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';

class _HomeRepository extends Mock implements ParentHomeRepository {}

class _ScheduleRepository extends Mock implements ParentScheduleRepository {}

class _LearningRepository extends Mock implements ParentLearningRepository {}

void main() {
  test('production DI creates fresh blocs for each parent shell', () async {
    final container = GetIt.asNewInstance()..init();
    addTearDown(container.reset);

    // Keep production bloc registrations, replacing only API dependencies.
    await container.unregister<ParentHomeRepository>();
    await container.unregister<ParentScheduleRepository>();
    await container.unregister<ParentLearningRepository>();
    container
      ..registerSingleton<ParentHomeRepository>(_HomeRepository())
      ..registerSingleton<ParentScheduleRepository>(_ScheduleRepository())
      ..registerSingleton<ParentLearningRepository>(_LearningRepository());

    final first = [
      container<ParentHomeBloc>(),
      container<ParentScheduleBloc>(),
      container<ParentLearningBloc>(),
    ];
    final second = [
      container<ParentHomeBloc>(),
      container<ParentScheduleBloc>(),
      container<ParentLearningBloc>(),
    ];
    for (final bloc in [...first, ...second]) {
      addTearDown(bloc.close);
    }
    for (var i = 0; i < first.length; i++) {
      expect(identical(first[i], second[i]), isFalse);
    }
  });
}
