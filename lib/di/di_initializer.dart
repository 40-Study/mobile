import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/di/di_initializer.config.dart';

@injectableInit
Future<GetIt> initDI(GetIt getIt, String environment) async {
  registerDependencies();
  await diContainer.isReady<SharedPreferences>();

  // Init local storages
  final prefs = diContainer<SharedPreferences>();
  await DailyGoalsStorage.instance.init(prefs);

  return getIt.init(environment: environment);
}

@module
void registerDependencies() {
  // SharedPreferences
  diContainer.registerLazySingletonAsync<SharedPreferences>(() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  });
}
