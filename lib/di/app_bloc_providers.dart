import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/init/init_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/theme/theme_cubit.dart';
import 'package:flutter_bloc_app_template/repository/theme_repository.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

import 'di_container.dart';

abstract class AppBlocProviders {
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider(
        create: (context) =>
            ThemeCubit(diContainer.get<ThemeRepository>())..loadTheme(),
      ),
      BlocProvider<InitBloc>(
        create: (_) => InitBloc()
          ..add(
            StartAppEvent(),
          ),
      ),
    ];
  }
}
