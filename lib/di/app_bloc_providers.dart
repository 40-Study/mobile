import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;
import 'package:study/bloc/init/init_bloc.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/repository/onboarding_repository.dart';
import 'package:study/repository/theme_repository.dart';

import 'di_container.dart';

abstract class AppBlocProviders {
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider(
        create: (context) =>
            ThemeCubit(diContainer.get<ThemeRepository>())..loadTheme(),
      ),
      BlocProvider<InitBloc>(
        create: (_) => InitBloc(diContainer.get<OnboardingRepository>())
          ..add(
            InitStarted(),
          ),
      ),
    ];
  }
}
