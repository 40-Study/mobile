import 'package:study/data/theme_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class DIDataModule {
  @lazySingleton
  ThemeStorage get themeStorage =>
      SharedPreferencesThemeStorage(diContainer.get<SharedPreferences>());
}
