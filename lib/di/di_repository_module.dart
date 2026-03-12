import 'package:study/data/theme_storage.dart';
import 'package:study/repository/theme_repository.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RepositoryModule {
  @factoryMethod
  ThemeRepository provideThemeRepository(ThemeStorage themeStorage) =>
      ThemeRepositoryImpl(themeStorage);
}
